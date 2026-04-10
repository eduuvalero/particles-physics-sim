#!/bin/bash
set -e
cd "$(dirname "$0")/.."

echo ""
echo "========================================="
echo " Running Particle Physics Visualizer"
echo "========================================="
echo ""

if [ ! -f "data/particles.csv" ]; then
    echo "[ERROR] data/particles.csv not found"
    echo "Please train first using: scripts/train.sh"
    exit 1
fi

if [ ! -f "data/predictions.csv" ]; then
    echo "[ERROR] data/predictions.csv not found"
    echo "Please train first using: scripts/train.sh"
    exit 1
fi

DIR=$(python visualize/utils.py)
echo "Results dir: $DIR"
python visualize/comparison.py --results "$DIR" &
python visualize/prediction.py --results "$DIR" &
python visualize/simulation.py --results "$DIR" &

echo ""
echo "========================================="
echo " Process completed!"
echo "========================================="
