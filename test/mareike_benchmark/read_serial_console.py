#!/usr/bin/env python3

import time
import serial

PI_SERIAL = "/dev/ttyFTDI_FT232R_USB_UART_A50285BI-00"
# PI_SERIAL = "/dev/ttyUSB5"
START_STR = "Starting benchmark:"
END_STR = "Done with Benchmark!"

# Sometimes serial does not work, retry in this case
for _ in range(5):
    lines = []
    reading = False
    try:
        with serial.Serial(PI_SERIAL, 115200) as ser:
            while len(lines) < 5000:
                l = ser.readline().strip(b"\r\n").decode("UTF-8", "ignore")
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
        time.sleep(5)
    # if no exception it worked
    else:
        break

print(f"Read {len(lines)} lines from serial:")
for line in lines:
    print(line)