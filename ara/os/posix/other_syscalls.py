from ara.graph import SyscallCategory

from ..os_util import syscall
from .posix_utils import logger, do_not_interpret_syscall, add_self_edge

class OtherSyscalls:

    @syscall(categories={SyscallCategory.comm})
    def pause(graph, abb, state, args, va):
        logger.debug("found pause() syscall")
        return add_self_edge(state, "pause()")