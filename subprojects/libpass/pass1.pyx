# distutils: language = c++

cimport cpass
cimport graph

# Create a Cython extension type which holds a C++ instance
# as an attribute and create a bunch of forwarding methods
# Python extension type.
cdef class PyPass:
    cdef cpass.Pass _c_pass  # Hold a C++ instance which we're wrapping

    def __cinit__(self):
        self._c_pass = cpass.Pass()

    def run(self, graph.PyGraph g, files):
        self._c_pass.run(g._c_graph, files)
