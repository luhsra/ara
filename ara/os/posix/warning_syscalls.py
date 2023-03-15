# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""This module contains syscall implementations that only throw a warning."""

from ara.graph import SyscallCategory
from ..os_util import syscall
from .posix_utils import no_double_warning

class WarningSyscalls:
    """Implement a warning for problematic syscalls."""

    @syscall(categories={SyscallCategory.create})
    def setjmp(graph, state, cpu_id, args, va):
        no_double_warning("Detected setjmp/longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def longjmp(graph, state, cpu_id, args, va):
        no_double_warning("Detected setjmp/longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def _setjmp(graph, state, cpu_id, args, va):
        no_double_warning("Detected _setjmp/_longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def _longjmp(graph, state, cpu_id, args, va):
        no_double_warning("Detected _setjmp/_longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def sigsetjmp(graph, state, cpu_id, args, va):
        no_double_warning("Detected sigsetjmp/siglongjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def siglongjmp(graph, state, cpu_id, args, va):
        no_double_warning("Detected sigsetjmp/siglongjmp !")
        return state