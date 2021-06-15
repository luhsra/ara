"""This module builds the full POSIX OS Model.

Just import the POSIX OS Model via "from ara.os.posix.posix import POSIX"
"""

from ara.graph import SyscallCategory
from ..os_base import OSBase
from ..os_util import syscall
from .posix_utils import logger, get_musl_weak_alias, do_not_interpret_syscall, CurrentSyscallCategories
from .file import FileSyscalls
from .file_descriptor import FileDescriptorSyscalls
from .pipe import PipeSyscalls
from .mutex import MutexSyscalls
from .signal import SignalSyscalls
from .thread import ThreadSyscalls
from .other_syscalls import OtherSyscalls
from .warning_syscalls import WarningSyscalls
from .syscall_set import syscall_set
from .syscall_stub_aliases import SyscallStubAliases

'''
    Hold on! To understand this file you need some information.

    The musl libc makes heavy use of weak aliases.
    E.g. The implementation of pthread_create() is provided in the function __pthread_create().
    pthread_create() is only a weak alias to __pthread_create().
    To detect syscalls like pthread_create() correctly make sure to set an alias to __{syscall_name}.
    For all syscall stubs the corresponding alias to __{syscall_name} is automatically set.

    Note: There might be other weak aliases than the __{syscall name} version in the musl libc.
          Check the musl libc implementation with:
                grep -rnw '<path to musl libc src>' -e "weak_alias"
          and search for you desired/undetected syscall.

    To add a syscall stub the only thing you need to do is adding the syscall name to the syscall_set. (See syscall_set.py)
    
    If you want to implement a new instance for the InstanceGraph create a new module in this package and make sure
    that _POSIXSyscalls inherit from the new syscall class that contains the new syscalls.
'''

def syscall_stub(graph, abb, state, args, va):
    """An empty stub for all not implemented syscalls in the syscall_set."""
    return do_not_interpret_syscall(graph, abb, state)


class _POSIXSyscalls(MutexSyscalls, PipeSyscalls, FileSyscalls, 
                     FileDescriptorSyscalls, SignalSyscalls, ThreadSyscalls, 
                     OtherSyscalls, WarningSyscalls, SyscallStubAliases):
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
        e.g. A non implemented Syscall in syscall_set will be redirected to syscall_stub()
        """
        if syscall_name in syscall_set:
            musl_alias = get_musl_weak_alias(syscall_name)
            if musl_alias != None:
                musl_alias = {musl_alias}
            return syscall(syscall_stub, aliases=musl_alias, name=syscall_name, is_stub=True) # Decorate syscall_stub to set the default musl libc alias and the syscall name.
        else:
            raise AttributeError


class POSIX(OSBase, _POSIXSyscalls, metaclass=_POSIXMetaClass):

    __metaclass__ = _POSIXMetaClass

    @staticmethod
    def get_special_steps():
        return ["POSIXInit"]

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        state.scheduler_on = True  # The Scheduler is always on in POSIX.

    @staticmethod
    def interpret(graph, abb, state, categories=SyscallCategory.every):
        """ Interprets a detected syscall. """

        cfg = graph.cfg

        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")
        logger.debug(f"found syscall in Callpath: {state.call_path}")

        syscall_function = POSIX.detected_syscalls()[syscall] # Alias handling

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.every not in categories:
            sys_cat = syscall_function.categories
            if sys_cat | categories != sys_cat:
                return do_not_interpret_syscall(graph, abb, state)

        CurrentSyscallCategories.set(categories)
        return syscall_function(graph, abb, state)