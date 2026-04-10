import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.cm as cm
import numpy as np
import argparse

from config import *

parser = argparse.ArgumentParser()
parser.add_argument('--results', type=str, default='results/sim1')
args = parser.parse_args()
result_dir = args.results

def load_simulation_data(filename):
    df = pd.read_csv(filename)
    particle_ids = df['id'].unique()
    total_steps = df['step'].max()
    
    return df, particle_ids, total_steps


def extract_trajectories(df, particle_ids):
    trajectories = {}
    
    for particle_id in particle_ids:
        particle_data = df[df['id'] == particle_id].sort_values('step')
        trajectories[particle_id] = {
            'x': particle_data['x'].values,
            'y': particle_data['y'].values,
            'z': particle_data['z'].values,
        }
    
    return trajectories

def setup_figure_and_axes(figsize=(12, 9)):
    fig = plt.figure(figsize=figsize)
    ax = fig.add_subplot(111, projection='3d')
    
    fig.patch.set_facecolor('#0a0a0a')
    ax.set_facecolor('#0a0a0a')
    text_color = 'white'
        
    for pane in [ax.xaxis.pane, ax.yaxis.pane, ax.zaxis.pane]:
        pane.fill = False
        pane.set_edgecolor('#404040')
        
    ax.xaxis.label.set_color(text_color)
    ax.yaxis.label.set_color(text_color)
    ax.zaxis.label.set_color(text_color)
    ax.tick_params(colors=text_color)
    
    ax.set_xlabel('X (m)', fontsize=10, fontweight='bold')
    ax.set_ylabel('Y (m)', fontsize=10, fontweight='bold')
    ax.set_zlabel('Z (m)', fontsize=10, fontweight='bold')
    
    return fig, ax


def setup_plot_objects(ax, particle_ids, trajectories):
    colors = cm.plasma(np.linspace(0.1, 0.9, len(particle_ids)))
    points = []
    trails = []
    
    for idx, particle_id in enumerate(particle_ids):
        color = colors[idx]
        
        point, = ax.plot([], [], [], 'o', color=color, markersize=7,
                        label=f'Particle {particle_id}', zorder=10)
        points.append(point)
        
        trail, = ax.plot([], [], [], '-', color=color, linewidth=0.8,
                        alpha=0.4, zorder=5)
        trails.append(trail)
    
    return points, trails, colors


def setup_axes_limits(ax, df):
    margin = 0.1 * max(
        (df['x'].max() - df['x'].min()),
        (df['y'].max() - df['y'].min()),
        (df['z'].max() - df['z'].min())
    )
    
    ax.set_xlim(df['x'].min() - margin, df['x'].max() + margin)
    ax.set_ylim(df['y'].min() - margin, df['y'].max() + margin)
    ax.set_zlim(df['z'].min() - margin, df['z'].max() + margin)

def create_animation(fig, ax, points, trails, particle_ids, trajectories, total_steps):
    def update_frame(frame):
        for idx, particle_id in enumerate(particle_ids):
            traj = trajectories[particle_id]
            
            points[idx].set_data([traj['x'][frame]], [traj['y'][frame]])
            points[idx].set_3d_properties([traj['z'][frame]])
            
            start_frame = max(0, frame - TRAIL_STEPS)
            trail_x = traj['x'][start_frame:frame+1]
            trail_y = traj['y'][start_frame:frame+1]
            trail_z = traj['z'][start_frame:frame+1]
            
            trails[idx].set_data(trail_x, trail_y)
            trails[idx].set_3d_properties(trail_z)
        
        return points + trails
    
    animation_obj = animation.FuncAnimation(
        fig, update_frame,
        frames=total_steps,
        interval=ANIMATION_INTERVAL,
        blit=False,
        repeat=True
    )
    
    return animation_obj

def visualize(data, title, type):
    df, particle_ids, total_steps = load_simulation_data(data)
    trajectories = extract_trajectories(df, particle_ids)
    
    fig, ax = setup_figure_and_axes()
    fig.canvas.manager.set_window_title(title)
    fig.suptitle(title, color='white', fontsize=14, fontweight='bold')
    setup_axes_limits(ax, df)
    points, trails, colors = setup_plot_objects(ax, particle_ids, trajectories)
    
    legend = ax.legend(loc='upper left', fontsize=9, framealpha=0.7,
                        facecolor='#1a1a1a',
                        labelcolor='white')
    
    animation_obj = create_animation(fig, ax, points, trails, particle_ids,
                                trajectories, total_steps)
    
    plt.tight_layout()
    
    plt.show()
    Writer = animation.FFMpegWriter(fps=30, bitrate=1800)
    animation_obj.save(f'{result_dir}/{type}.mp4', writer=Writer)