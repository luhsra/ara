#!/bin/bash

# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

kill $(ps aux | grep ara.py | grep -v grep | sed 's, \+, ,g' | cut -d ' ' -f 2)
