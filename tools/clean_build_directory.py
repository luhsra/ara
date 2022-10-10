#!/usr/bin/env python3
"""Cleans an ARA build directory for test execution."""

import argparse
import subprocess
import sys

from pathlib import Path

# all builded files that matches this strings will be emptied
QUERIES = ["steps_pch",  # a really big precompiled header
           "so.p",  # all object files that are needed for a shared library
           "a.p",  # all object files that are needed for a static library
           ]


def main():
    parser = argparse.ArgumentParser(description=sys.modules[__name__].__doc__)
    parser.add_argument('DIRECTORY', help='Path of the build directory.')
    parser.add_argument('-d', '--dry-run', action='store_true', default=False,
                        help='Only print which files are emptied.')
    parser.add_argument('--empty-tool',
                        default=Path(__file__).parent / 'empty_file.py',
                        help='Path to empty_file.py')
    args = parser.parse_args()

    # get full pathes
    ninja = subprocess.run(["ninja", "-C", args.DIRECTORY,
                            "-t", "targets", "all"],
                           capture_output=True)

    to_empty = []

    for line in ninja.stdout.decode('UTF-8').split('\n'):
        if any([x in line for x in QUERIES]):
            rel_path = line.split(': ')[0]
            path = Path(args.DIRECTORY) / rel_path
            if path.exists():
                to_empty.append(path)

    if args.dry_run:
        for p in to_empty:
            print(p.resolve())
        sys.exit()

    subprocess.run([str(Path(args.empty_tool).resolve())] +
                   [str(x.resolve()) for x in to_empty])


if __name__ == '__main__':
    main()
