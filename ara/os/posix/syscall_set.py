
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
    "ARA_sigaction_syscall_", # Special Musl wrapper for sigaction()
    "signal",
    "sigwait",
    "sigwaitinfo",
    "sigtimedwait",
    "pause",
    #"sleep", We want to redirect sleep() -> nanosleep()
    "ARA_nanosleep_syscall_", # Special Musl wrapper for nanosleep()
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
    "ARA_pthread_attr_setschedparam_syscall_" # Special Musl wrapper for pthread_attr_setschedparam(),
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
    "pthread_attr_setname_np", # IBM specific
    "pthread_setname_np", # GNU specific
    "clock_settime",
    "clock_nanosleep",

    # musl libc native Kernel syscalls
    "musl_syscall0_", # __syscall0 [function name in musl libc]
    "musl_syscall1_", # __syscall1
    "musl_syscall2_", # __syscall2
    "musl_syscall3_", # __syscall3
    "musl_syscall4_", # __syscall4
    "musl_syscall5_", # __syscall5
    "musl_syscall6_", # __syscall6

    ###########################################################
    ### Functions that we want to remove instead of analyse ###

    # Unwanted Getter [We can remove these with the remove_sysfunc_body step]
    "pthread_attr_getname_np", # IBM specific
    "pthread_getname_np", # GNU specific
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

    # Musl libc implementation is hard to analyse for this function.
    # We do not want to analyse close() so simply remove it.
    "fclose",

    # Let SVF handle these functions for us:
    "malloc",
    "calloc",
    "realloc",
    "free",
    "memccpy",
    "memchr",
    "memcmp",
    "memcpy",
    "memmove",
    "memset",
    
    # String functions can easily lead to statements that copy points-to targets.
    # Additionally these functions do not lead to syscalls.
    # In libmicrohttpd most structs have the same points-to targets because of these functions.
    "stpcpy",
    "stpncpy",
    "strcasecmp",
    "strcasecmp_l",
    "strcat",
    "strchr",
    "strcmp",
    "strcoll",
    "strcoll_l",
    "strcpy",
    "strcspn",
    "strdup",
    "strerror",
    "strerror_l",
    "strerror_r",
    "strfmon",
    "strfmon_l",
    "strftime",
    "strftime_l",
    "strlen",
    "strncasecmp",
    "strncasecmp_l",
    "strncat",
    "strncmp",
    "strncpy",
    "strndup",
    "strnlen",
    "strpbrk",
    "strptime",
    "strrchr",
    "strsignal",
    "strspn",
    "strstr",
    "strtod",
    "strtof",
    "strtoimax",
    "strtok",
    "strtok_r",
    "strtold",
    "strtol",
    "strtoll",
    "strtoul",
    "strtoull",
    "strtoumax",
    "strxfrm",
    "strxfrm_l",

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

    # The following are musl libc specific functions.
    #   These ARE NO Syscalls.
    #   But we want to remove the costly impl. of these calls. (With remove_sysfunc_body step)
    #   Some of them are accessing function pointers to more than ~93 possible functions.
    "libc_start_init",
    "libc_exit_fini",
    "__pthread_tsd_run_dtors",
    "at_quick_exit",
    "call",             # Hopefully nobody names his/her function "call" or "__call".
    "__syscall_cp",     # Cancellation point implementation for some syscalls.
                        # This function results in a pretty big callgraph.

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
    
    # Musl wrapper around futex() calls. These are not required if we are not interested in futex. 
    "__wake",
    "__futexwait",

    # Does normally not result to an interessting syscall. (if we do not analyze stdin, stdout, stderr, ...)
    # These calls are expensive to analyse.
    "printf",
    "sprintf",
    "snprintf",

    # These are functions that are possible call targets of calls to f->write(), f->read(), ... inside musl libc.
    # We are not interested in analysing these functions so we can increase performance and precision of the analysis a lot by removing these functions.
    "wms_seek",
	"wms_write",
	"ms_seek",
	"cookieseek",
	"cookiewrite",
	"mwrite",
	"mread",
	"mseek",
	"__stdio_seek", # Remove this if you want to detect seek functions.
	"ms_write",
	"cookieread",
    "__stdout_write",
    "sw_write",
    "sn_write",
    "string_read",
    "wstring_read",
    "do_read",
    "wms_close",
	"cookieclose",
	"mclose",
	"ms_close",
	"__stdio_close",

    # Socket functions we do not want to analyse.
    "send",
    "sendfile",
    "recv",

})