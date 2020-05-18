#!/usr/bin/env python3
"""Extract the gcc version string from GCC."""

import argparse
import subprocess
import sys

parser = argparse.ArgumentParser(description=sys.modules[__name__].__doc__)
parser.add_argument('gcc', help='GCC binary')
args = parser.parse_args()

version = subprocess.run([args.gcc, "--version"], capture_output=True)
print(version.stdout.split(b'\n')[0].split(b' ')[-1].decode('utf-8'))

