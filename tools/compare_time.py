#!/usr/bin/env python3
import argparse
import subprocess
import logging
from pprint import pprint
from collections import defaultdict
import re
import os

RED = ("\033[1;31m", "\033[1;0m")
BLUE = ("\033[1;34m", "\033[1;0m")
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('BUILD_DIR', help='directory containing the .ninja_log file')
    parser.add_argument('NAME', help='name of the app for filtering')
    parser.add_argument('-C', '--force-color', action='store_true',
                        help='force colorized changes')
    args = parser.parse_args()

    if not (args.force_color or os.isatty(1)):
        global RED, BLUE
        RED = ("","")
        BLUE = RED

    data = {}
    logfile = open(os.path.join(args.BUILD_DIR, '.ninja_log'))
    for logline in logfile:
        if logline.startswith('#'):
            continue
        if not args.NAME in logline:
            continue
        columns = logline.split()

        data[columns[3]] = {
            'star': int(columns[0]),
            'end ': int(columns[1]),
            'h   ': columns[2],
            'name': columns[3],
            'h2  ': columns[4],
            'duration': (int(columns[1]) - int(columns[0]))/1000,
            }

    for entry in sorted(data.values(), key=lambda x: x['duration']):
        print(f"{entry['duration']:10} {entry['name']}")
    return

if __name__ == '__main__':
    import sys
    main()
