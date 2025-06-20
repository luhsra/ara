#!/bin/bash

# Pre-test setup
echo "Running setup"
cd ../../../../build/
meson configure -Dara:autosar_benchmark=true && ninja

# Running test
meson test --suite automotive_benchmark_ara

# Post-test actions
echo "Done"