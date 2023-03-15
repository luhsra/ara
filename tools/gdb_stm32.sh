#!/bin/bash

# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

tmux new-session \
st-util ';' \
new-window \
"gdb-multiarch ${1} -ex 'target extended-remote :4242' - ex 'source ../libs/platform/stm32/tools/.gdbinit'" ';'
pkill st-util
