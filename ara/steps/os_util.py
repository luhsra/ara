import enum

class SyscallCategory(enum.Enum):
    UNDEFINED = 0
    ALL = 1
    CREATE = 2 # creates an instance
    COMM = 3   # set up a communication between multiple instances


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
        func = wrap(args[0], set((SyscallCategory.UNDEFINED, )))
        return func
    return wrap
