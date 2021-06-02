"""This module contains useful functions and classes for all POSIX modules in this package."""

import html
from dataclasses import dataclass, field
from abc import ABC, abstractmethod
from graph_tool import Vertex
from ara.util import get_logger, LEVEL
from ara.graph.graph import CFG
import ara.graph as _graph
from ..os_util import syscall, assign_id, Arg

logger = get_logger("POSIX")

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

def get_musl_weak_alias(syscall: str) -> str:
    """Returns the musl libc weak alias name version of the syscall name.

    For example: "pthread_create" -> "__pthread_create"
    For all names which start with a '_' there is no weak alias version.
    In this case this function will return None.
    """
    return "__" + syscall if syscall[0] != '_' else None

@dataclass
class POSIXInstance(ABC):
    #cfg: CFG            = field(init=False)     # the control flow graph
    #abb: Vertex         = field(init=False)     # the ABB of the system call which created this instance
    #call_path: Vertex   = field(init=False)     # call node within the call graph of the system call which created this instance [state.call_path]
    #vidx: Vertex        = field(init=False)     # vertex for this instance in the InstanceGraph of the state which created this instance [state.instances.add_vertex()]
    name: str   # The name of the instance. This is not an id for the instance.

    @property
    @abstractmethod
    def wanted_attrs(self) -> list:     # list[str]
        """Return all attributes as strings that are relevent to be printed as dot.

        This attribute will influence as_dot() and get_maximal_id().
        """

    @property
    @abstractmethod
    def dot_appearance(self) -> dict:   # dict[str, str]
        """Return dot rendering properties.

        Make sure to provide the following properties:
            "shape": e.g. "box"
            "fillcolor": e.g. "#6fbf87"
            "style": e.g. "filled"
        """

    def as_dot(self):
        attrs = [(x, str(getattr(self, x))) for x in self.wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                    for k, v in attrs])

        self.dot_appearance["sublabel"] = sublabel
        return self.dot_appearance

    def get_maximal_id(self):
        max_id_components = list(map(lambda obj_name: getattr(self, obj_name), self.wanted_attrs))
        max_id_components.append(self.__class__.__name__)
        return '.'.join(map(str, max_id_components))

class IDInstance(POSIXInstance):
    """Use this base class instead of POSIXInstance if you can not generate a meaningful name for the instance.
    
    This class will auto generate a name and a numeric id called num_id.
    The name is based on the numeric id and the name of the derived class.
    It is still possible to assign a name to the instance. The auto name will only applied if name == None.
    Make sure to call the __init__() of this class with a __post_init__() method.
    """
    _id_counter = 0
    def __init__(self):
        self.num_id = self.__class__._id_counter
        self.__class__._id_counter += 1
        if not self.name:
            self.name = f"{self.__class__.__name__} {self.num_id}"


def do_not_interpret_syscall(graph, abb, state):
    """Call this function via 'return do_not_interpret_syscall(graph, abb, state)' if the syscall should not be interpreted in POSIX.interpret()."""
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
    is_usually_taken = b(state.usually_taken, usually_taken)

    instances.vp.branch[v] = in_branch
    instances.vp.loop[v] = in_loop
    # If you are interested in the recursive field make sure that the option no_recursive_funcs is not set for RecursiveFunctions step.
    instances.vp.recursive[v] = is_recursive
    instances.vp.after_scheduler[v] = True # POSIX is dynamic. The scheduler is always on.
    instances.vp.usually_taken[v] = is_usually_taken
    instances.vp.unique[v] = not (is_recursive or in_branch or in_loop)
    instances.vp.soc[v] = abb
    instances.vp.llvm_soc[v] = cfg.vp.llvm_link[cfg.get_single_bb(abb)]
    instances.vp.file[v] = cfg.vp.file[abb]
    instances.vp.line[v] = cfg.vp.line[abb]


def register_instance(new_instance: POSIXInstance, label: str, graph, abb, state, va):

    logger.debug(f"Create new instance with label: {label}")
    state = state.copy()
    v = state.instances.add_vertex()
    state.instances.vp.label[v] = label
    handle_soc(state, v, graph.cfg, abb)

    #new_instance.cfg = graph.cfg
    #new_instance.abb = abb
    #new_instance.call_path = state.call_path
    #new_instance.vidx = v
    assert hasattr(new_instance, "name"), f"New instance of type {type(new_instance)} has no name."
    state.instances.vp.obj[v] = new_instance
    assign_id(state.instances, v)

    return state

def add_normal_cfg(cfg, abb, state):
    for oedge in cfg.vertex(abb).out_edges():
        if cfg.ep.type[oedge] == _graph.CFType.lcf:
            state.next_abbs.append(oedge.target())
