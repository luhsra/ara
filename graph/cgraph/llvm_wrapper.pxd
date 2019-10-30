# cython: language_level=3
# vim: set et ts=4 sw=4

cimport llvm

from libcpp.memory cimport unique_ptr

cdef class LLVMWrapper:
    cdef unique_ptr[llvm.Module] _c_module
