# distutils: language = c++

cimport cgraph
cimport graph

from libcpp.memory cimport shared_ptr, make_shared
from libcpp.string cimport string
from libcpp cimport bool

from backported_memory cimport static_pointer_cast as spc

from cython.operator cimport dereference as deref

# Create a Cython extension type which holds a C++ instance
# as an attribute and create a bunch of forwarding methods
# Python extension type.
cdef class PyGraph:

	def __cinit__(self):
		self._c_graph = cgraph.Graph()

	def set_vertex(self, Vertex vertex):
		self._c_graph.set_vertex(vertex._c_vertex)
	#TODO shared pointer problem
	#def get_type_vertices(self, unsigned long id):
	#	cdef size_t c_id = id
	#	return self._c_graph.get_type_vertices(c_id)
	
	
cdef class Vertex:
	cdef shared_ptr[cgraph.Vertex] _c_vertex

	def __cinit__(self, PyGraph graph, name, *args, **kwargs):
		# prevent double constructions
		# https://github.com/cython/cython/wiki/WrappingSetOfCppClasses
		if type(self) != Vertex:
			return
		cdef string bname = name.encode('UTF-8')
		self._c_vertex = make_shared[cgraph.Vertex](&graph._c_graph, bname)
		
		
	def get_name(self):
		cdef string c_string = deref(self._c_vertex).get_name()
		cdef bytes py_string = c_string
		return py_string
	
	


cdef class Alarm(Vertex):
	
	cdef inline shared_ptr[cgraph.Alarm] _c(self):
		return spc[cgraph.Alarm, cgraph.Vertex](self._c_vertex)

	def __cinit__(self, PyGraph graph, str name):
		cdef string bname = name.encode('UTF-8')
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

	def __cinit__(self, PyGraph graph, str name):
		cdef string bname = name.encode('UTF-8')
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

	def __cinit__(self, PyGraph graph, str name):
		cdef string bname = name.encode('UTF-8')
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

	def __cinit__(self, PyGraph graph, str name):
		cdef string bname = name.encode('UTF-8')
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

	def __cinit__(self, PyGraph graph, str name):
		cdef string bname = name.encode('UTF-8')
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

	def __cinit__(self, PyGraph graph, str name):
		cdef string bname = name.encode('UTF-8')
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

	def __cinit__(self, PyGraph graph, str name):
		cdef string bname = name.encode('UTF-8')
		self._c_vertex = spc[cgraph.Vertex, cgraph.Function](make_shared[cgraph.Function](&graph._c_graph, bname))


	def get_name(self):
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string
	
cdef class ABB(Vertex):
	
	cdef inline shared_ptr[cgraph.ABB] _c(self):
		return spc[cgraph.ABB, cgraph.Vertex](self._c_vertex)

	"""
	def __cinit__(self, PyGraph graph, Function function_reference ,  str name):
		cdef string bname = name.encode('UTF-8')
		self._c_vertex = spc[cgraph.Vertex, cgraph.ABB](make_shared[cgraph.ABB](&graph._c_graph,function_reference._c , bname))
	"""

	def get_name(self):
		cdef string c_string = deref(self._c()).get_name()
		cdef bytes py_string = c_string
		return py_string

