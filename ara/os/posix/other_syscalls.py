from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import logger, do_not_interpret_syscall, add_self_edge

class OtherSyscalls:

    # int pause(void);
    @syscall(categories={SyscallCategory.comm})
    def pause(graph, abb, state, args, va):
        return add_self_edge(state, "pause()")

    # unsigned sleep(unsigned seconds);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('seconds', hint=SigType.value),))
    def sleep(graph, abb, state, args, va):
        return add_self_edge(state, f"sleep({args.seconds})")