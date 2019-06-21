cimport cgraph
cimport warning

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.memory cimport shared_ptr

cdef extern from "validation.h" namespace "step":
    cdef cppclass ValidationStep:
        ValidationStep(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        vector[shared_ptr[warning.Warning]]& get_warnings()
        void run(cgraph.Graph a)
