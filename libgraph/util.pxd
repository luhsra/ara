# cython: language_level=3

from libcpp.string cimport string
cimport cgraph

cdef extern from "util.h" nogil:
    cdef string to_string[T](T& obj)
