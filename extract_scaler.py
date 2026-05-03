"""
Extract MinMaxScaler parameters EXACTLY as they were fitted during training.

Usage:
    python extract_scaler.py /path/to/TDB.csv
"""

import sys
import json
import os
import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder, MinMaxScaler
from sklearn.model_selection import train_test_split

if len(sys.argv) < 2:
    print("Usage: python extract_scaler.py /path/to/TDB.csv")
    sys.exit(1)

csv_path = sys.argv[1]
df = pd.read_csv(csv_path)

# 1. Limpeza de Classes (exatamente como no Colab)[cite: 2]
df['Interpretation'] = df['Interpretation'].astype(str).str.strip()
label_map = {
    'PE':'PE', 'PE_like':'PE', 'PEfouling':'PE',
    'PP':'PP', 'PP_like':'PP',
    'PS':'PS', 'EVA':'EVA', 'PA':'PA',
    'cellulose_like':'cellulose_like',
}
df = df[df['Interpretation'].isin(label_map)].copy()
df['label'] = df['Interpretation'].map(label_map)

# 2. Separação de X e Y (ignorando as colunas corretas)[cite: 2]
y = LabelEncoder().fit_transform(df['label'])
X_raw = df.drop(columns=['Sample','Interpretation','label'], errors='ignore')

print(f"Full real dataset shape: {X_raw.shape}")

# 3. Recriação EXATA do Split de Treino (usando a mesma SEED)[cite: 2]
SEED = 42
idx = np.arange(len(y))
idx_trval, idx_test = train_test_split(idx, test_size=0.15, stratify=y, random_state=SEED)
idx_train, idx_val  = train_test_split(idx_trval, test_size=0.1765, stratify=y[idx_trval], random_state=SEED)

# 4. Ajuste do Scaler APENAS nos dados de treino[cite: 2]
scaler = MinMaxScaler()
scaler.fit(X_raw.iloc[idx_train])

# 5. Exportação do JSON
out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "scaler_params.json")
with open(out_path, "w") as f:
    json.dump({
        "min": scaler.data_min_.tolist(),
        "max": scaler.data_max_.tolist(),
        "n_features": int(X_raw.shape[1]),
    }, f)

print(f"Training split shape used for scaling: {X_raw.iloc[idx_train].shape}")
print(f"Saved PERFECT scaler parameters to {out_path}")