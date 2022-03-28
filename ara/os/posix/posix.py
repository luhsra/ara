"""This module builds the full POSIX OS Model.

Just import the POSIX OS Model via "from ara.os.posix.posix import POSIX"
"""

from ara.graph import SyscallCategory, CallPath
from ara.graph.graph import Graph
from ..os_base import OSBase, CPUList, CPU, OSState, ExecState
from ..os_util import SysCall, set_next_abb, syscall
from .posix_utils import PosixOptions, get_running_thread, logger, get_musl_weak_alias, CurrentSyscallCategories
from .file import FileSyscalls
from .file_descriptor import FileDescriptorSyscalls
from .pipe import PipeSyscalls
from .mutex import MutexSyscalls
from .semaphore import SemaphoreSyscalls
from .condition_variable import CondSyscalls
from .signal import SignalCatchingFunc, SignalSyscalls
from .thread import ThreadSyscalls
from .other_syscalls import OtherSyscalls
from .warning_syscalls import WarningSyscalls
from .syscall_set import syscall_set
from .syscall_stub_aliases import SyscallStubAliases
from .native_musl_syscalls import MuslSyscalls, is_musl_syscall_wrapper, get_musl_syscall

'''
    --- General information ---

    The musl libc uses weak aliases for some syscall. Most notable: the pthread functions.
    E.g. The implementation of pthread_create() is provided in the function __pthread_create().
    pthread_create() is only a weak alias to __pthread_create().
    To detect syscalls like pthread_create() correctly make sure to set an alias to __{syscall_name}.
    For all syscall stubs the corresponding alias to __{syscall_name} is automatically set.

    Note: There might be other weak aliases than the __{syscall name} version in the musl libc.
          Check the musl libc implementation with:
                grep -rnw '<path to musl libc src>' -e "weak_alias"
          and search for you desired/undetected syscall.

    To add a syscall stub, the only thing you need to do is adding the syscall name to the syscall_set. (See syscall_set.py)
    
    If you want to implement a new instance for the Instance Graph, create a new module in this package and make sure
    that _POSIXSyscalls inherits from the new syscall class that contains the new syscall methods.
'''

def syscall_stub(graph, state, cpu_id, args, va):
    """An empty stub for all not implemented syscalls in the syscall_set."""
    return state


class _POSIXSyscalls(MutexSyscalls, SemaphoreSyscalls, CondSyscalls,
                     PipeSyscalls, FileSyscalls, FileDescriptorSyscalls,
                     SignalSyscalls, ThreadSyscalls, OtherSyscalls,
                     WarningSyscalls, SyscallStubAliases, MuslSyscalls):
    """This class combines all implemented syscall methods."""
    pass

class _POSIXMetaClass(type(_POSIXSyscalls)):
    """This is the MetaClass for the POSIX class. 
        
    The only purpose of this class is to provide the methods __dir__ and __getattr__ for the POSIX class.
    """

    def __dir__(cls):
        """Returns the union of all implemented syscall names and names in the syscall_set as list."""
        implented_syscalls = set(filter((lambda name : hasattr(getattr(cls, name), 'syscall')), dir(_POSIXSyscalls)))
        total_syscalls = implented_syscalls.union(syscall_set)
        syscall_list = list(total_syscalls)
        # Uncomment this line if you need all functions from dir():
        #syscall_list.extend(["get_special_steps", "has_dynamic_instances", "init", "interpret", "config", "get_name", "detected_syscalls", "is_syscall"])
        return syscall_list

    def __getattr__(cls, syscall_name):
        """This method provides all attributes that are not directly included in the POSIX class.

        These are all stub syscalls.
        e.g. A non implemented syscall in syscall_set will be redirected to syscall_stub()
        """
        if syscall_name in syscall_set:
            musl_alias = get_musl_weak_alias(syscall_name)
            if musl_alias != None:
                musl_alias = {musl_alias}
            return syscall(syscall_stub, aliases=musl_alias, name=syscall_name, is_stub=True) # Decorate syscall_stub to set the default musl libc alias and the syscall name.
        else:
            raise AttributeError


class POSIX(OSBase, _POSIXSyscalls, metaclass=_POSIXMetaClass):
    """The POSIX OS Model class."""

    __metaclass__ = _POSIXMetaClass

    @staticmethod
    def get_special_steps():
        return ["POSIXInit"] # This step initializes this OS Model.

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        state.scheduler_on = True  # The Scheduler is always on in POSIX.

    @staticmethod
    def get_initial_state(cfg, instances):
        return OSState(cpus=CPUList([CPU(id=0,
                                         irq_on=True,
                                         control_instance=None,
                                         abb=None,
                                         call_path=CallPath(),
                                         exec_state=ExecState.idle,
                                         analysis_context=None)]),
                       instances=instances, cfg=cfg)

    @staticmethod
    def _do_not_interpret(state: OSState, cpu_id: int):
        """Handling for the case that the current syscall should not be interpreted."""
        state = state.copy()
        state.next_abbs = []
        set_next_abb(state, cpu_id)
        return state

    @staticmethod
    def _syscall_category_matching(syscall: SysCall, categories: set) -> bool:
        """Does the set of categories in syscall matching to <categories> argument?"""
        if SyscallCategory.every not in categories:
            sys_cat = syscall.categories
            return (sys_cat | categories) == sys_cat

    @staticmethod
    def interpret(graph: Graph, state: OSState, cpu_id: int, categories=SyscallCategory.every):
        """Interprets a detected syscall."""

        cfg = graph.cfg
        cpu = state.cpus[cpu_id]
        abb = cpu.abb

        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")
        logger.debug(f"found syscall in Callpath: {cpu.call_path}")

        # Get syscall function. (Handles Musl/Linux syscalls)
        syscall_function = None
        sig_offest = 0
        if PosixOptions.enable_musl_syscalls and is_musl_syscall_wrapper(syscall):
            musl_syscall = get_musl_syscall(syscall, graph, state, cpu_id)
            if musl_syscall == None:
                return POSIX._do_not_interpret(state, cpu_id)
            syscall_function = getattr(POSIX, musl_syscall)
            sig_offest = 1 # Ignore first argument
        else:
            syscall_function = POSIX.detected_syscalls()[syscall] # Alias handling

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if not POSIX._syscall_category_matching(syscall_function, categories):
            return POSIX._do_not_interpret(state, cpu_id)

        # Throw error if a non-async-signal-safe syscalls is called in signal handler
        thread = get_running_thread(state, cpu_id)
        if type(thread) == SignalCatchingFunc and not syscall_function.signal_safe:
            logger.error(f"signal catching function {thread.name} has called not async-signal-safe syscall {syscall_function.name}(). Ignoring ...")
            return POSIX._do_not_interpret(state, cpu_id)

        # Call the syscall function.
        CurrentSyscallCategories.set(categories)
        return syscall_function(graph, state, cpu_id, sig_offest)