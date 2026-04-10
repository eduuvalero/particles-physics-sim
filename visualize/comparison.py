import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import argparse

from config import DATA, PREDICTIONS

parser = argparse.ArgumentParser()
parser.add_argument('--results', type=str, default='results/sim1')
args = parser.parse_args()
result_dir = args.results

df      = pd.read_csv(DATA)
df_pred = pd.read_csv(PREDICTIONS)
ids     = df['id'].unique()
colors  = cm.plasma(np.linspace(0.1, 0.9, len(ids)))

fig = plt.figure(figsize=(12, 9))
ax  = fig.add_subplot(111, projection='3d')
fig.patch.set_facecolor('#0a0a0a')
ax.set_facecolor('#0a0a0a')

for pane in [ax.xaxis.pane, ax.yaxis.pane, ax.zaxis.pane]:
    pane.fill = False
    pane.set_edgecolor('#404040')
ax.tick_params(colors='white')
ax.set_xlabel('X (m)', color='white')
ax.set_ylabel('Y (m)', color='white')
ax.set_zlabel('Z (m)', color='white')

for idx, pid in enumerate(ids):
    c = colors[idx]

    real = df[df['id'] == pid].sort_values('step')
    ax.plot(real['x'], real['y'], real['z'],
            '-', color=c, lw=0.8, alpha=0.5, label=f'Particle {pid} real')

    pred = df_pred[df_pred['id'] == pid].sort_values('step')
    ax.plot(pred['x'], pred['y'], pred['z'],
            '--', color=c, lw=0.8, alpha=1, label=f'Particle {pid} predicted')

margin = 0.5
ax.set_xlim(df['x'].min() - margin, df['x'].max() + margin)
ax.set_ylim(df['y'].min() - margin, df['y'].max() + margin)
ax.set_zlim(df['z'].min() - margin, df['z'].max() + margin)
ax.legend(facecolor='#1a1a1a', labelcolor='white', framealpha=0.6)
fig.canvas.manager.set_window_title("Simulation vs Model Prediction Comparison")
fig.suptitle("Simulation vs Model Prediction Comparison", color='white', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig(f'{result_dir}/comparison.png', dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
print(f"Saved to {result_dir}/comparison.png")
plt.show()
