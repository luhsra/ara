
class SyscallCount:
    """This class can be used to count the occurrence of syscalls.

    Aliases are handled automatically.
    Use print_stats() to display all counted syscalls.
    """

    _enabled = False
    _syscall_count_state: dict = {}

    @classmethod
    def enable(cls):
        """Enable this counter."""
        cls._enabled = True

    @classmethod
    def direct_add_syscall(cls, syscall: str):
        """Increment counter for syscall without doing alias handling.
        
        Does nothing if this syscall counter is not activated.
        """
        if not cls._enabled:
            return
        counter: int = cls._syscall_count_state.setdefault(syscall, 0)
        counter += 1
        cls._syscall_count_state[syscall] = counter

    @classmethod
    def add_syscall(cls, os, syscall: str):
        """Increment counter for syscall.
        
        Make sure to provide the current OS model with the os argument.
        Does nothing if this syscall counter is not activated.
        """
        if not cls._enabled:
            return
        syscall = os.detected_syscalls()[syscall].get_name() # Alias handling
        cls.direct_add_syscall(syscall)

    @classmethod
    def print_stats(cls):
        """Prints the count state of all syscalls in human readable form to stdout.
        
        Does nothing if there are no counted syscalls.
        """
        if not cls._syscall_count_state:
            return
        print("----- Syscall Count -----")
        for syscall in sorted(cls._syscall_count_state):
            print(f"{syscall}(): {cls._syscall_count_state[syscall]}")
        print("-------------------------")