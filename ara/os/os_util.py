import os.path
import typing
import dataclasses
import pyllco

from typing import Tuple

from ara.graph import SyscallCategory as _SyscallCategory, SigType as _SigType
from ara.graph import CFType as _CFType
from ara.util import get_logger

logger = get_logger("os_util.py")

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
    value -- LLVM raw value
    arg   -- Argument for this value
    """
    tys_allowed = arg.ty if isinstance(arg.ty, list) else [arg.ty]
    if not typing.Any in tys_allowed:
        if type(value.value) in tys_allowed:
            return value.value
        else:
            raise UnsuitableArgumentException(f"Value type {type(value.value)} does not match wanted type {arg.ty}.")
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
        except NotImplementedError as not_imp_error:
            raise UnsuitableArgumentException(f"NotImplementedError in pyllco: {not_imp_error}")
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
    optional: bool = False  # Set this to True if this argument is an optional argument for the syscall. 

    def get_hint(self) -> _SigType:
        return self._hint

    def set_hint(self, nhint: _SigType):
        if nhint in [_SigType.symbol, _SigType.instance]:
            self.raw_value = True
        self._hint = nhint
Argument.hint = property(Argument.get_hint, Argument.set_hint)
Arg = Argument


class SysCall:
    """Defines a system call.

    A system call consists of a several attributes:
    1. func_body: The function that is called to interpret this system call.
    2. categories: The categories of this system call.
    3. signature: The arguments of the system call.

    A Syscall objects acts like a (static) function and can be called.
    """

    def __init__(self, func_body, categories, signature, custom_control_flow, aliases, name, is_stub, signal_safe):
        # visible attributes
        self.syscall = True
        self.categories = categories
        self.aliases = aliases
        self._func = func_body
        self._signature = signature
        self._ccf = custom_control_flow
        self.name = name if name != None else func_body.__name__
        self.is_stub = is_stub
        self.signal_safe = signal_safe

    def get_name(self):
        """Returns the name of the syscall function."""
        return self.name

    def __get__(self, obj, objtype=None):
        """Simulate bound descriptor access. However a systemcall acts like a
        static method so just return itself here."""
        return self

    def __call__(self, graph, abb, state, sig_offest=0):
        """Interpret the system call.

        In principal, this function performs a value analysis, then calls
        func_body with the retrieved arguments, takes a new state back from
        func_body and follows the normal control flow patterns if wanted.

        In particular func_body is called with this arguments:
        graph -- the system graph
        abb   -- the ABB of the system call
        state -- the OS state
        args  -- A special args object, that contains the retrieved arguments.
                 It has as fields the attribute names that are given by the
                 Argument tuple.
        va    -- The value analyzer.

        Arguments:
        graph       -- the graph object
        abb         -- the abb ob the system call
        state       -- the OS state
        sig_offset  -- offset at which position the signature for the syscall function starts.
                       The default value is 0. Do not set this value unless you have at least 
                       one argument at the beginning that does not belong to the syscall signature.
        """

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
        ValuesUnknown = get_native_component("ValuesUnknown")
        for idx, arg in enumerate(self._signature):
            hint = arg.hint
            if arg.hint == _SigType.instance:
                hint = _SigType.symbol

            try:
                value, attrs, offset = va.get_argument_value(abb, idx + sig_offest,
                                                callpath=state.call_path,
                                                hint=hint)
                
                # TODO, ignore offset for now
                
            except ValuesUnknown as va_unknown_exc:
                # Do not throw warning if an optional argument is not applied:
                if not (arg.optional and str(va_unknown_exc) == "Argument number is too big."):
                    logger.warning(f"{self.name}(): ValueAnalyzer could not get argument {arg.name}. Exception: \"{va_unknown_exc}\"")
                values.append(None)
                fields.append(arg.name)
                continue

            llvm_value = LLVMRawValue(value=value, attrs=attrs)
            try:
                extracted_value = get_argument(llvm_value, arg)
            except UnsuitableArgumentException as uns_arg_exc:
                logger.warning(f"{self.name}(): Extracted value of argument {arg.name} has wrong type. Exception: \"{uns_arg_exc}\"")
                values.append(None)
                fields.append(arg.name)
                continue

            values.append(extracted_value)

            # identify the type of arg.ty that matched
            arg_single_ty = None
            if isinstance(arg.ty, list):
                if typing.Any in arg.ty:
                    arg_single_ty = typing.Any
                else:
                    arg_single_ty_index = arg.ty.index(type(extracted_value))
                    arg_single_ty = arg.ty[arg_single_ty_index]
            else:
                arg_single_ty = arg.ty

            fields.append((arg.name, arg_single_ty))

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
                # Only assign this instance if it is changed.
                if values[idx] != None and (not sys_obj is values[idx]):
                    try:
                        va.assign_system_object(abb, sys_obj,
                                                callpath=state.call_path,
                                                argument_nr=idx+sig_offest)
                    except ValuesUnknown as va_unknown_exc:
                        logger.warning(f"{self.name}(): ValueAnalyzer could not assign Instance to argument pointer {arg.name} in signature. Exception: \"{va_unknown_exc}\"") 

        # add standard control flow successors if wanted
        new_state.next_abbs = []
        if not self._ccf:
            for oedge in cfg.vertex(abb).out_edges():
                if cfg.ep.type[oedge] == _CFType.lcf:
                    new_state.next_abbs.append(oedge.target())

        return new_state


def syscall(*args,
            categories: Tuple[_SyscallCategory] = None,
            signature: Tuple[Argument] = None,
            custom_control_flow: bool = False,
            aliases: Tuple[str] = None,
            name: str = None,
            is_stub: bool = False,
            signal_safe: bool = False):
    """System call decorator. Changes a function into a system call.

    Returns a Syscall object. See it's documentation for more information.

    Arguments:
    categories          -- Categories of the system call
    signature           -- Specification of all system call arguments
    custom_control_flow -- Does this system call alter the control flow?
    aliases             -- Alias names of the system call.
    name                -- The name of the syscall. 
                           If not set, the name of the syscalls equals the name of the decorated function.
    is_stub             -- Set this to True if the syscall is not implemented and only a Stub.
    signal_safe         -- Is it safe to call the syscall in a signal handler? (default: False)
    """
    if categories is None:
        categories = {_SyscallCategory.undefined}
    if signature is None:
        signature = []
    if aliases is None:
        aliases = []

    outer_categories = categories
    outer_signature = signature
    outer_aliases = aliases
    outer_ccf = custom_control_flow
    outer_name = name
    outer_is_stub = is_stub
    outer_signal_safe = signal_safe

    def wrap(func, categories=outer_categories, signature=outer_signature,
             custom_control_flow=outer_ccf, aliases=outer_aliases, name=outer_name, 
             is_stub=outer_is_stub, signal_safe=outer_signal_safe):
        wrapper = SysCall(func, categories, signature, custom_control_flow, aliases, name, is_stub, signal_safe)
        return wrapper

    if len(args) == 1 and callable(args[0]):
        # decorator was called without keyword arguments, first argument is the
        # function, return a replacement function for the decorated function
        func = wrap(args[0], categories, signature, custom_control_flow, aliases, name, is_stub, signal_safe)
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
