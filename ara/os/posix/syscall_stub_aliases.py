
from ..os_util import syscall
from .posix_utils import do_not_interpret_syscall

class SyscallStubAliases:
    """Provide a do_not_interpret implementation in this class for syscall stubs with custom aliases."""
    
    @syscall(aliases={"default_malloc", "__libc_malloc_impl", "__libc_malloc", "__simple_malloc"}, is_stub=True)
    def malloc(graph, abb, state, args, va):
        return do_not_interpret_syscall(graph, abb, state)