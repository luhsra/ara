cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "cfg_prep.h" namespace "ara::step":
    cdef cppclass CFGPreparation:
        CFGPreparation(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
