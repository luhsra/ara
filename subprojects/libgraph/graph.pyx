# distutils: language = c++
# vim: set et ts=4 sw=4:

cimport cgraph
cimport graph

#from arsa.steps.enumerations import Type

from libcpp.memory cimport shared_ptr, make_shared
from libcpp.string cimport string
from libcpp.list cimport list as clist
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
	elif name == "Alarm":
		hash_type = typeid(cgraph.Alarm).hash_code()
	elif name == "QueueSet":
		hash_type = typeid(cgraph.QueueSet).hash_code()
	elif name == "RTOS":
		hash_type = typeid(cgraph.RTOS).hash_code()
	
	return  hash_type


class call_definition_type(IntEnum):
	sys_call  = <int> cgraph.sys_call
	func_call = <int> cgraph.func_call
	no_call   = <int> cgraph.no_call
	has_call  = <int> cgraph.has_call




class syscall_definition_type(IntEnum):
	computate  = <int> cgraph.computate
	create = <int> cgraph.create
	destroy   = <int> cgraph.destroy
	receive  = <int> cgraph.receive
	commit = <int> cgraph.commit
	release = <int> cgraph.release
	schedule = <int> cgraph.schedule
	reset = <int> cgraph.reset
	
class data_type(IntEnum):
	string = 1
	integer = 2
	unsigned_integer = 3
	long = 4
	
	
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
	     typeid(cgraph.Counter).hash_code(): Counter,
	     typeid(cgraph.Task).hash_code(): Task,
	     typeid(cgraph.ISR).hash_code(): ISR,
	     typeid(cgraph.ABB).hash_code(): ABB
	}


	cdef size_t type_id = deref(vertex).get_type()

	cdef Vertex py_obj = a[type_id](None, None,None,_raw=True)

	py_obj._c_vertex = vertex
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

		cdef size_t hash_type = 0
		
		
		if name == "Function":
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
		elif name == "Alarm":
			hash_type = typeid(cgraph.Alarm).hash_code()
		elif name == "QueueSet":
			hash_type = typeid(cgraph.QueueSet).hash_code()


		cdef clist[shared_ptr[cgraph.Vertex]] vertices = self._c_graph.get_type_vertices(hash_type)

		pylist = []

		#print("-------------------Size of Vertices:", vertices.size())

		for vertex in vertices:
			pylist.append(create_from_pointer(vertex))


		#print(pylist)

		return pylist


	
		
		
    #@staticmethod
    #cdef create_from_pointer(shared_ptr[cgraph.Vertex] vertex):
        #py_obj = Vertex(None, "empty", _raw=True)
        #py_obj._c_vertex = vertex
        #return py_obj


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
		cdef string c_string = deref(self._c_vertex).get_name()
		cdef bytes py_string = c_string
		return py_string

	def get_seed(self):
		return deref(self._c_vertex).get_seed()


cdef class Alarm(Vertex):

	cdef inline shared_ptr[cgraph.Alarm] _c(self):
		return spc[cgraph.Alarm, cgraph.Vertex](self._c_vertex)

	def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
		cdef string bname
		if not _raw:
			bname = name.encode('UTF-8')
			self._c_vertex = spc[cgraph.Vertex, cgraph.Alarm](make_shared[cgraph.Alarm](&graph._c_graph, bname))

	def set_task_reference(self, str task_name):
		cdef string c_task_name = task_name.encode('UTF-8')
		deref(self._c()).set_task_reference(c_task_name)

	def set_counter_reference(self, str counter_name):
		cdef string c_counter_name = counter_name.encode('UTF-8')
		deref(self._c()).set_counter_reference(c_counter_name)

	def set_event_reference(self, str event_name):
		cdef string c_event_name = event_name.encode('UTF-8')
		deref(self._c()).set_event_reference(c_event_name)

	def set_alarm_callback_reference(self, str callback_name):
		cdef string c_callback_name = callback_name.encode('UTF-8')
		deref(self._c()).set_alarm_callback_reference(c_callback_name)

	def set_appmode(self, str appmode_name):
		cdef string c_appmode_name = appmode_name.encode('UTF-8')
		deref(self._c()).set_appmode(c_appmode_name)

	def set_autostart(self, bool autostart):
		deref(self._c()).set_autostart(autostart)

	def set_alarm_time(self, unsigned int alarm_time):
		deref(self._c()).set_alarm_time(alarm_time)

	def set_cycle_time(self, unsigned int cycle_time):
		deref(self._c()).set_cycle_time(cycle_time)

	def get_name(self):
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string


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
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string


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
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string




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

	def set_resource_reference(self, str resource_name):
		cdef string c_resource_name = resource_name.encode('UTF-8')
		deref(self._c()).set_resource_reference(c_resource_name)

	def get_name(self):
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string



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
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string


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
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string



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
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string
	
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

	def get_name(self):
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string
	
	def get_name(self):
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string

	def set_syscall_name(self,  name):
		cdef bname
		if isinstance(name, str):
			bname = name.encode('UTF-8')
		else:
			bname = name
		
		return deref(self._c()).set_syscall_name(bname)


	def convert_call_to_syscall(self, name):
		cdef bname
		if isinstance(name, str):
			bname = name.encode('UTF-8')
		else:
			bname = name
		
		return deref(self._c()).convert_call_to_syscall(bname)
	
	def get_syscall_name(self):
		return deref(self._c()).get_syscall_name()

	def get_call_names(self):
		cdef clist[string] call_names =  deref(self._c()).get_call_names()
		pylist = []
		cdef bytes tmp_name
		for name in call_names:
			tmp_name = name
			pylist.append( tmp_name)
			
		return pylist
		
	def get_call_type(self):
		cdef cgraph.call_definition_type t = deref(self._c()).get_call_type()
		return call_definition_type(<int> t)
	
	def set_call_type(self, int syscall_type ):
		cdef cgraph.call_definition_type t = <cgraph.call_definition_type> syscall_type
		return deref(self._c()).set_call_type(t)
	
	def set_syscall_type(self, int syscall_type ):
		cdef cgraph.syscall_definition_type t = <cgraph.syscall_definition_type> syscall_type
		return deref(self._c()).set_syscall_type(t)
	
	def set_call_target_instance(self, ptype ):

		for hash_type in ptype:
			deref(self._c()).set_call_target_instance( <size_t>  hash_type)
			
	#def set_expected_syscall_argument_types(self, argument_types ):
		#cdef data_type_hash
		#for argument_type in argument_types:
			#if argument_type == data_type.integer:
				#data_type_hash = typeid(long).hash_code()
			#elif argument_type == data_type.string:
				#data_type_hash = typeid(string).hash_code()
			#elif argument_type == data_type.long:
				#data_type_hash = typeid(long).hash_code()
			#deref(self._c()).set_expected_syscall_argument_type( data_type_hash)
			
	def get_call_argument_types(self ):
		
		cdef clist[clist[size_t]] argument_types_list =  deref(self._c()).get_call_argument_types()
			
		
		pylist = []
			
		for	argument_types in argument_types_list:
			tmp_pylist = []
			pylist.append(argument_types)
			
		return pylist
	
	
	def expend_call_sites(self,ABB abb):
		return deref(self._c()).expend_call_sites(abb._c())
	
	def remove_successor(self,ABB abb):
		return deref(self._c()).remove_successor(abb._c())
	
	def remove_predecessor(self,ABB abb):
		return deref(self._c()).remove_predecessor(abb._c())

	def adapt_exit_bb(self,ABB abb):
		return deref(self._c()).adapt_exit_bb(abb._c())
	
	
	def get_called_functions(self):
		
		cdef clist[shared_ptr[cgraph.Function]] function_list  =  deref(self._c()).get_called_functions()
		
		
		pylist = []
		
		for function in function_list:
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
		
		
		
		
		
cdef class Timer(Vertex):

	cdef inline shared_ptr[cgraph.Timer] _c(self):
		return spc[cgraph.Timer, cgraph.Vertex](self._c_vertex)

	def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
		cdef string bname
		if not _raw:
			bname = name.encode('UTF-8')
			self._c_vertex = spc[cgraph.Vertex, cgraph.Timer](make_shared[cgraph.Timer](&graph._c_graph, bname))
			

		
cdef class RTOS(Vertex):

	cdef inline shared_ptr[cgraph.RTOS] _c(self):
		return spc[cgraph.RTOS, cgraph.Vertex](self._c_vertex)

	def __cinit__(self, PyGraph graph, str name, *args, _raw=False, **kwargs):
		cdef string bname
		if not _raw:
			bname = name.encode('UTF-8')
			self._c_vertex = spc[cgraph.Vertex, cgraph.RTOS](make_shared[cgraph.RTOS](&graph._c_graph, bname))
			
			
