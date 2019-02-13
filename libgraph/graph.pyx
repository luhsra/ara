# distutils: language = c++
# vim: set et ts=4 sw=4:

cimport cgraph
cimport graph

#from arsa.steps.enumerations import Type

from libcpp.memory cimport shared_ptr, make_shared
from libcpp.string cimport string
from libcpp.list cimport list as clist
from libcpp.vector cimport vector as cvector

from libcpp cimport bool

from backported_memory cimport static_pointer_cast as spc
from backported_memory cimport dynamic_pointer_cast as dpc
from cython.operator cimport typeid
from cython.operator cimport dereference as deref
from enum import IntEnum



from libcpp.typeinfo cimport type_info




cpdef get_type_hash(name):
    hash_type = 0
    if name== "Function":
        hash_type = typeid(cgraph.Function).hash_code()
    elif name== "ABB":
        hash_type = typeid(cgraph.ABB).hash_code()
    elif name == "Semaphore":
        hash_type = typeid(cgraph.Semaphore).hash_code()
    elif name == "Task":
        hash_type = typeid(cgraph.Task).hash_code()
    elif name == "Event":
        hash_type = typeid(cgraph.Event).hash_code()
    elif name == "Queue":
        hash_type = typeid(cgraph.Queue).hash_code()
    elif name == "Resource":
        hash_type = typeid(cgraph.Resource).hash_code()
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

    return  hash_type

class start_scheduler_relation(IntEnum):
    after  = <int> cgraph.after
    uncertain = <int> cgraph.uncertain
    before   = <int> cgraph.before
    not_defined  = <int> cgraph.not_defined



class call_definition_type(IntEnum):
    sys_call  = <int> cgraph.sys_call
    func_call = <int> cgraph.func_call
    no_call   = <int> cgraph.no_call
    has_call  = <int> cgraph.has_call
    computation  = <int> cgraph.computation


class timer_type(IntEnum):
    oneshot  = <int> cgraph.oneshot
    autoreload = <int> cgraph.autoreload
    autostart   = <int> cgraph.autostart
    not_autostart   = <int> cgraph.autostart



class syscall_definition_type(IntEnum):
    computate  = <int> cgraph.computate
    create = <int> cgraph.create
    destroy   = <int> cgraph.destroy
    receive  = <int> cgraph.receive
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

#class hook_type(IntEnum):
    #start_up  = <int> cgraph.start_up
    #shut_down = <int> cgraph.shut_down
    #pre_task   = <int> cgraph.pre_task
    #post_task  = <int> cgraph.post_task
    #failed = <int> cgraph.failed
    #error = <int> cgraph.error
    #idle = <int> cgraph.idle
    #tick = <int> cgraph.tick
    #no_hook = <int> cgraph.no_hook

class data_type(IntEnum):
    string = 1
    integer = 2
    unsigned_integer = 3
    long = 4

class os_type(IntEnum):

    FreeRTOS = <int> cgraph.FreeRTOS
    OSEK = <int> cgraph.OSEK

cpdef cast_expected_syscall_argument_types(argument_types ):

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
        int before(const type_info&)
        bool operator==(const type_info&)
        bool operator!=(const type_info&)
        # C++11-only
        size_t hash_code()



cdef create_from_pointer(shared_ptr[cgraph.Vertex] vertex):

    #cdef const type_info* info = &typeid(cgraph.Vertex())
    a = {typeid(cgraph.Vertex).hash_code(): Vertex,
        typeid(cgraph.Function).hash_code(): Function,
        typeid(cgraph.ABB).hash_code(): ABB,
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
        typeid(cgraph.Resource).hash_code(): Resource,
        typeid(cgraph.QueueSet).hash_code(): QueueSet,
    }
    if (vertex == NULL):
        return None


    cdef size_t type_id = deref(vertex).get_type()

    cdef Vertex py_obj = a[type_id](None, None,None,_raw=True)

    py_obj._c_vertex = vertex
    return py_obj


cdef create_abb(shared_ptr[cgraph.ABB] abb):
    cdef Vertex py_obj = ABB(None, None, None, _raw=True)
    py_obj._c_vertex = spc[cgraph.Vertex, cgraph.ABB](abb)
    return py_obj


cdef class PyGraph:

    def __cinit__(self):
        self._c_graph = cgraph.Graph()

    def set_vertex(self, Vertex vertex):
        self._c_graph.set_vertex(vertex._c_vertex)

    def get_vertex(self, seed ):
        cdef shared_ptr[cgraph.Vertex]  vertex = self._c_graph.get_vertex(seed)
        return create_from_pointer(vertex)

    def remove_vertex(self,seed):
        return self._c_graph.remove_vertex(seed)


    def get_type_vertices(self, name):


        cdef c_hash_type = get_type_hash(name)

        cdef clist[shared_ptr[cgraph.Vertex]] vertices = self._c_graph.get_type_vertices(c_hash_type)

        pylist = []

        #print("-------------------Size of Vertices:", vertices.size())

        for vertex in vertices:
            pylist.append(create_from_pointer(vertex))


        #print(pylist)

        return pylist

    def set_os_type(self, int type_os):
        cdef cgraph.os_type tmp_type = <cgraph.os_type> type_os
        return self._c_graph.set_os_type(tmp_type)




    #@staticmethod
    #cdef create_from_pointer(shared_ptr[cgraph.Vertex] vertex):
        #py_obj = Vertex(None, "empty", _raw=True)
        #py_obj._c_vertex = vertex
        #return py_obj

cdef class Edge:

    cdef shared_ptr[cgraph.Edge] _c_edge

    def __cinit__(self, PyGraph graph, name,Vertex start_vertex , Vertex target_vertex , ABB abb_reference , *args, _raw=False, **kwargs):
        # prevent double constructions
        # https://github.com/cython/cython/wiki/WrappingSetOfCppClasses
        if type(self) != Edge:
            return
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_edge = make_shared[cgraph.Edge](&graph._c_graph, bname,start_vertex._c_vertex ,target_vertex._c_vertex ,spc[cgraph.ABB, cgraph.Vertex](abb_reference._c_vertex))

    def get_start_vertex(self):

        cdef shared_ptr[cgraph.Vertex] start = deref(self._c_edge).get_start_vertex()
        if start!= NULL:
            return create_from_pointer(start)
        else:
            return None

    def get_target_vertex(self):


        cdef shared_ptr[cgraph.Vertex] target = deref(self._c_edge).get_target_vertex()

        if target!= NULL:

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
            self._c_vertex = make_shared[cgraph.Vertex](&graph._c_graph, bname)

    #@staticmethod
    #cdef create_from_pointer(shared_ptr[cgraph.Vertex] vertex):
        #py_obj = Vertex(None, None, _raw=True)
        #py_obj._c_vertex = vertex
        #return py_obj

    def get_name(self):
        return deref(self._c_vertex).get_name().decode('UTF-8')

    def get_seed(self):
        return deref(self._c_vertex).get_seed()

    def get_type(self):
        return deref(self._c_vertex).get_type()

    def	set_handler_name(self,str name):
        cdef string handlername = name.encode('UTF-8')
        deref(self._c_vertex).set_handler_name(handlername)

    def	get_outgoing_edges(self):

        cdef clist[shared_ptr[cgraph.Edge]] edges = deref(self._c_vertex).get_outgoing_edges()
        cdef shared_ptr[cgraph.Vertex] start
        pylist = []
        for edge in edges:

            py_obj= Edge(None, None,None,None,None,_raw=True)

            py_obj._c_edge = edge

            start = deref(edge).get_start_vertex()

            pylist.append(py_obj)

        return pylist








cdef class Counter(Vertex):
    cdef inline shared_ptr[cgraph.Counter] _c(self):
        return spc[cgraph.Counter, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Counter](make_shared[cgraph.Counter](&graph._c_graph, bname))

    def set_max_allowed_value(self, unsigned long max_allowed_value):
        deref(self._c()).set_max_allowed_value(max_allowed_value)

    def set_ticks_per_base(self, unsigned long ticks):
        deref(self._c()).set_ticks_per_base(ticks)

    def set_min_cycle(self, unsigned long min_cycle):
        deref(self._c()).set_min_cycle(min_cycle)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')


cdef class Event(Vertex):
    cdef inline shared_ptr[cgraph.Event] _c(self):
        return spc[cgraph.Event, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Event](make_shared[cgraph.Event](&graph._c_graph, bname))

    def set_event_mask(self, unsigned long mask):
        return deref(self._c()).set_event_mask(mask)

    def set_event_mask_auto(self):
        return deref(self._c()).set_event_mask_auto()

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')




cdef class ISR(Vertex):
    cdef inline shared_ptr[cgraph.ISR] _c(self):
        return spc[cgraph.ISR, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.ISR](make_shared[cgraph.ISR](&graph._c_graph, bname))

    def set_category(self, int category):
        deref(self._c()).set_category(category)

    def get_category(self):
        cdef int category = deref(self._c()).get_category()
        return category

    def set_resource_reference(self, str resource_name):
        cdef string c_resource_name = resource_name.encode('UTF-8')
        deref(self._c()).set_resource_reference(c_resource_name)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')

    def get_definition_function(self):
        cdef shared_ptr [cgraph.Function] function = deref(self._c()).get_definition_function()
        return create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function))

    def set_definition_function(self, str function_name):
        cdef string c_function_name = function_name.encode('UTF-8')
        return deref(self._c()).set_definition_function(c_function_name)

cdef class Resource(Vertex):
    cdef inline shared_ptr[cgraph.Resource] _c(self):
        return spc[cgraph.Resource, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Resource](make_shared[cgraph.Resource](&graph._c_graph, bname))

    def set_resource_property(self, str prop, str linked_resource):
        cdef string c_prop= prop.encode('UTF-8')
        cdef string c_linked_resource = linked_resource.encode('UTF-8')
        deref(self._c()).set_resource_property(c_prop, c_linked_resource)

    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')


cdef class Task(Vertex):

    cdef inline shared_ptr[cgraph.Task] _c(self):
        return spc[cgraph.Task, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Task](make_shared[cgraph.Task](&graph._c_graph, bname))

    def set_priority(self, unsigned long priority):
        return deref(self._c()).set_priority(priority)

    def set_activation(self, unsigned long activation):
        return deref(self._c()).set_activation(activation)

    def set_autostart(self, bool autostart):
        return deref(self._c()).set_autostart(autostart)

    def set_definition_function(self, str function_name):
        cdef string c_function_name = function_name.encode('UTF-8')
        return deref(self._c()).set_definition_function(c_function_name)

    def set_appmode(self, str appmode_name):
        cdef string c_appmode_name = appmode_name.encode('UTF-8')
        return deref(self._c()).set_appmode(c_appmode_name)

    def set_scheduler(self, str scheduler_name):
        cdef string c_scheduler_name = scheduler_name.encode('UTF-8')
        return deref(self._c()).set_scheduler(c_scheduler_name)

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




cdef class Function(Vertex):



    cdef inline shared_ptr[cgraph.Function] _c(self):
        return spc[cgraph.Function, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Function](make_shared[cgraph.Function](&graph._c_graph, bname))

    def get_atomic_basic_blocks(self):

        cdef clist[shared_ptr[cgraph.ABB]] abbs = deref(self._c()).get_atomic_basic_blocks()

        pylist = []


        for abb in abbs:

            #shared_ptr[cgraph.ABB] = abb
            pylist.append(create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb)))

        return pylist


    def get_name(self):
        return deref(self._c()).get_name().decode('UTF-8')

    def set_has_syscall(self,flag):
        cdef bool has_syscall= flag
        return deref(self._c()).has_syscall(has_syscall)

    def get_has_syscall(self):

        return deref(self._c()).has_syscall()

    def remove_abb(self,seed):
        return deref(self._c()).remove_abb(seed)

    def set_exit_abb(self, ABB abb):
        return deref(self._c()).set_exit_abb(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    def get_exit_abb(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_exit_abb()
        if abb!= NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None

    def get_entry_abb(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_entry_abb()
        if abb!= NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None


    def get_called_functions(self):

        cdef cvector[shared_ptr[cgraph.Function]] function_list  =  deref(self._c()).get_called_functions()


        pylist = []

        for function in function_list:
            pylist.append(create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function)))


        return pylist
    
    
    def set_definition_vertex(self,Vertex vertex):
        return deref(self._c()).set_definition_vertex(vertex._c_vertex)
    
    
    
    #def get_call_target_instance(self):
        #return deref(self._c()).get_call_target_instance()


    #cdef get_function(self):
    #	return deref(self._c())


    #@staticmethod
    #cdef create_from_pointer(shared_ptr[cgraph.Function] function):
    #	# we have to create an empty dummy graph to fulfil the constructor
    #	py_obj = Function(PyGraph(), "empty", _raw=True)
    #	py_obj._c = function
    #	return py_obj


cdef class ABB(Vertex):

    cdef inline shared_ptr[cgraph.ABB] _c(self):
        return spc[cgraph.ABB, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph,  str name ,Function function_reference, *args, _raw=False, **kwargs):
    #def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.ABB](make_shared[cgraph.ABB](&graph._c_graph,spc[cgraph.Function, cgraph.Vertex](function_reference._c_vertex) , bname))

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
        cdef call_name =  deref(self._c()).get_call_name()

        cdef bytes tmp_name = call_name

        return tmp_name

    def get_call_type(self):
        cdef cgraph.call_definition_type t = deref(self._c()).get_call_type()
        return call_definition_type(<int> t)

    def set_call_type(self, int syscall_type ):
        cdef cgraph.call_definition_type t = <cgraph.call_definition_type> syscall_type
        return deref(self._c()).set_call_type(t)

    def set_syscall_type(self, int syscall_type ):
        cdef cgraph.syscall_definition_type t = <cgraph.syscall_definition_type> syscall_type
        return deref(self._c()).set_syscall_type(t)

    def get_syscall_type(self):
        cdef cgraph.syscall_definition_type t = deref(self._c()).get_syscall_type()
        return syscall_definition_type(<int> t)

    def set_call_target_instance(self, ptype ):

        for hash_type in ptype:
            deref(self._c()).set_call_target_instance( <size_t>  hash_type)


    def get_call_argument_types(self ):

        cdef clist[clist[size_t]] call_arguments_types =  deref(self._c()).get_call_argument_types()

        tmp_call_argument_types = []


        for argument in call_arguments_types:
            argument_types = []
            for argument_type in argument:
                argument_types.append(argument_type)

            tmp_call_argument_types.append(argument_types)


        return tmp_call_argument_types


    def expend_call_sites(self,ABB abb):
        return deref(self._c()).expend_call_sites(abb._c())

    def remove_successor(self,ABB abb):
        return deref(self._c()).remove_successor(abb._c())

    def remove_predecessor(self,ABB abb):
        return deref(self._c()).remove_predecessor(abb._c())

    def adapt_exit_bb(self,ABB abb):
        return deref(self._c()).adapt_exit_bb(abb._c())


    def get_called_functions(self):

        cdef shared_ptr[cgraph.Function] function  =  deref(self._c()).get_called_function()


        pylist = []

        if function != NULL:
            pylist.append(create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function)))


        return pylist

    def get_successors(self):

        cdef clist[shared_ptr[cgraph.ABB]] abb_list =  deref(self._c()).get_ABB_successors()

        pylist = []

        for abb in abb_list:
            pylist.append(create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb)))

        return pylist

    def get_predecessors(self):

        cdef clist[shared_ptr[cgraph.ABB]] abb_list =  deref(self._c()).get_ABB_predecessors()

        pylist = []

        for abb in abb_list:
            pylist.append(create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb)))

        return pylist

    def get_single_successor(self):

        cdef shared_ptr[cgraph.ABB] abb =  deref(self._c()).get_single_ABB_successor()

        if abb == NULL:
            print("error in getting single abb successor")

        return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))


    def is_mergeable(self):
        return deref(self._c()).is_mergeable()

    def has_single_successor(self):
        return deref(self._c()).has_single_successor()

    def append_basic_blocks(self, ABB  abb):
        return deref(self._c()).append_basic_blocks(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))


    def set_successor(self, ABB  abb):
        return deref(self._c()).set_ABB_successor(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))

    
    
    def set_predecessor(self, ABB  abb):	
        return deref(self._c()).set_ABB_predecessor(spc[cgraph.ABB, cgraph.Vertex](abb._c_vertex))


    def get_parent_function(self):

        cdef shared_ptr[cgraph.Function] function =  deref(self._c()).get_parent_function()

        if function == NULL:
            print("error in getting function parent")

        return create_from_pointer(spc[cgraph.Vertex, cgraph.Function](function))

    def get_dominator(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_dominator()
        if abb!= NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None

    def get_postdominator(self):
        cdef shared_ptr[cgraph.ABB] abb = deref(self._c()).get_postdominator()
        if abb!= NULL:
            return create_from_pointer(spc[cgraph.Vertex, cgraph.ABB](abb))
        else:
            return None

    def set_handler_argument_index(self,index):
        return deref(self._c()).set_handler_argument_index(index)

    def get_start_scheduler_relation(self):

        cdef cgraph.start_scheduler_relation relation = deref(self._c()).get_start_scheduler_relation()
        return start_scheduler_relation(<int> relation)

    def get_loop_information(self):

        cdef bool loop_information = deref(self._c()).get_loop_information()
        return loop_information

    def  print_information(self):
        return deref(self._c()).print_information()


cdef class Queue(Vertex):

    cdef inline shared_ptr[cgraph.Queue] _c(self):
        return spc[cgraph.Queue, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Queue](make_shared[cgraph.Queue](&graph._c_graph, bname))


cdef class Semaphore(Vertex):

    cdef inline shared_ptr[cgraph.Semaphore] _c(self):
        return spc[cgraph.Semaphore, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Semaphore](make_shared[cgraph.Semaphore](&graph._c_graph, bname))


cdef class Buffer(Vertex):

    cdef inline shared_ptr[cgraph.Buffer] _c(self):
        return spc[cgraph.Buffer, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Buffer](make_shared[cgraph.Buffer](&graph._c_graph, bname))


cdef class QueueSet(Vertex):

    cdef inline shared_ptr[cgraph.QueueSet] _c(self):
        return spc[cgraph.QueueSet, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.QueueSet](make_shared[cgraph.QueueSet](&graph._c_graph, bname))


cdef class Timer(Vertex):

    cdef inline shared_ptr[cgraph.Timer] _c(self):
        return spc[cgraph.Timer, cgraph.Vertex](self._c_vertex)

    def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
        cdef string bname
        if not _raw:
            bname = name.encode('UTF-8')
            self._c_vertex = spc[cgraph.Vertex, cgraph.Timer](make_shared[cgraph.Timer](&graph._c_graph, bname))

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
            self._c_vertex = spc[cgraph.Vertex, cgraph.RTOS](make_shared[cgraph.RTOS](&graph._c_graph, bname))


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
            self._c_vertex = spc[cgraph.Vertex, cgraph.CoRoutine](make_shared[cgraph.CoRoutine](&graph._c_graph, bname))
