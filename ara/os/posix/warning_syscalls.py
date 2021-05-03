""" This module contains syscall implementations that only throw a warning.
"""

from ara.graph import SyscallCategory
from ..os_util import syscall
from .posix_utils import no_double_warning

class WarningSyscalls:

    @syscall(categories={SyscallCategory.create})
    def setjmp(graph, abb, state, args, va):
        no_double_warning("Detected setjmp/longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def longjmp(graph, abb, state, args, va):
        no_double_warning("Detected setjmp/longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def _setjmp(graph, abb, state, args, va):
        no_double_warning("Detected _setjmp/_longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def _longjmp(graph, abb, state, args, va):
        no_double_warning("Detected _setjmp/_longjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def sigsetjmp(graph, abb, state, args, va):
        no_double_warning("Detected sigsetjmp/siglongjmp !")
        return state

    @syscall(categories={SyscallCategory.create})
    def siglongjmp(graph, abb, state, args, va):
        no_double_warning("Detected sigsetjmp/siglongjmp !")
        return state