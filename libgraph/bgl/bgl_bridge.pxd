#cython: language_level=3

from libc.stdint cimport uint64_t
from libcpp cimport bool
from libcpp.memory cimport unique_ptr
from libcpp.utility cimport pair

cdef extern from "bgl_bridge.h" namespace "ara::bgl_wrapper":
    cdef cppclass BoostPropImpl[T]:
        T& get()
