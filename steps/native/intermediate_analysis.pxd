cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "intermediate_analysis.h" namespace "step":
    cdef cppclass IntermediateAnalysisStep:
        IntermediateAnalysisStep(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
