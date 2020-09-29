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
                 throw an EmptyArgumentException otherwise. Implies raw=False.
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

    value = arg.get_value(key=call_path, raw=raw_value)
    if ty is not None and not isinstance(value, ty):
        raise UnsuitableArgumentException(f"Expecting {ty} but got {type(value)}")

    return value
