from typing import Any
from ara.graph.graph import Graph
from ara.os.os_base import OSState
from ara.steps.instance_graph_stats import MissingInteractions
import pyllco
from ara.graph import SyscallCategory, SigType
from enum import IntFlag
from dataclasses import dataclass
from ..os_util import syscall, Arg, UnknownArgument
from .posix_utils import POSIXInstance, PosixEdgeType, add_edge_from_self_to, logger

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
    type: FDType   # Type of the file descriptor.

    def __hash__(self):
        return id(self)

def create_file_desc_of(instance: POSIXInstance, type: FDType = FDType.BOTH):
    """Creates a file descriptor of given type encapsulating given instance.
    
    Make sure to only provide File Descriptor objects like File, Pipe, ...
    """
    assert instance != None
    return FileDescriptor(points_to=instance, type=type)

class FileDescriptorSyscalls:

    def _fd_syscall_impl(graph: Graph, state: OSState, args, cpu_id: int, label: str, expected_type: FDType):
        """Implementation for all file descriptor interaction systemcalls.

        Arguments:
        label           -- label for the interaction edge.
        expected_type   -- The file descriptor type that the systemcall requires.
                           (e.g. for read() it is FDType.READ)
        """
        cpu = state.cpus[cpu_id]
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        if type(args.fildes) != FileDescriptor:
            logger.warning(f"{label}: Could not get file descriptor argument. {('ValueAnalyzer failed with: ' + str(args.fildes.exception)) if type(args.fildes) == UnknownArgument else ''}")
            MissingInteractions.add_imprecise(['File', 'Pipe'], cpu.abb)
            return state
        assert args.fildes.points_to != None and args.fildes.type != None
        edge_type = PosixEdgeType.interaction
        if args.fildes.type & expected_type != expected_type:
            logger.error(f"{label}: file descriptor type {args.fildes.type.name} is not matching {expected_type.name}.")
            label = f"used {label} with {args.fildes.type.name} fd"
            edge_type = PosixEdgeType.interaction_error
        return add_edge_from_self_to(state, args.fildes.points_to, label, cpu_id, edge_type, expected_instance=['File', 'Pipe'])

    # ssize_t read(int fildes, void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm}, signal_safe=True,
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def read(graph, state, cpu_id, args, va):
        return FileDescriptorSyscalls._fd_syscall_impl(graph, state, args, cpu_id, "read()", FDType.READ)

    # ssize_t write(int fildes, const void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm}, signal_safe=True,
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def write(graph, state, cpu_id, args, va):
        return FileDescriptorSyscalls._fd_syscall_impl(graph, state, args, cpu_id, "write()", FDType.WRITE)

    # ssize_t writev(int fildes, const struct iovec *iov, int iovcnt)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('iov', hint=SigType.symbol),
                        Arg('iovcnt', hint=SigType.value)))
    def writev(graph, state, cpu_id, args, va):
        return FileDescriptorSyscalls._fd_syscall_impl(graph, state, args, cpu_id, "writev()", FDType.WRITE)

    # ssize_t readv(int fildes, const struct iovec *iov, int iovcnt)
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[FileDescriptor, pyllco.ConstantInt]),
                        Arg('iov', hint=SigType.symbol),
                        Arg('iovcnt', hint=SigType.value)))
    def readv(graph, state, cpu_id, args, va):
        return FileDescriptorSyscalls._fd_syscall_impl(graph, state, args, cpu_id, "readv()", FDType.READ)