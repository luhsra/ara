
from ..os_util import syscall
from .posix_utils import no_double_warning, do_not_interpret_syscall

class SyscallStubAliases:
    
    @syscall(aliases={"default_malloc", "__libc_malloc_impl", "__libc_malloc", "__simple_malloc"}, is_stub=True)
    def malloc(graph, abb, state, args, va):
        return do_not_interpret_syscall(graph, abb, state)