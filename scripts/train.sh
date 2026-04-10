#!/bin/bash
set -e
cd "$(dirname "$0")/.."

echo ""
echo "========================================="
echo " Executing simulator and training model"
echo "========================================="
echo ""

if [ ! -f "data/dataset.csv" ]; then
    echo "[ERROR] data/dataset.csv not found"
    echo "Please create data/dataset.csv"
    exit 1
fi

if [ ! -f "simulator/simulator" ]; then
    echo "[ERROR] simulator/simulator not found"
    echo "Please build first using: make"
    exit 1
fi

echo "[1/3] Running simulator..."
simulator/simulator
echo "Simulator done"
echo ""

echo "[2/3] Training model..."
python model/train.py
echo "Model trained"
echo ""

echo "[3/3] Running predictions..."
python model/predictions.py
echo "Predictions done"
echo ""

echo "========================================="
echo " Process completed!"
echo "========================================="
