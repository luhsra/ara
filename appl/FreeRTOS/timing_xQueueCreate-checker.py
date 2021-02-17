#!/usr/bin/env python3

import re
def check(emulator, elf, result):
    if result.returncode:
        raise RuntimeError(f"emulator failed: {result.returncode}")
