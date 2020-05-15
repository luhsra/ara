#!/usr/bin/env python3

def check(emulator, elf, result):
    if result.returncode:
        raise RuntimeError(f"emulator failed: {result.returncode}")
    if not b'{{EXIT_STATUS:' in result.stdout:
        raise RuntimeError('no exitstatus in result')
