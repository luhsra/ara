import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc

class SignalType(IntEnum):
    """ The values of these signals are Linux specific.

        All values are copied from <bits/signum-generic.h> and <bits/signum-arch.h> included by <signal.h>
    """

    # Non architecture dependend signals <bits/signum-generic.h>
    SIGINT =    2	# Interactive attention signal.
    SIGILL =    4	# Illegal instruction.
    SIGABRT =   6	# Abnormal termination.
    SIGFPE =    8	# Erroneous arithmetic operation.
    SIGSEGV =   11	# Invalid access to storage.
    SIGTERM	=   15	# Termination request.
    SIGHUP =    1	# Hangup.
    SIGQUIT =   3	# Quit.
    SIGTRAP =   5	# Trace/breakpoint trap.
    SIGKILL	=   9	# Killed.
    SIGPIPE	=   13	# Broken pipe.
    SIGALRM	=   14	# Alarm clock.

    # Architecture dependend signals <bits/signum-arch.h>
    SIGBUS =    7	# Bus error.
    SIGSYS =    31	# Bad system call.
    SIGURG =    23	# Urgent data is available at a socket.
    SIGSTOP	=   19	# Stop, unblockable.
    SIGTSTP	=   20	# Keyboard stop.
    SIGCONT	=   18	# Continue.
    SIGCHLD	=   17	# Child terminated or stopped.
    SIGTTIN	=   21	# Background read from control terminal.
    SIGTTOU	=   22	# Background write to control terminal.
    SIGPOLL	=   29	# Pollable event occurred (System V).
    SIGXFSZ	=   25	# File size limit exceeded.
    SIGXCPU	=   24	# CPU time limit exceeded.
    SIGVTALRM = 26	# Virtual timer expired.
    SIGPROF	=   27	# Profiling timer expired.
    SIGUSR1	=   10	# User-defined signal 1.
    SIGUSR2	=   12	# User-defined signal 2.

    # Non POSIX signals
    #SIGSTKFLT =    16	# Stack fault (obsolete).
    #SIGPWR	=       30	# Power failure imminent.
    #SIGWINCH =     28	# Window size change (4.3 BSD, Sun).

class _SignalDefaultAction(Enum):
    T = 0   # Abnormal termination of the process.
    A = 1   # Abnormal termination of the process with additional actions. 
    I = 2   # Ignore the signal.
    S = 3   # Stop the process.
    C = 4   # Continue the process, if it is stopped; otherwise, ignore the signal.

defaultActionOfSignal: Dict[SignalType, _SignalDefaultAction] = {
    SignalType.SIGABRT: _SignalDefaultAction.A,
    SignalType.SIGALRM: _SignalDefaultAction.T,
    SignalType.SIGBUS: _SignalDefaultAction.A,
    # TODO: fill in the rest of signal default actions 
}

class _SignalAction_DFL_IGN(Enum):
    SIG_DFL = 0     # Default signal action
    SIG_IGN = 1     # Ignore the signal

_SignalAction_Function = Any # TODO: determine type of a signal handler function

SignalAction = Union[_SignalAction_DFL_IGN, _SignalAction_Function]

@dataclass
class SignalHandler(POSIXInstance):
    pass # TODO: define

class SignalSyscalls:
    pass