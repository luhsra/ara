#!/usr/bin/env python3
"""Helper script to write ARGS into FILE."""

import sys
import os

if len(sys.argv) < 2:
    print("Usage: {} FILE MODE [ARGS]".format(sys.argv[0]))
    print("Write ARGS into FILE with MODE.")
    sys.exit(1)

FILE_PATH = sys.argv[1]
MODE = int(sys.argv[2], 0)
ARGS = sys.argv[3:]

with open(FILE_PATH, 'w') as f:
    f.write(' '.join(ARGS))

os.chmod(FILE_PATH, MODE)
