#!/bin/bash

# Pre-test setup
echo "Running setup"
cd ../../../../build/
meson configure -Dara:autosar_benchmark=true && ninja

# Running test
meson test --suite automotive_benchmark_ara

# Post-test actions
# Parse into csv
cd "../subprojects/ara/test/mareike_benchmark/"
now=$(date +"%Y-%m-%dT%H:%M")
python3 ara_meson_parser.py ../../../../build/meson-logs/testlog.txt res-ara-$now.csv
echo "Now use \"python3 ara_plot.py res-ara-$now.csv\""

echo "Done"