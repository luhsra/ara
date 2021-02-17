#!/usr/bin/env python3

def check(emulator, elf, result):
    if b'done_sched_start' in result.stdout:
        return True
    if result.returncode:
        raise RuntimeError(f"emulator failed: {result.returncode}")
