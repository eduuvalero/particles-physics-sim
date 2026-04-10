# PARTICLE PHYSICS SIMULATOR

This project is a simple particle physics simulator that calculates the acceleration of each particle taking into account gravitational force, electrical force and elastic collisions with other particles. Once the simulation is complete, it trains a Random Forest Regressor machine learning model from scikit-learn and makes a prediction of the movement of the particles with the model. Finally, it shows and saves one animation with the simulation, another animation with the prediction, and an image comparing both movements.

- The simulation is made in C++, and it has a time complexity of $$O(m * n^2)$$, where ***m*** is the number of **steps** and ***n*** is the number of **particles**
- The machine learning model is trained and run in Python, using Pandas, Numpy and the Scikit-Learn library for it. 
- The visualization it's also made in Python using Numpy and MatplotLib.
---
This is an example of the output of the full program running it with the default values of`data\dataset.csv` and `data\config.csv`

<p align="center">
  <img src="https://github.com/user-attachments/assets/e987d90f-b0a5-4438-9a9a-c9b8215ba9b1" width="33%">
  <img src="https://github.com/user-attachments/assets/a1fbdfb7-21d9-4787-82b4-1e01bc6d1bab" width="33%">
  <img src="https://github.com/user-attachments/assets/a8adfcd5-8252-4363-94a7-062f8673e0d3" width="24%">
</p>

---
## Requirements

### System dependencies
- **C++17** or later
  - MacOS: `xcode-select --install`
  - Linux: `sudo apt install g++` | `sudo dnf install g++` | `pacman -Sy g++`
  - Windows: [MinGW](https://www.mingw-w64.org/)
   
- **Make**
  - MacOS: included with Xcode Command Line Tools
  - Linux: `sudo apt install make` | `sudo dnf install make` | `pacman -Sy make`
  - Windows: not necessary
   
- **Python 3** — [python.org](https://www.python.org/downloads/)
  
- **FFmpeg** — required for saving animations
  - MacOS: `brew install ffmpeg`
  - Linux: `sudo apt install ffmpeg` | `sudo dnf install ffmpeg` | `pacman -Sy ffmpeg`
  - Windows: [ffmpeg.org/download.html](https://ffmpeg.org/download.html)

### Python dependencies
`pip install -r requirements.txt`

---
## How to use the program
To use the program you will have to put some data in the `data\dataset.csv` and `data\config.csv` files. They contain some default values, but you may change them if you want to do add steps, change the time of each step, or add, substract or change the particles that will be simulated.

### Format of [`config.csv`](./data/config.csv)
- ***steps*** is the number of positions that the program will simulate. Must be greater than 0
- ***dt*** is the time of each movement in ***Seconds*** that will be used for the calculus. Must be greater than 0
  
| steps  | dt            |
|--------|---------------|
| (int)  | (long double) |

### Format of [`dataset.csv`](./data/dataset.csv)
It must contain at least one particle, but it can contain as many as you want
- ***x, y, z*** is the initial position of the particle on each axis in ***Metres***
- ***vx, vy, vz*** is the initial velocity of the particle on each axis in ***Metres/Second***
- ***mass*** is the mass of the particle in ***Kilograms***. Must be greater than 0
- ***charge*** is the charge of the particle in ***Coulombs***
- ***radius*** is the radius of the particle in ***Metres***. Must be greater than 0
  
| x             | y             | z             | vx            | vy            | vz            | mass           | charge        | radius         |
|---------------|---------------|---------------|---------------|---------------|---------------|----------------|---------------|----------------|
| (long double) | (long double) | (long double) | (long double) | (long double) | (long double) | (long double)  | (long double) | (long double)  |
---
## How to run the program

There are two ways of running the program

### Full pipeline

Runs everything in order — build, simulate, train, predict and visualize.
The pipeline is smart: it only recompiles if a source file has changed, only re-simulates if `dataset.csv` or `config.csv` has changed, and only retrains if the simulation output has changed. If nothing has changed, each step is skipped automatically.

```bash
# Linux / MacOS
./run.sh
```
```bash
# Windows
.\run.bat
```

### Individual scripts

Run each step separately from the `scripts/` folder when you only want to redo one single part of the pipeline.

> Compile the C++ simulator
```bash
# Linux / MacOS
make
```
```bash
# Windows
.\scripts\build.bat
```
> Run the simulator, train the model and generate predictions
```bash
# Linux / MacOS
./scripts/train.sh
```
```bash
# Windows
.\scripts\train.bat
```

> Open the visualizers
```bash
# Linux / MacOS
./scripts/visualize.sh
```
```bash
# Windows
.\scripts\visualize.bat
```
---
## Project Architecture

- C++: numerical simulation (high performance)
- Python: machine learning pipeline and visualization
- CSV files: interface between both systems

  particle-physics-simulator/
├── src/  
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
│   ├── train.sh   
│   ├── visualize.sh   
│   ├── build.bat  
│   ├── train.bat  
│   └── visualize.bat  
├── data/  
│   ├── config.csv  
│   ├── dataset.csv  
│   ├── particles.csv    
│   ├── predictions.csv    
│   └── model.pkl   
├── requirements.txt    
├── run.sh    
├── run.bat   
├── Makefile   
├── license   
└── README.md   
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
The ML pipeline takes the simulation output and trains a model to predict future particle positions. It consists of two stages: training and inference.

#### Feature function
Before training, three additional features are derived from the raw simulation data:
- **Speed** — scalar magnitude of the velocity vector
- **Acceleration magnitude** — scalar magnitude of the acceleration vector  
- **Distance to origin** — Euclidean distance from the coordinate origin

This gives the model 12 input features per particle per step: position (x, y, z), velocity (vx, vy, vz), acceleration (ax, ay, az) and the three derived features.

#### Training
Given the state of a particle at step t, the model learns to predict its position (x, y, z) at step t + H, where H is the prediction horizon. The dataset is built by sliding a window of size H over each particle's trajectory.

The model is a **Random Forest Regressor** — an ensemble of decision trees that captures non-linear relationships between the input features and the target position. Training uses 80% of the data, with the remaining 20% held out for evaluation.

| Metric | Value |
|--------|-------|
| R² train | 0.9995 |
| R² test  |0.9995 |
| Horizon  |200 |
> The high R² score is expected due to the deterministic nature of the system and the strong correlation between input features and target variables.

#### Inference
The trained model and feature scaler are saved to `data/model.pkl`. The inference script loads this file, runs predictions for each particle across the full trajectory, and writes the results to `data/predictions.csv`.

> #### Limitations of the ML model
> The current model is quite simple and it directly predicts future positions, which does not enforce physical constraints such as conservation of energy or momentum.
> As a result, predictions may diverge for long horizons despite high R² scores.

---

### Python Visualization

The visualization module compares the physics simulation with the machine learning model predictions. It uses Matplotlib to generate two animations and one static comparison plot.

> The goal is to provide a qualitative evaluation of how well the ML model reproduces the underlying physical system.

#### Simulation animation (ground truth)

This animation visualizes the evolution of the particle system generated by the C++ simulator. Each particle is displayed as a point in 3D space, evolving under gravitational and electrostatic forces computed at each simulation step.

#### Prediction animation (ML model)

This animation shows the trajectories predicted by the machine learning model using the same initial conditions and time horizon. The predicted positions are rendered using the same visual format as the simulation to ensure a direct comparison.

> Matplotlib is used for visualization due to its simplicity and ease of integration with the rest of the pipeline. However, it is not optimized for large-scale real-time rendering of particle systems. As the number of particles increases, especially in 3D animations, performance may degrade significantly due to the overhead of Python-level rendering and frame-by-frame updates. For this reason, Matplotlib is suitable for small to medium-scale simulations and prototype-level analysis, but it is not ideal for high-performance or real-time visualization of large particle systems.

#### Trajectory comparison

A static plot is generated where both trajectories are overlaid:

- Ground truth trajectories (simulation)
- Predicted trajectories (ML model)

This visualization highlights deviations between physical and learned dynamics.

This allows observation of:
- trajectory divergence
- stability over time
- accumulated prediction error

---
## Limitations
-  $$O(n^2)$$ scaling limits large simulations
- No relativistic or quantum effects
- Simple ML model that no enforce physical laws
- MatplotLib doing the animations

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
