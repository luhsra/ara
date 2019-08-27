# cython: language_level=3

from libcpp.string cimport string
from libcpp.utility cimport pair
from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr, shared_ptr

cdef extern from "common/cy_helper.h" namespace "ara::cy_helper":
    # cdef cppclass PtrIterator[T, P]:
    #     P* operator*()
    #     PtrIterator[T, P] operator++()
    #     PtrIterator[T, P] operator--()
    #     PtrIterator[T, P] operator+(size_type)
    #     PtrIterator[T, P] operator-(size_type)
    #     bint operator==(iterator)
    #     bint operator!=(iterator)
    #     bint operator<(iterator)
    #     bint operator>(iterator)
    #     bint operator<=(iterator)
    #     bint operator>=(iterator)

    # cdef cppclass PtrRange[T, P]:
    #     PtrRange()
    #     PtrRange(T f, T s)
    #     PtrIterator[T, P] begin()
    #     PtrIterator[T, P] end()

    # PtrRange[T, P] make_ptr_range[T, P](pair[T, T] iterators)

    string to_string[T](const T& obj)

    # cdef cppclass SubgraphIterator[T]:
    #     long unsigned int& operator*()
    #     SubgraphIterator[T] operator++()
    #     SubgraphIterator[T] operator--()
    #     SubgraphIterator[T] operator+(size_type)
    #     SubgraphIterator[T] operator-(size_type)
    #     bint operator==(iterator)
    #     bint operator!=(iterator)
    #     bint operator<(iterator)
    #     bint operator>(iterator)
    #     bint operator<=(iterator)
    #     bint operator>=(iterator)

    # cdef cppclass SubgraphRange[T]:
    #     SubgraphRange()
    #     SubgraphRange(T& s)
    #     SubgraphIterator[T] begin()
    #     SubgraphIterator[T] end()

    # # boost wrapper
    # V source[E, V, G](E e, G g)
    # V target[E, V, G](E e, G g)

    # pair[E, E] edges[E, G](G g)
    # pair[V, V] vertices[V, G](G g)

    void assign_enum[E](E& e, int i)

    # unique_ptr[B] cast_unique_ptr[B, D](unique_ptr[D])

    shared_ptr[T] to_shared_ptr[T](unique_ptr[T])
