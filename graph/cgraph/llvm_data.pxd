# cython: language_level=3
# vim: set et ts=4 sw=4:

cdef extern from "llvm_data.h" namespace "ara::graph":
    cdef cppclass LLVMData:
        pass

cdef class PyLLVMData:
    cdef LLVMData _c_data
