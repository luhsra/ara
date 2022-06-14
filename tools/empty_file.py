#!/usr/bin/env python3
"""Empties a file without touching its timestamp."""

import argparse
import os
import sys


def main():
    parser = argparse.ArgumentParser(description=sys.modules[__name__].__doc__)
    parser.add_argument('FILE', nargs='+',
                        help='Files that should be emptied.')
    args = parser.parse_args()

    for file in args.FILE:
        stat = os.stat(file)
        with open(file, 'w'):
            pass
        os.utime(file, ns=(stat.st_atime_ns, stat.st_mtime_ns))


if __name__ == '__main__':
    main()
