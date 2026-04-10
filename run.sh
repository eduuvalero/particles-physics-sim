#!/bin/bash

set -e

cd "$(dirname "$0")"

echo ""
echo "========================================="
echo " Particle Physics Simulator - Linux"
echo "========================================="
echo ""

if ! command -v g++ &> /dev/null; then
    echo "[ERROR] g++ not found. Install it with: sudo dnf install g++"
    exit 1
fi

echo "[1/5] Compiling..."
make
echo ""

echo "[2/5] Running simulator..."
if [ ! -f "data/particles.csv" ] || [ "data/dataset.csv" -nt "data/particles.csv" ] || [ "data/config.csv" -nt "data/particles.csv" ] || [ "src/simulator"    -nt "data/particles.csv" ]; then
    src/simulator
    echo "Simulator done"
else
    echo "Simulation up to date, skipping"
fi
echo ""

echo "[3/5] Training model..."
if [ ! -f "data/model.pkl" ] || [ "data/particles.csv" -nt "data/model.pkl" ]; then
    python model/train.py
    echo "Model trained"
else
    echo "Model up to date, skipping"
fi
echo ""

echo "[4/5] Running predictions..."
if [ ! -f "data/predictions.csv" ] || [ "data/model.pkl" -nt "data/predictions.csv" ]; then
    python model/predictions.py
    echo "Predictions done"
else
    echo "Predictions up to date, skipping"
fi
echo ""

echo "[5/5] Visualizing..."
DIR=$(python visualize/utils.py)
echo "Results dir: $DIR"
python visualizer/comparison-vis.py --results "$DIR" &
python visualizer/prediction.py --results "$DIR" &
python visualizer/simulation.py --results "$DIR" &
echo ""

echo "========================================="
echo " Process completed!"
echo "========================================="