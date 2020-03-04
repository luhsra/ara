#!/bin/bash
set -m
stty $((115200*8)) -F /dev/ttyACM0
cat /dev/ttyACM0 &
st-info --serial > /dev/null
fg
