import os.path
import pyllco

from ara.graph import SyscallCategory as _SyscallCategory, SigType as _SigType

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



def get_argument(cfg, abb, call_path, num, raw=False, raw_value=False, can_fail=True, ty=None):
    """Retrieve an interpreted argument.

    Arguments:
    cfg        -- control flow graph
    abb        -- ABB in this graph
    call_path  -- call path
    num        -- the number of the argument

    Keyword arguments:
    raw       -- return the uninterpreted argument
    raw_value -- return the uninterpreted llvm value. Implies raw=False.
    can_fail  -- return None if an argument does not contain a value,
                 throw an EmptyArgumentException or pyllco.InvalidValue
                 otherwise. Implies raw=False.
    ty        -- check for this specific type. This automatically implies
                 raw=False, raw_value=True, can_fail=False. Throw an
                 UnsuitableArgumentException, if the type does not fit.
    """
    # constraints
    if ty is not None:
        raw=False
        raw_value=True
        can_fail=False

    arg = cfg.vp.arguments[abb][num]

    if raw:
        return arg

    if len(arg) == 0:
        if can_fail:
            return None
        else:
            raise EmptyArgumentException("Argument is empty.")

    try:
        value = arg.get_value(key=call_path, raw=raw_value)
    except pyllco.InvalidValue as iv:
        if can_fail:
            return None
        else:
            raise iv
    if ty is not None and not isinstance(value, ty):
        raise UnsuitableArgumentException(f"Expecting {ty} but got {type(value)}")

    return value


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
