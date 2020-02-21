def syscall(func):
    func.syscall = True
    func = staticmethod(func)
    return func
