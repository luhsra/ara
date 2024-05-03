# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later

assert __name__ == 'ara.generator.coder.autosar'

from .arch_posix import PosixArch
from .arch_arm import ArmArch
from .arch_riscv import RiscVArch

from .os_autosar_generic import AUTOSARGenericOS
