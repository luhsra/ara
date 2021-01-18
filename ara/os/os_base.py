class OSBase:
    config = {}

    @classmethod
    def get_name(cls):
        """Return the name of the Operating System."""
        return cls.__name__

    @classmethod
    def is_syscall(cls, function_name):
        """Return whether a function name is a system call of this OS."""
        if hasattr(cls, function_name):
            return hasattr(getattr(cls, function_name), 'syscall')
        return False

    @classmethod
    def detected_syscalls(cls):
        """Return a dict of detected system calls.

        The key is the syscall name, the value the syscall interpretation
        function.
        """
        names = [x for x in dir(cls) if hasattr(getattr(cls, x), 'syscall')]
        syscalls = []
        for name in names:
            syscall = getattr(cls, name)
            syscalls.append((name, syscall))
            for alias in syscall.aliases:
                syscalls.append((alias, syscall))
        sys_dict = dict(syscalls)
        assert len(sys_dict) == len(syscalls), "Ambigoues syscall name"
        return sys_dict
