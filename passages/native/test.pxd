cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "test.h" namespace "passage":
    cdef cppclass Test0Passage:
        Test0Passage(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)

    cdef cppclass Test2Passage:
        Test2Passage(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
