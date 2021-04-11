""" This module builds the full POSIX OS Model.

    Just import the POSIX OS Model via "from ara.os.posix.posix import POSIX"
"""

from ara.graph import SyscallCategory
from ..os_base import OSBase
from .posix_utils import debug_log, logger, handle_soc
from .file import FileSyscalls
from .locale import LocaleSyscalls
from .process import SessionSyscalls, TerminalSyscalls, ProcessGroupSyscalls, ProcessSyscalls
from .signal import SignalSyscalls
from .thread import ThreadSyscalls
from .user import UserSyscalls, GroupSyscalls

class POSIX(OSBase, FileSyscalls, GroupSyscalls, LocaleSyscalls, 
                    ProcessSyscalls, ProcessGroupSyscalls, SessionSyscalls, 
                    SignalSyscalls, TerminalSyscalls, ThreadSyscalls, UserSyscalls):

    @staticmethod
    def get_special_steps():
        return []

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        state.scheduler_on = True  # The Scheduler is always on in POSIX.

    @staticmethod
    def interpret(graph, abb, state, categories=SyscallCategory.every):
        """interprets a detected syscall"""

        cfg = graph.cfg

        debug_log("in interpret")

        syscall = cfg.get_syscall_name(abb)
        debug_log('get syscall: %s', syscall)
        debug_log(f"Get syscall: {syscall}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall_function = getattr(POSIX, syscall)

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.every not in categories:
            sys_cat = syscall_function.categories
            if sys_cat | categories != sys_cat:
                # do not interpret this syscall
                state = state.copy()
                state.next_abbs = []
                add_normal_cfg(cfg, abb, state)
                return state

        return getattr(POSIX, syscall)(graph, abb, state)