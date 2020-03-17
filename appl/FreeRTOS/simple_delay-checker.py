#!/usr/bin/env python3

import re
def check(emulator, elf, result):
    if result.returncode:
        exit(result.returncode)
    if not b'T' in result.stdout:
        raise RuntimeError("T missing")
    if not b't' in result.stdout:
        raise RuntimeError('t missing')
    if not re.search(b't+T+t+T', result.stdout):
        raise RuntimeError('Tasks nicht abwechselnd')

