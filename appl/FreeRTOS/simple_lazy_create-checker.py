#!/usr/bin/env python3

import re
def check(emulator, elf, result):
    if result.returncode:
        raise RuntimeError(f"emulator failed: {result.returncode}")
    if not b'aaabbbccc' in result.stdout:
        raise RuntimeError("Wrong result, expected 'aaabbbccc'")
    t1_my_handle = None
    t1_handle = None
    t2_my_handle = None
    t2_handle = None
    for line in result.stdout.split(b'\n'):
        if b'{{EXIT_STATUS' in line:
            status = int(line[:-2].split(b':')[1].decode(), base=0)
            if status != 0:
                raise RuntimeError("wrong exit status")
        if b'handle' in line:
            handle = line.split(b':')[1].strip()
            if b'T1' in line:
                t1_handle = handle
            elif b'T2'in line:
                t2_handle = handle
            elif b't1 my' in line:
                t1_my_handle = handle
            elif b't2 my' in line:
                t2_my_handle = handle
            else:
                raise RuntimeError(f"unexpected handle: {line}")

    if not t1_my_handle or t1_my_handle != t1_handle:
        raise RuntimeError("t1 task handles not identical")
    if not t2_my_handle or t2_my_handle != t2_handle:
        raise RuntimeError("t2 task handles not identical")
