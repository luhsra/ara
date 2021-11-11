# cython: language_level=3

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr, shared_ptr

cdef extern from "common/cy_helper.h" namespace "ara::cy_helper":
    string to_string[T](const T& obj)

    void assign_enum[E](E& e, int i)

    shared_ptr[T] to_shared_ptr[T](unique_ptr[T])
