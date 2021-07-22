from typing import Any
import pyllco
from ara.graph import SyscallCategory, SigType
from enum import IntFlag
from dataclasses import dataclass
from ..os_util import syscall, Arg
from .posix_utils import POSIXInstance, add_edge_from_self_to, logger

class FDType(IntFlag):
    """The type of a file descriptor.
    
    Describes which actions are allowed for the file descriptor.
    """
    READ = 1    # reading is allowed
    WRITE = 2   # writing is allowed
    BOTH = 3    # READ + WRITE allowed

@dataclass(eq = False)
class FileDescriptor:
    points_to: Any # An object like File, Pipe, ...
    type: FDType

    def __hash__(self):
        return id(self)

def create_file_desc_of(instance: POSIXInstance, type: FDType = FDType.BOTH):
    """Creates a file descriptor of given type encapsulating given instance.
    
    Make sure to only provide File Descriptor objects like File, Pipe, ...
    """
    assert instance != None
    return FileDescriptor(points_to=instance, type=type)

class FileDescriptorSyscalls:

    def fd_syscall_impl(graph, state, args, label: str, expected_type: FDType):
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        if type(args.fildes) != FileDescriptor:
            logger.warning(f"{label}: Could not get file descriptor argument.")
            return state
        assert args.fildes.points_to != None and args.fildes.type != None
        if args.fildes.type & expected_type != expected_type:
            logger.error(f"{label}: file descriptor type {args.fildes.type.name} is not matching {expected_type.name}.")
            label = f"used {label} with {args.fildes.type.name} fd"
        return add_edge_from_self_to(state, args.fildes.points_to, label)

    # ssize_t read(int fildes, void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm}, signal_safe=True,
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def read(graph, abb, state, args, va):
        return FileDescriptorSyscalls.fd_syscall_impl(graph, state, args, "read()", FDType.READ)

    # ssize_t write(int fildes, const void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm}, signal_safe=True,
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def write(graph, abb, state, args, va):
        return FileDescriptorSyscalls.fd_syscall_impl(graph, state, args, "write()", FDType.WRITE)

    # ssize_t writev(int fildes, const struct iovec *iov, int iovcnt)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('iov', hint=SigType.symbol),
                        Arg('iovcnt', hint=SigType.value)))
    def writev(graph, abb, state, args, va):
        return FileDescriptorSyscalls.fd_syscall_impl(graph, state, args, "writev()", FDType.WRITE)

    # ssize_t readv(int fildes, const struct iovec *iov, int iovcnt)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('iov', hint=SigType.symbol),
                        Arg('iovcnt', hint=SigType.value)))
    def readv(graph, abb, state, args, va):
        return FileDescriptorSyscalls.fd_syscall_impl(graph, state, args, "readv()", FDType.READ)