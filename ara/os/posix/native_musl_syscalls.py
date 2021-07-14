import re
import pyllco
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from ara.steps.syscall_count import SyscallCount
from .posix_utils import logger, do_not_interpret_syscall

# All the Linux syscalls we want to detect with there ids.
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

def get_musl_syscall(syscall_wrapper_name: str, graph, abb, state) -> str:
    """Returns the name of the native musl syscall that syscall wrapper calls.
    
    Arguments:
    syscall_wrapper_name    -- the name of the musl syscall wrapper that is currently handled.
    (graph, abb and state)  -- the normal arguments for the interpret() function.
    
    Only call this function if syscall wrapper is the current syscall that the OS Model handles.
    This function performs a value analysis for the first argument in syscall wrapper.
    If that value is not matching to the identifier of a musl syscall in that we are interested,
    this function returns None.
    """
    from ara.steps import get_native_component
    ValueAnalyzer = get_native_component("ValueAnalyzer")
    va = ValueAnalyzer(graph)
    ValuesUnknown = get_native_component("ValuesUnknown")
    value = None
    try:
        value, attrs, offset = va.get_argument_value(abb, 0,
                                        callpath=state.call_path,
                                        hint=SigType.value)
    except ValuesUnknown as va_unknown_exc:
        logger.warning(f"{syscall_wrapper_name}(): ValueAnalyzer could not get the first argument that describes the syscall. Exception: \"{va_unknown_exc}\"")
        return None
    assert value != None
    if type(value) != pyllco.ConstantInt:
        logger.warning(f"{syscall_wrapper_name}(): The first argument is not a number, it is of type {type(value)}")
        return None
    linux_syscall = LINUX_SYSCALL_IDS.get(value.get(), None)
    if linux_syscall == None:
        return None # We do not want to analyse this syscall if not in LINUX_SYSCALL_IDS.
    logger.info(f"Detected Linux Syscall: {linux_syscall}")
    SyscallCount.direct_add_syscall(linux_syscall)
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
    def musl_syscall0_(graph, abb, state, args, va):
        """A musl syscall without arguments.
        
        The real name of this function is __syscall0.
        We need to write musl_syscall0_ to make the function public in Python.
        """
        return do_not_interpret_syscall(graph, abb, state)

    @syscall(aliases={"__syscall1"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1')))
    def musl_syscall1_(graph, abb, state, args, va):
        """A musl syscall with one argument.
        
        The real name of this function is __syscall1.
        We need to write musl_syscall1_ to make the function public in Python.
        """
        return do_not_interpret_syscall(graph, abb, state)

    @syscall(aliases={"__syscall2"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2')))
    def musl_syscall2_(graph, abb, state, args, va):
        """A musl syscall with 2 arguments.
        
        The real name of this function is __syscall2.
        We need to write musl_syscall2_ to make the function public in Python.
        """
        return do_not_interpret_syscall(graph, abb, state)

    @syscall(aliases={"__syscall3"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3')))
    def musl_syscall3_(graph, abb, state, args, va):
        """A musl syscall with 3 arguments.
        
        The real name of this function is __syscall3.
        We need to write musl_syscall3_ to make the function public in Python.
        """
        return do_not_interpret_syscall(graph, abb, state)

    # Currently we are not analysing syscalls with more than 3 arguments. 
    # So let us save a bit of performance by deactivating the analysis for syscalls with more arguments.
    # If you want to analyse syscalls with more than 3 arguments remove the is_stub field for the following syscalls:
    @syscall(aliases={"__syscall4"}, is_stub=True,
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3'),
                        Arg('a4')))
    def musl_syscall4_(graph, abb, state, args, va):
        """A musl syscall with 4 arguments.
        
        The real name of this function is __syscall4.
        We need to write musl_syscall4_ to make the function public in Python.
        """
        return do_not_interpret_syscall(graph, abb, state)

    @syscall(aliases={"__syscall5"}, is_stub=True,
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3'),
                        Arg('a4'),
                        Arg('a5')))
    def musl_syscall5_(graph, abb, state, args, va):
        """A musl syscall with 5 arguments.
        
        The real name of this function is __syscall5.
        We need to write musl_syscall5_ to make the function public in Python.
        """
        return do_not_interpret_syscall(graph, abb, state)

    @syscall(aliases={"__syscall6"}, is_stub=True,
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('a1'),
                        Arg('a2'),
                        Arg('a3'),
                        Arg('a4'),
                        Arg('a5'),
                        Arg('a6')))
    def musl_syscall6_(graph, abb, state, args, va):
        """A musl syscall with 6 arguments.
        
        The real name of this function is __syscall6.
        We need to write musl_syscall6_ to make the function public in Python.
        """
        return do_not_interpret_syscall(graph, abb, state)