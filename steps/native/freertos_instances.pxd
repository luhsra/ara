cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "freertos_instances.h" namespace "step":
    cdef cppclass FreeRTOSInstancesStep:
        FreeRTOSInstancesStep(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
