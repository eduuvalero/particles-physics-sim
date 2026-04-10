import pandas as pd
import numpy as np
import pickle

from utils import *

df = pd.read_csv(DATA)
df = features(df)

with open(MODEL, 'rb') as f:
        saved = pickle.load(f)

model  = saved['model']
scaler = saved['scaler']

ids = df['id'].unique()
X, meta = [], []

for pid in ids:
        particle = df[df['id'] == pid].sort_values('step').reset_index(drop=True)

        for step in range(len(particle) - HORIZON):
                current = particle.iloc[step]

                X.append([current[col] for col in FEATURES])
                meta.append({'step': int(current['step']), 'id': int(pid)})

X = np.array(X, dtype=np.float64)
X = scaler.transform(X)         
Y_pred = model.predict(X)  

results = pd.DataFrame(meta)                     
results['x'] = Y_pred[:, 0]
results['y'] = Y_pred[:, 1]
results['z'] = Y_pred[:, 2]

results.to_csv(PREDICTIONS, index=False)
print("Saved to data/predictions.csv")