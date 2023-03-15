#!/usr/bin/env python3.6

# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from init_test import init_test


def main():
    """Test for correct creation of the LLVM module from multiple IR files."""
    init_test(['IRReader'])


if __name__ == '__main__':
    main()
