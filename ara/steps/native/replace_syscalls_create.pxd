cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport uintptr_t
from ir cimport Value

cdef extern from "replace_syscalls_create.h" namespace "ara::step":
    cdef cppclass ReplaceSyscallsCreate:
        ReplaceSyscallsCreate(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
        bool replace_mutex_create_static(cgraph.Graph, uintptr_t, char*)
        bool replace_mutex_create_initialized(cgraph.Graph, uintptr_t, char*)
        bool replace_queue_create_static(cgraph.Graph, uintptr_t, char*, char*)
        bool replace_queue_create_initialized(cgraph.Graph, uintptr_t, char*)
        bool replace_task_create_static(cgraph.Graph, uintptr_t, char*, char*)
        bool replace_task_create_initialized(cgraph.Graph, uintptr_t, char*)
