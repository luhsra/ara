#!/usr/bin/env python3

import time
import sys
import serial

PI_SERIAL = sys.argv[1]
# PI_SERIAL = "/dev/ttyUSB5"
START_STR = "Starting benchmark:"
END_STR = "Done with Benchmark!"

# Sometimes serial does not work, retry in this case
for _ in range(5):
    lines = []
    reading = False
    try:
        print("Trying to read: ")
        with serial.Serial(PI_SERIAL, 115200) as ser:
            while len(lines) < 10:
                l = ser.readline().strip(b"\r\n").decode("UTF-8", "ignore")
                print(l)
                if l.startswith(START_STR):
                    reading = True
                if reading:
                    lines.append(l)
                if l.startswith(END_STR):
                    reading = False
                    break
    # if this error occures wait and retry
    except serial.SerialException as e:
        print("Serial Error, retrying")
        print(e)
        time.sleep(2)
    # if no exception it worked
    else:
        break

print(f"Read {len(lines)} lines from serial:")
for line in lines:
    print(line)