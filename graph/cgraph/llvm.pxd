# cython: language_level=3
# vim: set et ts=4 sw=4:

cdef extern from "llvm/IR/Module.h" namespace "llvm":
    cdef cppclass Module:
        pass
