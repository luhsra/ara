import enum

class SyscallCategory(enum.Enum):
    UNDEFINED = 0
    ALL = 1
    CREATE = 2
    COMMUNICATION = 3


def syscall(*args):
    def wrap(func):
        func.syscall = True
        func.categories = set(args)
        func = staticmethod(func)
        return func

    if len(args) == 1 and callable(args[0]):
        func = wrap(args[0])
        func.categories = set((SyscallCategory.UNDEFINED, ))
        return func
    return wrap
