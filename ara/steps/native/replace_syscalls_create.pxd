cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport uintptr_t
from ir cimport Value

cdef extern from "replace_syscalls_create.h" namespace "ara::step":
    cdef cppclass ReplaceSyscallsCreate:
        object replace_task_create(object pyo_task)
        object replace_queue_create(object pyo_task)
        object replace_mutex_create(object pyo_task)
