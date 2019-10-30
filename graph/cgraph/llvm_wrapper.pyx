# cython: language_level=3
# vim: set et ts=4 sw=4:
cimport llvm_wrapper

from libcpp cimport nullptr

cdef class LLVMWrapper:
    def __cinit__(self):
        self._c_module = unique_ptr[llvm.Module](nullptr)
