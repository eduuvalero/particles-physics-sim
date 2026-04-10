import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import pickle

from utils import *

def read_data():
    df = pd.read_csv(DATA)
    df = features(df)   
    ids = df['id'].unique()

    X, Y = [], []

    for pid in ids:
        particle = df[df['id'] == pid]

        for step in range(len(particle) - HORIZON):
            current = particle.iloc[step]
            future  = particle.iloc[step + HORIZON]

            X.append([current[col] for col in FEATURES])  
            Y.append([future['x'], future['y'], future['z']])

    X = np.array(X, dtype=np.float64)
    Y = np.array(Y, dtype=np.float64)

    return X,Y

def train_model(X, Y):
    X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2)

    scaler  = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test  = scaler.transform(X_test)

    model = RandomForestRegressor(n_estimators=100)
    model.fit(X_train, Y_train)

    print(f"R² train: {model.score(X_train, Y_train):.4f}")
    print(f"R² test:  {model.score(X_test,  Y_test):.4f}")
    print(f"Horizon:  {HORIZON}")

    return model, scaler


X,Y = read_data()

print("X shape:", X.shape)
print("Y shape:", Y.shape)
print(f"Dataset: {X.shape[0]} samples, {X.shape[1]} features → {Y.shape[1]} targets")

model, scaler = train_model(X, Y)
with open(MODEL, 'wb') as f:
    pickle.dump({'model': model, 'scaler': scaler}, f)

print("Model saved to data/model.pkl")