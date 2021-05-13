class OSBase:
    
    config = {}
    _detected_syscalls: dict = None # Chaches the constant return value of detected_syscalls to improve performance.

    @classmethod
    def get_name(cls):
        """Return the name of the Operating System."""
        return cls.__name__

    @classmethod
    def detected_syscalls(cls):
        """Return a dict of detected system calls.

        The key is the syscall name, the value the syscall interpretation
        function.
        """
        if cls._detected_syscalls == None:
            names = [x for x in dir(cls) if hasattr(getattr(cls, x), 'syscall')]
            syscalls = []
            for name in names:
                syscall = getattr(cls, name)
                syscalls.append((name, syscall))
                for alias in syscall.aliases:
                    syscalls.append((alias, syscall))
            sys_dict = dict(syscalls)
            assert len(sys_dict) == len(syscalls), "Ambigoues syscall name"
            cls._detected_syscalls = sys_dict
        return cls._detected_syscalls

    @classmethod
    def is_syscall(cls, function_name):
        """Return whether a function name is a system call of this OS."""
        sys_dict = cls.detected_syscalls()
        return sys_dict.get(function_name, None) != None