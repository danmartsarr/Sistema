"""
DeepMicroplastic MLP Inference Server

Run: /path/to/venv/python mlp_server.py

Endpoints:
  GET    /health
  POST   /predict                              — {wavenumbers, intensities}
  POST   /predict_csv                          — multipart CSV upload
  POST   /spectra/{institution_slug}/{dataset_id}
  GET    /spectra/{institution_slug}/{dataset_id}/{sample_id}
  DELETE /spectra/{institution_slug}/{dataset_id}/{sample_id}

Scaler: generate scaler_params.json with extract_scaler.py for best accuracy;
        falls back to per-sample normalization if missing.
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
SPECTRA_DIR = os.path.join(BASE_DIR, "spectra_data")
os.makedirs(SPECTRA_DIR, exist_ok=True)

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
    print("WARNING: scaler_params.json not found — falling back to per-sample normalization.")

# ── Constants ─────────────────────────────────────────────────────────────────
CLASS_NAMES = ["EVA", "PA", "PE", "PP", "PS", "cellulose_like"]

WAVENUMBERS = np.linspace(3998, 600, 1763, dtype=np.float32)
ATTN_STEP = max(1, len(WAVENUMBERS) // 200)
SPEC_STEP = max(1, len(WAVENUMBERS) // 500)


# ── Helpers ───────────────────────────────────────────────────────────────────

def _normalize(spectrum: np.ndarray) -> np.ndarray:
    """MinMaxScaler from training data, or per-sample fallback."""
    if scaler_min is not None and scaler_max is not None:
        scale = scaler_max - scaler_min
        scale[scale == 0] = 1.0
        out = (spectrum - scaler_min) / scale
    else:
        s_min, s_max = float(spectrum.min()), float(spectrum.max())
        out = (spectrum - s_min) / (s_max - s_min) if s_max > s_min else spectrum.copy()
    return np.clip(out, 0.0, None).astype(np.float32)


def _interpolate(wn: np.ndarray, inten: np.ndarray) -> np.ndarray:
    """Interpolate (wn, inten) onto the model grid (3998→600 cm⁻¹)."""
    order   = np.argsort(wn)
    wn_s    = wn[order]
    inten_s = inten[order]
    # np.interp requires ascending xp; WAVENUMBERS is descending, so reverse
    result = np.interp(
        WAVENUMBERS[::-1], wn_s, inten_s,
        left=float(inten_s[0]), right=float(inten_s[-1]),
    )[::-1].copy()
    return result.astype(np.float32)


def _infer(spectrum_norm: np.ndarray, spectrum_original: np.ndarray) -> dict:
    """Run inference and return prediction with saliency map."""
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

    attention_list = [
        {"wavenumber": float(WAVENUMBERS[i]), "attention": float(saliency[i])}
        for i in range(len(WAVENUMBERS))
    ]

    return {
        "polymer":       CLASS_NAMES[idx],
        "confidence":    float(probs_np[idx]),
        "wavenumbers":   WAVENUMBERS.tolist(),     
        "intensities":   spectrum_original.tolist(),
        "attention":     attention_list,
    }

def _extract_spectral_columns(df: pd.DataFrame) -> tuple[list[str], list[float]]:
    """Return (col_names, wavenumbers) for columns with numeric headers."""
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
    """Return the sample-name column if present, else None."""
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


class SpectrumStoreRequest(BaseModel):
    sample_id: str
    wavenumbers: list[float]
    intensities: list[float]


def _safe_segment(value: str, label: str) -> str:
    safe = "".join(c for c in value if c.isalnum() or c in "-_")
    if not safe:
        raise HTTPException(status_code=400, detail=f"Invalid {label}")
    return safe


def _spectra_csv_path(institution_slug: str, dataset_id: str) -> str:
    inst = _safe_segment(institution_slug, "institution_slug")
    ds = _safe_segment(dataset_id, "dataset_id")
    inst_dir = os.path.join(SPECTRA_DIR, inst)
    os.makedirs(inst_dir, exist_ok=True)
    return os.path.join(inst_dir, f"{ds}.csv")


# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    """Server status, class list, and scaler config."""
    return {
        "status":     "ok",
        "classes":    CLASS_NAMES,
        "n_features": int(len(WAVENUMBERS)),
        "scaler":     "training" if scaler_min is not None else "per_sample",
    }


@app.post("/predict")
def predict(req: PredictRequest):
    """Predict a single sample."""
    wn    = np.array(req.wavenumbers, dtype=np.float32)
    inten = np.array(req.intensities, dtype=np.float32)

    spectrum = _interpolate(wn, inten)
    norm = _normalize(spectrum)
    return _infer(norm, spectrum)


@app.post("/predict_csv")
async def predict_csv(file: UploadFile = File(...)):
    """Batch prediction from a CSV file (one sample per row, numeric headers = wavenumbers)."""
    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="File must be .csv")

    content = await file.read()
    try:
        df = pd.read_csv(io.StringIO(content.decode("utf-8")))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to read CSV: {e}")

    if df.empty:
        raise HTTPException(status_code=400, detail="Empty CSV")

    spectral_cols, wavenumbers = _extract_spectral_columns(df)
    if len(spectral_cols) < 10:
        raise HTTPException(
            status_code=400,
            detail=f"Only {len(spectral_cols)} numeric column(s) found. Check that wavenumbers are column headers.",
        )

    name_col   = _find_name_column(df)
    wn_arr     = np.array(wavenumbers, dtype=np.float32)
    results    = []

    for row_idx, row in df.iterrows():
        inten = row[spectral_cols].values.astype(np.float32)

        spectrum = _interpolate(wn_arr, inten)
        norm     = _normalize(spectrum)
        pred     = _infer(norm, spectrum)

        step = max(1, len(spectral_cols) // 500)
        spectral_data = [
            {"wavenumber": float(wn_arr[i]), "intensity": float(inten[i])}
            for i in range(0, len(spectral_cols), step)
        ]

        sample_name = str(row[name_col]) if name_col else f"Sample {int(row_idx) + 1}"

        results.append({
            "row":          int(row_idx),
            "sample_name":  sample_name,
            "spectral_data": spectral_data,
            **pred,
        })

    return {"n_samples": len(results), "results": results}


# ── Spectra storage ───────────────────────────────────────────────────────────

@app.post("/spectra/{institution_slug}/{dataset_id}")
def save_spectrum(institution_slug: str, dataset_id: str, req: SpectrumStoreRequest):
    """Upsert a spectrum into the dataset CSV."""
    if len(req.wavenumbers) != len(req.intensities):
        raise HTTPException(status_code=400, detail="wavenumbers and intensities must have the same length")

    path = _spectra_csv_path(institution_slug, dataset_id)
    new_row = pd.DataFrame(
        [[req.sample_id] + list(req.intensities)],
        columns=["sample_id"] + [str(w) for w in req.wavenumbers],
    )

    if os.path.exists(path):
        existing = pd.read_csv(path)
        existing = existing[existing["sample_id"].astype(str) != req.sample_id]
        if list(existing.columns) == list(new_row.columns):
            df = pd.concat([existing, new_row], ignore_index=True)
        else:
            # Header mismatch: re-interpolate onto existing wavenumber grid
            wn_existing = np.array([float(c) for c in existing.columns[1:]],
                                   dtype=np.float32)
            wn_new      = np.array(req.wavenumbers, dtype=np.float32)
            inten_new   = np.array(req.intensities, dtype=np.float32)
            order = np.argsort(wn_new)
            interp_inten = np.interp(
                wn_existing, wn_new[order], inten_new[order],
                left=float(inten_new[order][0]),
                right=float(inten_new[order][-1]),
            )
            aligned = pd.DataFrame(
                [[req.sample_id] + interp_inten.tolist()],
                columns=existing.columns,
            )
            df = pd.concat([existing, aligned], ignore_index=True)
    else:
        df = new_row

    df.to_csv(path, index=False)
    return {"status": "ok", "sample_id": req.sample_id, "rows": len(df)}


@app.get("/spectra/{institution_slug}/{dataset_id}/{sample_id}")
def load_spectrum(institution_slug: str, dataset_id: str, sample_id: str):
    """Return stored spectrum by sample ID."""
    path = _spectra_csv_path(institution_slug, dataset_id)
    if not os.path.exists(path):
        raise HTTPException(status_code=404, detail="No spectra saved for this dataset")

    df = pd.read_csv(path)
    match = df[df["sample_id"].astype(str) == sample_id]
    if match.empty:
        raise HTTPException(status_code=404, detail="sample_id not found")

    row = match.iloc[0]
    wavenumbers = [float(c) for c in df.columns[1:]]
    intensities = [float(v) for v in row.values[1:]]
    return {
        "sample_id":   sample_id,
        "wavenumbers": wavenumbers,
        "intensities": intensities,
    }


@app.delete("/spectra/{institution_slug}/{dataset_id}/{sample_id}")
def delete_spectrum(institution_slug: str, dataset_id: str, sample_id: str):
    """Delete a spectrum row from the dataset CSV. Returns removed=0 if not found."""
    path = _spectra_csv_path(institution_slug, dataset_id)
    if not os.path.exists(path):
        return {"status": "ok", "removed": 0}
    df = pd.read_csv(path)
    before = len(df)
    df = df[df["sample_id"].astype(str) != sample_id]
    removed = before - len(df)
    if df.empty:
        os.remove(path)
    else:
        df.to_csv(path, index=False)
    return {"status": "ok", "removed": removed}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
