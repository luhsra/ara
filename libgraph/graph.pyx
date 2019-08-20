# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph
cimport newgraph
cimport cfg
cimport cfg_wrapper
cimport cfg.abbtype
cimport graph
cimport cy_helper
cimport boost

from libcpp.memory cimport shared_ptr, make_shared, unique_ptr, make_unique
from libcpp.string cimport string
from libcpp.list cimport list as clist
from libcpp.set cimport set as cset
from libcpp.vector cimport vector as cvector
from libcpp.utility cimport pair

from libcpp cimport bool
from libc.stdint cimport int64_t

from backported_memory cimport static_pointer_cast as spc
from backported_memory cimport dynamic_pointer_cast as dpc
from cy_helper cimport to_string #, make_ptr_range, get_subgraph_prop
from cython.operator cimport typeid
from cython.operator cimport dereference as deref
from enum import IntEnum

cimport bgl

# from cfg cimport FunctionDescriptor as FuncDesc
# from cfg cimport ABBGraph as CABBGraph

from libcpp.typeinfo cimport type_info

# ctypedef CABBGraph.edge_descriptor EdgeDesc
# ctypedef CABBGraph.edge_iterator EdgeIter
# ctypedef CABBGraph.children_iterator ChildIter

class ABBType(IntEnum):
    computation = <int> cfg.abbtype.computation
    syscall = <int> cfg.abbtype.syscall
    call = <int> cfg.abbtype.call
    not_implemented = <int> cfg.abbtype.not_implemented

# cdef class ABB(bgl.Vertex):
#     pass
#
# cdef class ABBEdge(bgl.Edge):
#     pass
#
# cdef class Function(bgl.Graph):
#     pass

cdef class ABBGraph(bgl.Graph):
    cdef unique_ptr[cfg_wrapper.ABBGraph] _c_graph

    pass

# cdef class ABB:
#     cdef long unsigned int _c_graph_id
#     cdef cfg.ABBGraph* _c_abbgraph
#
#     def __hash__(self):
#         return self._c_graph_id
#
#     def __init__(self, __raw=False):
#         if not __raw:
#             raise ValueError("Must not be directly constructed.")
#
#     def __eq__(self, other):
#         return self.graph_id == other.graph_id
#
#     def __str__(self):
#         # return to_string(deref(self._c_abbgraph)[self._c_graph_id]).decode('utf-8')
#         # do not use C++ print because the Python type has the additional
#         # graph_id
#         return f"ABB({self.graph_id}, {self.name})"
#
#     def get_call(self):
#         return deref(self._c_abbgraph)[self._c_graph_id].get_call().decode('utf-8')
#
#     def is_indirect(self):
#         return deref(self._c_abbgraph)[self._c_graph_id].is_indirect()
#
#     @property
#     def graph_id(self):
#         return self._c_graph_id
#
#     @property
#     def type(self):
#         return ABBType(<int> deref(self._c_abbgraph)[self._c_graph_id].type)
#
#     @type.setter
#     def type(self, value):
#         cy_helper.assign_enum[cfg.abbtype.ABBType](deref(self._c_abbgraph)[self._c_graph_id].type,
#                                                    int(value))
#
#     @property
#     def name(self):
#         return deref(self._c_abbgraph)[self._c_graph_id].name.decode('utf-8')
#
#
# cdef abb_factory(long unsigned int graph_id, cfg.ABBGraph* abbgraph):
#     abb = ABB(__raw=True)
#     abb._c_graph_id = graph_id
#     abb._c_abbgraph = abbgraph
#     return abb
#
#
# cdef class Function:
#     cdef FuncDesc* _c_func
#     cdef cfg.ABBGraph* _c_abbgraph
#
#     def __init__(self, __raw=False):
#         if not __raw:
#             raise ValueError("Must not be directly constructed.")
#
#     @property
#     def name(self):
#         return deref(get_subgraph_prop(self._c_func)).name.decode('utf-8')
#
#     @name.setter
#     def name(self, value):
#         deref(get_subgraph_prop(self._c_func)).name = value
#
#     @property
#     def implemented(self):
#         return deref(get_subgraph_prop(self._c_func)).implemented
#
#     def vertices(self):
#         cdef cy_helper.SubgraphRange[FuncDesc] ra = cy_helper.SubgraphRange[FuncDesc](deref(self._c_func))
#         for vertex in ra:
#             py_abb = abb_factory(vertex, self._c_abbgraph)
#             yield py_abb
#
#
# cdef function_factory(FuncDesc* func, cfg.ABBGraph* abbgraph):
#     py_func = Function(__raw=True)
#     py_func._c_func = func
#     py_func._c_abbgraph = abbgraph
#     return py_func
#
#
# ctypedef long unsigned int vert_desc;
#
#
# cdef class ABBEdge:
#     cdef EdgeDesc _c_edge_id
#     cdef cfg.ABBGraph* _c_abbgraph
#
#     def __init__(self, __raw=False):
#         if not __raw:
#             raise ValueError("Must not be directly constructed.")
#
#     # def __eq__(self, other):
#     #     return self._c_edge_id == other._c_edge_id
#
#     def source(self):
#         cdef long unsigned int other
#         other = cy_helper.source[EdgeDesc,
#                                  vert_desc,
#                                  cfg.ABBGraph](self._c_edge_id,
#                                                deref(self._c_abbgraph))
#         return abb_factory(other, self._c_abbgraph)
#
#     def target(self):
#         cdef long unsigned int other
#         other = cy_helper.target[EdgeDesc,
#                                  vert_desc,
#                                  cfg.ABBGraph](self._c_edge_id,
#                                                deref(self._c_abbgraph))
#         return abb_factory(other, self._c_abbgraph)
#
#
# cdef abbedge_factory(EdgeDesc edge_id, cfg.ABBGraph* abbgraph):
#     edge = ABBEdge(__raw=True)
#     edge._c_edge_id = edge_id
#     edge._c_abbgraph = abbgraph
#     return edge
#
#
# cdef class ABBGraph:
#     """NEVER EVER construct this by yourself. Instead, use Graph.abbs()."""
#
#     # This should be a reference, since the lifetime is associated to the graph
#     # object and it should only be constructable with Graph.abbs(). However,
#     # Cython is not able to achieve this, so instead use a pointer.
#     cdef cfg.ABBGraph* _c_abbgraph
#
#     def __str__(self):
#         return to_string(deref(self._c_abbgraph)).decode('utf-8')
#
#     def edges(self):
#         cdef EdgeDesc edge
#         cdef boost.iterator_range[EdgeIter] ran
#         cdef pair[EdgeIter, EdgeIter] it_pair
#         it_pair = cy_helper.edges[EdgeIter,
#                                   cfg.ABBGraph](deref(self._c_abbgraph))
#         ran = boost.make_iterator_range[EdgeIter](it_pair.first, it_pair.second)
#         for edge in ran:
#             yield abbedge_factory(edge, self._c_abbgraph)
#
#
#     def vertices(self):
#         cdef cy_helper.SubgraphRange[cfg.ABBGraph] ra = cy_helper.SubgraphRange[cfg.ABBGraph](deref(self._c_abbgraph))
#         for vertex in ra:
#             py_abb = abb_factory(vertex, self._c_abbgraph)
#             yield py_abb
#
#     def functions(self):
#         cdef py_func
#         cdef FuncDesc* func_ptr
#         cdef cy_helper.PtrRange[CABBGraph.children_iterator, FuncDesc] ra = make_ptr_range[CABBGraph.children_iterator, FuncDesc](deref(self._c_abbgraph).children())
#         for func_ptr in ra:
#             py_func = function_factory(func_ptr, self._c_abbgraph)
#             yield py_func


cdef class Graph:
    # TODO make this a unique pointer once the graph transition is done
    cdef newgraph.Graph* _c_graph

    # def __cinit__(self):
    #     self._c_graph = make_unique[cgraph.Graph]()

    def abbs(self):
        cdef ABBGraph g = ABBGraph()
        g._c_graph = make_unique[cfg_wrapper.ABBGraph](cfg_wrapper.ABBGraph(self._c_graph.abbs()))
        return g


cpdef get_type_hash(name):
    hash_type = 0
    if name == "Function":
        hash_type = typeid(cgraph.Function).hash_code()
    elif name == "ABB":
        hash_type = typeid(cgraph.ABB).hash_code()
    elif name == "Semaphore":
        hash_type = typeid(cgraph.Semaphore).hash_code()
    elif name == "Task":
        hash_type = typeid(cgraph.Task).hash_code()
    elif name == "Event":
        hash_type = typeid(cgraph.Event).hash_code()
    elif name == "Queue":
        hash_type = typeid(cgraph.Queue).hash_code()
    elif name == "Mutex":
        hash_type = typeid(cgraph.Mutex).hash_code()
    elif name == "Timer":
        hash_type = typeid(cgraph.Timer).hash_code()
    elif name == "Buffer":
        hash_type = typeid(cgraph.Buffer).hash_code()
    elif name == "QueueSet":
        hash_type = typeid(cgraph.QueueSet).hash_code()
    elif name == "RTOS":
        hash_type = typeid(cgraph.RTOS).hash_code()
    elif name == "ISR":
        hash_type = typeid(cgraph.ISR).hash_code()
    elif name == "CoRoutine":
        hash_type = typeid(cgraph.CoRoutine).hash_code()

    return hash_type


class start_scheduler_relation(IntEnum):
    after = <int> cgraph.after
    uncertain = <int> cgraph.uncertain
    before = <int> cgraph.before
    not_defined = <int> cgraph.not_defined


class call_definition_type(IntEnum):
    sys_call = <int> cgraph.sys_call
    func_call = <int> cgraph.func_call
    no_call = <int> cgraph.no_call
    has_call = <int> cgraph.has_call
    computation = <int> cgraph.computation


class timer_type(IntEnum):
    oneshot = <int> cgraph.oneshot
    autoreload = <int> cgraph.autoreload
    autostart = <int> cgraph.autostart
    not_autostart = <int> cgraph.autostart


class syscall_definition_type(IntEnum):
    undefined = <int> cgraph.undefined
    computate = <int> cgraph.computate
    create = <int> cgraph.create
    destroy = <int> cgraph.destroy
    receive = <int> cgraph.receive
    commit = <int> cgraph.commit
    release = <int> cgraph.release
    schedule = <int> cgraph.schedule
    reset = <int> cgraph.reset
    activate = <int> cgraph.activate
    enable = <int> cgraph.enable
    add = <int> cgraph.add
    disable = <int> cgraph.disable
    take_out = <int> cgraph.take_out
    wait = <int> cgraph.wait
    take = <int> cgraph.take
    synchronize = <int> cgraph.synchronize
    set_priority = <int> cgraph.set_priority
    resume = <int> cgraph.resume
    suspend = <int> cgraph.suspend
    exit_critical = <int> cgraph.exit_critical
    enter_critical = <int> cgraph.enter_critical
    start_scheduler = <int> cgraph.start_scheduler
    end_scheduler = <int> cgraph.end_scheduler
    chain = <int> cgraph.chain
    delay = <int> cgraph.delay

# class hook_type(IntEnum):
    # start_up  = <int> cgraph.start_up
    # shut_down = <int> cgraph.shut_down
    # pre_task   = <int> cgraph.pre_task
    # post_task  = <int> cgraph.post_task
    # failed = <int> cgraph.failed
    # error = <int> cgraph.error
    # idle = <int> cgraph.idle
    # tick = <int> cgraph.tick
    # no_hook = <int> cgraph.no_hook


class protocol_type(IntEnum):
    none = <int> cgraph.none
    priority_inheritance = <int> cgraph.priority_inheritance
    priority_ceiling = <int> cgraph.priority_ceiling


class message_property(IntEnum):
    none = <int> cgraph.none
    SEND_STATIC_INTERNAL = <int> cgraph.SEND_STATIC_INTERNAL
    SEND_STATIC_EXTERNAL = <int> cgraph.SEND_STATIC_EXTERNAL
    SEND_DYNAMIC_EXTERNAL = <int> cgraph.SEND_DYNAMIC_EXTERNAL
    SEND_ZERO_INTERNAL = <int> cgraph.SEND_ZERO_INTERNAL
    SEND_ZERO_EXTERNAL = <int> cgraph.SEND_ZERO_EXTERNAL
    RECEIVE_ZERO_INTERNAL = <int> cgraph.RECEIVE_ZERO_INTERNAL
    RECEIVE_ZERO_EXTERNAL = <int> cgraph.RECEIVE_ZERO_EXTERNAL
    RECEIVE_UNQUEUED_INTERNAL = <int> cgraph.RECEIVE_UNQUEUED_INTERNAL
    RECEIVE_QUEUED_INTERNAL = <int> cgraph.RECEIVE_QUEUED_INTERNAL
    RECEIVE_QUEUED_EXTERNAL = <int> cgraph.RECEIVE_QUEUED_EXTERNAL
    RECEIVE_UNQUEUED_EXTERNAL = <int> cgraph.RECEIVE_UNQUEUED_EXTERNAL
    RECEIVE_DYNAMIC_EXTERNAL = <int> cgraph.RECEIVE_DYNAMIC_EXTERNAL
    RECEIVE_ZERO_SENDERS = <int> cgraph.RECEIVE_ZERO_SENDERS


class data_type(IntEnum):
    string = 1
    integer = 2
    unsigned_integer = 3
    long = 4


class os_type(IntEnum):

    FreeRTOS = <int> cgraph.FreeRTOS
    OSEK = <int> cgraph.OSEK


cpdef cast_expected_syscall_argument_types(argument_types):

    cdef data_type_hash

    pylist = []

    for argument_type in argument_types:
        if isinstance(argument_type, list):

            pylist.append(cast_expected_syscall_argument_types(argument_type))

        else:

            if argument_type == data_type.integer:
                data_type_hash = typeid(long).hash_code()
            elif argument_type == data_type.string:
                data_type_hash = typeid(string).hash_code()
            elif argument_type == data_type.long:
                data_type_hash = typeid(long).hash_code()

            pylist.append(data_type_hash)

    return pylist

cdef extern from "<typeinfo>" namespace "std" nogil:
    cdef cppclass type_info:
        const char* name()
        int before(const type_info &)
        bool operator == (const type_info &)
        bool operator != (const type_info &)
        # C++11-only
        size_t hash_code()


cdef create_from_pointer(shared_ptr[cgraph.Vertex] vertex):

    # cdef const type_info* info = &typeid(cgraph.Vertex())
    a = {typeid(cgraph.Vertex).hash_code(): Vertex,
         typeid(cgraph.Function).hash_code(): PyFunction,
         typeid(cgraph.ABB).hash_code(): PyABB,
         typeid(cgraph.Counter).hash_code(): Counter,
         typeid(cgraph.Task).hash_code(): Task,
         typeid(cgraph.Queue).hash_code(): Queue,
         typeid(cgraph.Buffer).hash_code(): Buffer,
         typeid(cgraph.Timer).hash_code(): Timer,
         typeid(cgraph.Semaphore).hash_code(): Semaphore,
         typeid(cgraph.Event).hash_code(): Event,
         typeid(cgraph.Edge).hash_code(): Edge,
         typeid(cgraph.RTOS).hash_code(): RTOS,
         typeid(cgraph.ISR).hash_code(): ISR,
         typeid(cgraph.Mutex).hash_code(): Mutex,
         typeid(cgraph.QueueSet).hash_code(): QueueSet,
         }
    if (vertex == NULL):
        return None

    cdef size_t type_id = deref(vertex).get_type()

    cdef Vertex py_obj = a[type_id](None, None, None, _raw=True)

    py_obj._c_vertex = vertex
    return py_obj


cdef create_abb(shared_ptr[cgraph.ABB] abb):
    cdef Vertex py_obj = PyABB(None, None, None, _raw=True)
    py_obj._c_vertex = spc[cgraph.Vertex, cgraph.ABB](abb)
    return py_obj


cdef class PyGraph:

    def __cinit__(self):
        self._c_graph = make_shared[cgraph.Graph]()

    @property
    def new_graph(self):
        cdef Graph g = Graph()
        g._c_graph = &deref(self._c_graph).new_graph
        return g

    def __str__(self):
        return to_string(deref(self._c_graph)).decode('utf-8')

    def set_vertex(self, Vertex vertex):
        deref(self._c_graph).set_vertex(vertex._c_vertex)

    def get_vertex(self, seed):
        cdef shared_ptr[cgraph.Vertex]  vertex = deref(self._c_graph).get_vertex(seed)
        return create_from_pointer(vertex)

    def remove_vertex(self, seed):
        return deref(self._c_graph).remove_vertex(seed)

    def get_type_vertices(self, name):
        cdef c_hash_type = get_type_hash(name)
        cdef clist[shared_ptr[cgraph.Vertex]] vertices = deref(self._c_graph).get_type_vertices(c_hash_type)
        pylist = []

        for vertex in vertices:
            pylist.append(create_from_pointer(vertex))

        return pylist

    def set_os_type(self, int type_os):
        cdef cgraph.os_type tmp_type = <cgraph.os_type> type_os
        return deref(self._c_graph).set_os_type(tmp_type)

    #@staticmethod
    # cdef create_from_pointer(shared_ptr[cgraph.Vertex] vertex):
        #py_obj = Vertex(None, "empty", _raw=True)
        #py_obj._c_vertex = vertex
        # return py_obj

cdef class Edge:

    cdef shared_ptr[cgraph.Edge] _c_edge

    def __cinit__(self, PyGraph graph, name, Vertex start_vertex, Vertex target_vertex, PyABB abb_reference, *args, _raw=False, **kwargs):
        # prevent double constructions
        # https://github.com/cython/cython/wiki/WrappingSetOfCppClasses
        if type(self) != Edge:
            return
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_edge = make_shared[cgraph.Edge](graph._c_graph.get(), bname, start_vertex._c_vertex, target_vertex._c_vertex, spc[cgraph.ABB, cgraph.Vertex](abb_reference._c_vertex))

    def get_start_vertex(self):

        cdef shared_ptr[cgraph.Vertex] start = deref(self._c_edge).get_start_vertex()
        if start != NULL:
            return create_from_pointer(start)
        else:
            return None

    def get_target_vertex(self):

        cdef shared_ptr[cgraph.Vertex] target = deref(self._c_edge).get_target_vertex()

        if target != NULL:

            return create_from_pointer(target)
        else:
            return None

    def get_name(self):
        return deref(self._c_edge).get_name().decode('UTF-8')

    def get_abb_reference(self):

        cdef shared_ptr[cgraph.ABB] abb_reference = deref(self._c_edge).get_abb_reference()
        cdef shared_ptr[cgraph.Vertex] v_ref = spc[cgraph.Vertex, cgraph.ABB](abb_reference)
        return create_from_pointer(v_ref)


cdef class Vertex:

    cdef shared_ptr[cgraph.Vertex] _c_vertex

    def __cinit__(self, PyGraph graph, name, *args, _raw=False, **kwargs):
        # prevent double constructions
        # https://github.com/cython/cython/wiki/WrappingSetOfCppClasses
        if type(self) != Vertex:
            return
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = make_shared[cgraph.Vertex](graph._c_graph.get(), bname)

    #@staticmethod
    # cdef create_from_pointer(shared_ptr[cgraph.Vertex] vertex):
        #py_obj = Vertex(None, None, _raw=True)
        #py_obj._c_vertex = vertex
        # return py_obj

    def get_name(self):
        return deref(self._c_vertex).get_name().decode('UTF-8')

    def get_seed(self):
        return deref(self._c_vertex).get_seed()

    def get_type(self):
        return deref(self._c_vertex).get_type()

    def get_multiple_create(self):
        return deref(self._c_vertex).get_multiple_create()

    def get_unsure_create(self):
        return deref(self._c_vertex).get_unsure_create()

    def set_handler_name(self, str name):
        cdef string handlername = name.encode('UTF-8')
        deref(self._c_vertex).set_handler_name(handlername)

    def get_outgoing_edges(self):

        cdef clist[shared_ptr[cgraph.Edge]] edges = deref(self._c_vertex).get_outgoing_edges()
        cdef shared_ptr[cgraph.Vertex] start
        pylist = []
        for edge in edges:

            py_obj = Edge(None, None, None, None, None, _raw=True)

            py_obj._c_edge = edge

            start = deref(edge).get_start_vertex()

            pylist.append(py_obj)

        return pylist

    def get_start_scheduler_creation_flag(self):
        return deref(self._c_vertex).get_start_scheduler_creation_flag()


cdef class Counter(Vertex):
    cdef inline shared_ptr[cgraph.Counter] _c(self):
        return spc[cgraph.Counter, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Counter](make_shared[cgraph.Counter](graph._c_graph.get(), bname))

    def set_max_allowed_value(self, unsigned long max_allowed_value):
        deref(self._c()).set_max_allowed_value(max_allowed_value)

    def set_ticks_per_base(self, unsigned long ticks):
        deref(self._c()).set_ticks_per_base(ticks)

    def set_min_cycle(self, unsigned long min_cycle):
        deref(self._c()).set_min_cycle(min_cycle)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')


cdef class Event(Vertex):
    MASK_AUTO = cgraph.MASK_AUTO

    cdef inline shared_ptr[cgraph.Event] _c(self):
        return spc[cgraph.Event, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Event](make_shared[cgraph.Event](graph._c_graph.get(), bname))

    def set_event_mask(self, int64_t mask):
        return deref(self._c()).set_event_mask(mask)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')


cdef class ISR(Vertex):
    cdef inline shared_ptr[cgraph.ISR] _c(self):
        return spc[cgraph.ISR, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.ISR](make_shared[cgraph.ISR](graph._c_graph.get(), bname))

    def set_category(self, int category):
        deref(self._c()).set_category(category)

    def set_priority(self, int priority):
        deref(self._c()).set_priority(priority)

    def get_category(self):
        cdef int category = deref(self._c()).get_category()
        return category

    def set_resource_reference(self, str resource_name):
        cdef string c_resource_name = resource_name.encode('UTF-8')
        deref(self._c()).set_resource_reference(c_resource_name)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')

    def get_definition_function(self):
        cdef shared_ptr[cgraph.Function] function = deref(self._c()).get_definition_function()
        return create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function))

    def set_definition_function(self, str function_name):
        cdef string c_function_name = function_name.encode('UTF-8')
        return deref(self._c()).set_definition_function(c_function_name)

cdef class Mutex(Vertex):
    cdef inline shared_ptr[cgraph.Mutex] _c(self):
        return spc[cgraph.Mutex, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Mutex](make_shared[cgraph.Mutex](graph._c_graph.get(), bname))

    def set_resource_property(self, str prop, str linked_resource):
        cdef string c_prop = prop.encode('UTF-8')
        cdef string c_linked_resource = linked_resource.encode('UTF-8')
        deref(self._c()).set_resource_property(c_prop, c_linked_resource)

    def set_protocol_type(self, int protocol):
        cdef cgraph.protocol_type t = <cgraph.protocol_type> protocol
        deref(self._c()).set_protocol_type(t)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')


cdef class Task(Vertex):

    cdef inline shared_ptr[cgraph.Task] _c(self):
        return spc[cgraph.Task, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Task](make_shared[cgraph.Task](graph._c_graph.get(), bname))

    def set_priority(self, unsigned long priority):
        return deref(self._c()).set_priority(priority)

    def set_activation(self, unsigned long activation):
        return deref(self._c()).set_activation(activation)

    def get_activation(self):
        return deref(self._c()).get_activation()

    def set_autostart(self, bool autostart):
        return deref(self._c()).set_autostart(autostart)

    def is_autostarted(self):
        return deref(self._c()).is_autostarted()

    def set_definition_function(self, str function_name):
        cdef string c_function_name = function_name.encode('UTF-8')
        return deref(self._c()).set_definition_function(c_function_name)

    def set_appmode(self, str appmode_name):
        cdef string c_appmode_name = appmode_name.encode('UTF-8')
        return deref(self._c()).set_appmode(c_appmode_name)

    def set_scheduler(self, bool schedule):
        return deref(self._c()).set_schedule(schedule)

    def is_scheduled(self):
        return deref(self._c()).is_scheduled()

    def set_resource_reference(self, str resource_name):
        cdef string c_resource_name = resource_name.encode('UTF-8')
        return deref(self._c()).set_resource_reference(c_resource_name)

    def set_event_reference(self, str event_name):
        cdef string c_event_name = event_name.encode('UTF-8')
        return deref(self._c()).set_event_reference(c_event_name)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')

    def get_definition_function(self):
        cdef shared_ptr[cgraph.Function] function = deref(self._c()).get_definition_function()
        return create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function))

    def get_stacksize(self):
        return deref(self._c()).get_stacksize()

    def get_priority(self):
        return deref(self._c()).get_priority()


cdef class PyFunction(Vertex):

    cdef inline shared_ptr[cgraph.Function] _c(self):
        return spc[cgraph.Function, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Function](make_shared[cgraph.Function](graph._c_graph.get(), bname))

    def get_atomic_basic_blocks(self):

        cdef clist[shared_ptr[cgraph.ABB]] abbs = deref(self._c()).get_atomic_basic_blocks()

        pylist = []

        for abb in abbs:

            #shared_ptr[cgraph.ABB] = abb
            pylist.append(create_from_pointer(
                spc[cgraph.Vertex, cgraph.ABB](abb)))

        return pylist

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')

    def set_has_syscall(self, flag):
        cdef bool has_syscall = flag
        return deref(self._c()).has_syscall(has_syscall)

    def get_has_syscall(self):

        return deref(self._c()).has_syscall()

    def remove_abb(self, seed):
        return deref(self._c()).remove_abb(seed)

    def set_exit_abb(self, PyABB abb):
        return deref(self._c()).set_exit_abb(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    def get_exit_abb(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_exit_abb()
        if abb != NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None

    def get_entry_abb(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_entry_abb()
        if abb != NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None

    def get_called_functions(self):

        cdef cvector[shared_ptr[cgraph.Function]] function_list = deref(self._c()).get_called_functions()

        pylist = []

        for function in function_list:
            pylist.append(create_from_pointer(
                spc[cgraph.Vertex, cgraph.Function](function)))

        return pylist

    def set_definition_vertex(self, Vertex vertex):
        return deref(self._c()).set_definition_vertex(vertex._c_vertex)

    # def get_call_target_instance(self):
        # return deref(self._c()).get_call_target_instance()

    # cdef get_function(self):
    #	return deref(self._c())

    #@staticmethod
    # cdef create_from_pointer(shared_ptr[cgraph.Function] function):
    #	# we have to create an empty dummy graph to fulfil the constructor
    #	py_obj = Function(PyGraph(), "empty", _raw=True)
    #	py_obj._c = function
    #	return py_obj


cdef class PyABB(Vertex):

    cdef inline shared_ptr[cgraph.ABB] _c(self):
        return spc[cgraph.ABB, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph,  str name, PyFunction function_reference, *args, _raw=False, **kwargs):
        # def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.ABB](make_shared[cgraph.ABB](graph._c_graph.get(), spc[cgraph.Function, cgraph.Vertex](function_reference._c_vertex), bname))

    def convert_call_to_syscall(self, name):
        cdef bname
        if isinstance(name, str):
            bname = name.encode('UTF-8')
        else:
            bname = name

        return deref(self._c()).convert_call_to_syscall(bname)

    def get_syscall_name(self):
        cdef bytes name = deref(self._c()).get_syscall_name()
        return deref(self._c()).get_syscall_name()

    def get_call_name(self):
        cdef call_name = deref(self._c()).get_call_name()

        cdef bytes tmp_name = call_name

        return tmp_name

    def get_call_type(self):
        cdef cgraph.call_definition_type t = deref(self._c()).get_call_type()
        return call_definition_type(<int> t)

    def set_call_type(self, int syscall_type):
        cdef cgraph.call_definition_type t = <cgraph.call_definition_type> syscall_type
        return deref(self._c()).set_call_type(t)

    def set_syscall_type(self, int syscall_type):
        cdef cgraph.syscall_definition_type t = <cgraph.syscall_definition_type> syscall_type
        return deref(self._c()).set_syscall_type(t)

    def get_syscall_type(self):
        cdef cgraph.syscall_definition_type t = deref(self._c()).get_syscall_type()
        cdef int num = <int> t
        return syscall_definition_type(num)

    def set_call_target_instance(self, ptype):

        for hash_type in ptype:
            deref(self._c()).set_call_target_instance(<size_t> hash_type)

    def get_call_argument_types(self):

        cdef clist[clist[size_t]] call_arguments_types = deref(self._c()).get_call_argument_types()

        tmp_call_argument_types = []

        for argument in call_arguments_types:
            argument_types = []
            for argument_type in argument:
                argument_types.append(argument_type)

            tmp_call_argument_types.append(argument_types)

        return tmp_call_argument_types

    def expend_call_sites(self, PyABB abb):
        return deref(self._c()).expend_call_sites(abb._c())

    def remove_successor(self, PyABB abb):
        return deref(self._c()).remove_successor(abb._c())

    def remove_predecessor(self, PyABB abb):
        return deref(self._c()).remove_predecessor(abb._c())

    def adapt_exit_bb(self, PyABB abb):
        return deref(self._c()).adapt_exit_bb(abb._c())

    def get_called_functions(self):

        cdef shared_ptr[cgraph.Function] function = deref(self._c()).get_called_function()

        pylist = []

        if function != NULL:
            pylist.append(create_from_pointer(
                spc[cgraph.Vertex, cgraph.Function](function)))

        return pylist

    def get_successors(self):

        cdef cset[shared_ptr[cgraph.ABB]] abb_set = deref(self._c()).get_ABB_successors()

        pylist = set()

        for abb in abb_set:
            pylist.add(create_from_pointer(
                spc[cgraph.Vertex, cgraph.ABB](abb)))

        return pylist

    def get_predecessors(self):

        cdef cset[shared_ptr[cgraph.ABB]] abb_set = deref(self._c()).get_ABB_predecessors()

        pylist = set()

        for abb in abb_set:
            pylist.add(create_from_pointer(
                spc[cgraph.Vertex, cgraph.ABB](abb)))

        return pylist

    def get_single_successor(self):

        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_single_ABB_successor()

        if abb == NULL:
            print("error in getting single abb successor")

        return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))

    def is_mergeable(self):
        return deref(self._c()).is_mergeable()

    def has_single_successor(self):
        return deref(self._c()).has_single_successor()

    def append_basic_blocks(self, PyABB  abb):
        return deref(self._c()).append_basic_blocks(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    def set_successor(self, PyABB  abb):
        deref(self._c()).set_ABB_successor(
            spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    def set_predecessor(self, PyABB  abb):
        deref(self._c()).set_ABB_predecessor(
            spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    def get_parent_function(self):

        cdef shared_ptr[cgraph.Function] function = deref(self._c()).get_parent_function()

        if function == NULL:
            print("error in getting function parent")

        return create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function))

    def get_dominator(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_dominator()
        if abb != NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None

    def get_postdominator(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_postdominator()
        if abb != NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None

    def set_handler_argument_index(self, index):
        return deref(self._c()).set_handler_argument_index(index)

    def get_start_scheduler_relation(self):

        cdef cgraph.start_scheduler_relation relation = deref(self._c()).get_start_scheduler_relation()
        return start_scheduler_relation(<int> relation)

    def get_loop_information(self):

        cdef bool loop_information = deref(self._c()).get_loop_information()
        return loop_information

    def dominates(self, PyABB abb):
        return deref(self._c()).dominates(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    def postdominates(self, PyABB abb):
        return deref(self._c()).postdominates(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    def print_information(self):
        return deref(self._c()).print_information()


cdef class Queue(Vertex):

    cdef inline shared_ptr[cgraph.Queue] _c(self):
        return spc[cgraph.Queue, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Queue](make_shared[cgraph.Queue](graph._c_graph.get(), bname))

    def set_message_property(self, int input_property):
        cdef cgraph.message_property t = <cgraph.message_property> input_property
        deref(self._c()).set_message_property(t)

    def set_length(self, int length):
        deref(self._c()).set_length(length)


cdef class Semaphore(Vertex):

    cdef inline shared_ptr[cgraph.Semaphore] _c(self):
        return spc[cgraph.Semaphore, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Semaphore](make_shared[cgraph.Semaphore](graph._c_graph.get(), bname))


cdef class Buffer(Vertex):

    cdef inline shared_ptr[cgraph.Buffer] _c(self):
        return spc[cgraph.Buffer, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Buffer](make_shared[cgraph.Buffer](graph._c_graph.get(), bname))


cdef class QueueSet(Vertex):

    cdef inline shared_ptr[cgraph.QueueSet] _c(self):
        return spc[cgraph.QueueSet, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.QueueSet](make_shared[cgraph.QueueSet](graph._c_graph.get(), bname))


cdef class Timer(Vertex):

    cdef inline shared_ptr[cgraph.Timer] _c(self):
        return spc[cgraph.Timer, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Timer](make_shared[cgraph.Timer](graph._c_graph.get(), bname))

    def get_definition_function(self):
        cdef shared_ptr[cgraph.Function] function = deref(self._c()).get_callback_function()

        return create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function))

    def set_callback_function(self, str function_name):
        cdef string c_function_name = function_name.encode('UTF-8')
        return deref(self._c()).set_callback_function(c_function_name)

    def set_task_reference(self, str task_name):
        cdef string c_task_name = task_name.encode('UTF-8')
        deref(self._c()).set_task_reference(c_task_name)

    def set_counter_reference(self, str counter_name):
        cdef string c_counter_name = counter_name.encode('UTF-8')
        deref(self._c()).set_counter_reference(c_counter_name)

    def set_event_reference(self, str event_name):
        cdef string c_event_name = event_name.encode('UTF-8')
        deref(self._c()).set_event_reference(c_event_name)

    def set_callback_reference(self, str callback_name):
        cdef string c_callback_name = callback_name.encode('UTF-8')
        deref(self._c()).set_callback_function(c_callback_name)

    def set_appmode(self, str appmode_name):
        cdef string c_appmode_name = appmode_name.encode('UTF-8')
        deref(self._c()).set_appmode(c_appmode_name)

    def set_timer_type(self, int timer_type):
        cdef cgraph.timer_type t = <cgraph.timer_type> timer_type
        return deref(self._c()).set_timer_type(t)

    def set_alarm_time(self, unsigned int alarm_time):
        deref(self._c()).set_alarm_time(alarm_time)

    def set_cycle_time(self, unsigned int cycle_time):
        deref(self._c()).set_cycle_time(cycle_time)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')

cdef class RTOS(Vertex):

    cdef inline shared_ptr[cgraph.RTOS] _c(self):
        return spc[cgraph.RTOS, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.RTOS](make_shared[cgraph.RTOS](graph._c_graph.get(), bname))

    def enable_startup_hook(self, attribute):

        cdef bool enable = False
        if attribute == "FALSE":
            enable = False
        elif attribute == "TRUE":
            enable = True
        else:
            print("unexpected OSEK hook enable attribute value")

        deref(self._c()).enable_startup_hook(enable)

    def enable_posttask_hook(self, attribute):

        cdef bool enable = False
        if attribute == "FALSE":
            enable = False
        elif attribute == "TRUE":
            enable = True
        else:
            print("unexpected OSEK hook enable attribute value")

        deref(self._c()).enable_posttask_hook(enable)

    def enable_pretask_hook(self, attribute):

        cdef bool enable = False
        if attribute == "FALSE":
            enable = False
        elif attribute == "TRUE":
            enable = True
        else:
            print("unexpected OSEK hook enable attribute value")

        deref(self._c()).enable_pretask_hook(enable)

    def enable_shutdown_hook(self, attribute):

        cdef bool enable = False
        if attribute == "FALSE":
            enable = False
        elif attribute == "TRUE":
            enable = True
        else:
            print("unexpected OSEK hook enable attribute value")

        deref(self._c()).enable_shutdown_hook(enable)

    def enable_error_hook(self, attribute):

        cdef bool enable = False
        if attribute == "FALSE":
            enable = False
        elif attribute == "TRUE":
            enable = True
        else:
            print("unexpected OSEK hook enable attribute value")

        deref(self._c()).enable_error_hook(enable)


cdef class CoRoutine(Vertex):

    cdef inline shared_ptr[cgraph.CoRoutine] _c(self):
        return spc[cgraph.CoRoutine, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.CoRoutine](make_shared[cgraph.CoRoutine](graph._c_graph.get(), bname))
