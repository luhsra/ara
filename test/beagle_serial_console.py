#!/usr/bin/env python3

import serial
import re

MAX_RUNS = 1
GOOD = re.compile(r"[a-z]+\[.*?\]=\d+")

lines = 0
#run = 0
should_print = False
with serial.Serial("/dev/ttyUSB0", 115200, timeout=1) as ser:
    while lines < 250 :
        line = ser.readline().strip(b"\r\n").decode("UTF-8", "ignore")
        print("RAW", line)
        if line.startswith("## Starting all cores at 0x80000000 ..."):
            print("NEWRUN")
            should_print = True
        if should_print:
            print(line)
        if line.startswith("Shutting down..."):
            break
        lines += 1