from __future__ import annotations # Activate Postponed Evaluation of Annotations

from .os_util import syscall, assign_id, Arg
from .os_base import OSBase

import pyllco
import functools
import html

import ara.graph as _graph
from ara.graph import CallPath, SyscallCategory, SigType
from ara.graph.graph import CFG
from ara.util import get_logger
from ara.steps.util import current_step
from graph_tool import Vertex

from queue import Queue
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict

logger = get_logger("POSIX")

# TODO: Add task in sse.py

@dataclass
class POSIXInstance(object):
    cfg: CFG            # the control flow graph
    abb: Vertex         # the ABB of the system call which created this instance
    call_path: Vertex   # call node within the call graph of the system call which created this instance [state.call_path]
    name: str
    vidx: Vertex        # vertex for this instance in the InstanceGraph of the state which created this instance [state.instances.add_vertex()]

@dataclass
class User(POSIXInstance):
    userID: int
    init_group: Group
    init_working_dir: str
    init_user_program: str

@dataclass
class Group(POSIXInstance):
    groupID: int
    allowed_users: list[User]

class FileType(Enum):
    REGULAR = 0
    DIRECTORY = 1
    # TODO: Add all file types

@dataclass
class File(POSIXInstance):
    absolute_pathname: str
    file_type: FileType
    # TODO: Add further file mode data

@dataclass
class FileDescriptor(POSIXInstance):
    value: int
    connectedToFile: Optional[File]

@dataclass
class Locale(POSIXInstance):
    pass    # Save only the name for now.
            # The POSIX locale is called "POSIX" or "C".
            # The default locale is implementation defined.

@dataclass
class Terminal(POSIXInstance):
    foreground_process_group: Optional[ProcessGroup]
    canonical_mode_input_processing: bool # If true the terminal read in lines.

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

@dataclass
class Signal(POSIXInstance):
    signal_type: SignalType
    value: Any # TODO: change this type
    destination: Union[Process, Thread]

class _SignalAction_DFL_IGN(Enum):
    SIG_DFL = 0     # Default signal action
    SIG_IGN = 1     # Ignore the signal

_SignalAction_Function = Any # TODO: determine type of a signal handler function

SignalAction = Union[_SignalAction_DFL_IGN, _SignalAction_Function]

@dataclass
class SignalMask(object):
    pass # TODO: define

@dataclass
class Session(POSIXInstance):
    process_groups: list[ProcessGroup] # TODO: Init to []
    session_leader: Process
    controlling_terminal: Optional[Terminal]
    # TODO: init this class

@dataclass
class ProcessGroup(POSIXInstance):
    process_group_ID: int = field(init=False)
    process_group_leader: Process
    session_membership: Session
    processes: list[Process] = field(init=False)

    def __post_init__(self):
        self.process_group_ID = self.process_group_leader
        self.processes = list(self.process_group_leader)

@dataclass
class Process(POSIXInstance):
    process_ID: int
    parent_process: Process
    process_group: ProcessGroup
    #session_membership: Session # TODO: investigate: Can a process change its session membership without changing the process group
    real_user: User
    effective_user: User
    saved_user: User
    real_group: Group
    effective_group: Group
    saved_group: Group
    supplementary_groups: list[Group]
    working_dir: str
    root_dir: str
    file_mode_creation_mask: Any # TODO: determine type of this field
    file_descriptors: list[FileDescriptor] # TODO: Init to []
    global_locale: Locale
    controlling_terminal: Optional[Terminal]
    pending_signals: Queue[Signal] # TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    threads: list[Thread] # TODO: Init to []
    isLiving: bool = True

    def as_dot(self):
        pass

@dataclass
class Thread(POSIXInstance):
    entry_abb: Any
    function: Any
    threadID: int
    priority: int
    sched_policy: str
    floating_point_env: Any # TODO: check type
    current_locale: Optional[Locale]
    signal_mask: SignalMask
    pending_signals: Queue[Signal] # TODO: Do all POSIX processes and threads have a signal queue? If yes how big is the queue?
    errno: int
    partOfProcess: Process

    def as_dot(self):
        wanted_attrs = ["name", "function", "priority"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                    for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#6fbf87",
            "style": "filled",
            "sublabel": sublabel
        }

    def get_maximal_id(self):
        # TODO: use a better max_id
        return '.'.join(map(str, ["Thread",
                                  self.name,
                                  self.function,
                                  self.priority,
                                 ]))

_id_ = 1

class POSIX(OSBase):

    @staticmethod
    def get_special_steps():
        return []

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        state.scheduler_on = True  # The Scheduler is always on in POSIX.

    @staticmethod
    def interpret(graph, abb, state, categories=SyscallCategory.every):
        """interprets a detected syscall"""

        cfg = graph.cfg
        logger.debug("interpret called")

        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall_function = getattr(POSIX, syscall)

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.every not in categories:
            sys_cat = syscall_function.categories
            if sys_cat | categories != sys_cat:
                # do not interpret this syscall
                state = state.copy()
                state.next_abbs = []
                POSIX.add_normal_cfg(cfg, abb, state)
                return state

        return getattr(POSIX, syscall)(graph, abb, state)

    def handle_soc(state, v, cfg, abb,
                   branch=None, loop=None, recursive=None, scheduler_on=None,
                   usually_taken=None):
        instances = state.instances

        def b(c1, c2):
            if c2 is None:
                return c1
            else:
                return c2

        in_branch = b(state.branch, branch)
        in_loop = b(state.loop, loop)
        is_recursive = b(state.recursive, recursive)
        logger.debug("scheduler " + str(state.scheduler_on)) # TODO: fix scheduler off issue
        after_sched = b(state.scheduler_on, scheduler_on)
        is_usually_taken = b(state.usually_taken, usually_taken)

        instances.vp.branch[v] = in_branch
        instances.vp.loop[v] = in_loop
        instances.vp.recursive[v] = is_recursive
        instances.vp.after_scheduler[v] = after_sched
        instances.vp.usually_taken[v] = is_usually_taken
        instances.vp.unique[v] = not (is_recursive or in_branch or in_loop)
        instances.vp.soc[v] = abb
        instances.vp.llvm_soc[v] = cfg.vp.llvm_link[cfg.get_single_bb(abb)]
        instances.vp.file[v] = cfg.vp.file[abb]
        instances.vp.line[v] = cfg.vp.line[abb]

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())


    ##############################################
    ###            --- Syscalls ---           ####


    @syscall(categories={SyscallCategory.create})
    def pause(graph, abb, state, args, va):
        logger.debug("found pause() syscall")

        print(type(graph.cfg))

        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Thread"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        POSIX.handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Thread(graph.cfg, abb=None, call_path=None, name="Test thread",
                                        vidx = v,
                                        entry_abb = None,
                                        function = None,
                                        threadID = 3,
                                        priority = 2,
                                        sched_policy = None,
                                        floating_point_env = None, # TODO: check type
                                        partOfTask = None
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg('fildes', hint=SigType.value),
                        Arg('buf', hint=SigType.symbol),
                        Arg('nbyte', hint=SigType.value)))
    def write(graph, abb, state, args, va):
        logger.debug("found write() syscall")
        global _id_
        _id_ += 1
        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Write"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        POSIX.handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Thread(graph.cfg, abb=None, call_path=None, name="Write_test_thread_" + str(_id_),
                                        vidx = v,
                                        entry_abb = None,
                                        function = None,
                                        threadID = 3,
                                        priority = 2,
                                        sched_policy = None,
                                        floating_point_env = None, # TODO: check type
                                        partOfTask = None,
                                        
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg('ptr', hint=SigType.symbol),
                        Arg('size', hint=SigType.value),
                        Arg('nitems', hint=SigType.value),
                        Arg('stream', hint=SigType.symbol)))
    def fwrite(graph, abb, state, args, va):
        logger.debug("found fwrite() syscall")
        global _id_
        _id_ += 1
        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "FWrite"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        POSIX.handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Thread(graph.cfg, abb=None, call_path=None, name="Write_test_thread_" + str(_id_),
                                        vidx = v,
                                        entry_abb = None,
                                        function = None,
                                        threadID = 3,
                                        priority = 2,
                                        sched_policy = None,
                                        floating_point_env = None, # TODO: check type
                                        partOfProcess = None
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state