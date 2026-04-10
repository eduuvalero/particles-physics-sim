import numpy as np

HORIZON = 200
DATA    = 'data/particles.csv'
PREDICTIONS = 'data/predictions.csv'
MODEL   = 'data/model.pkl'
FEATURES = ['x', 'y', 'z', 
            'vx', 'vy', 'vz', 
            'ax', 'ay', 'az', 
            'speed', 'acc_mag', 'dist_origin']

def features(df):
    df = df.copy()
    df['speed']       = np.sqrt(df['vx']**2 + df['vy']**2 + df['vz']**2)
    df['acc_mag']     = np.sqrt(df['ax']**2 + df['ay']**2 + df['az']**2)
    df['dist_origin'] = np.sqrt(df['x']**2  + df['y']**2  + df['z']**2)
    return df