cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint import intptr_t, int
from ir cimport Value

cdef extern from "replace_syscalls_create.h" namespace "ara::step":
    cdef cppclass ReplaceSyscallsCreate:
        ReplaceSyscallsCreate(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
        bool replace_queue_create_static(cgraph.Graph, int, char*, char*)
