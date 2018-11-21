# vim: set et ts=4 sw=4:
from libcpp.string cimport string
from libcpp.list cimport list as clist
from libcpp cimport bool
from libcpp.memory cimport shared_ptr

cdef extern from "graph.h":
	cdef cppclass call_definition_type:
		pass
		
cdef extern from "graph.h":
	cdef cppclass syscall_definition_type:
		pass

cdef extern from "graph.h" namespace "call_definition_type":
	cdef call_definition_type sys_call
	cdef call_definition_type func_call
	cdef call_definition_type no_call
	cdef call_definition_type has_call

	
cdef extern from "graph.h" namespace "syscall_definition_type":
	cdef syscall_definition_type computate
	cdef syscall_definition_type create
	cdef syscall_definition_type destroy
	cdef syscall_definition_type receive
	cdef syscall_definition_type commit
	cdef syscall_definition_type release
	cdef syscall_definition_type schedule
	cdef syscall_definition_type reset

cdef extern from "graph.h" namespace "graph":
	cdef cppclass Graph:
		Graph() except +

		void set_vertex(shared_ptr[Vertex] vertex)
		clist[shared_ptr[Vertex]] get_type_vertices(size_t type_info)
		void append_basic_blocks(shared_ptr[Vertex] entry_abb,shared_ptr[Vertex] abb)
		
		
	cdef cppclass Vertex:
		Vertex(Graph* graph, string name) except +
		size_t get_seed()
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
		
		
	cdef cppclass Queue:
		Queue(Graph* graph, string name) except +

	cdef cppclass QueueSet:
		QueueSet(Graph* graph, string name) except +
		
	cdef cppclass Semaphore:
		Semaphore(Graph* graph, string name) except +

	
	cdef cppclass Timer:
		Timer(Graph* graph, string name) except +


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

		
	cdef cppclass RTOS:
		RTOS(Graph* graph,string name) except +



	cdef cppclass ABB:
		ABB(Graph* graph, shared_ptr[Function] function_reference ,string name) except +

		
		call_definition_type get_call_type()
		
		void expend_call_sites(shared_ptr[ABB])
		void remove_successor(shared_ptr[ABB])
		void set_call_type(call_definition_type type)
		void set_syscall_type(syscall_definition_type type)
		void set_call_target_instance(size_t target_instance)
		void set_expected_syscall_argument_type(size_t data_type_hash)
		clist[shared_ptr[Function]] get_called_functions()
		
		clist[shared_ptr[ABB]]  get_ABB_successors()
		clist[shared_ptr[ABB]]  get_ABB_predecessors()
		clist[size_t] get_syscall_argument_types()
		void adapt_exit_bb(shared_ptr[ABB])
		bool is_mergeable()
			
		clist[string] get_call_names()
		string get_syscall_name()
		void set_syscall_name(string)
		string get_name()


