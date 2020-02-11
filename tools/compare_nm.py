#!/usr/bin/env python3
import argparse
import subprocess
import logging
from pprint import pprint
from collections import defaultdict
import re

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('NM_TOOL', help='nm binary')
    parser.add_argument('NAME ELF', help='tuples to analyze, '
                        'e.g. special: special_version.elf',
                        nargs='+')
    args = parser.parse_args()

    inp = getattr(args, 'NAME ELF', [])
    if len(inp) % 2:
        parser.print_help()
    pairs = [(inp[i], inp[i+1]) for i in range(0,len(inp), 2)]

    common = {}
    data = {}
    keys = {}
    for pair in pairs:
        name, filename = pair
        data[name] = parse_elf(args.NM_TOOL, filename)
        keys[name] = set(data[name].keys())
        for symbol, obj in data[name].items():
            common[symbol] = obj


    common_keys = keys[name].intersection(*keys.values())
    unique_keys = keys[name].union(*keys.values()) - common_keys

    lens = {name: len(name) for name in data.keys()}

    fields = ['segment']
    fields += [f'{n:^{lens[n]}}' for n in data.keys()]
    fields += ['name']
    print(" | ".join(fields))


    for keyset in [unique_keys, common_keys]:
        for key in sorted(keyset):
            sizes = [data[n][key]['size'] for n in data.keys()]
            if len(set(sizes)) == 1:
                continue
            fields = [f"{common[key]['segment']:7}"]
            fields += [f"{data[n][key]['size']:{lens[n]}}" for n in data.keys()]
            fields += [f"{common[key]['name']}"]
            print(" | ".join(fields))
        print('\n')


def parse_elf(nm, elf):
    result = subprocess.run([nm, '-SP', elf],
                            check=True,
                            stdout=subprocess.PIPE)
    ret = defaultdict(lambda: defaultdict(lambda:''))
    for line in result.stdout.decode().strip().split('\n'):
        match = re.match("(?P<name>\S+) (?P<seg>\S) (?P<addr>\S+) (?P<size>\S*)",
                         line)
        if not match:
            logging.debug("failed line: %s", line)
            if ' N ' in line or line.startswith('N '):
                continue
            return
        name = match.group('name')
        ret[name] = {
            'segment': match.group('seg'),
            'size': int(match.group('size') or '0', 16),
            'addr': match.group('addr'),
            'name': name,
            }
    return ret


if __name__ == '__main__':
    import sys
    main()
