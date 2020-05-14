#!/usr/bin/env python3

import re
def check(emulator, elf, result):
    if result.returncode:
        raise RuntimeError(f"emulator failed: {result.returncode}")
    if not b'T' in result.stdout:
        raise RuntimeError("T missing")
    if not b't' in result.stdout:
        raise RuntimeError('t missing')
    if not re.search(b't+T+t+T', result.stdout):
        raise RuntimeError('Tasks nicht abwechselnd')

    my_handle = None
    T1_handle = None
    for line in result.stdout.split(b'\n'):
        if b'my_handle' in line:
            my_handle = line.split(b':')[1].strip()
        elif b'T1 handle' in line:
            T1_handle = line.split(b':')[1].strip()

    if not my_handle or my_handle != T1_handle:
        raise RuntimeError("task handles not identical")
