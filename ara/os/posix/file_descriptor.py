import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType
import pyllco

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, logger, handle_soc, do_not_interpret_syscall

# This FileDescriptor is not an instance in the Instance Graph
@dataclass
class FileDescriptor:
    pass

class FileDescriptorSyscalls:

    @syscall(categories={SyscallCategory.comm},
            signature=(Arg('fildes', hint=SigType.value, raw_value=True),
                       Arg('buf', hint=SigType.symbol),
                       Arg('nbyte', hint=SigType.value)))
    def write(graph, abb, state, args, va):

        logger.debug("found write() syscall")
        return do_not_interpret_syscall(graph, abb, state)


    # # TODO: Remove this unimplemented fwrite()
    # @syscall(categories={SyscallCategory.comm},
    #         signature=(Arg('ptr', hint=SigType.symbol),
    #                    Arg('size', hint=SigType.value),
    #                    Arg('nitems', hint=SigType.value),
    #                    Arg('stream', hint=SigType.symbol)))
    # def fwrite(graph, abb, state, args, va):

    #     logger.debug("found fwrite() syscall")
    #     return state