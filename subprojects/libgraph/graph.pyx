# distutils: language = c++

cimport cgraph
cimport graph

from libcpp.memory cimport shared_ptr, make_shared
from libcpp.string cimport string

from cython.operator cimport dereference as deref

# Create a Cython extension type which holds a C++ instance
# as an attribute and create a bunch of forwarding methods
# Python extension type.
cdef class PyGraph:

    def __cinit__(self):
        self._c_graph = cgraph.Graph()

    def set_vertex(self, Vertex vertex):
        self._c_graph.set_vertex(vertex._c_vertex)


cdef class Vertex:
    cdef shared_ptr[cgraph.Vertex] _c_vertex

    def __cinit__(self, PyGraph graph, name):
        # prevent double constructions
        # https://github.com/cython/cython/wiki/WrappingSetOfCppClasses
        if type(self) != Vertex:
            return
        cdef string bname = name.encode('UTF-8')
        self._c_vertex = make_shared[cgraph.Vertex](&graph._c_graph, bname)


cdef class Alarm(Vertex):
    cdef shared_ptr[cgraph.Alarm] _c_alarm

    def __cinit__(self, PyGraph graph, str name):
        cdef string bname = name.encode('UTF-8')
        self._c_alarm = make_shared[cgraph.Alarm](&graph._c_graph, bname)


cdef class Counter(Vertex):
    cdef shared_ptr[cgraph.Counter] _c_counter

    def __cinit__(self, PyGraph graph, str name):
        cdef string bname = name.encode('UTF-8')
        self._c_counter = make_shared[cgraph.Counter](&graph._c_graph, bname)

    def set_max_allowedvalue(self, unsigned long max_allowedvalue):
        deref(self._c_counter).set_max_allowedvalue(max_allowedvalue)


cdef class Event(Vertex):
    cdef shared_ptr[cgraph.Event] _c_event

    def __cinit__(self, PyGraph graph, str name):
        cdef string bname = name.encode('UTF-8')
        self._c_event = make_shared[cgraph.Event](&graph._c_graph, bname)


cdef class ISR(Vertex):
    cdef shared_ptr[cgraph.ISR] _c_isr

    def __cinit__(self, PyGraph graph, str name):
        cdef string bname = name.encode('UTF-8')
        self._c_isr = make_shared[cgraph.ISR](&graph._c_graph, bname)


cdef class Resource(Vertex):
    cdef shared_ptr[cgraph.Resource] _c_resource

    def __cinit__(self, PyGraph graph, str name):
        cdef string bname = name.encode('UTF-8')
        self._c_resource = make_shared[cgraph.Resource](&graph._c_graph, bname)

    def set_resource_property(self, string prop, string linked_resource):
        deref(self._c_resource).set_resource_property(prop, linked_resource)


cdef class Task(Vertex):
    cdef shared_ptr[cgraph.Task] _c_task

    def __cinit__(self, PyGraph graph, str name):
        cdef string bname = name.encode('UTF-8')
        self._c_task = make_shared[cgraph.Task](&graph._c_graph, bname)

    def set_message_reference(self, string message):
        return deref(self._c_task).set_message_reference(message)
