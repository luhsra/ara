import re
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from ara.steps.syscall_count import SyscallCount
from .posix_utils import PosixClass, CurrentSyscallCategories, logger

# All the Linux syscalls we want to detect with there ids.
LINUX_SYSCALL_IDS = dict({
    (0, 'read'),
    (1, 'write'),
    (2, 'open'),
    (19, 'readv'),
    (20, 'writev'),
    (22, 'pipe'),
    (34, 'pause'),
    (35, 'nanosleep'),
})

class MuslSyscalls:
    """This class allows the detection of musl Linux syscalls.
    
    In the musl libc there are functions in the form __syscall0, __syscall1, ..., __syscall6.
    These functions are defined in the following way: (i defines the number of arguments)
        long __syscall<i> (long n, long a1, ..., long a<i>) {
            return __asm__ syscall(n, a1, ..., a<i>);
            -> perform syscall with id n and with the arguments a1 - a<i>
        }

    Our goal is to interpret these functions and extract the actual called POSIX syscalls.
    If we have a definition for the syscall in the POSIX OS Model we will call it and interpret the syscall in the usual way.
    """

    # Pattern to detect whether an argument in args is an argument for the actual syscall.
    argument_pattern = re.compile("a[1-6]")

    def perform_musl_syscall(graph, abb, state, args, va):
        """The implementation for all functions in the form __syscall<i>."""
        
        # Get the Linux syscall as syscall object.
        syscall_name = LINUX_SYSCALL_IDS.get(args.n, None)
        if syscall_name == None:
            return state
        logger.debug(f"Detected Linux syscall {syscall_name}()")
        SyscallCount.direct_add_syscall(syscall_name)
        syscall = PosixClass.get().detected_syscalls().get(syscall_name, None)
        if syscall == None:
            logger.info(f"Can not interpret Linux syscall {syscall_name} because the syscall is not defined in the POSIX OS Model.")
            return state

        # Check whether the categories of the syscall is compatible with the current categories.
        syscall_cats = syscall.categories
        current_step_cats = CurrentSyscallCategories.get()
        if syscall_cats | current_step_cats != syscall_cats:
            return state

        # Write all values of args in arg_dict.
        # The key is the position of the argument (e.g. a1 -> key 0).
        arg_dict = {}
        for name in args.__annotations__:
            name = str(name)
            if MuslSyscalls.argument_pattern.match(name):
                arg_dict[int(name[1]) - 1] = getattr(args, name)

        # Call the syscall function
        state, write_back_list = syscall.direct_call(graph, abb, state, arg_dict, va)
        
        # Synchronize the args object to allow writing back of system instances.
        for idx, arg in enumerate(write_back_list):
            setattr(args, f"a{idx}", arg)
        return state


    @syscall(aliases={"__syscall0"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),))
    def _musl_syscall0(graph, abb, state, args, va):
        """A musl syscall without arguments.
        
        The real name of this function is __syscall0.
        We need to write _musl_syscall0 to make the function public in Python.
        """
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(aliases={"__syscall1"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value)))
    def _musl_syscall1(graph, abb, state, args, va):
        """A musl syscall with one argument.
        
        The real name of this function is __syscall1.
        We need to write _musl_syscall1 to make the function public in Python.
        """
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(aliases={"__syscall2"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value)))
    def _musl_syscall2(graph, abb, state, args, va):
        """A musl syscall with 2 arguments.
        
        The real name of this function is __syscall2.
        We need to write _musl_syscall2 to make the function public in Python.
        """
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(aliases={"__syscall3"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value)))
    def _musl_syscall3(graph, abb, state, args, va):
        """A musl syscall with 3 arguments.
        
        The real name of this function is __syscall3.
        We need to write _musl_syscall3 to make the function public in Python.
        """
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(aliases={"__syscall4"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value),
                        Arg('a4', hint=SigType.value)))
    def _musl_syscall4(graph, abb, state, args, va):
        """A musl syscall with 4 arguments.
        
        The real name of this function is __syscall4.
        We need to write _musl_syscall4 to make the function public in Python.
        """
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(aliases={"__syscall5"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value),
                        Arg('a4', hint=SigType.value),
                        Arg('a5', hint=SigType.value)))
    def _musl_syscall5(graph, abb, state, args, va):
        """A musl syscall with 5 arguments.
        
        The real name of this function is __syscall5.
        We need to write _musl_syscall5 to make the function public in Python.
        """
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(aliases={"__syscall6"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value),
                        Arg('a4', hint=SigType.value),
                        Arg('a5', hint=SigType.value),
                        Arg('a6', hint=SigType.value)))
    def _musl_syscall6(graph, abb, state, args, va):
        """A musl syscall with 6 arguments.
        
        The real name of this function is __syscall6.
        We need to write _musl_syscall6 to make the function public in Python.
        """
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)