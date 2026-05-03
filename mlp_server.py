"""
DeepMicroplastic MLP Inference Server

Run with:
    /path/to/venv/python mlp_server.py

Endpoints:
  GET  /health          — status + class list
  POST /predict         — JSON body: {wavenumbers: [...], intensities: [...]}
  POST /predict_csv     — multipart file upload: CSV onde cada linha = uma amostra
                          Colunas com cabeçalho numérico (float) = números de onda.
                          Colunas categóricas (name, sample, interpretation, etc.)
                          são detectadas e removidas automaticamente.

Preprocessing:
  O modelo foi treinado com MinMaxScaler ajustado nos dados sintéticos.
  Para precisão ótima, gere scaler_params.json com extract_scaler.py.
  Sem ele, normalização per-amostra é usada como fallback.
"""

import io
import os
import json
import numpy as np
import pandas as pd
import tensorflow as tf
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR    = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH  = os.path.join(BASE_DIR, "MLP_best_model.h5")
SCALER_PATH = os.path.join(BASE_DIR, "scaler_params.json")

# ── Model ─────────────────────────────────────────────────────────────────────
print(f"Loading model from {MODEL_PATH} ...")
model = tf.keras.models.load_model(MODEL_PATH)
print("Model loaded.")

# ── Scaler ────────────────────────────────────────────────────────────────────
scaler_min: np.ndarray | None = None
scaler_max: np.ndarray | None = None

if os.path.exists(SCALER_PATH):
    with open(SCALER_PATH) as f:
        params = json.load(f)
    scaler_min = np.array(params["min"], dtype=np.float32)
    scaler_max = np.array(params["max"], dtype=np.float32)
    print(f"Scaler loaded from {SCALER_PATH}.")
else:
    print("WARNING: scaler_params.json not found — usando normalização per-amostra.")

# ── Constants ─────────────────────────────────────────────────────────────────
CLASS_NAMES = ["EVA", "PA", "PE", "PP", "PS", "cellulose_like"]

# Grade de números de onda: 1763 pontos de 3998 a 600 cm⁻¹
WAVENUMBERS = np.linspace(3998, 600, 1763, dtype=np.float32)

# Downsampling da atenção (~200 pontos)
ATTN_STEP = max(1, len(WAVENUMBERS) // 200)

# Downsampling do espectro para visualização (~500 pontos)
SPEC_STEP = max(1, len(WAVENUMBERS) // 500)


# ── Helpers ───────────────────────────────────────────────────────────────────

def _normalize(spectrum: np.ndarray) -> np.ndarray:
    """Aplica MinMaxScaler de treino (se disponível) ou normalização per-amostra."""
    if scaler_min is not None and scaler_max is not None:
        scale = scaler_max - scaler_min
        scale[scale == 0] = 1.0
        out = (spectrum - scaler_min) / scale
    else:
        s_min, s_max = float(spectrum.min()), float(spectrum.max())
        out = (spectrum - s_min) / (s_max - s_min) if s_max > s_min else spectrum.copy()
    return np.clip(out, 0.0, None).astype(np.float32)


def _interpolate(wn: np.ndarray, inten: np.ndarray) -> np.ndarray:
    """Interpola (wn, inten) para a grade do modelo (WAVENUMBERS, 3998→600)."""
    order   = np.argsort(wn)
    wn_s    = wn[order]
    inten_s = inten[order]
    # np.interp precisa de xp crescente; WAVENUMBERS é decrescente, então usamos reverso
    result = np.interp(
        WAVENUMBERS[::-1], wn_s, inten_s,
        left=float(inten_s[0]), right=float(inten_s[-1]),
    )[::-1].copy()
    return result.astype(np.float32)


def _infer(spectrum_norm: np.ndarray) -> dict:
    """
    Roda o modelo e computa o mapa de saliência (gradiente × entrada).
    Retorna polymer, confidence, probabilities e attention (downsampled).
    """
    x = tf.Variable(spectrum_norm.reshape(1, -1), dtype=tf.float32)
    with tf.GradientTape() as tape:
        probs = model(x, training=False)
        idx   = int(tf.argmax(probs[0]).numpy())
        score = probs[0, idx]

    grad     = tape.gradient(score, x).numpy()[0]
    saliency = np.abs(grad * spectrum_norm)
    s_max_   = saliency.max()
    if s_max_ > 0:
        saliency /= s_max_

    probs_np = probs.numpy()[0]
    attn = [
        {"wavenumber": float(WAVENUMBERS[i]), "attention": float(saliency[i])}
        for i in range(0, len(WAVENUMBERS), ATTN_STEP)
    ]

    return {
        "polymer":       CLASS_NAMES[idx],
        "confidence":    float(probs_np[idx]),
        "probabilities": {cls: float(p) for cls, p in zip(CLASS_NAMES, probs_np)},
        "attention":     attn,
    }


def _extract_spectral_columns(df: pd.DataFrame) -> tuple[list[str], list[float]]:
    """
    Detecta as colunas espectrais: aquelas cujo cabeçalho pode ser convertido
    para float (i.e., são números de onda). Retorna (col_names, wavenumbers).
    Colunas categóricas (name, sample, interpretation, etc.) são ignoradas.
    """
    spectral_cols = []
    wavenumbers   = []
    for col in df.columns:
        try:
            wn = float(col)
            spectral_cols.append(col)
            wavenumbers.append(wn)
        except (ValueError, TypeError):
            continue
    return spectral_cols, wavenumbers


def _find_name_column(df: pd.DataFrame) -> str | None:
    """Procura coluna de nome da amostra por convenção de nome."""
    candidates = ["name", "sample", "id", "amostra", "sample_id", "specimen"]
    for col in df.columns:
        if col.strip().lower() in candidates:
            return col
    return None


# ── App ───────────────────────────────────────────────────────────────────────
app = FastAPI(title="DeepMicroplastic MLP API", version="1.1")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


class PredictRequest(BaseModel):
    wavenumbers: list[float]
    intensities: list[float]


# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {
        "status":     "ok",
        "classes":    CLASS_NAMES,
        "n_features": int(len(WAVENUMBERS)),
        "scaler":     "training" if scaler_min is not None else "per_sample",
    }


@app.post("/predict")
def predict(req: PredictRequest):
    """Predição para uma única amostra via JSON."""
    wn    = np.array(req.wavenumbers, dtype=np.float32)
    inten = np.array(req.intensities, dtype=np.float32)

    spectrum = _interpolate(wn, inten)
    spectrum = _normalize(spectrum)
    return _infer(spectrum)


@app.post("/predict_csv")
async def predict_csv(file: UploadFile = File(...)):
    """
    Predição em lote a partir de um arquivo CSV.

    Formato esperado:
      - Cada linha = uma amostra
      - Colunas com cabeçalho numérico (ex.: '600.0', '3998.0') = intensidades
      - Colunas categóricas (name, sample, interpretation, etc.) são removidas
        automaticamente — não é necessário pré-processar o CSV antes de enviar

    Retorna lista de resultados, um por linha do CSV.
    """
    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="Arquivo deve ser .csv")

    content = await file.read()
    try:
        df = pd.read_csv(io.StringIO(content.decode("utf-8")))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Erro ao ler CSV: {e}")

    if df.empty:
        raise HTTPException(status_code=400, detail="CSV vazio")

    spectral_cols, wavenumbers = _extract_spectral_columns(df)
    if len(spectral_cols) < 10:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Apenas {len(spectral_cols)} coluna(s) com cabeçalho numérico "
                "encontrada(s). Verifique se o CSV tem os números de onda como "
                "cabeçalho de coluna."
            ),
        )

    name_col   = _find_name_column(df)
    wn_arr     = np.array(wavenumbers, dtype=np.float32)
    results    = []

    for row_idx, row in df.iterrows():
        inten = row[spectral_cols].values.astype(np.float32)

        # Espectro interpolado para grade do modelo
        spectrum = _interpolate(wn_arr, inten)
        norm     = _normalize(spectrum)
        pred     = _infer(norm)

        # Dados espectrais originais (downsampled para o gráfico)
        step = max(1, len(spectral_cols) // 500)
        spectral_data = [
            {"wavenumber": float(wn_arr[i]), "intensity": float(inten[i])}
            for i in range(0, len(spectral_cols), step)
        ]

        sample_name = (
            str(row[name_col]) if name_col else f"Amostra {int(row_idx) + 1}"
        )

        results.append({
            "row":          int(row_idx),
            "sample_name":  sample_name,
            "spectral_data": spectral_data,
            **pred,
        })

    return {"n_samples": len(results), "results": results}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
