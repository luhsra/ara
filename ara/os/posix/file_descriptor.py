import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from queue import Queue
from ara.graph import SyscallCategory, SigType
import pyllco

from ..os_util import syscall, assign_id, Arg
from .posix_utils import IDInstance, logger, handle_soc, do_not_interpret_syscall, add_edge_from_self_to
from .file import File
from .pipe import Pipe

# This FileDescriptor is not an instance in the Instance Graph
@dataclass
class FileDescriptor:
    pass

class FileDescriptorSyscalls:

    # ssize_t read(int fildes, void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', hint=SigType.instance, ty=[File, Pipe]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def read(graph, abb, state, args, va):
        return add_edge_from_self_to(graph, abb, state, args.fildes, "read()")

    # ssize_t write(int fildes, const void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', hint=SigType.instance, ty=[File, Pipe]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def write(graph, abb, state, args, va):
        return add_edge_from_self_to(graph, abb, state, args.fildes, "write()")

    # # TODO: Remove this unimplemented fwrite()
    # @syscall(categories={SyscallCategory.comm},
    #         signature=(Arg('ptr', hint=SigType.symbol),
    #                    Arg('size', hint=SigType.value),
    #                    Arg('nitems', hint=SigType.value),
    #                    Arg('stream', hint=SigType.symbol)))
    # def fwrite(graph, abb, state, args, va):

    #     logger.debug("found fwrite() syscall")
    #     return state