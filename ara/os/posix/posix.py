""" This module builds the full POSIX OS Model.

    Just import the POSIX OS Model via "from ara.os.posix.posix import POSIX"
"""

from ara.graph import SyscallCategory
from ..os_base import OSBase
from ..os_util import syscall
from .posix_utils import debug_log, logger, handle_soc, add_normal_cfg
from .file import FileSyscalls
from .file_descriptor import FileDescriptorSyscalls
from .mutex import MutexSyscalls
from .signal import SignalSyscalls
from .thread import ThreadSyscalls
from .other_syscalls import OtherSyscalls
from .warning_syscalls import WarningSyscalls
from .syscall_set import syscall_set

'''
    Hold on! To understand this file you need some information.

    The musl libc makes heavy use of weak aliases.
    E.g. The implementation of pthread_create() is provided in the function __pthread_create().
    pthread_create() is only a weak alias to __pthread_create().
    ARA can only detect the original function (__pthread_create). 
    And the musl libc also call internally syscall functions with "__" prefixed.
    The __{syscall name} version is called "[musl libc] weak alias version" in this OS Model.

    To detect the syscalls correctly we need to provide an implementation for these prefixed functions.
    This is done by redirecting POSIX.__syscall -> POSIX.syscall. (See _POSIXMetaClass)

    To add a syscall stub the only thing you need to do is adding the syscall name to the syscall_set. (See syscall_set.py)
    
    If you want to implement a new instance for the InstanceGraph create a new module in this package and make sure
    that _POSIXSyscalls inherit from the new syscall class that contains the new syscalls.
'''

@syscall
def syscall_stub(graph, abb, state, args, va):
    """ An empty stub for all not implemented syscalls in the syscall_set. """
    pass

def get_weak_alias(syscall):
    """ Returns the musl libc weak alias name version of the syscall name.

        For example: "pthread_create" -> "__pthread_create"

        For all names which start with a '_' there is no weak alias version.
        In this case this function will return None.
    """
    return "__" + syscall if syscall[0] != '_' else None

def is_weak_alias(syscall):
    """ Returns True if the syscall name is a musl libc weak alias name. """
    return len(syscall) > 2 and syscall[0:2] == "__" and syscall[2] != '_'


class _POSIXSyscalls(MutexSyscalls, FileSyscalls, FileDescriptorSyscalls,
                     SignalSyscalls, ThreadSyscalls, OtherSyscalls,
                     WarningSyscalls):
    """ This class combines all implemented syscall methods. """
    pass

class _POSIXMetaClass(type(_POSIXSyscalls)):
    """ This is the MetaClass for the POSIX class. 
        
        The only purpose of this class is to provide the methods __dir__ and __getattr__ for the POSIX class.
    """

    def __dir__(cls):
        """ Returns the union of all implemented syscall names and names in the syscall_set as list.

            The musl libc weak alias versions of all names from above are also included in this list.
        """
        implented_syscalls = set(filter((lambda name : name[0:2] != "__" and name[-2:] != "__"), dir(_POSIXSyscalls)))
        total_syscalls = implented_syscalls.union(syscall_set)
        syscall_list = list()
        for syscall in total_syscalls:
            syscall_list.append(syscall)
            weak_alias_version = get_weak_alias(syscall)
            if weak_alias_version != None:
                syscall_list.append(weak_alias_version)
        # Uncomment this line if you need all functions from dir():
        #syscall_list.extend(["get_special_steps", "has_dynamic_instances", "init", "interpret", "config", "get_name"])
        return syscall_list

    def __getattr__(cls, syscall):
        """ This method provides all attributes that are not directly included in POSIX.

            These are all stub syscalls and musl libc weak aliases.
            e.g. __pthread_create() will be redirected to the implementation of pthread_create()
            e.g. A non implemented Syscall in syscall_set will be redirected to syscall_stub()
        """
        if is_weak_alias(syscall):
            orig_syscall = syscall[2:]
            syscall_func = getattr(_POSIXSyscalls, orig_syscall, None)
            if syscall_func != None:
                return syscall_func
            elif orig_syscall in syscall_set:
                return syscall_stub
            else:
                raise AttributeError

        if syscall in syscall_set:
            return syscall_stub
        else:
            raise AttributeError


class POSIX(OSBase, _POSIXSyscalls, metaclass=_POSIXMetaClass):

    __metaclass__ = _POSIXMetaClass

    @staticmethod
    def get_special_steps():
        return []

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        pass
        #state.scheduler_on = True  # The Scheduler is always on in POSIX.

    @staticmethod
    def interpret(graph, abb, state, categories=SyscallCategory.every):
        """interprets a detected syscall"""

        cfg = graph.cfg

        syscall = cfg.get_syscall_name(abb)
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