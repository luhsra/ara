#!/bin/bash

# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

echo $@
# qemu-system-stm32 -machine stm32-p103 -nographic -serial mon:stdio -kernel ${1}
qemu-system-stm32 -machine stm32-p103 -nographic -serial file:/dev/stdout -monitor none -kernel $@
