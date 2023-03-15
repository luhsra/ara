#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2019 Benedikt Steinmeier
# SPDX-FileCopyrightText: 2019 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# vim: set et ts=4 sw=4:
"""Automatic Real-time System Analyzer"""

import sys
import ara.ara as _ara

if __name__ == '__main__':
    sys.exit(_ara.main())
