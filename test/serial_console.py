#!/usr/bin/env python3

import serial
import re

MAX_RUNS = 1
GOOD = re.compile(r"[a-z]+\[.*?\]=\d+")

lines = 0
run = 0
should_print = False
with serial.Serial("/dev/ttyUSB1", 115200, timeout=1) as ser:
    while lines <= 300 and run <= MAX_RUNS:
        line = ser.readline().strip(b"\r\n").decode("UTF-8", "ignore")
        print("RAW", line)
        if line.startswith("## Starting application at 0x"):
            print("NEWRUN")
            should_print = True
            run += 1
        if should_print:
            print(line)
        if line.startswith("machine mode: unhandlable trap 7"):
            break
        lines += 1