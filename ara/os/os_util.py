import os.path
import typing
import dataclasses
import html
import pyllco
from abc import ABC, abstractmethod

from typing import Tuple, Set

from ara.graph import SyscallCategory as _SyscallCategory, SigType as _SigType
from ara.graph import CFType as _CFType, CFGView as _CFGView

from .os_base import ExecState

# from ara.util import get_logger
# logger = get_logger("OS_UTIL")

class AutoDotInstance(ABC):
    """This class auto implements as_dot() and get_maximal_id().
    
    Instances that inherit from this class must implement wanted_attrs() and dot_appearance() to describe the dot printing."""
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

class UnsuitableArgumentException(Exception):
    """The argument contains a value that is not suitable."""


@dataclasses.dataclass(frozen=True)
class UnknownArgument:
    """A wrapper class to indicate that an argument cannot be found.

    The specific reason is stored in the exception.
    """
    exception: Exception
    value: pyllco.Value

    def __bool__(self):
        """Allow `if self:`"""
        return False

    def __str__(self):
        return "<unknown>"

@dataclasses.dataclass(frozen=True)
class DefaultArgument:
    """A wrapper class to indicate that an argument for an instance is not set.
    
    If value is not modified the encapsulated value is holding simply <default>.
    You can modify the default value as you wish.
    """
    def __init__(self, default_value="<default>"):
        self.value = default_value

    def __str__(self):
        return str(self.value)

@dataclasses.dataclass(frozen=True)
class LikelyArgument:
    """Represents the likely attribute.
    
    The likely attribute means:
    It is not sure that the variable has this value but it is likely.
    """
    def __init__(self, likely_value):
        self.value = likely_value

    def __str__(self):
        return f"<likely: {self.value}>"

def is_llvm_type(ty):
    return getattr(ty, '__module__', None) == pyllco.__name__


def get_argument(value, arg):
    """Retrieve an interpreted argument.

    Arguments:
    value -- LLVM raw value
    arg   -- Argument for this value
    """
    def check_ty(lvalue, ty):
        if ty == typing.Any or type(lvalue) == ty:
            return lvalue
        else:
            raise UnsuitableArgumentException(f"Value type {type(lvalue)} does not match wanted type {ty}.")

    if arg.ty != typing.Any and issubclass(arg.ty, pyllco.Value):
        return check_ty(value.value, arg.ty)
    if arg.ty != typing.Any and arg.hint == _SigType.instance:
        return check_ty(value.value, arg.ty)
    if arg.raw_value:
        return value
    if value is None:
        return None
    if isinstance(value.value, pyllco.ConstantPointerNull):
        check_ty(value.value, arg.ty)
        return "nullptr"
    if isinstance(value.value, pyllco.Constant):
        return check_ty(value.value.get(attrs=value.attrs), arg.ty)
    raise UnsuitableArgumentException("Value cannot be interpreted as Python value")


@dataclasses.dataclass
class Argument:
    """Class that captures an argument.

    name must be given. It is the field name of the args argument.
    If hint is SigType.symbol or SigType.instance raw_value is automatically
    true.
    """
    name: str
    ty: typing.Any = typing.Any
    # WARNING: raw_value must come _before_ hint, since hint modifies raw_value
    raw_value: bool = False
    hint: _SigType = _SigType.value

    def get_hint(self) -> _SigType:
        return self._hint

    def set_hint(self, nhint: _SigType):
        if nhint in [_SigType.symbol, _SigType.instance]:
            self.raw_value = True
        self._hint = nhint
Argument.hint = property(Argument.get_hint, Argument.set_hint)
Arg = Argument


def set_next_abb(state, cpu_id):
    """Set the CPU specified with cpu_id to the next abb.

    Note: Call this functions on syscalls only.
    """
    lcfg = _CFGView(state.cfg, efilt=state.cfg.ep.type.fa == _CFType.lcf)
    cpu = state.cpus[cpu_id]
    for idx, next_abb in enumerate(lcfg.vertex(cpu.abb).out_neighbors()):
        if idx > 1:
            raise RuntimeError("A syscall must not have more than one successor.")
        cpu.abb = next_abb
        cpu.exec_state = ExecState.from_abbtype(state.cfg.vp.type[next_abb])


class SysCall:
    """Defines a system call.

    A system call consists of a several attributes:
    1. func_body: The function that is called to interpret this system call.
    2. categories: The categories of this system call.
    3. signature: The arguments of the system call.

    A Syscall objects acts like a (static) function and can be called.
    """

    def __init__(self, func_body, categories, has_time, signature, custom_control_flow, aliases):
        # visible attributes
        self.syscall = True
        self.categories = categories
        self.has_time = has_time
        self._func = func_body
        self._signature = signature
        self._ccf = custom_control_flow
        self.aliases = aliases

    def __get__(self, obj, objtype=None):
        """Simulate bound descriptor access. However a systemcall acts like a
        static method so just return itself here."""
        return self

    def __call__(self, graph, state, cpu_id):
        """Interpret the system call.

        In principal, this function performs a value analysis, then calls
        func_body with the retrieved arguments, takes a new state back from
        func_body and follows the normal control flow patterns if wanted.

        In particular func_body is called with this arguments:
        graph  -- the system graph
        state  -- the OS state
        cpu_id -- the cpu_id that should be interpreted
        args   -- A special args object, that contains the retrieved arguments.
                  It has as fields the attribute names that are given by the
                  Argument tuple.
        va     -- The value analyzer.

        Arguments:
        graph  -- the graph object
        state  -- the OS state
        cpu_id -- the cpu_id that should be interpreted
        """

        if _SyscallCategory.undefined in self.categories:
            raise NotImplementedError(f"{self._func.__name__} is only a stub.")

        # avoid dependency conflicts, therefore import dynamically
        from ara.steps import get_native_component
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        ValuesUnknown = get_native_component("ValuesUnknown")

        va = ValueAnalyzer(graph)

        # copy the original state
        new_state = state.copy()

        fields = []
        values = []

        abb = new_state.cpus[cpu_id].abb
        callpath = new_state.cpus[cpu_id].call_path

        # retrieve arguments
        for idx, arg in enumerate(self._signature):
            fields.append((arg.name, arg.ty))
            hint = arg.hint
            if arg.hint == _SigType.instance:
                hint = _SigType.symbol
            try:
                result = va.get_argument_value(abb, idx,
                                               callpath=callpath,
                                               hint=hint)
            except ValuesUnknown as e:
                values.append(UnknownArgument(exception=e, value=None))
                continue
            try:
                values.append(get_argument(result, arg))
            except (UnsuitableArgumentException, pyllco.InvalidValue) as e:
                values.append(UnknownArgument(exception=e, value=result))

        # repack into dataclass
        Arguments = dataclasses.make_dataclass('Arguments', fields)
        args = Arguments(*values)

        # syscall specific handling
        new_states = self._func(graph, new_state, cpu_id, args, va)
        assert new_states is not None, "The syscall does not return anything."

        # few syscalls return multiple follow up states, so wrap everythin
        # into a list, if not already done
        if not isinstance(new_states, list):
            new_states = [new_states]

        # add standard control flow successors if wanted
        if not self._ccf:
            for new_state in new_states:
                set_next_abb(new_state, cpu_id)

        return new_states


def syscall(*args,
            categories: Tuple[_SyscallCategory] = None,
            signature: Tuple[Argument] = None,
            has_time: bool = False,
            custom_control_flow: bool = False,
            aliases: Set[str] = None):
    """System call decorator. Changes a function into a system call.

    Returns a Syscall object. See it's documentation for more information.

    Arguments:
    categories          -- Categories of the system call
    signature           -- Specification of all system call arguments
    has_time            -- The syscall handling needs time (e.g. taking a spinlock)
    custom_control_flow -- Does this system call alter the control flow?
    aliases             -- Alias names of the syscall
    """
    if categories is None:
        categories = {_SyscallCategory.undefined}
    if signature is None:
        signature = []
    if aliases is None:
        aliases = []

    outer_categories = categories
    outer_signature = signature
    outer_has_time = has_time
    outer_ccf = custom_control_flow
    outer_aliases = aliases

    def wrap(func, categories=outer_categories, signature=outer_signature,
             has_time=outer_has_time, custom_control_flow=outer_ccf, aliases=outer_aliases):
        wrapper = SysCall(func, categories, has_time, signature, custom_control_flow, aliases)
        return wrapper

    if len(args) == 1 and callable(args[0]):
        # decorator was called without keyword arguments, first argument is the
        # function, return a replacement function for the decorated function
        func = wrap(args[0], categories, signature, has_time, custom_control_flow, aliases)
        return func

    # decorator was called with keyword arguments, the returned function is
    # called with the decorated function and its result replaces the decorated
    # function
    return wrap


def assign_id(instances, instance):
    """Assign the shortest unique prefix ID to instance.

    This function uses instance.get_maximal_id() to assign the shortest unique
    prefix ID to this instance. If other instance IDs needs update they are
    updated.

    Example:
        Instance | ID  | Maximal ID
        ---------|-----|-----------
        I1       | 1.2 | 1.2.3.4
        I2       | 2   | 2.1.1
        I3       | 1.3 | 1.3.1.2.1

    Now Instance I4 with the maximal ID 1.3.1.1.1 should be added. The algorithm
    then assigns the ID 1.3.1.1 to I4 and 1.3.1.2 to I3.
    """
    other_ids = [(instances.vp.id[x].split('.'), x)
                 for x in instances.vertices()
                 if x != instance]

    target_id = instances.vp.obj[instance].get_maximal_id().split('.')

    longest = 0
    must_be_longer = None
    for other_id, inst in other_ids:
        prefix = os.path.commonprefix([target_id, other_id])
        assert prefix != target_id, "Cannot find a unique id."
        longest = max(longest, len(prefix))
        if len(prefix) == len(other_id):
            assert must_be_longer is None, "Something went wrong."
            must_be_longer = inst

    if must_be_longer:
        other_id = instances.vp.obj[must_be_longer].get_maximal_id().split('.')
        prefix = os.path.commonprefix([target_id, other_id])
        assert prefix != target_id and prefix != other_id, "Cannot find a unique id."
        longest = len(prefix)
        instances.vp.id[must_be_longer] = '.'.join(other_id[:longest+1])

    instances.vp.id[instance] = '.'.join(target_id[:longest+1])


def find_return_value(abb, callpath, va):
    """Try to retrieve the best possible return value.

    The function first get the raw return value (the next store) and try to
    follow it back to the original value.

    Arguments:
    abb      -- The call instruction which return value should be retrieved.
    callpath -- The call context.
    va.      -- A ValueAnalyzer instance.

    Returns a ValueAnalyzerResult with empty attrs.
    """
    from ara.steps import get_native_component
    ValuesUnknown = get_native_component("ValuesUnknown")
    ValueAnalyzerResult = get_native_component("ValueAnalyzerResult")

    ret_val = va.get_return_value(abb, callpath=callpath)
    try:
        return va.get_memory_value(ret_val, callpath=callpath)
    except ValuesUnknown:
        return ValueAnalyzerResult(ret_val, [], None, callpath)


def connect_instances(instance_graph, src, tgt, abb, label, ty=None):
    src = instance_graph.vertex(src)
    tgt = instance_graph.vertex(tgt)
    existing = instance_graph.edge(src, tgt)
    if existing and instance_graph.ep.syscall[existing] == abb:
        return

    e = instance_graph.add_edge(src, tgt)
    instance_graph.ep.syscall[e] = abb
    instance_graph.ep.label[e] = label
    if ty:
        instance_graph.ep.type[e] = ty


def connect_from_here(state, cpu_id, tgt, label, ty=None):
    cpu = state.cpus[cpu_id]
    connect_instances(state.instances, cpu.control_instance, tgt,
                      cpu.abb, label, ty=ty)

def add_self_edge(state, cpu_id, label, ty=None):
    cpu = state.cpus[cpu_id]
    connect_from_here(state, cpu_id, cpu.control_instance, label, ty)

def find_instance_node(instances, obj):
    for ins in instances.vertices():
        if instances.vp.obj[ins] is obj:
            return ins
    raise RuntimeError("Instance could not be found.")
