"""This module contains useful functions and classes for all POSIX modules in this package."""

import html
import pyllco
from dataclasses import dataclass, field
from typing import Callable
from abc import ABC, abstractmethod
from graph_tool import Vertex
from ara.graph import SyscallCategory
from ara.util import get_logger, LEVEL
from ..os_util import assign_id

logger = get_logger("POSIX")

# A set of all messages created via no_double_output().
# We do not want to repeat messages of a second call to no_double_output() with the same message.
_already_done_messages = set()

def no_double_output(cust_logger, log_level: int, msg: str):
    """Issues a message with log_level only once in runtime. Using the custom logger."""
    identifier = str(log_level) + msg
    if not identifier in _already_done_messages:
        cust_logger.log(log_level, msg)
        _already_done_messages.add(identifier)

def no_double_warning(msg: str):
    """Issues a warning only once in runtime."""
    no_double_output(logger, LEVEL["warning"], msg)

def get_musl_weak_alias(syscall: str) -> str:
    """Returns the musl libc weak alias name version of the syscall name.

    For example: "pthread_create" -> "__pthread_create"
    For all names which start with a '_' there is no weak alias version.
    In this case this function will return None.
    """
    return "__" + syscall if syscall[0] != '_' else None

# The new ValueAnalyzer Interface and some algorithms in sse.py requires system instances to be hashable.
# The default hash method for dataclasses is based on the fields in the class.
# A change in the instance will result in an change of the hash. 
# We do not want this. We want both, hashable and mutable instances.
# Therefore we provide an custom hash based on the id. This id is always unique for an instance.
@dataclass(eq = False)
class POSIXInstance(ABC):
    name: str                           # The name of the instance. This is not an id for the instance.
    vertex: Vertex = field(init=False)  # vertex for this instance in the InstanceGraph.

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

    def __hash__(self):
        return id(self)

class IDInstance(POSIXInstance):
    """Use this base class instead of POSIXInstance if you can not generate a meaningful name for the instance.
    
    This class will auto generate a name and a numeric id called num_id.
    The name is based on the numeric id and the name of the derived class.
    It is still possible to assign a name to the instance. The auto name will only applied if name == None.
    Make sure to call the __init__() method of this class in a __post_init__() method.
    """
    _id_counter = 0
    def __init__(self):
        self.num_id = self.__class__._id_counter
        self.__class__._id_counter += 1
        if not self.name:
            self.name = f"{self.__class__.__name__} {self.num_id}"


class PosixOptions:
    """This static class contains the values of all OS Model options.
    
    All options can be set as step options for POSIXInit.
    """
    enable_static_init_detection: bool = None
    enable_musl_syscalls: bool = None

class MainThread:
    """This static class wraps the MainThread instance.
    
    Call MainThread.get() to get the MainThread.
    """
    main_thread = None

    @classmethod
    def get(cls) -> POSIXInstance:
        return cls.main_thread

    @classmethod
    def set(cls, main_thread: POSIXInstance):
        cls.main_thread = main_thread

class CurrentSyscallCategories:
    """This static class wraps the current syscall categories that are analyzed in the current step.
    
    Call CurrentSyscallCategories.get() to get the current categories as set.
    """
    current_syscall_cats: set = None

    @classmethod
    def get(cls) -> set:
        return cls.current_syscall_cats

    @classmethod
    def set(cls, syscall_cats: set):
        cls.current_syscall_cats = syscall_cats

class StaticInitSyscalls:
    """This static class contains all static initializer syscalls.
    
    Add all static initializer syscalls via add_comms() to register them.
    POSIXInit will optimize them if static initializer detection is disabled.
    """
    static_init_syscalls = list()

    @classmethod
    def get_comms(cls) -> list:
        """Get a list of all static initializer syscalls."""
        return cls.static_init_syscalls

    @classmethod
    def add_comms(cls, comms: list):
        """Adds all syscalls in comms to the list of static initializer syscalls."""
        cls.static_init_syscalls.extend(comms)

def do_not_interpret_syscall(graph, abb, state):
    """Call this function via 'return do_not_interpret_syscall(graph, abb, state)' if the syscall should not be interpreted in POSIX.interpret()."""
    # Add your custom do_not_interpret code here.
    return state

def handle_soc(state, v, cfg, abb):
    instances = state.instances
    instances.vp.branch[v] = state.branch
    instances.vp.loop[v] = state.loop
    # If you are interested in the recursive field make sure that the option no_recursive_funcs is not set for RecursiveFunctions step.
    instances.vp.recursive[v] = state.recursive
    instances.vp.after_scheduler[v] = True # POSIX is dynamic. The scheduler is always on.
    instances.vp.usually_taken[v] = state.usually_taken
    instances.vp.unique[v] = not (state.recursive or state.branch or state.loop)
    instances.vp.soc[v] = abb
    instances.vp.llvm_soc[v] = cfg.vp.llvm_link[cfg.get_single_bb(abb)]
    instances.vp.file[v] = cfg.vp.file[abb]
    instances.vp.line[v] = cfg.vp.line[abb]

def handle_static_soc(instances, v):
    instances.vp.branch[v] = False
    instances.vp.loop[v] = False
    instances.vp.recursive[v] = False
    instances.vp.after_scheduler[v] = False
    instances.vp.usually_taken[v] = True
    instances.vp.unique[v] = True

    # The following values are not applicable
    instances.vp.soc[v] = 0
    instances.vp.llvm_soc[v] = 0
    instances.vp.file[v] = "N/A"
    instances.vp.line[v] = 0

def register_instance(new_instance: POSIXInstance, label: str, graph, abb, state, is_static=False):
    """Register the POSIX Instance <new_instance> in the Instance Graph."""

    logger.debug(f"Create new instance with label: {label}")
    v = state.instances.add_vertex()
    state.instances.vp.label[v] = label
    if is_static:
        handle_static_soc(state.instances, v)
    else:
        handle_soc(state, v, graph.cfg, abb)

    new_instance.vertex = v
    assert hasattr(new_instance, "name"), f"New instance of type {type(new_instance)} has no name."
    state.instances.vp.obj[v] = new_instance
    assign_id(state.instances, v)

    return state

def get_running_thread(state) -> POSIXInstance:
    """Get the currently running thread as Instance object."""
    return state.instances.vp.obj[state.running] if state.running != None else MainThread.get()

def add_interaction_edge(instances, source: POSIXInstance, dest: POSIXInstance, label: str):
    """Add an edge from <source> to <dest> in the Instance Graph <instances>."""
    edge = instances.add_edge(source.vertex, dest.vertex)
    instances.ep.label[edge] = label

def add_edge_from_self_to(state, to: POSIXInstance, label: str):
    """Add an edge from the current thread to <to>."""
    running_thread = get_running_thread(state)
    if not isinstance(to, POSIXInstance):
        logger.warning(f"Could not create edge from \"{running_thread.name}\" to \"{to}\" with label: \"{label}\"! This is mostly an issue with the ValueAnalyzer.")
        return state
    logger.debug(f"Create new edge from \"{running_thread.name}\" to \"{to.name}\" with label: \"{label}\"")
    add_interaction_edge(state.instances, running_thread, to, label)
    return state

def add_self_edge(state, label: str):
    """Add an edge from the current thread to the current thread."""
    running_thread = get_running_thread(state)
    logger.debug(f"Create new self edge for \"{running_thread.name}\" with label: \"{label}\"")
    add_interaction_edge(state.instances, running_thread, running_thread, label)
    return state

def assign_instance_to_return_value(va, abb, call_path, instance: POSIXInstance) -> bool:
    """Calls va.assign_system_object() with proper error handling.
    
    Returns True on success. False if an error occurred in ValueAnalyzer.
    """
    from ara.steps import get_native_component # avoid dependency conflicts, therefore import dynamically
    ValuesUnknown = get_native_component("ValuesUnknown")
    try:
        va.assign_system_object(abb, instance, callpath=call_path)
        return True
    except ValuesUnknown as va_unknown_exc:
        logger.warning(f"ValueAnalyzer could not assign Instance {instance} to return value. Exception: \"{va_unknown_exc}\"")
        return False

def static_init_detection(create_static_inst: Callable, comm_func: Callable, inst_obj, graph, abb, state, args, va):
    """Handles the static init detection (e.g. detection of PTHREAD_MUTEX_INITIALIZER).
    
    Call this function in all comm syscalls related to an instance that can be created statically.
    Make sure the calling syscall is of both categories {create, comm}.
    Make sure the calling syscall also accepts the type pyllco.GlobalVariable as instance argument.

    Arguments:
    create_static_inst              -- A function that creates a new instance. Signature: create_static_inst(graph, abb, state, args, va, register_instance).
                                       Use the delivered register_instance() function to register the new instance.
    comm_func                       -- A function that handles the communication (e.g. create a new edge). Signature: comm_func(graph, abb, state, args, va).
    inst_obj                        -- The instance object in args.
    (graph, abb, state, args, va)   -- The signature for syscalls. Just put your local values for this variables into this function.

    Returns the new state object so that you can do: return static_init_detection(...).
    Make sure to provide the calling syscall also globally to the function StaticInitSyscalls.add_comms().
    Via this way your syscall is registered as static initializer syscall.
    Note that only comm syscalls can be static initializer syscalls.
    """

    # If Category "create": Create a new object if inst_obj is a pyllco.GlobalVariable (e.g. args.mutex == PTHREAD_MUTEX_INITIALIZER)
    if SyscallCategory.create in CurrentSyscallCategories.get():
        if PosixOptions.enable_static_init_detection and type(inst_obj) == pyllco.GlobalVariable:
            state = create_static_inst(graph, abb, state, args, va,
                                            lambda new_instance, label, graph, abb, state:
                                                register_instance(new_instance, label, graph, abb, state, is_static=True))

    # If Category "comm": Handle the normal edge creation by calling comm_part.
    if SyscallCategory.comm in CurrentSyscallCategories.get():
        if type(inst_obj) != pyllco.GlobalVariable or not PosixOptions.enable_static_init_detection:
            state = comm_func(graph, abb, state, args, va)
        else:
            logger.warning("static_init_detection(): inst_obj is of type pyllco.GlobalVariable. Probably there was an error in the PTHREAD_*_INITIALIZER detection.")

    return state
