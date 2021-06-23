import re
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import PosixClass, CurrentSyscallCategories

LINUX_SYSCALL_IDS = dict({
    (2, 'open'),
})

ENABLE_MUSL_SYSCALLS = True

class MuslSyscalls:

    argument_pattern = re.compile("a[1-6]")

    def perform_musl_syscall(graph, abb, state, args, va):
        syscall_name = LINUX_SYSCALL_IDS.get(args.n, None)
        if syscall_name == None:
            return state
        arg_dict = {}
        for name in args.__annotations__:
            name = str(name)
            if MuslSyscalls.argument_pattern.match(name):
                arg_dict[int(name[1]) - 1] = getattr(args, name)
        syscall = PosixClass.get().detected_syscalls()[syscall_name]
        syscall_cats = syscall.categories
        current_step_cats = CurrentSyscallCategories.get()
        if syscall_cats | current_step_cats != syscall_cats:
            return state
        state, write_back_list = syscall.direct_call(graph, abb, state, arg_dict, va)
        for idx, arg in enumerate(write_back_list):
            setattr(args, f"a{idx}", arg)
        return state

    @syscall(is_stub = not ENABLE_MUSL_SYSCALLS,
             aliases={"__syscall0"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),))
    def _musl_syscall0(graph, abb, state, args, va):
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(is_stub = not ENABLE_MUSL_SYSCALLS,
             aliases={"__syscall1"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value)))
    def _musl_syscall1(graph, abb, state, args, va):
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(is_stub = not ENABLE_MUSL_SYSCALLS,
             aliases={"__syscall2"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value)))
    def _musl_syscall2(graph, abb, state, args, va):
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(is_stub = not ENABLE_MUSL_SYSCALLS,
             aliases={"__syscall3"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value)))
    def _musl_syscall3(graph, abb, state, args, va):
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(is_stub = not ENABLE_MUSL_SYSCALLS,
             aliases={"__syscall4"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value),
                        Arg('a4', hint=SigType.value)))
    def _musl_syscall4(graph, abb, state, args, va):
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(is_stub = not ENABLE_MUSL_SYSCALLS,
             aliases={"__syscall5"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value),
                        Arg('a4', hint=SigType.value),
                        Arg('a5', hint=SigType.value)))
    def _musl_syscall5(graph, abb, state, args, va):
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)

    @syscall(is_stub = not ENABLE_MUSL_SYSCALLS,
             aliases={"__syscall6"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('n', hint=SigType.value),
                        Arg('a1', hint=SigType.value),
                        Arg('a2', hint=SigType.value),
                        Arg('a3', hint=SigType.value),
                        Arg('a4', hint=SigType.value),
                        Arg('a5', hint=SigType.value),
                        Arg('a6', hint=SigType.value)))
    def _musl_syscall6(graph, abb, state, args, va):
        return MuslSyscalls.perform_musl_syscall(graph, abb, state, args, va)