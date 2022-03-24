cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "test.h" namespace "ara::step":
    cdef cppclass Test0Step:
        pass

    cdef cppclass Test2Step:
        pass

    cdef cppclass BBSplitTest:
        pass

    cdef cppclass CFGOptimizeTest:
        pass

    cdef cppclass CompInsertTest:
        pass

    cdef cppclass FnSingleExitTest:
        pass

    cdef cppclass LLVMMapTest:
        pass

    cdef cppclass PosixClangGlobalTest:
        pass