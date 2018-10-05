cimport cgraph

from libcpp.string cimport string

cdef extern from "llvm.h" namespace "pass":
    cdef cppclass LLVMPass:
        LLVMPass() except +
        string get_name()
        string get_description()
        void run(cgraph.Graph a)
