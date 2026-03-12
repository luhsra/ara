#!/bin/bash

# Pre-test setup
echo "Running setup"
cd ../../../../build/
meson configure -Dara:autosar_benchmark=true && ninja

# Running test
meson test --suite automotive_benchmark_ara_riscv

# Post-test actions
# Parse into csv
cd "../subprojects/ara/test/mareike_benchmark/"
now=$(date +"%Y-%m-%dT%H:%M")
python3 ara_meson_parser.py ../../../../build/meson-logs/testlog.txt res-ara-riscv-$now.csv
echo "Now use \"python3 ara_plot.py res-ara-riscv-$now.csv\""

echo "Done"