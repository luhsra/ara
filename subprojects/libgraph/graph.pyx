# distutils: language = c++

cimport cgraph
cimport graph

# Create a Cython extension type which holds a C++ instance
# as an attribute and create a bunch of forwarding methods
# Python extension type.
cdef class PyGraph:

    def __cinit__(self):
        self._c_graph = cgraph.Graph()
