"""
Extract MinMaxScaler parameters from the synthetic training CSV.

Usage:
    python extract_scaler.py /path/to/DB_10cl_100sp.csv

Produces scaler_params.json next to this script, which mlp_server.py
uses for optimal preprocessing (matching the training pipeline exactly).
"""

import sys
import json
import os
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler

if len(sys.argv) < 2:
    print("Usage: python extract_scaler.py /path/to/DB_10cl_100sp.csv")
    sys.exit(1)

csv_path = sys.argv[1]
df = pd.read_csv(csv_path)

X_raw = df.drop(columns=["name", "interpretation"], errors="ignore")
print(f"Training data shape: {X_raw.shape}")
print(f"Wavenumber range: {float(X_raw.columns[0]):.0f} – {float(X_raw.columns[-1]):.0f} cm⁻¹")

scaler = MinMaxScaler()
scaler.fit(X_raw)

out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "scaler_params.json")
with open(out_path, "w") as f:
    json.dump({
        "min": scaler.data_min_.tolist(),
        "max": scaler.data_max_.tolist(),
        "n_features": int(X_raw.shape[1]),
    }, f)

print(f"Saved scaler parameters to {out_path}")
