from libcpp.memory cimport shared_ptr

cdef extern from "<memory>" namespace "std" nogil:
    # taken from https://github.com/cython/cython/blob/master/Cython/Includes/libcpp/memory.pxd
    # No checking on the compatibility of T and U.
    cdef shared_ptr[T] static_pointer_cast[T, U](const shared_ptr[U]&)
    cdef shared_ptr[T] dynamic_pointer_cast[T, U](const shared_ptr[U]&)
    cdef shared_ptr[T] const_pointer_cast[T, U](const shared_ptr[U]&)
    cdef shared_ptr[T] reinterpret_pointer_cast[T, U](const shared_ptr[U]&)
