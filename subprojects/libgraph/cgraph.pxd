# vim: set et ts=4 sw=4:
from libcpp.string cimport string
from libcpp.list cimport list as clist
from libcpp cimport bool
from libcpp.memory cimport shared_ptr

cdef extern from "graph.h":
	cdef cppclass call_definition_type:
		pass

cdef extern from "graph.h" namespace "call_definition_type":
	cdef call_definition_type sys_call
	cdef call_definition_type func_call
	cdef call_definition_type no_call
	cdef call_definition_type has_call

cdef extern from './graph.h':
	ctypedef enum _syscall_definition_type 'syscall_definition_type':
		_computate 	'computate'
		_create 	'create'
		_destroy 	'destroy'
		_receive 	'receive'
		_approach 	'approach'
		_release 	'release'
		_schedule 	'schedule'


cdef extern from "graph.h" namespace "graph":
	cdef cppclass Graph:
		Graph() except +

		void set_vertex(shared_ptr[Vertex] vertex)
		clist[shared_ptr[Vertex]] get_type_vertices(size_t type_info)

	cdef cppclass Vertex:
		Vertex(Graph* graph, string name) except +

		size_t get_type()
		string get_name()


	cdef cppclass Edge:
		Edge() except +

cdef extern from "graph.h" namespace "OS":
	cdef cppclass Alarm:
		Alarm(Graph* graph, string name) except +


		bool set_task_reference(string task)
		bool set_counter_reference(string counter)
		bool set_event_reference(string event)
		void set_alarm_callback_reference(string callback_name)
		void set_autostart(bool flag)
		void set_alarm_time(unsigned int alarm_time)
		void set_cycle_time(unsigned int cycle_time)
		void set_appmode(string appmode)

		string get_name()

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
		bool set_resource_reference(string)

		string get_name()

	cdef cppclass Resource:
		Resource(Graph* graph, string name) except +

		void set_resource_property(string prop, string linked_resource)

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

		string get_name()


	cdef cppclass Function:
		Function(Graph* graph, string name) except +

		clist[shared_ptr[ABB]] get_atomic_basic_blocks()
		string get_name()




	cdef cppclass ABB:
		ABB(Graph* graph, shared_ptr[Function] function_reference ,string name) except +

		call_definition_type get_call_type()

		string get_name()


