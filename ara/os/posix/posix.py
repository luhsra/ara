""" This module builds the full POSIX OS Model.

    Just import the POSIX OS Model via "from ara.os.posix.posix import POSIX"
"""

from ara.graph import SyscallCategory
from ..os_base import OSBase
from ..os_util import syscall
from .posix_utils import debug_log, logger, handle_soc, add_normal_cfg, get_weak_alias, is_weak_alias, get_orig_of_weak_alias, do_not_interpret_syscall
from .file import FileSyscalls
from .file_descriptor import FileDescriptorSyscalls
from .mutex import MutexSyscalls
from .signal import SignalSyscalls
from .thread import ThreadSyscalls
from .other_syscalls import OtherSyscalls
from .warning_syscalls import WarningSyscalls
from .syscall_set import syscall_set
from .syscall_count import SyscallCount

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

    Note: There might be other weak aliases than the __{syscall name} version in the musl libc.
          These syscalls/C-Functions are not supported. 
          Check the musl libc implementation with:
                grep -rnw '<path to musl libc src>' -e "weak_alias"
          and search for you desired/undetected syscall.
          You can create a redirection as Syscall Method in this model to provide an implementation for this weak alias.

    To add a syscall stub the only thing you need to do is adding the syscall name to the syscall_set. (See syscall_set.py)
    
    If you want to implement a new instance for the InstanceGraph create a new module in this package and make sure
    that _POSIXSyscalls inherit from the new syscall class that contains the new syscalls.
'''

@syscall(categories={SyscallCategory.create}) # Make sure this syscall stub will be called to allow syscall count.
def syscall_stub(graph, abb, state, args, va):
    """ An empty stub for all not implemented syscalls in the syscall_set. """
    return do_not_interpret_syscall(graph, abb, state)


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
            #if weak_alias_version != None:
                #syscall_list.append(weak_alias_version)
        # Uncomment this line if you need all functions from dir():
        #syscall_list.extend(["get_special_steps", "has_dynamic_instances", "init", "interpret", "config", "get_name"])
        return syscall_list

    def __getattr__(cls, syscall):
        """ This method provides all attributes that are not directly included in POSIX.

            These are all stub syscalls and musl libc weak aliases.
            e.g. __pthread_create() will be redirected to the implementation of pthread_create()
            e.g. A non implemented Syscall in syscall_set will be redirected to syscall_stub()
        """
        #if is_weak_alias(syscall):
        #    orig_syscall = get_orig_of_weak_alias(syscall)
        #    syscall_func = getattr(_POSIXSyscalls, orig_syscall, None)
        #    if syscall_func != None:
        #        return syscall_func
        #    elif orig_syscall in syscall_set:
        #        return syscall_stub
        #    else:
        #        raise AttributeError

        print(syscall)
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
        """ Interprets a detected syscall. """

        cfg = graph.cfg

        syscall = cfg.get_syscall_name(abb)
        debug_log(f"Get syscall: {syscall}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall_function = POSIX.detected_syscalls()[syscall] # Alias handling

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.every not in categories:
            sys_cat = syscall_function.categories
            if sys_cat | categories != sys_cat:
                return do_not_interpret_syscall(graph, abb, state)

        SyscallCount.add_syscall(syscall)
        return syscall_function(graph, abb, state)