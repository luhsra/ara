# taken from https://github.com/cython/cython/blob/master/Cython/Includes/libcpp/utility.pxd
# to avaid dependency on Cython >= 0.29.17 which is not available in
# Ubuntu 20.04

cdef extern from * namespace "cython_std" nogil:
    """
    #if __cplusplus > 199711L
    #include <type_traits>
    namespace cython_std {
    template <typename T> typename std::remove_reference<T>::type&& move(T& t) noexcept { return std::move(t); }
    template <typename T> typename std::remove_reference<T>::type&& move(T&& t) noexcept { return std::move(t); }
    }
    #endif
    """
    cdef T move[T](T)
