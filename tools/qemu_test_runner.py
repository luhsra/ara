#!/usr/bin/env python3

import sys
import subprocess
import runpy

def main():
    emulator = sys.argv[1]
    name = sys.argv[2]
    elf = sys.argv[3]

    if elf == 'nop':
        sys.exit(77)

    try:
        checker = runpy.run_path(f"{name}-checker.py")
        if checker.get("ALWAYS_GOOD", False):
            print("Always good")
            sys.exit(0)
        result = subprocess.run([emulator, elf],
#                                timeout=20,
                                check=False,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        checker['check'](emulator, elf, result)
    except RuntimeError as err:
        print("--- stdout of emulator ---", file=sys.stderr)
        print(result.stdout.decode(), file=sys.stderr)
        print("\n\n--- stderr of emulator ---", file=sys.stderr)
        print(result.stderr.decode(), file=sys.stderr)
        print(err, file=sys.stderr)
        sys.exit(1)
    except subprocess.TimeoutExpired as err:
        print(err, '==> TIMEOUT', file=sys.stderr)
        sys.exit(4)
    except FileNotFoundError as err:
        print(err, '==> SKIP', file=sys.stderr)
        sys.exit(77)

if __name__ == '__main__':
    main()
