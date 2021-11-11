#!/usr/bin/env python3

import sys
import subprocess
import runpy

def main():
    app_name = sys.argv[1]
    version = sys.argv[2]
    modified_app = sys.argv[3]
    generated_os_filename = sys.argv[4]
    elf = sys.argv[5]

    if elf == 'nop':
        sys.exit(77)

    try:
        checker = runpy.run_path(f"{app_name}-generator_validator.py")
        if checker.get("ALWAYS_GOOD", False):
            print("Always good")
            sys.exit(0)
        generated_os_file = open(generated_os_filename, 'r')
        generated_os = generated_os_file.read()
        try:
            checker_function = checker['check_'+version]
        except KeyError as err:
            print(err, 'no check function specified ==> SKIP', file=sys.stderr)
            sys.exit(77)
        checker_function(app_name, modified_app, generated_os, elf)
    except AssertionError as err:
        print(err, file=sys.stderr)
        print(generated_os)
        raise err
    except RuntimeError as err:
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
