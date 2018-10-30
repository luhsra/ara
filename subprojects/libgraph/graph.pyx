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

from libcpp.typeinfo cimport type_info
#def get_vertex_object(shared_ptr[cgraph.Vertex] vertex):
	#py_obj = Vertex.create_from_pointer(vertex)
	#if type(py_obj) == Alarm:
		#return 
	#return Alarm
	#return ISR


cdef extern from './graph.h':
	ctypedef enum _syscall_definition_type 'syscall_definition_type':
		_computate 	'computate'
		_create 	'create'
		_destroy 	'destroy'
		_receive 	'receive'
		_approach 	'approach'
		_release 	'release'
		_schedule 	'schedule'



cpdef enum syscall_definition_type:
	computate 	=	_computate 	
	create 		= 	_create	
	destroy		=	_destroy	
	receive 	= 	_receive	
	approach	=	_approach	
	release		= 	_release	
	schedule	= 	_schedule

	
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
	     11246527478366681422: Function,
	     typeid(cgraph.Counter).hash_code(): Counter,
	     typeid(cgraph.Task).hash_code(): Task,
	     typeid(cgraph.ISR).hash_code(): ISR
	}
	cdef size_t type_id = deref(vertex).get_type()
	
	py_obj = a[type_id](None, None,_raw=True)
	
	print("ASFJALSKDFJASLKDJFLASJDFLAKSJDFLKAJSDLFJASLKDJFALSKJDFLKASJF", py_obj)
	print(type(py_obj))
	
	#py_obj.set_c_vertex(vertex)
	return py_obj




cdef class PyGraph:

	def __cinit__(self):
		self._c_graph = cgraph.Graph()

	def set_vertex(self, Vertex vertex):
		self._c_graph.set_vertex(vertex._c_vertex)

	def get_type_vertices(self, ptype):
		
		cdef size_t hash_type = 0 
		
		if ptype == type(Function):
			#11246527478366681422
			#hash_type = 
			print("hash_type python",typeid(cgraph.Function).hash_code())
			hash_type = 11246527478366681422
			print("hash_type",hash_type)
		#elif Type.counter == id:
			#hash_type = typeid(cgraph.Counter).hash_code()
		#elif Type.task == id:
			#hash_type = typeid(cgraph.Task).hash_code()
		#elif Type.isr == id:
			#hash_type = typeid(cgraph.ISR).hash_code() 

		cdef clist[shared_ptr[cgraph.Vertex]] vertices = self._c_graph.get_type_vertices(hash_type)
		pylist = []
		
		print("-------------------Size of Vertices:", vertices.size())
		
		for vertex in vertices:
			pylist.append(create_from_pointer(vertex))
		return pylist


cdef class Vertex:
	
	
	
	cdef shared_ptr[cgraph.Vertex] _c_vertex
	
	cdef set_c_vertex(self, shared_ptr[cgraph.Vertex] vertex):
		self._c_vertex = vertex

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


	def get_name(self):
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string

	#@staticmethod
	#cdef create_from_pointer(shared_ptr[cgraph.Function] function):
	#	# we have to create an empty dummy graph to fulfil the constructor
	#	py_obj = Function(PyGraph(), "empty", _raw=True)
	#	py_obj._c = function
	#	return py_obj
	
	
#cdef class ABB(Vertex):

	#cdef inline shared_ptr[cgraph.ABB] _c(self):
		#return spc[cgraph.ABB, cgraph.Vertex](self._c_vertex)

	#def __cinit__(self, PyGraph graph, shared_ptr[cgraph.Function] function_reference, str name, *args, _raw=False, **kwargs):
		#cdef string bname 
		#if not _raw:
			#bname = name.encode('UTF-8')
			#self._c_vertex = spc[cgraph.Vertex, cgraph.ABB](make_shared[cgraph.ABB](&graph._c_graph,function_reference._c , bname))

	#def get_name(self):
		#cdef string c_string = deref(self._c()).get_name()
		#cdef bytes py_string = c_string
		#return py_string

