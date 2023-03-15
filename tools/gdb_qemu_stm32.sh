#!/bin/bash

# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

file=`mktemp`
trap "rm -f -- $file" INT EXIT
echo "target remote :33754" > $file
#qemu_pid=$!
#trap "rm -f -- $file; kill $qemu_pid 2>/dev/null" INT EXIT
tmux new-session\
	 "qemu-system-stm32 -gdb tcp::33754 -machine stm32-p103 -nographic -serial file:/dev/stdout -monitor none -S -no-shutdown -kernel $@; read" ';'\
	 new-window \
	 "cat $file; gdb-multiarch -x $file ${1} ; read" ';'

