from ara.graph import SyscallCategory as _SyscallCategory

def syscall(*args):
    def wrap(func, categories=None):
        func.syscall = True
        if categories is None:
            func.categories = set(args)
        else:
            func.categories = categories
        func = staticmethod(func)
        return func

    if len(args) == 1 and callable(args[0]):
        func = wrap(args[0], set((_SyscallCategory.undefined, )))
        return func
    return wrap
