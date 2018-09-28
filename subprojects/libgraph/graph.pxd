cimport cgraph

cdef class PyGraph:
    cdef cgraph.Graph _c_graph  # Hold a C++ instance which we're wrapping
