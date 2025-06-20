#!/usr/bin/env python3

import serial

PI_SERIAL = "/dev/ttyFTDI_FT232R_USB_UART_A50285BI-00"
START_STR = "Starting benchmark:"
END_STR = "Done with Benchmark!"

lines = []
reading = False
with serial.Serial(PI_SERIAL, 115200) as ser:
    while len(lines) < 1000:
        l = ser.readline().strip(b"\r\n").decode("UTF-8", "ignore")
        if l.startswith(START_STR):
            reading = True
        if reading:
            lines.append(l)
        if l.startswith(END_STR):
            reading = False
            break
print(f"Read {len(lines)} lines from serial:")
for line in lines:
    print(line)