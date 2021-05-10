
from .posix_utils import is_weak_alias, get_orig_of_weak_alias

# TODO: Handle syscallCategory.every
# TODO: Make CFGStats Syscall Categories working
class SyscallCount:

    _enabled = False
    _syscall_count_state: dict = {}

    @classmethod
    def enable(cls):
        cls._enabled = True

    @classmethod
    def add_syscall(cls, syscall: str):
        if not cls._enabled:
            return
        if is_weak_alias(syscall):
            syscall = get_orig_of_weak_alias(syscall)
        counter: int = cls._syscall_count_state.setdefault(syscall, 0)
        counter += 1
        cls._syscall_count_state[syscall] = counter

    @classmethod
    def print_stats(cls):
        if not cls._enabled:
            return
        print("----- Syscall Count -----")
        for syscall in sorted(cls._syscall_count_state):
            print(f"{syscall}(): {cls._syscall_count_state[syscall]}")
        print("-------------------------")