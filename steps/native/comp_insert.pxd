cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "comp_insert.h" namespace "step":
    cdef cppclass CompInsert:
        CompInsert(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
