# Particle Physics Simulator

This project is a simple particle physics simulator that simulates the motion of charged particles in 3D space with a C++ engine, trains a Random Forest Regressor machine learning model from scikit-learn model in Python, and visualizes, stores and compare both simulated and predicted trajectories.

The pipeline includes:
- A **C++ simulator** with pairwise gravitational and electrostatic interactions plus elastic collisions
- A **Python ML stage** using scikit-learn (`RandomForestRegressor`) to predict future positions
- A **Python visualization stage** with Matplotlib animations and trajectory comparison plots

The simulation complexity is `O(m * n^2)`, where:
- `m` is the number of time steps
- `n` is the number of particles

---
This is an example of the output of the full program running it with the default values of`data\dataset.csv` and `data\config.csv`

<p align="center">
  <img src="https://github.com/user-attachments/assets/e987d90f-b0a5-4438-9a9a-c9b8215ba9b1" width="33%">
  <img src="https://github.com/user-attachments/assets/a1fbdfb7-21d9-4787-82b4-1e01bc6d1bab" width="33%">
  <img src="https://github.com/user-attachments/assets/a8adfcd5-8252-4363-94a7-062f8673e0d3" width="24%">
</p>

---
## Requirements

### System
- **C++17** compiler (e.g. `g++`)
- **Python 3.9+**
- **FFmpeg** (required to export MP4 animations)

### Python dependencies
Install with:

```bash
pip install -r requirements.txt
```

---
## Input Files

### [`config.csv`](./data/config.csv)
Contains global simulation settings:
- `steps` (int): number of simulation steps, must be `> 0`
- `dt` (float): time step in seconds, must be `> 0`
| steps | dt |
|---|---|
| int | long double |

### [`dataset.csv`](./data/dataset.csv)
Contains one row per particle with initial state:
- Position: `x, y, z` (meters)
- Velocity: `vx, vy, vz` (m/s)
- `mass` (kg, must be `> 0`)
- `charge` (C)
- `radius` (m, must be `> 0`)

| x | y | z | vx | vy | vz | mass | charge | radius |
|---|---|---|---|---|---|---|---|---|
| long double | long double | long double | long double | long double | long double | long double | long double | long double |

> The program needs one particle at least

---
## Run the project

There are two ways of running the program

### Full pipeline

Runs everything in order — build, simulate, train, predict and visualize.
The pipeline is smart: it only recompiles if a source file has changed, only re-simulates if `dataset.csv` or `config.csv` has changed, and only retrains if the simulation output has changed. If nothing has changed, each step is skipped automatically.

Linux / macOS

```bash
./run.sh
```

Windows

```bash
.\run.bat
```

### Individual stages

Run each step separately from the `scripts/` folder when you only want to redo one single part of the pipeline.

> Compile the C++ simulator
Linux / MacOS

```bash
make
```

Windows:

```bash
.\scripts\build.bat
```

> Run the simulator, train the model and generate predictions

Linux/macOS

```bash
./scripts/train.sh
```

Windows

```bat
.\scripts\train.bat
```

> Visualize the final result

Linux/macOS

```bash
./scripts/visualize.sh
```

Windows:

```bat
.\scripts\visualize.bat
```
---
## Project Architecture

- C++: numerical simulation (high performance)
- Python: machine learning pipeline and visualization
- CSV files: interface between both systems

```text
particle-physics/
├── simulator/
│   ├── main.cc
│   ├── Physics.cc
│   ├── Physics.h
│   ├── Particle.cc
│   └── Particle.h
├── model/
│   ├── train.py
│   ├── predictions.py
│   └── utils.py
├── visualize/
│   ├── visualizer.py
│   ├── comparison.py
│   ├── prediction.py
│   ├── simulation.py
│   ├── utils.py
│   └── config.py
├── scripts/
│   ├── build.bat
│   ├── train.sh
│   ├── train.bat
│   ├── visualize.sh
│   └── visualize.bat
├── data/
│   ├── config.csv
│   └── dataset.csv
├── requirements.txt
├── makefile
├── run.sh
├── run.bat
└── README.md
```

---
## How the program works

### C++ Simulator
The simulator models the dynamics of N charged particles in three-dimensional space under the influence of gravitational and electrostatic forces. The net force acting on each particle is computed as the superposition of the Newtonian gravitational attraction and the Coulomb electrostatic interaction.
> Particle initial conditions and simulation parameters are loaded from external CSV files, allowing the simulator to be configured without recompilation.

The equations of motion are integrated using the [Velocity Verlet algorithm](#velocity-verlet-integration), a second-order symplectic integrator.

At each time step, the simulator:
1. Updates particle positions using current velocities and accelerations
2. [Recomputes accelerations](#compute-acceleration) from the net force on each particle pair — O(n²) per step, as forces are evaluated for every unique pair of particles
3. Updates velocities using the average of the old and new accelerations
4. [Resolves elastic collisions](#elastic-collision) between overlapping particles

The time complexity per simulation step is $$O(n^2)$$, since all pairwise interactions are evaluated.

Over a full simulation of $$m$$ steps, the total time complexity is $$O(m \cdot n^2)$$, where ***m*** is the number of **steps** and ***n*** is the number of **particles**. This is acceptable for small to medium simulations; for large-scale simulations a spatial partitioning algorithm such as [Barnes-Hut](https://en.wikipedia.org/wiki/Barnes%E2%80%93Hut_simulation) could reduce the per-step complexity from  $$O(n^2)$$ to  $$O(n \cdot \log{n})$$

> The simulation outputs position, velocity and acceleration vectors for each particle at every time step to a CSV file that also contains the mass, charge and radius of each particle. This file is used as input for the ML pipeline.

---

### Python ML model

The model is trained on simulation output to predict future positions `(x, y, z)` at a fixed horizon `H`.

Features include:
- position (`x, y, z`)
- velocity (`vx, vy, vz`)
- acceleration (`ax, ay, az`)
- derived scalars (`speed`, `acc_mag`, `dist_origin`)

Feature vector at step `t`:

$$X_t = [x_t, y_t, z_t, vx_t, vy_t, vz_t, ax_t, ay_t, az_t, ||\vec{v}_t||, ||\vec{a}_t||, ||\vec{r}_t||]$$

Target vector:

$$Y_t = [x_{t+H}, y_{t+H}, z_{t+H}]$$

The dataset is built with a sliding window per particle trajectory. A `RandomForestRegressor` is trained after scaling inputs with `StandardScaler`.

The trained model is saved to `data/model.pkl`, and predictions are written to `data/predictions.csv`.

> #### Limitations of the ML model
> The current model is quite simple and it directly predicts future positions, which does not enforce physical constraints such as conservation of energy or momentum. As a result, predictions may diverge for long horizons despite high R² scores.

---

### Python Visualization

The visualization module compares the physics simulation with the machine learning model predictions. It uses Matplotlib to generate two animations and one static comparison plot.

> The goal is to provide a qualitative evaluation of how well the ML model reproduces the underlying physical system.

#### Simulation animation

This animation visualizes the evolution of the particle system generated by the C++ simulator. Each particle is displayed as a point in 3D space, evolving under gravitational and electrostatic forces computed at each simulation step.

#### Prediction animation (ML model)

This animation shows the trajectories predicted by the machine learning model using the same initial conditions and time horizon. The predicted positions are rendered using the same visual format as the simulation to ensure a direct comparison.

> Matplotlib is used for visualization due to its simplicity and ease of integration with the rest of the pipeline. However, it is not optimized for large-scale real-time rendering of particle systems. As the number of particles increases, especially in 3D animations, performance may degrade significantly due to the overhead of Python-level rendering and frame-by-frame updates. For this reason, Matplotlib is suitable for small to medium-scale simulations and prototype-level analysis, but it is not ideal for high-performance or real-time visualization of large particle systems.

#### Trajectory comparison

A static plot is generated where both trajectories are overlaid:

- Ground truth trajectories (simulation)
- Predicted trajectories (ML model)

This visualization highlights deviations between physical and learned dynamics.

Outputs are stored under a timestamped run directory in `results/`.

---
## Limitations
- Pairwise-force simulation scales as $$O(n^2)$$ per step, which limits large particle counts
- No relativistic or quantum effects are modeled
- The model predicts positions directly and does not enforce conservation laws
- Matplotlib visualization is very limited. It is suitable for analysis/prototyping, not real-time large-scale rendering

---
## Physical laws and methods of the simulation

### Compute acceleration
For each pair of particles ***(a)*** and ***(b)***:
<div align="center">

<strong><em>Relative position vector</em></strong>

$$\vec{r}_{ab} = \vec{r}_b - \vec{r}_a$$ 

<strong><em>Euclidean distance</em></strong>

$$|\vec{r}_{ab}| = \sqrt{(x_b-x_a)^2 + (y_b-y_a)^2 + (z_b-z_a)^2}$$

<strong><em>Unit vector (radial direction)</em></strong>

$$\hat{r}_{ab} = \frac{\vec{r}_{ab}}{|\vec{r}_{ab}|}$$

<strong><em>Newton's law of universal gravitation and Coulomb's law</em></strong>

$$\vec{F}_g = - G \frac{m_a m_b}{|\vec{r}_{ab}|^2} \hat{r}_{ab} \quad \quad \vec{F}_e = k_e \frac{q_a q_b}{|\vec{r}_{ab}|^2} \hat{r}_{ab}$$

<strong><em>Second and third Newton's laws</em></strong>

$$\vec{a}_{ab} = \frac{\vec{F}_g + \vec{F}_e}{m_a} \quad \quad \vec{a}_{ba} = -\frac{\vec{F}_g + \vec{F}_e}{m_b}$$

*[Return](#c-simulator)*
</div>

---

### Elastic Collision
For each pair of particles ***(a)*** and ***(b)***:

<div align="center">
<strong><em>Step 1: Project velocities along the collision normal</em></strong>

$$  v_{a,n} = \vec{v}_a \cdot \vec{n} \quad \quad  v_{b,n} = \vec{v}_b \cdot \vec{n}  $$

<strong><em> Step 2: Compute post-collision normal velocities (1D elastic collision)</em></strong>

$$  v_{a,n}' = \frac{v_{a,n}(m_a - m_b) + 2 m_b v_{b,n}}{m_a + m_b} \quad \quad  v_{b,n}' = \frac{v_{b,n}(m_b - m_a) + 2 m_a v_{a,n}}{m_a + m_b}  $$

<strong><em> Step 3: Update 3D velocities</em></strong>

$$  \vec{v}_a' = \vec{v}_a + (v_{a,n}' - v_{a,n}) \vec{n}, \quad \quad  \vec{v}_b' = \vec{v}_b + (v_{b,n}' - v_{b,n}) \vec{n}  $$

<strong><em> Step 4: Correct overlap along normal</em></strong>

$$\delta = \frac{r_a + r_b - |\vec{r}_b - \vec{r}_a|}{2}$$

$$  \vec{r}_a' = \vec{r}_a - \delta \vec{n} \quad \quad  \vec{r}_b' = \vec{r}_b + \delta \vec{n}  $$

*[Return](#c-simulator)*
</div>

---
### Velocity-Verlet Integration

<div align="center">
<strong><em>Step 1: Update positions</em></strong>

$$\vec{r}_i(t + \Delta t) = \vec{r}_i(t) + \vec{v}_i(t) \Delta t + \frac{1}{2} \vec{a}_i(t) \Delta t^2$$

<strong><em>Step 2: Compute new accelerations</em></strong>

$$\vec{a}_i(t + \Delta t) = \frac{\vec{F}_i(t + \Delta t)}{m_i}$$

<strong><em>Step 3: Update velocities</em></strong>

$$\vec{v}_i(t + \Delta t) = \vec{v}_i(t) + \frac{1}{2} \left[\vec{a}_i(t) + \vec{a}_i(t + \Delta t)\right] \Delta t$$

*[Return](#c-simulator)*
</div>