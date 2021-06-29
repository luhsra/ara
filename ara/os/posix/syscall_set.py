
"""This module contains the syscall_set.

This set contains all syscalls that are in interest for an OS analysis.
For all syscalls in this set the OS model will generate a stub function.
Even when there is no implementation for a syscall, ARA will detect at least all syscalls in this set.
For all detected syscalls it is possible to remove the libc implementation with the RemoveSysfuncBody step.
    
If you add an implementation for a new syscall which is not in this set, consider to add the name in this set beforehand,
then we have a complete list/set of all syscalls.
"""

syscall_set = set({

    # Priority 1 [Important]
    "pthread_create",
    "pthread_cancel",
    "pthread_join",
    "pthread_barrier_init",
    "pthread_barrier_wait",
    "pthread_mutex_init",
    "pthread_mutex_lock",
    "pthread_mutex_trylock",
    "pthread_mutex_timedlock",
    "pthread_mutex_unlock",
    "pthread_mutex_setprioceiling",
    "pthread_rwlock_init",
    "pthread_rwlock_rdlock",
    "pthread_rwlock_tryrdlock",
    "pthread_rwlock_timedrdlock",
    "pthread_rwlock_wrlock",
    "pthread_rwlock_trywrlock",
    "pthread_rwlock_timedwrlock"
    "pthread_rwlock_unlock",
    "pthread_spin_init",
    "pthread_spin_lock",
    "pthread_spin_trylock",
    "pthread_spin_unlock",
    "pthread_cond_init",
    "pthread_cond_broadcast",
    "pthread_cond_signal",
    "pthread_cond_wait",
    "pthread_cond_timedwait",
    "sem_init",
    "sem_open",
    "sem_wait",
    "sem_trywait",
    "sem_timedwait",
    "sem_post",
    "_ARA_sigaction_syscall_", # Special Musl wrapper for sigaction()
    "signal",
    "sigwait",
    "sigwaitinfo",
    "sigtimedwait",
    "pause",
    #"sleep", We want to redirect sleep() -> nanosleep()
    "_ARA_nanosleep_syscall_", # Special Musl wrapper for nanosleep()
    "clock_nanosleep",
    "alarm",
    "timer_create",
    "timer_settime",
    "pthread_kill",
    "raise",
    "pthread_sigqueue",
    "pipe",
    "open",
    "openat",
    "read",
    "pread",
    "write",
    "pwrite",
    "writev",
    "mq_open",
    "mq_send",
    "mq_timedsend",
    "mq_receive",
    "mq_timedreceive",
    "mq_notify",

    # Priority 2
    "pthread_attr_destroy",
    "pthread_attr_init",
    "pthread_attr_setdetachstate",
    "pthread_attr_setguardsize",
    "pthread_attr_setinheritsched",
    "_ARA_pthread_attr_setschedparam_syscall_" # Special Musl wrapper for pthread_attr_setschedparam(),
    "pthread_attr_setschedpolicy",
    "pthread_attr_setscope",
    "pthread_attr_setstack",
    "pthread_attr_setstacksize",
    "pthread_exit",
    "pthread_detach",
    "pthread_barrierattr_destroy",
    "pthread_barrierattr_init",
    "pthread_barrierattr_setpshared",
    "pthread_barrier_destroy",
    "pthread_mutexattr_init",
    "pthread_mutexattr_setprioceiling",
    "pthread_mutexattr_setprotocol",
    "pthread_mutexattr_setpshared",
    "pthread_mutexattr_setrobust",
    "pthread_mutexattr_settype",
    "pthread_mutexattr_destroy",
    "pthread_mutex_destroy",
    "pthread_mutex_consistent",
    "pthread_rwlockattr_destroy",
    "pthread_rwlockattr_init",
    "pthread_rwlockattr_setpshared",
    "pthread_rwlock_destroy",
    "pthread_spin_destroy",
    "pthread_condattr_destroy",
    "pthread_condattr_init",
    "pthread_condattr_setclock",
    "pthread_condattr_setpshared",
    "pthread_cond_destroy",
    "sem_destroy",
    "sem_close",
    "pthread_setschedparam",
    "pthread_setcancelstate",
    "pthread_setcanceltype",
    "pthread_key_create",
    "pthread_key_delete",
    "pthread_setspecific",
    "sigprocmask",
    "pthread_sigmask",
    "sigsuspend",
    "timer_delete",
    "setitimer",
    "timerfd_create",
    "timerfd_settime",
    "sched_yield",
    "fcntl",
    "dup",
    "dup2",
    "aio_cancel",
    "aio_error",
    "aio_fsync",
    "aio_read",
    "aio_return",
    "aio_suspend",
    "aio_write",
    "close",
    "mq_setattr",
    "mq_close",
    "mq_unlink",
    "pthread_attr_setname_np",
    "pthread_setname_np",
    "clock_settime",
    "clock_nanosleep",

    # Unwanted Getter [We can remove these with the remove_sysfunc_body step]
    "pthread_attr_getname_np",
    "pthread_getname_np",
    "pthread_attr_getdetachstate",
    "pthread_attr_getguardsize",
    "pthread_attr_getinheritsched",
    "pthread_attr_getschedparam",
    "pthread_attr_getschedpolicy",
    "pthread_attr_getscope",
    "pthread_attr_getstack",
    "pthread_attr_getstacksize",
    "pthread_barrierattr_getpshared",
    "pthread_mutexattr_getprioceiling",
    "pthread_mutexattr_getprotocol",
    "pthread_mutexattr_getpshared",
    "pthread_mutexattr_getrobust",
    "pthread_mutexattr_gettype",
    "pthread_rwlockattr_getpshared",
    "pthread_condattr_getclock",
    "pthread_condattr_getpshared",
    "pthread_getconcurrency",
    "pthread_getcpuclockid",
    "pthread_getschedparam",
    "pthread_getspecific",
    "timerfd_gettime",
    "mq_getattr",
    "clock_gettime",
    "clock_getres",

    # Let SVF handle those functions for us:
    "malloc",
    "calloc", # calloc is not working with SVF but with the help of musl libc we can do:  calloc -> malloc
    "realloc",
    "free",
    "memccpy",
    "memchr",
    "memcmp",
    "memcpy",
    "memmove",
    "memset",

    # Stack unwinding functions (Throw warning if we detect one)
    "setjmp",
    "longjmp",
    "_setjmp",
    "_longjmp",
    "sigsetjmp",
    "siglongjmp",

    # Remove body of these functions
    # We do not want to interpret this
    "exit",
    "abort",
    "fork",
    "posix_spawn",
    "posix_spawnp",
    #"daemon",
    
    #"va_arg",
    #"va_copy",
    #"va_end",
    #"va_start",

    # The following are musl libc specific functions.
    #   These ARE NO Syscalls.
    #   But we want to remove the costly impl. of these calls. (With remove_sysfunc_body step)
    #   All of them are accessing function pointers to more than ~93 possible functions.
    "libc_start_init",
    "libc_exit_fini",
    "__pthread_tsd_run_dtors",
    "at_quick_exit",
    "call", # Hopefully nobody names his/her function "call" or "__call".

    # musl libc native Kernel syscalls
    "_musl_syscall0", # __syscall0 [function name in musl libc]
    "_musl_syscall1", # __syscall1
    "_musl_syscall2", # __syscall2
    "_musl_syscall3", # __syscall3
    "_musl_syscall4", # __syscall4
    "_musl_syscall5", # __syscall5
    "_musl_syscall6", # __syscall6

    # Remove musl libc x64 asm functions
    # SVF tries to match a function pointer to the __asm__ call.
    # We do not want this.
    "a_cas",
    "a_cas_p",
    "a_swap",
    "a_fetch_add",
    "a_and",
    "a_or",
    "a_and_64",
    "a_or_64",
    "a_inc",
    "a_dec",
    "a_store",
    "a_barrier",
    "a_spin",
    "a_crash",
    "a_ctz_64",
    "a_clz_64",
    "__get_tp",

    # More unwanted musl libc specific functions
    "__syscall_cp", # All Syscalls as cancellation point. This function results in a pretty big callgraph.
    "fopencookie", # I do not know what this API function does. It is not in the POSIX or C Standard and is not called internally. Just remove it, it leads to more wrong matched function pointers.
    
    # Musl wrapper around futex() calls. These are not required if we are not interested in futex. 
    "__wake",
    "__futexwait",

    # Does normally not result to an interessting syscall. (if we do not analyze stdin, stdout, stderr, ...)
    # These calls are expensive for the analysis.
    "printf",
    "sprintf",
    "snprintf",

    # functions in libmicrohttpd that leads to problems.
    "file_free_callback",
    "free_callback",
    "dir_free_callback",
    "unescape_wrapper",
    "MHD_http_unescape",
    "recv_param_adapter",
    "try_ready_chunked_body",

    # Problematic functions in musl libc.
    "tdelete",
    "__tsearch_balance",
    "__stdio_exit",
    "__stdio_seek",
    "__stdio_close",
    "munmap",
    "setsockopt",
    "wms_seek",
    "ms_write",
    "mseek",
    "mwrite",
    "mread",
    "__stdio_seek", # Remove this if you want to detect seek functions.
    "ms_seek",
    "wms_write",
    "readdir"

    "send",
    "recv",

})