cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport uintptr_t
from ir cimport Value

cdef extern from "replace_syscalls_create.h" namespace "ara::step":
    cdef cppclass ReplaceSyscallsCreate:
        bool replace_mutex_create_static(uintptr_t, char*)
        bool replace_mutex_create_initialized(uintptr_t, char*)
        bool replace_queue_create_static(uintptr_t, char*, char*)
        bool replace_queue_create_initialized(uintptr_t, char*)
        object replace_task_create(object pyo_task)
