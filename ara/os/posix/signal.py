import pyllco
from dataclasses import dataclass
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, register_instance, logger

SIGNAL_TYPES = dict({ 
    # The values of these signals are Linux specific.
    # All values are copied from glibcs <bits/signum-generic.h> and <bits/signum-arch.h> included by <signal.h>.
    # This list was compared to musl libc's signal list generated in <bits/signal.h>.

    # Non architecture dependend signals <bits/signum-generic.h>
    (2, 'SIGINT'),      # Interactive attention signal.
    (4, 'SIGILL'),      # Illegal instruction.
    (6, 'SIGABRT'),     # Abnormal termination. (aka: SIGIOT)
    (8, 'SIGFPE'),      # Erroneous arithmetic operation.
    (11, 'SIGSEGV'),    # Invalid access to storage.
    (15, 'SIGTERM'),    # Termination request.
    (1, 'SIGHUP'),      # Hangup.
    (3, 'SIGQUIT'),     # Quit.
    (5, 'SIGTRAP'),     # Trace/breakpoint trap.
    (9, 'SIGKILL'),     # Killed.
    (13, 'SIGPIPE'),    # Broken pipe.
    (14, 'SIGALRM'),    # Alarm clock.

    # Architecture dependend signals <bits/signum-arch.h>
    (7, 'SIGBUS'),      # Bus error.
    (31, 'SIGSYS'),     # Bad system call. (aka: SIGUNUSED)
    (23, 'SIGURG'),     # Urgent data is available at a socket.
    (19, 'SIGSTOP'),    # Stop, unblockable.
    (20, 'SIGTSTP'),    # Keyboard stop.
    (18, 'SIGCONT'),    # Continue.
    (17, 'SIGCHLD'),    # Child terminated or stopped.
    (21, 'SIGTTIN'),    # Background read from control terminal.
    (22, 'SIGTTOU'),    # Background write to control terminal.
    (29, 'SIGPOLL'),    # Pollable event occurred (System V). (aka: SIGIO)
    (25, 'SIGXFSZ'),    # File size limit exceeded.
    (24, 'SIGXCPU'),    # CPU time limit exceeded.
    (26, 'SIGVTALRM'),  # Virtual timer expired.
    (27, 'SIGPROF'),    # Profiling timer expired.
    (10, 'SIGUSR1'),    # User-defined signal 1.
    (12, 'SIGUSR2'),    # User-defined signal 2.

    # Non POSIX signals
    (16, 'SIGSTKFLT'),	# Stack fault (obsolete).
    (30, 'SIGPWR'),	    # Power failure imminent.
    (28, 'SIGWINCH'),   # Window size change (4.3 BSD, Sun).
})

@dataclass(eq = False)
class SignalCatchingFunc(IDInstance):
    entry_abb: Any              # The entry point as abb type
    function: pyllco.Function   # The entry point as function type
    catching_signals: set       # all signals that the handler is catching (of type: set[str])
    is_regular: bool = True     # True if the entry function is available

    wanted_attrs = ["name", "function", "catching_signals"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#ffa500",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

    def __hash__(self):
        return hash(self.num_id)

# SA_SIGINFO flag for sigaction.sa_sigaction
SA_SIGINFO = 4

class SignalSyscalls:

    # Keep track of all already created signal catching functions.
    # This allows us to add more signals to an already existing signal catching function.
    signal_catching_functions = dict()

    # int sigaction(int sig, const struct sigaction *restrict act,
    #       struct sigaction *restrict oact);
    @syscall(categories={SyscallCategory.create}, signal_safe=True,
             signature=(Arg('sig', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('sa_handler', hint=SigType.symbol, ty=[pyllco.Function, pyllco.ConstantPointerNull, pyllco.GlobalVariable, pyllco.AllocaInst]),
                        Arg('sa_mask', hint=SigType.symbol),
                        Arg('sa_flags', hint=SigType.value, ty=[pyllco.ConstantInt, pyllco.ConstantAggregateZero, pyllco.GlobalVariable, pyllco.AllocaInst]),
                        Arg('sa_sigaction', hint=SigType.symbol, ty=[pyllco.Function, pyllco.ConstantPointerNull, pyllco.GlobalVariable, pyllco.AllocaInst]),
                        Arg('oact', hint=SigType.symbol)))   
    def ARA_sigaction_syscall_(graph, abb, state, args, va): # sigaction()
        
        # suppress some "argument is of wrong type" warnings
        sa_handler = args.sa_handler
        sa_sigaction = args.sa_sigaction
        sa_flags = args.sa_flags
        if type(sa_handler) in [pyllco.ConstantPointerNull, pyllco.GlobalVariable, pyllco.AllocaInst]:
            sa_handler = None
        if type(sa_sigaction) in [pyllco.ConstantPointerNull, pyllco.GlobalVariable, pyllco.AllocaInst]:
            sa_sigaction = None
        if type(sa_flags) in [pyllco.ConstantAggregateZero, pyllco.GlobalVariable, pyllco.AllocaInst]:
            sa_flags = None

        # Search for a valid function pointer
        function_pointer = None

        # If: no function pointer is avaliable
        if sa_handler == None and sa_sigaction == None:
            logger.info("No function pointer found in sigaction() call. Ignore ...")
            return state

        # Get the expected function pointer field (SA_SIGINFO in args.sa_flags)
        expected_func_ptr_field = None
        if sa_flags != None:
            expected_func_ptr_field = "sa_sigaction" if (sa_flags.get() & SA_SIGINFO) == SA_SIGINFO else "sa_handler"
        else:
            expected_func_ptr_field = "sa_handler"

        # If: sa_handler and sa_sigaction both are set [This is not allowed in POSIX].
        # We handle this case but throw an error.
        if sa_handler != None and sa_sigaction != None:
            logger.error(f"sa_handler and sa_sigaction both are set in sigaction() [This is not allowed in POSIX]. Choose {expected_func_ptr_field} due to sa_flags.")
            function_pointer = getattr(args, expected_func_ptr_field)

        # If: only one field is set (sa_handler or sa_sigaction).
        # We also check for consistency with SA_SIGINFO in sa_flags.
        else:
            set_func_ptr_field = "sa_handler" if sa_handler != None else "sa_sigaction"
            if set_func_ptr_field != expected_func_ptr_field:
                logger.error(f"{set_func_ptr_field} is set in sigaction() but {expected_func_ptr_field} is expected due to sa_flags. Choose {set_func_ptr_field}.")
            function_pointer = getattr(args, set_func_ptr_field)


        # So, now we have a valid function pointer.
        assert(type(function_pointer) == pyllco.Function)
        func_name = function_pointer.get_name()

        # Translate the args.sig argument to a meaningful string.
        catching_signal = None
        if args.sig != None:
            catching_signal = SIGNAL_TYPES.get(args.sig.get(), None)
            if catching_signal == None:
                logger.error(f"Unknown signal type with id {args.sig.get()}")
        else:
            logger.warning("Could not get sig (signal) field in sigaction()")

        # Check if there is already a signal catching function with the received function pointer.
        if func_name in SignalSyscalls.signal_catching_functions:
            if catching_signal != None:
                SignalSyscalls.signal_catching_functions[func_name].catching_signals.add(catching_signal)
            return state

        # Create new signal catching function.
        new_scf = SignalCatchingFunc(entry_abb=graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name)),
                                     function=func_name,
                                     catching_signals=set({catching_signal}) if catching_signal != None else set(),
                                     name=f"{func_name}()"
        )
        SignalSyscalls.signal_catching_functions[func_name] = new_scf
        return register_instance(new_scf, new_scf.name, graph, abb, state)