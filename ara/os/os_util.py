import os.path
import typing
import dataclasses
import pyllco

from ara.graph import SyscallCategory as _SyscallCategory, SigType as _SigType
from ara.graph import CFType as _CFType

def syscall(*args, categories=None, signature=None):
    if categories is None:
        categories = {_SyscallCategory.undefined}
    if signature is None:
        signature = tuple()
    outer_categories = categories
    outer_signature = signature

    def wrap(func, categories=outer_categories, signature=outer_signature):
        func.syscall = True
        func.categories = categories
        func.signature = signature
        func = staticmethod(func)
        return func

    if len(args) == 1 and callable(args[0]):
        func = wrap(args[0], categories, signature)
        return func
    return wrap


class EmptyArgumentException(Exception):
    """The argument is empty, aka contains no values."""


class UnsuitableArgumentException(Exception):
    """The argument contains a value that is not suitable."""


@dataclasses.dataclass
class LLVMRawValue:
    value: typing.Any
    attrs: pyllco.AttributeSet


def is_llvm_type(ty):
    return getattr(ty, '__module__', None) == pyllco.__name__


def get_argument(value, arg):
    """Retrieve an interpreted argument.

    Arguments:
    value      -- LLVM raw value
    attr       -- LLVM attributes
    """
    if is_llvm_type(arg.ty):
        print("TY")
        assert type(value.value) == arg.ty
        return value.value
    if arg.raw_value:
        if arg.hint == _SigType.instance:
            return value.value
        else:
            return value
    if value is None:
        return None
    if isinstance(value.value, pyllco.ConstantPointerNull):
        return "nullptr"
    if isinstance(value.value, pyllco.Constant):
        try:
            return value.value.get(attrs=value.attrs)
        except pyllco.InvalidValue:
            return None
    raise UnsuitableArgumentException("Value cannot be interpreted as Python value")


@dataclasses.dataclass
class Argument:
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


class SysCall:
    def __init__(self, func_body, categories, signature, custom_control_flow):
        # visible attributes
        self.syscall = True
        self.categories = categories
        self._func = func_body
        self._signature = signature
        self._ccf = custom_control_flow

    def __get__(self, obj, objtype=None):
        """Simulate bound descriptor access. However a systemcall acts like a
        static method so just return itself here."""
        return self

    def __call__(self, graph, abb, state):
        if _SyscallCategory.undefined in self.categories:
            raise NotImplementedError(f"{self._func.__name__} is only a stub.")

        cfg = graph.cfg

        # avoid dependency conflicts, therefore import dynamically
        from ara.steps import get_native_component
        ValueAnalyzer = get_native_component("ValueAnalyzer")

        va = ValueAnalyzer(graph)

        # copy the original state
        state = state.copy()

        fields = []
        values = []

        # retrieve arguments
        for idx, arg in enumerate(self._signature):
            hint = arg.hint
            if arg.hint == _SigType.instance:
                hint = _SigType.symbol
            value, attrs = va.get_argument_value(abb, idx,
                                                callpath=state.call_path,
                                                hint=hint)

            value = LLVMRawValue(value=value, attrs=attrs)
            values.append(get_argument(value, arg))
            fields.append((arg.name, arg.ty))

        # repack into dataclass
        Arguments = dataclasses.make_dataclass('Arguments', fields)
        args = Arguments(*values)

        # syscall specific handling
        new_state = self._func(graph, abb, state, args, va)

        # write instances back for SOCs if they are handled via argument
        # pointers
        if _SyscallCategory.create in self.categories:
            for idx, arg in enumerate(self._signature):
                if arg.hint != _SigType.instance:
                    continue
                sys_obj = getattr(args, dataclasses.fields(args)[idx].name)
                va.assign_system_object(abb, sys_obj,
                                        callpath=state.call_path,
                                        argument_nr=idx)

        # add standard control flow successors if wanted
        new_state.next_abbs = []
        if not self._ccf:
            for oedge in cfg.vertex(abb).out_edges():
                if cfg.ep.type[oedge] == _CFType.lcf:
                    new_state.next_abbs.append(oedge.target())

        return new_state


def syscall2(*args, categories=None, signature=None, custom_control_flow=False):
    if categories is None:
        categories = {_SyscallCategory.undefined}
    if signature is None:
        signature = []

    outer_categories = categories
    outer_signature = signature
    outer_ccf = custom_control_flow

    def wrap(func, categories=outer_categories, signature=outer_signature,
             custom_control_flow=outer_ccf):
        wrapper = SysCall(func, categories, signature, custom_control_flow)
        return wrapper

    if len(args) == 1 and callable(args[0]):
        # decorator was called without keyword arguments, first argument is the
        # function, return a replacement function for the decorated function
        func = wrap(args[0], categories, signature, custom_control_flow)
        return func

    # decorator was called with keyword arguments, the returned function is
    # called with the decorated function and its result replaces the decorated
    # function
    return wrap


def get_return_value(cfg, abb, call_path):
    """Retrieve the return value.

    Arguments:
    cfg        -- control flow graph
    abb        -- ABB in this graph
    call_path  -- call path
    """
    handler = cfg.vp.arguments[abb].get_return_value()
    if handler is None:
        return None
    try:
        return handler.get_value(key=call_path, raw=True)
    except IndexError:
        return None



def assign_id(instances, instance):
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
