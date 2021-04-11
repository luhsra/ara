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
#_POSIX_DEBUG_LOG_LEVEL = LEVEL["debug"]
_POSIX_DEBUG_LOG_LEVEL = LEVEL["info"]

def debug_log(msg, *args, **kwargs):
    """Logs a debug message in the POSIX package"""
    logger.log(_POSIX_DEBUG_LOG_LEVEL, msg, *args, **kwargs)

@dataclass
class POSIXInstance(object):
    cfg: CFG            # the control flow graph
    abb: Vertex         # the ABB of the system call which created this instance
    call_path: Vertex   # call node within the call graph of the system call which created this instance [state.call_path]
    name: str
    vidx: Vertex        # vertex for this instance in the InstanceGraph of the state which created this instance [state.instances.add_vertex()]

def add_initial_instance_to_state(state, instance, label: str):
    v = state.instances.add_vertex()
    state.instances.vp.label[v] = label
    state.instances.vp.obj[v] = instance
    assign_id(state.instances, v)
    debug_log(type(state))

    instances = state.instances
    instances.vp.branch[v] = False
    instances.vp.loop[v] = False
    instances.vp.recursive[v] = False
    instances.vp.after_scheduler[v] = False
    instances.vp.usually_taken[v] = True
    instances.vp.unique[v] = True
    instances.vp.soc[v] = 0
    instances.vp.llvm_soc[v] = 0
    instances.vp.file[v] = 0
    instances.vp.line[v] = 0


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

def add_normal_cfg(cfg, abb, state):
    for oedge in cfg.vertex(abb).out_edges():
        if cfg.ep.type[oedge] == _graph.CFType.lcf:
            state.next_abbs.append(oedge.target())
