#!/usr/bin/env python3

import os
import sys
import subprocess
import runpy
import re

def main():
    emulator = sys.argv[1]
    name = sys.argv[2]
    elf = sys.argv[3]

    result = subprocess.run([emulator, elf],
                            timeout=20,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    try:
        checker = runpy.run_path(f"{name}-checker.py")
        checker['check'](emulator, elf, result)
    except RuntimeError as e:
        print("--- stdout of emulator ---")
        print(result.stdout.decode())
        print("\n\n--- stderr of emulator ---")
        print(result.stderr.decode())
        print(e)
        exit(1)
    except FileNotFoundError as e:
        print(e, '==> SKIP', file=sys.stderr)
        exit(77)

if __name__ == '__main__':
    main()
