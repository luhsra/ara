#!/bin/bash

# Pre-test setup
echo "Running setup"
cd "../../../../build/"
ninja

# Running test
meson test --suite automotive_benchmark_pi

# Post-test actions
echo "Post Task"
ssh lab-pc00 "./power.py NET3 OFF"

# Parse into csv
cd "../subprojects/ara/test/mareike_benchmark/"
now=$(date +"%Y-%m-%dT%H:%M")
python3 pi_meson_parser.py ../../../../build/meson-logs/testlog.txt res-pi-$now.csv
echo "Now use \"python3 pi_plot.py res-pi-$now.csv\""

echo "Done"