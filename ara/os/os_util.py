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
