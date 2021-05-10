""" This module contains useful functions and classes for all POSIX modules in this package.
"""

from dataclasses import dataclass, field
from graph_tool import Vertex
from ara.util import get_logger, LEVEL
from ara.graph.graph import CFG
import ara.graph as _graph
from ..os_util import syscall, assign_id, Arg

logger = get_logger("POSIX")

# Switch to set all POSIX debug logs to "info" 
# -> this highlights all POSIX debug messages. 
#_POSIX_DEBUG_LOG_LEVEL: int = LEVEL["debug"]
_POSIX_DEBUG_LOG_LEVEL: int = LEVEL["info"]

def debug_log(msg, *args, **kwargs):
    """ Logs a debug message in the POSIX package. """
    logger.log(_POSIX_DEBUG_LOG_LEVEL, msg, *args, **kwargs)

_already_done_messages = set()

def no_double_output(cust_logger, log_level: int, msg: str):
    """ Issues a message with log_level only once. Using the custom logger. """
    identifier = str(log_level) + msg
    if not identifier in _already_done_messages:
        cust_logger.log(log_level, msg)
        _already_done_messages.add(identifier)

def no_double_warning(msg: str):
    """ Issues a warning only once. """
    no_double_output(logger, LEVEL["warning"], msg)


def get_weak_alias(syscall: str) -> str:
    """ Returns the musl libc weak alias name version of the syscall name.

        For example: "pthread_create" -> "__pthread_create"

        For all names which start with a '_' there is no weak alias version.
        In this case this function will return None.
    """
    return "__" + syscall if syscall[0] != '_' else None

def is_weak_alias(syscall: str) -> bool:
    """ Returns True if the syscall name is a musl libc weak alias name. """
    return len(syscall) > 2 and syscall[0:2] == "__" and syscall[2] != '_'

def get_orig_of_weak_alias(weak_alias: str) -> str:
    """ Returns the original syscall name of the musl libc weak alias name weak_alias. 

        For example: "__pthread_create" -> "pthread_create"

        No check is performed whether weak_alias is a valid weak alias.
    """
    return weak_alias[2:]


@dataclass
class POSIXInstance(object):
    cfg: CFG            = field(init=False)     # the control flow graph
    abb: Vertex         = field(init=False)     # the ABB of the system call which created this instance
    call_path: Vertex   = field(init=False)     # call node within the call graph of the system call which created this instance [state.call_path]
    vidx: Vertex        = field(init=False)     # vertex for this instance in the InstanceGraph of the state which created this instance [state.instances.add_vertex()]
    name: str

def do_not_interpret_syscall(graph, abb, state):
    """ Call this function via 'return do_not_interpret_syscall(cfg, abb, state)' if the syscall should not be interpreted in POSIX.interpret(). """
    state = state.copy()
    state.next_abbs = []
    add_normal_cfg(graph.cfg, abb, state)
    return state

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
    debug_log("scheduler " + str(state.scheduler_on)) # TODO: fix scheduler off issue
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

def register_instance(new_instance: POSIXInstance, label: str, graph, abb, state, va):

    debug_log(f"Create new instance with label: {label}")
    state = state.copy()
    v = state.instances.add_vertex()
    state.instances.vp.label[v] = label
    handle_soc(state, v, graph.cfg, abb)

    new_instance.cfg=graph.cfg, 
    new_instance.abb=abb, 
    new_instance.call_path=state.call_path, 
    new_instance.vidx = v
    state.instances.vp.obj[v] = new_instance
    assign_id(state.instances, v)

    return state

def add_normal_cfg(cfg, abb, state):
    for oedge in cfg.vertex(abb).out_edges():
        if cfg.ep.type[oedge] == _graph.CFType.lcf:
            state.next_abbs.append(oedge.target())
