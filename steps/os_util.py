def syscall(func):
    func = staticmethod(func)
    func.syscall = True
    return func
