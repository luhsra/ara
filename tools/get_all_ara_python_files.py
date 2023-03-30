#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

import os

EXCLUDE_DIRS = {'common',
                os.path.join('steps', 'native'),
                os.path.join('graph', 'cgraph')}

def add_dir(ara_dir, subdir) -> str:
    if subdir in EXCLUDE_DIRS:
        return ""
    ret: str = ""
    system_dir = os.path.join(ara_dir, subdir) if subdir != None else ara_dir
    with os.scandir(system_dir) as it:
        for file in it:
            path_in_subdir = os.path.join(subdir, file.name) if subdir != None else file.name
            if file.is_file():
                if file.name != 'meson.build':
                    ret += f" {os.path.join(ara_dir, path_in_subdir)}:{os.path.join('ara', subdir) if subdir != None else 'ara'}"
            elif file.is_dir():
                if file.name != '__pycache__':
                    ret += add_dir(ara_dir, path_in_subdir)
    return ret

def main():
    ara_dir = os.path.join(os.environ['MESON_SOURCE_ROOT'], os.environ['MESON_SUBDIR'])
    print(add_dir(ara_dir, None)[1:])

if __name__ == '__main__':
    main()
