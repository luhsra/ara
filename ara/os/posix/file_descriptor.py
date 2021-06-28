from typing import Any
import pyllco
from ara.graph import SyscallCategory, SigType
from dataclasses import dataclass
from ..os_util import syscall, Arg
from .posix_utils import add_edge_from_self_to

@dataclass(eq = False)
class FileDescriptor:
    points_to: Any # An object like File, Pipe, ...

    def __hash__(self):
        return id(self)

def create_file_desc_of(instance):
    """Creates a file descriptor encapsulating the given instance.
    
    Make sure to only provide File Descriptor objects like File, Pipe, ...
    """
    assert instance != None
    return FileDescriptor(points_to=instance)

class FileDescriptorSyscalls:

    # ssize_t read(int fildes, void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def read(graph, abb, state, args, va):
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        return add_edge_from_self_to(state, args.fildes.points_to if args.fildes != None else None, "read()")

    # ssize_t write(int fildes, const void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def write(graph, abb, state, args, va):
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        return add_edge_from_self_to(state, args.fildes.points_to if args.fildes != None else None, "write()")

    # ssize_t writev(int fildes, const struct iovec *iov, int iovcnt)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('iov', hint=SigType.symbol),
                        Arg('iovcnt', hint=SigType.value)))
    def writev(graph, abb, state, args, va):
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        return add_edge_from_self_to(state, args.fildes.points_to if args.fildes != None else None, "writev()")

    # ssize_t readv(int fildes, const struct iovec *iov, int iovcnt)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('iov', hint=SigType.symbol),
                        Arg('iovcnt', hint=SigType.value)))
    def readv(graph, abb, state, args, va):
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        return add_edge_from_self_to(state, args.fildes.points_to if args.fildes != None else None, "readv()")