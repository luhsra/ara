cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "load_os_config.h" namespace "ara::step":
    cdef cppclass LoadOSConfig:
        LoadOSConfig(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
