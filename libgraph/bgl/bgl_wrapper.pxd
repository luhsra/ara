#cython: language_level=3

from libc.stdint cimport uint64_t
from libcpp cimport bool
from libcpp.memory cimport unique_ptr
from libcpp.utility cimport pair

cdef extern from "bgl_wrapper.h" namespace "boost":
    cdef cppclass iterator_range[I]:
        I begin()
        I end()

    iterator_range[I] make_iterator_range[I](I begin, I end)

cdef extern from "bgl_wrapper.h" namespace "ara::bgl_wrapper":
    ctypedef ptrdiff_t difference_type

    cdef cppclass GraphIterator[T]:
        unique_ptr[T] operator*()
        GraphIterator[T] operator++()
        GraphIterator[T] operator--()
        GraphIterator[T] operator+(size_type)
        GraphIterator[T] operator-(size_type)
        difference_type operator-(GraphIterator[T])
        bint operator==(GraphIterator[T])
        bint operator!=(GraphIterator[T])
        bint operator<(GraphIterator[T])
        bint operator>(GraphIterator[T])
        bint operator<=(GraphIterator[T])
        bint operator>=(GraphIterator[T])

    cdef cppclass Predicate:
        pass

    cdef cppclass VertexWrapper:
        pair[unique_ptr[GraphIterator[EdgeWrapper]], unique_ptr[GraphIterator[EdgeWrapper]]] in_edges()
        pair[unique_ptr[GraphIterator[EdgeWrapper]], unique_ptr[GraphIterator[EdgeWrapper]]] out_edges()

        uint64_t in_degree()
        uint64_t out_degree()
        uint64_t degree()

        pair[unique_ptr[GraphIterator[VertexWrapper]], unique_ptr[GraphIterator[VertexWrapper]]] adjacent_vertices()
        pair[unique_ptr[GraphIterator[VertexWrapper]], unique_ptr[GraphIterator[VertexWrapper]]] inv_adjacent_vertices()

        void clear_in_edges()
        void clear_out_edges()
        void clear_edges()

    cdef cppclass EdgeWrapper:
        unique_ptr[VertexWrapper] source()
        unique_ptr[VertexWrapper] target()

    cdef cppclass GraphWrapper:
        pair[unique_ptr[GraphIterator[VertexWrapper]], unique_ptr[GraphIterator[VertexWrapper]]] vertices()
        uint64_t num_vertices()

        pair[unique_ptr[GraphIterator[EdgeWrapper]], unique_ptr[GraphIterator[EdgeWrapper]]] edges()
        uint64_t num_edges()

        unique_ptr[VertexWrapper] add_vertex()
        # void remove_vertex(VertexWrapper& vertex)

        unique_ptr[EdgeWrapper] add_edge(VertexWrapper& source, VertexWrapper& target)
        void remove_edge(EdgeWrapper& edge)

        unique_ptr[GraphWrapper] create_subgraph()

        bool is_root()

        unique_ptr[GraphWrapper] root()

        unique_ptr[GraphWrapper] parent()

        pair[unique_ptr[GraphIterator[GraphWrapper]], unique_ptr[GraphIterator[GraphWrapper]]] children()

        unique_ptr[VertexWrapper] local_to_global(VertexWrapper& vertex)
        unique_ptr[EdgeWrapper] local_to_global(EdgeWrapper& vertex)

        unique_ptr[VertexWrapper] global_to_local(VertexWrapper& vertex)
        unique_ptr[EdgeWrapper] global_to_local(EdgeWrapper& vertex)

        unique_ptr[GraphWrapper] filter_by(Predicate vertex, Predicate edge)
