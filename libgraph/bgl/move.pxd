#cython: language_level=3

cdef extern from * namespace "ara_move":
    """
    namespace ara_move {

    template <typename T>
    inline typename std::remove_reference<T>::type&& move(T& t) {
        return std::move(t);
    }

    template <typename T>
    inline typename std::remove_reference<T>::type&& move(T&& t) {
        return std::move(t);
    }

    }  // namespace ara_move
    """
    cdef T move[T](T)
