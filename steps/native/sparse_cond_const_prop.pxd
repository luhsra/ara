cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "sparse_cond_const_prop.h" namespace "ara::step":
    cdef cppclass SparseCondConstProp:
        SparseCondConstProp(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
