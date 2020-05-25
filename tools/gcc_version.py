#!/usr/bin/env python3
"""Extract the gcc version string from GCC."""

import argparse
import subprocess
import sys
import re

parser = argparse.ArgumentParser(description=sys.modules[__name__].__doc__)
parser.add_argument('gcc', help='GCC binary')
args = parser.parse_args()

# version = subprocess.run([args.gcc, "--version"], capture_output=True)
# output = version.stdout
output = subprocess.check_output([args.gcc, "--version"])
print(re.search('(\d\.\d\.\d)', output.split(b'\n')[0].decode('utf-8')).group(0))
