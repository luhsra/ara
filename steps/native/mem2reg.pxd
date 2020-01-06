cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "mem2reg.h" namespace "ara::step":
    cdef cppclass Mem2Reg:
        Mem2Reg(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
