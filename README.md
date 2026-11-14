# RAVI — Recognition Automated Via Infrared

**App:** https://danmartsarr.github.io/Sistema/

Identificação de microplásticos a partir de espectros de infravermelho (FTIR).
O usuário envia um espectro (CSV) e o sistema responde qual polímero ele é —
**EVA, PA, PE, PP, PS ou celulose** — com a confiança de cada classe e **quais
faixas do espectro pesaram na decisão** (mapa de saliência sobre o número de onda).

Faz parte da pesquisa de doutorado sobre identificação de microplásticos com
aprendizado profundo e IA explicável.

## Como funciona

1. **Pré-processamento** — o espectro é interpolado para uma grade fixa de
   1.763 pontos (3998–600 cm⁻¹) e normalizado com os parâmetros do treino
   (`scaler_params.json`, gerado por `extract_scaler.py`).
2. **Classificação** — uma rede MLP treinada (Keras, `MLP_best_model.h5`)
   devolve a probabilidade de cada um dos seis polímeros.
3. **Explicação** — o gradiente da saída em relação à entrada (saliência)
   aponta as bandas de absorção que mais influenciaram a resposta, para o
   especialista conferir se batem com a química do material.

## Partes

```
mlp_server.py        API de inferência (FastAPI): /predict, /predict_csv, armazenamento de espectros
extract_scaler.py    extrai os parâmetros de normalização usados no treino
MLP_best_model.h5    modelo treinado
dataBases/           bases de espectros de referência
deepmicroplastic/    app Flutter (web e mobile), publicado no GitHub Pages
docs/                documentação do sistema (PDF)
```

## Rodar a API

```bash
python3 -m venv .venv && .venv/bin/pip install tensorflow fastapi uvicorn pandas python-multipart
.venv/bin/python mlp_server.py
```

`POST /predict` recebe `{"wavenumbers": [...], "intensities": [...]}`;
`POST /predict_csv` recebe o arquivo exportado pelo espectrômetro.
