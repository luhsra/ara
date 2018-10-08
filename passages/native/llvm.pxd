cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "llvm.h" namespace "pass":
    cdef cppclass LLVMPass:
        LLVMPass(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
