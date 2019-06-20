cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "test.h" namespace "step":
    cdef cppclass Test0Step:
        Test0Step(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)

    cdef cppclass Test2Step:
        Test2Step(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)

    cdef cppclass BBSplitTest:
        BBSplitTest(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)

    cdef cppclass CompInsertTest:
        CompInsertTest(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)

    cdef cppclass FnSingleExitTest:
        FnSingleExitTest(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
