# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from ara.os.posix.posix_utils import PosixEdgeType
import pyllco
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg, add_self_edge

class OtherSyscalls:

    # int pause(void);
    @syscall(categories={SyscallCategory.comm}, signal_safe=True)
    def pause(graph, state, cpu_id, args, va):
        add_self_edge(state, cpu_id, "pause()", ty=PosixEdgeType.interaction)
        return state

    # int nanosleep(const struct timespec *rqtp, struct timespec *rmtp);
    #
    # nanosleep() is not async-signal-safe.
    # But sleep() is async-signal-safe and we redirect sleep() -> nanosleep() with the help of musl libc. 
    # We do not want to throw an error if sleep() is used in a signal handler so we set this flag here.
    @syscall(categories={SyscallCategory.comm}, signal_safe=True,
             signature=(Arg('tv_sec', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('tv_nsec', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('rmtp', hint=SigType.symbol)))
    def ARA_nanosleep_syscall_(graph, state, cpu_id, args, va):
        tv_sec = args.tv_sec.get() if type(args.tv_sec) == pyllco.ConstantInt else "<unknown>"
        tv_nsec = args.tv_nsec.get() if type(args.tv_nsec) == pyllco.ConstantInt else "<unknown>"
        add_self_edge(state, cpu_id, f"nanosleep(tv_sec: {tv_sec}, tv_nsec: {tv_nsec})", ty=PosixEdgeType.interaction)
        return state