# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# taken from https://github.com/cython/cython/blob/master/Cython/Includes/libcpp/utility.pxd
# to avoid dependency on Cython >= 0.29.17 which is not available in
# Ubuntu 20.04

cdef extern from "<utility>" namespace "std" nogil:
    cdef cppclass pair[T, U]:
        ctypedef T first_type
        ctypedef U second_type
        T first
        U second
        pair() except +
        pair(pair&) except +
        pair(T&, U&) except +
        bint operator==(pair&, pair&)
        bint operator!=(pair&, pair&)
        bint operator<(pair&, pair&)
        bint operator>(pair&, pair&)
        bint operator<=(pair&, pair&)
        bint operator>=(pair&, pair&)

cdef extern from * namespace "cython_std_backported" nogil:
    """
    #if __cplusplus > 199711L
    #include <type_traits>

    namespace cython_std_backported {
    template <typename T> typename std::remove_reference<T>::type&& move(T& t) noexcept { return std::move(t); }
    template <typename T> typename std::remove_reference<T>::type&& move(T&& t) noexcept { return std::move(t); }
    }

    #endif
    """
    cdef T move[T](T)
