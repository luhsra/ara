from carguments cimport CallPath
from libcpp.memory cimport unique_ptr
from common.backported_utility cimport pair

cimport cgraph

cdef extern from "value_analyzer.h" namespace "ara::cython":
    cdef void raise_py_valueerror()

cdef extern from "value_analyzer.h" namespace "ara::step":
    cdef cppclass ValueAnalyzer:
        @staticmethod
        unique_ptr[ValueAnalyzer] get(cgraph.Graph, object)

        object py_get_argument_value(object, CallPath, unsigned, int, object) except +raise_py_valueerror
        void py_assign_system_object(object, unsigned, CallPath, int) except +raise_py_valueerror
        object py_get_return_value(object, CallPath) except +raise_py_valueerror
