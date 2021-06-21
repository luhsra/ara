import pyllco
from ara.graph import SyscallCategory, SigType
from ..os_util import syscall, Arg
from .posix_utils import add_edge_from_self_to
from .file import File
from .pipe import Pipe

class FileDescriptorSyscalls:

    # ssize_t read(int fildes, void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[File, Pipe, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def read(graph, abb, state, args, va):
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        return add_edge_from_self_to(state, args.fildes, "read()")

    # ssize_t write(int fildes, const void *buf, size_t nbyte);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('fildes', ty=[File, Pipe, pyllco.ConstantInt]),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def write(graph, abb, state, args, va):
        if type(args.fildes) == pyllco.ConstantInt: # Do not throw warning
            return state
        return add_edge_from_self_to(state, args.fildes, "write()")

    # # TODO: Remove this unimplemented fwrite()
    # @syscall(categories={SyscallCategory.comm},
    #         signature=(Arg('ptr', hint=SigType.symbol),
    #                    Arg('size', hint=SigType.value),
    #                    Arg('nitems', hint=SigType.value),
    #                    Arg('stream', hint=SigType.symbol)))
    # def fwrite(graph, abb, state, args, va):

    #     logger.debug("found fwrite() syscall")
    #     return state