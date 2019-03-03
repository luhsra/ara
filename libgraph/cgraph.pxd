# vim: set et ts=4 sw=4:
from libcpp.string cimport string
from libcpp.list cimport list as clist
from libcpp.set cimport set as cset
from libcpp.vector cimport vector as cvector
from libcpp cimport bool
from libcpp.memory cimport shared_ptr



cdef extern from "graph.h":
    cdef cppclass start_scheduler_relation:
        pass


cdef extern from "graph.h":
    cdef cppclass timer_type:
        pass

cdef extern from "graph.h":
    cdef cppclass call_definition_type:
        pass

cdef extern from "graph.h":
    cdef cppclass syscall_definition_type:
        pass

cdef extern from "graph.h":
    cdef cppclass os_type:
        pass

cdef extern from "graph.h":
    cdef cppclass protocol_type:
        pass
        
cdef extern from "graph.h":
    cdef cppclass message_property:
        pass

cdef extern from "graph.h" namespace "start_scheduler_relation":
    cdef timer_type before
    cdef timer_type after
    cdef timer_type uncertain
    cdef timer_type not_defined

cdef extern from "graph.h" namespace "timer_type":
    cdef timer_type oneshot
    cdef timer_type autoreload
    cdef timer_type autostart
    cdef timer_type not_autostart


cdef extern from "graph.h" namespace "call_definition_type":
    cdef call_definition_type sys_call
    cdef call_definition_type func_call
    cdef call_definition_type no_call
    cdef call_definition_type has_call
    cdef call_definition_type computation

cdef extern from "graph.h" namespace "os_type":
    cdef os_type  OSEK
    cdef os_type FreeRTOS

cdef extern from "graph.h" namespace "protocol_type":
    cdef protocol_type priority_ceiling
    cdef protocol_type priority_inheritance
    cdef protocol_type none
    
cdef extern from "graph.h" namespace "syscall_definition_type":
    cdef syscall_definition_type computate
    cdef syscall_definition_type create
    cdef syscall_definition_type destroy
    cdef syscall_definition_type receive
    cdef syscall_definition_type commit
    cdef syscall_definition_type release
    cdef syscall_definition_type schedule
    cdef syscall_definition_type reset
    cdef syscall_definition_type activate
    cdef syscall_definition_type enable
    cdef syscall_definition_type disable
    cdef syscall_definition_type add
    cdef syscall_definition_type take_out
    cdef syscall_definition_type wait
    cdef syscall_definition_type synchronize
    cdef syscall_definition_type take
    cdef syscall_definition_type set_priority
    cdef syscall_definition_type resume
    cdef syscall_definition_type suspend
    cdef syscall_definition_type enter_critical
    cdef syscall_definition_type exit_critical
    cdef syscall_definition_type start_scheduler
    cdef syscall_definition_type end_scheduler
    cdef syscall_definition_type chain
    cdef syscall_definition_type delay
    
cdef extern from "graph.h" namespace "message_property":
    cdef message_property none
    cdef message_property SEND_STATIC_INTERNAL
    cdef message_property SEND_STATIC_EXTERNAL
    cdef message_property SEND_DYNAMIC_EXTERNAL
    cdef message_property SEND_ZERO_INTERNAL
    cdef message_property SEND_ZERO_EXTERNAL
    cdef message_property RECEIVE_ZERO_INTERNAL
    cdef message_property RECEIVE_ZERO_EXTERNAL
    cdef message_property RECEIVE_UNQUEUED_INTERNAL
    cdef message_property RECEIVE_QUEUED_INTERNAL
    cdef message_property RECEIVE_UNQUEUED_EXTERNAL
    cdef message_property RECEIVE_QUEUED_EXTERNAL
    cdef message_property RECEIVE_DYNAMIC_EXTERNAL
    cdef message_property RECEIVE_ZERO_SENDERS


cdef extern from "graph.h" namespace "graph":
    cdef cppclass Graph:
        Graph() except +

        void set_vertex(shared_ptr[Vertex] vertex)
        clist[shared_ptr[Vertex]] get_type_vertices(size_t type_info)
        bool remove_vertex(size_t)

        shared_ptr[Vertex] get_vertex(size_t seed)

        void set_os_type(os_type)

    cdef cppclass Vertex:
        Vertex(Graph* graph, string name) except +
        size_t get_seed()
        size_t get_type()
        string get_name()
        void set_handler_name(string)
        clist[shared_ptr[Edge]] get_outgoing_edges()

    cdef cppclass Edge:
        Edge(Graph* graph,string name , shared_ptr[Vertex] start , shared_ptr[Vertex] target ,shared_ptr[ABB] abb_reference) except +

        shared_ptr[Vertex] get_start_vertex()
        shared_ptr[Vertex] get_target_vertex()
        shared_ptr[ABB] get_abb_reference()
        string get_name()


cdef extern from "graph.h" namespace "OS":

    cdef cppclass Counter:
        Counter(Graph* graph, string name) except +

        void set_max_allowed_value(unsigned long max_allowed_value)

        void set_ticks_per_base(unsigned long ticks)

        void set_min_cycle(unsigned long min_cycle)

        string get_name()

    cdef cppclass Event:
        Event(Graph* graph, string name) except +

        void set_event_mask_auto()
        void set_event_mask(unsigned long mask)

        string get_name()


    cdef cppclass ISR:
        ISR(Graph* graph, string name) except +

        bool set_category(int category)
        
        void set_priority(int priority)
        
        int get_category()
        bool set_resource_reference(string)
        shared_ptr[Function] get_definition_function()
        bool set_definition_function(string function_name)
        string get_name()


    cdef cppclass Mutex:
        Mutex(Graph* graph, string name) except +

        void set_resource_property(string prop, string linked_resource)
        void set_protocol_type(protocol_type type)
        string get_name()

    cdef cppclass Task:
        Task(Graph* graph, string name) except +


        void set_priority(unsigned long priority)
        void set_activation(unsigned long activation)
        void set_autostart(bool autostart)
        bool set_definition_function(string function_name)
        void set_appmode(string app_mode)

        bool set_scheduler(string scheduler)
        bool set_resource_reference(string resource)
        bool set_event_reference(string event)

        shared_ptr[Function] get_definition_function()
        string get_name()


    cdef cppclass Queue:
        Queue(Graph* graph, string name) except +
        
        void set_message_property(message_property property)
        void set_length(unsigned long size)

    cdef cppclass QueueSet:
        QueueSet(Graph* graph, string name) except +

    cdef cppclass Semaphore:
        Semaphore(Graph* graph, string name) except +


    cdef cppclass Timer:
        Timer(Graph* graph, string name) except +
        shared_ptr[Function] get_callback_function()
        bool set_callback_function(string function_name)
        bool set_task_reference(string task)
        bool set_counter_reference(string counter)
        bool set_event_reference(string event)
        void set_alarm_callback_reference(string callback_name)
        void set_timer_type(timer_type type)
        void set_alarm_time(unsigned int alarm_time)
        void set_cycle_time(unsigned int cycle_time)
        void set_appmode(string appmode)

        string get_name()

    cdef cppclass Event:
        Event(Graph* graph, string name) except +



    cdef cppclass Buffer:
        Buffer(Graph* graph, string name) except +





    cdef cppclass Function:
        Function(Graph* graph, string name) except +

        clist[shared_ptr[ABB]] get_atomic_basic_blocks()
        string get_name()
        void has_syscall(bool flag)
        bool has_syscall()

        bool remove_abb(size_t seed)

        void set_exit_abb(shared_ptr[ABB])
        shared_ptr[ABB] get_exit_abb()
        shared_ptr[ABB] get_entry_abb()

        cvector[shared_ptr[Function]] get_called_functions()

        bool set_definition_vertex(shared_ptr[Vertex])


    cdef cppclass RTOS:

        RTOS(Graph* graph,string name) except +

        void enable_startup_hook(bool flag)
        void enable_error_hook (bool flag)
        void enable_shutdown_hook(bool flag)
        void enable_pretask_hook (bool flag)
        void enable_posttask_hook (bool flag)

    cdef cppclass CoRoutine:
        RTOS(Graph* graph,string name) except +

    cdef cppclass ABB:
        ABB(Graph* graph, shared_ptr[Function] function_reference ,string name) except +


        call_definition_type get_call_type()

        void expend_call_sites(shared_ptr[ABB])
        void remove_successor(shared_ptr[ABB])
        void remove_predecessor(shared_ptr[ABB])
        void set_call_type(call_definition_type type)
        void set_syscall_type(syscall_definition_type type)
        void set_call_target_instance(size_t target_instance)
        #void set_expected_syscall_argument_type(size_t data_type_hash)
        shared_ptr[Function] get_called_function()

        cset[shared_ptr[ABB]]  get_ABB_successors()

        clist[clist[size_t]] get_call_argument_types()

        shared_ptr[ABB]  get_single_ABB_successor()

        cset[shared_ptr[ABB]]  get_ABB_predecessors()
        clist[size_t] get_syscall_argument_types()
        void adapt_exit_bb(shared_ptr[ABB])
        bool is_mergeable()
        bool has_single_successor()
        string get_call_name()
        string get_syscall_name()
        syscall_definition_type get_syscall_type()

        bool convert_call_to_syscall(string)
        string get_name()

        void append_basic_blocks(shared_ptr[ABB] abb)

        void set_ABB_successor(shared_ptr[ABB] abb)
        void set_ABB_predecessor(shared_ptr[ABB] abb)

        void print_information()
        shared_ptr[Function] get_parent_function()

        shared_ptr[ABB] get_postdominator()
        shared_ptr[ABB] get_dominator()

        void set_handler_argument_index(size_t index)

        start_scheduler_relation get_start_scheduler_relation()
        bool get_loop_information()
        bool dominates(shared_ptr[ABB])
        bool postdominates(shared_ptr[ABB])
