import pyllco
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import add_self_edge

class OtherSyscalls:

    # int pause(void);
    @syscall(categories={SyscallCategory.comm}, signal_safe=True)
    def pause(graph, abb, state, args, va):
        return add_self_edge(state, "pause()")

    # int nanosleep(const struct timespec *rqtp, struct timespec *rmtp);
    #
    # nanosleep() is not async-signal-safe.
    # But sleep() is async-signal-safe and we redirect sleep() -> nanosleep() with the help of musl libc. 
    # We do not want to throw an error if sleep() is used in a signal handler so we set this flag here.
    @syscall(categories={SyscallCategory.comm}, signal_safe=True,
             signature=(Arg('tv_sec', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('tv_nsec', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('rmtp', hint=SigType.symbol)))
    def ARA_nanosleep_syscall_(graph, abb, state, args, va):
        tv_sec = args.tv_sec.get() if args.tv_sec != None else "<unknown>"
        tv_nsec = args.tv_nsec.get() if args.tv_nsec != None else "<unknown>"
        return add_self_edge(state, f"nanosleep(tv_sec: {tv_sec}, tv_nsec: {tv_nsec})")