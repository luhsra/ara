#!/bin/bash

# Pre-test setup
echo "Running setup"
cd ../../../../build/
ninja

# Running test
meson test --suite automotive_benchmark_pi

# Post-test actions
echo "Post Task"
ssh lab-pc00 "./power.py NET3 OFF"
echo "Done"