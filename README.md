# RAVI — Recognition Automated Via Infrared

**App:** https://danmartsarr.github.io/Sistema/

Microplastic identification from infrared (FTIR) spectra. Upload a spectrum
(CSV) and the system answers which polymer it is — **EVA, PA, PE, PP, PS or
cellulose** — with the confidence for each class and **which regions of the
spectrum drove the decision** (a saliency map over wavenumber).

## How it works

1. **Pre-processing** — the spectrum is interpolated onto a fixed grid of
   1,763 points (3998–600 cm⁻¹) and normalised with the training parameters
   (`scaler_params.json`, produced by `extract_scaler.py`).
2. **Classification** — a trained MLP (Keras, `MLP_best_model.h5`) returns the
   probability of each of the six polymers.
3. **Explanation** — the gradient of the output with respect to the input
   (saliency) highlights the absorption bands that most influenced the answer,
   so a specialist can check them against the material's chemistry.

## Layout

```
mlp_server.py        inference API (FastAPI): /predict, /predict_csv, spectra storage
extract_scaler.py    extracts the normalisation parameters used in training
MLP_best_model.h5    trained model
dataBases/           reference spectra
deepmicroplastic/    Flutter app (web and mobile), published on GitHub Pages
docs/                system documentation (PDF, Portuguese)
```

## Run the API

```bash
python3 -m venv .venv && .venv/bin/pip install tensorflow fastapi uvicorn pandas python-multipart
.venv/bin/python mlp_server.py
```

`POST /predict` takes `{"wavenumbers": [...], "intensities": [...]}`;
`POST /predict_csv` takes the file exported by the spectrometer.
