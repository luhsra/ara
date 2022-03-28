import re
from ara.graph.graph import Graph
from ara.os.os_base import OSState
import pyllco
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import logger

# All the Linux syscalls we want to detect with there ids.
# We are not analysing syscalls with 1, 2, 4, 5 or 6 arguments.
# If you add a syscall with this number of arguments,
# remove the is_stub field in the matching musl syscall function below in MuslSyscalls.
LINUX_SYSCALL_IDS = dict({
    (0, 'read'),
    (1, 'write'),
    (2, 'open'),
    (19, 'readv'),
    (20, 'writev'),
    #(22, 'pipe'), We can not redirect Linux syscall pipe -> ARA_pipe_syscall_.
    (34, 'pause'),
    #(35, 'nanosleep'), We can not redirect Linux syscall nanosleep -> ARA_nanosleep_syscall_.
    # We do not need to analyse rt_sigaction() because this Linux Syscall is only called in musl libc´s sigaction() implementation.
})

# Pattern to detect if a syscall name is a musl syscall wrapper function.
musl_syscall_pattern = re.compile("__syscall[0-6]")

def is_musl_syscall_wrapper(syscall_name: str) -> bool:
    """Returns True if syscall_name is a name of a musl syscall wrapper."""
    return musl_syscall_pattern.match(syscall_name)

def get_musl_syscall(syscall_wrapper_name: str, graph: Graph, state: OSState, cpu_id: int) -> str:
    """Returns the name of the native musl syscall (Linux Syscall) that syscall wrapper calls.
    
    Arguments:
    syscall_wrapper_name    -- the name of the musl syscall wrapper that is currently handled.
    (graph, state, cpu_id)  -- the normal arguments for the interpret() function.
    
    Only call this function if syscall wrapper is the current syscall that the OS Model handles.
    This function performs a value analysis for the first argument in syscall wrapper.
    If that value is not matching to the identifier of a musl syscall in that we are interested,
    this function returns None.
    """
    from ara.steps import get_native_component
    ValueAnalyzer = get_native_component("ValueAnalyzer")
    va = ValueAnalyzer(graph)
    ValuesUnknown = get_native_component("ValuesUnknown")
    new_state = state.copy()
    abb = new_state.cpus[cpu_id].abb
    callpath = new_state.cpus[cpu_id].call_path
    try:
        result = va.get_argument_value(abb, 0,
                                       callpath=callpath,
                                       hint=SigType.value)
    except ValuesUnknown as va_unknown_exc:
        logger.warning(f"{syscall_wrapper_name}(): ValueAnalyzer could not get the first argument that describes the syscall. Exception: \"{va_unknown_exc}\"")
        return None
    assert result != None and result.value != None
    value = result.value
    if type(value) != pyllco.ConstantInt:
        logger.warning(f"{syscall_wrapper_name}(): The first argument is not a number, it is of type {type(value)}")
        return None
    linux_syscall = LINUX_SYSCALL_IDS.get(value.get(), None)
    if linux_syscall == None:
        return None # We do not want to analyse this syscall if not in LINUX_SYSCALL_IDS.
    logger.debug(f"Detected Linux Syscall: {linux_syscall}")
    return linux_syscall

class MuslSyscalls:
    """This class contains the syscall wrapper functions of musl libc.
    
    In musl libc there are functions in the form __syscall0, __syscall1, ..., __syscall6.
    These functions are defined in the following way: (i defines the number of arguments)
        long __syscall<i> (long n, long a1, ..., long a<i>) {
            return __asm__ syscall(n, a1, ..., a<i>);
            -> perform syscall with id n and arguments a1 - a<i>
        }

    Our goal is to interpret these functions and extract the actual called POSIX syscalls.
    This is done by get_musl_syscall().
    """

    @syscall(aliases={"__syscall0"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),))
    def musl_syscall0_(graph, state, cpu_id, args, va):
        """A musl syscall without arguments.
        
        The real name of this function is __syscall0.
        We need to write musl_syscall0_ to make the function public in Python.
        """
        return state

    # We are not analysing syscalls with one argument.
    # Setting this function to a stub saves performance.
    # If you want to analyse a syscall with one argument, remove the is_stub field
    @syscall(aliases={"__syscall1"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1')))
    def musl_syscall1_(graph, state, cpu_id, args, va):
        """A musl syscall with one argument.
        
        The real name of this function is __syscall1.
        We need to write musl_syscall1_ to make the function public in Python.
        """
        return state

    # We are not analysing syscalls with 2 arguments.
    # Setting this function to a stub saves performance.
    # If you want to analyse a syscall with 2 arguments, remove the is_stub field
    @syscall(aliases={"__syscall2"}, is_stub=True,
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2')))
    def musl_syscall2_(graph, state, cpu_id, args, va):
        """A musl syscall with 2 arguments.
        
        The real name of this function is __syscall2.
        We need to write musl_syscall2_ to make the function public in Python.
        """
        return state

    @syscall(aliases={"__syscall3"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3')))
    def musl_syscall3_(graph, state, cpu_id, args, va):
        """A musl syscall with 3 arguments.
        
        The real name of this function is __syscall3.
        We need to write musl_syscall3_ to make the function public in Python.
        """
        return state

    # Currently we are not analysing syscalls with more than 3 arguments. 
    # So let us save a bit of performance by deactivating the analysis for syscalls with more arguments.
    # If you want to analyse syscalls with more than 3 arguments, remove the is_stub field for the following syscalls:
    @syscall(aliases={"__syscall4"}, is_stub=True,
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3'),
                        Arg('a4')))
    def musl_syscall4_(graph, state, cpu_id, args, va):
        """A musl syscall with 4 arguments.
        
        The real name of this function is __syscall4.
        We need to write musl_syscall4_ to make the function public in Python.
        """
        return state

    @syscall(aliases={"__syscall5"}, is_stub=True,
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3'),
                        Arg('a4'),
                        Arg('a5')))
    def musl_syscall5_(graph, state, cpu_id, args, va):
        """A musl syscall with 5 arguments.
        
        The real name of this function is __syscall5.
        We need to write musl_syscall5_ to make the function public in Python.
        """
        return state

    @syscall(aliases={"__syscall6"}, is_stub=True,
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3'),
                        Arg('a4'),
                        Arg('a5'),
                        Arg('a6')))
    def musl_syscall6_(graph, state, cpu_id, args, va):
        """A musl syscall with 6 arguments.
        
        The real name of this function is __syscall6.
        We need to write musl_syscall6_ to make the function public in Python.
        """
        return state