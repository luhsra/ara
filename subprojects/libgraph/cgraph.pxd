from libcpp.string cimport string
from libcpp cimport bool
from libcpp.memory cimport shared_ptr

cdef extern from "graph.h" namespace "graph":
    cdef cppclass Graph:
        Graph() except +

        void set_vertex(shared_ptr[Vertex] vertex)

    cdef cppclass Vertex:
        Vertex(Graph* graph, string name) except +

    cdef cppclass Edge:
        Edge() except +

cdef extern from "graph.h" namespace "OS":
    cdef cppclass Alarm:
        Alarm(Graph* graph, string name) except +

    cdef cppclass Counter:
        Counter(Graph* graph, string name) except +

        void set_max_allowedvalue(unsigned long max_allowedvalue)

    cdef cppclass Event:
        Event(Graph* graph, string name) except +

    cdef cppclass Function:
        Function(Graph* graph, string name) except +

    cdef cppclass ISR:
        ISR(Graph* graph, string name) except +

    cdef cppclass Resource:
        Resource(Graph* graph, string name) except +

        void set_resource_property(string prop, string linked_resource)

    cdef cppclass Task:
        Task(Graph* graph, string name) except +

        bool set_message_reference(string message)
