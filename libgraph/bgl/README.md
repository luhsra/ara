Wrapper between the BGL (Boost Graph Library) and Cython
========================================================

This whole folder makes an as generic mapping as possible (at least I hope so) between arbitrary Boost graphs and Cython.

It therefore creates ready to use Cython classes, defined in `bgl.pyx` from which can be inherited:

- `bgl.Vertex`
- `bgl.Graph`
- `bgl.Edge`

All iterator function create Python iterators that use C++ iterators internally.
Additionally, since the classes are meant to inherited from their functions return the specialized classes.

Usage example
-------------

As an example lets say I have a graph of train station, the `TrainStationGraph` that manages `TrainStation`s as nodes and edges between them.
With the `bgl` interface it is possible to say:
```
cimport bgl

cdef class TrainStation(bgl.Vertex):
	pass

cdef class TrainStationGraph(bgl.Graph):
	def __cinit__(self):
		self.vert.n_type = TrainStation
```
The line `self.vert.n_type` then specifies that `TrainStationGraph` as well as its edges and vertices will always return `TrainStation`s as vertex type. So for example, when `TrainStationGraph.vertices()` is called, an iterator of `TrainStation`s is returned.

However, what is missing is the actual boost graph that underlies the wrapper. Therefore the attribute `_c_graph` of `bgl.Graph` has to be set, which is a `std::shared_ptr<ara::bgl::GraphWrapper>`. To now connect this to Boost we first need a Boot graph:
```
struct TrainStation {
	...
};

typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::bidirectionalS,
    TrainStation> TrainStations;
```
To finally connect the two graphs the following wrapper object needs to be created:
```
TrainStations& my_stations = ...;
auto wrapper = std::make_shared<ara::bgl::GraphImpl<TrainStations>>(my_stations);
```
`wrapper` then needs to be assigned to `_c_graph` of `bgl.Graph`.

Internal functionality
----------------------

The BGL works mainly with templates. Since templates can only be used with defined types in Cython the wrapper maps the template magic to inheritance.

Most boost graphs fulfil more less the same interface. This interface is defined in `bgl_wrapper.h` in the classes: `GraphWrapper`, `EdgeWrapper` and `VertexWrapper`. In `bgl_bridge.h` a set of template classes exist that inherit from the classes in `bgl_wrapper.h` and actually implement the functions. The template classes in `bgl_bridge.h` are therefore specialized with the actual Boost types.

In `bgl.pyx` then a set of Python classes exist that uses the interface base classes from `bgl_wrapper.h` to call the function actually implement by the wrapper classes in `bgl_bridge.h`.

The bridging of course is not as flexible as the BGL itself, however it abstracts most of the needed constructs.
