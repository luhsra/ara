#!/usr/bin/env python3

import re
def check(emulator, elf, result):
    if result.returncode:
        raise RuntimeError(f"emulator failed: {result.returncode}")
    if not b't' in result.stdout:
        raise RuntimeError("sender not working")
    if not b'TtTtTtUuUuUuVvVvVvWwWwWw' in result.stdout:
        raise RuntimeError("Higher prio receiver is not working")
    if not b'tttugugugvhvhvhwiwiwijjj' in result.stdout:
        raise RuntimeError('lower prio receiver is missing')
