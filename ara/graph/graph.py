
import graph_tool
import graph_tool.util

from graph_tool.topology import label_out_component

from .graph_data import PyGraphData, _get_llvm_obj
from .mix import ABBType, CFType, SyscallCategory, NodeLevel, StateType, MSTType

from collections.abc import Iterator


class FailedGraphConstraint(Exception):
    """The graph has another structure than anticipated."""


def single_check(iterator):
    """Check, if iterator is exhausted after exactly one iteration.

    It returns the single element, if it exists and raises an
    FailedGraphConstraint otherwise.
    """
    if not isinstance(iterator, Iterator):
        iterator = iter(iterator)

    first = next(iterator, None)
    if first is None:
        raise FailedGraphConstraint("No element present.")
    second = next(iterator, None)
    if second is not None:
        raise FailedGraphConstraint("More than one element present.")
    return first


class CFGError(Exception):
    """Some error with a CFG function."""


class CFG(graph_tool.Graph):
    """Describe the local, interprocedural and global control flow.

    Contains BBs, ABBs and functions that can be differentiated with the
    "level" property.

    The ABBs itself can have different types, set by the "type" property
    containing an ABBType.

    A function is connected with all its ABBs with CFType.f2a edges (see "type"
    property). An ABB is connected with its BBs with CFType.a2b edges.
    Local, interprocedural and global control flow is marked with CFType.lcf,
    CFType.icf and CFType.gcf.

    The is_entry property indicates that the edge points to the entry ABB of
    the function and the entry BB of an ABB.

    The pointer to the respective LLVM datastructure is stored via llvm_link.
    """
    def __init__(self):
        super().__init__()
        # properties
        # ATTENTION: If you modify this values, you also have to update
        # cgraph/graph.cpp and cgraph/graph.h.

        # vertex properties
        self.vertex_properties["name"] = self.new_vp("string")
        self.vertex_properties["type"] = self.new_vp("int") # ABBType
        self.vertex_properties["level"] = self.new_vp("int") # NodeLevel
        # Level dependent vertex properties
        self.vertex_properties["llvm_link"] = self.new_vp("int64_t") # BB/Function
        self.vertex_properties["bcet"] = self.new_vp("int64_t") # ABB
        self.vertex_properties["wcet"] = self.new_vp("int64_t") # ABB
        self.vertex_properties["loop_bound"] = self.new_vp("int64_t") # ABB
        self.vertex_properties["is_exit"] = self.new_vp("bool") # BB/ABB
        self.vertex_properties["is_exit_loop_head"] = self.new_vp("bool") # BB/ABB
        self.vertex_properties["part_of_loop"] = self.new_vp("bool") # BB/ABB
        self.vertex_properties["loop_head"] = self.new_vp("bool") # ABB
        self.vertex_properties["files"] = self.new_vp("vector<string>") # BB/call ABB
        self.vertex_properties["lines"] = self.new_vp("vector<int32_t>") # BB/call ABB
        self.vertex_properties["implemented"] = self.new_vp("bool") # Function
        self.vertex_properties["sysfunc"] = self.new_vp("bool") # Function
        self.vertex_properties["arguments"] = self.new_vp("object") # Function
        self.vertex_properties["call_graph_link"] = self.new_vp("long") # Function

        # edge properties
        self.edge_properties["type"] = self.new_ep("int") # CFType
        # f2a, a2b edges
        self.edge_properties["is_entry"] = self.new_ep("bool")

    def get_function_by_name(self, name: str):
        """Find a specific function."""
        func = graph_tool.util.find_vertex(self, self.vp["name"], name)
        assert len(func) == 1 and self.vp.level[func[0]] == NodeLevel.function
        return func[0]

    def get_llvm_obj(self, vertex):
        """Return the LLVM object that belongs to the specified vertex.

        Returns only values for function and basic block vertices and None
        otherwise.
        """
        return _get_llvm_obj(self, vertex)

    def get_function(self, abb):
        """Get the function node for an ABB."""
        abb = self.vertex(abb)

        def is_func(abb):
            return self.ep.type[abb] == CFType.f2a

        entry = list(filter(is_func, abb.in_edges()))
        if entry:
            assert len(entry) == 1
            return entry[0].source()
        return None

    def get_abbs(self, function):
        """Get the ABBs of the functions."""
        for edge in self.vertex(function).out_edges():
            if self.ep.type[edge] == CFType.f2a:
                yield edge.target()

    def get_function_bbs(self, function):
        """Get the BBs of the functions."""
        for edge in self.vertex(function).out_edges():
            if self.ep.type[edge] == CFType.f2b:
                yield edge.target()

    def get_abb(self, bb):
        """Get the ABB node for a BB."""
        bb = self.vertex(bb)

        def is_abb(bb):
            return self.ep.type[bb] == CFType.a2b

        entry = list(filter(is_abb, bb.in_edges()))
        if entry:
            assert len(entry) == 1
            return entry[0].source()
        return None

    def get_bbs(self, abb):
        """Get the BBs of the ABB."""
        for edge in self.vertex(abb).out_edges():
            if self.ep.type[edge] == CFType.a2b:
                yield edge.target()

    def get_single_bb(self, abb):
        """Get the single BB for an ABB.

        Also ensure it is the only existing one.
        """
        ret = None
        for node in self.get_bbs(abb):
            if ret:
                raise CFGError("More than one BB.")
            ret = node
        if not ret:
            raise CFGError("No BB found.")
        return ret

    def _get_entry(self, function, edge_type=CFType.f2a):
        """Return the entry block of the given function."""
        def is_entry(block):
            return self.ep.is_entry[block] and self.ep.type[block] == edge_type

        function = self.vertex(function)

        entry = list(filter(is_entry, function.out_edges()))
        assert len(entry) == 1
        return entry[0].target()

    def get_entry_abb(self, function):
        """Return the entry abb of the given function."""
        return self._get_entry(function, edge_type=CFType.f2a)

    def get_entry_bb(self, function):
        """Return the entry bb of the given function."""
        return self._get_entry(function, edge_type=CFType.f2b)

    def _get_exit(self, function, level):
        function = self.vertex(function)

        def is_exit(block):
            return self.vp.is_exit[block] and self.vp.level[block] == level

        entry = list(filter(is_exit, function.out_neighbors()))
        if entry:
            assert len(entry) == 1, f"Multiple exits in function {self.vp.name[function]}"
            return entry[0]
        return None

    def get_function_exit_bb(self, function):
        return self._get_exit(function, level=NodeLevel.bb)

    def get_exit_abb(self, function):
        return self._get_exit(function, level=NodeLevel.abb)

    def get_syscall_name(self, abb):
        """Return the called syscall name for a given abb."""
        abb = self.vertex(abb)
        if not self.vp.type[abb] == ABBType.syscall:
            return ''
        syscall = [x.target() for x in abb.out_edges()
                   if self.ep.type[x] == CFType.icf]
        assert len(syscall) == 1
        syscall_func = [x.source() for x in syscall[0].in_edges()
                        if self.ep.type[x] == CFType.f2a]
        assert len(syscall_func) == 1
        return self.vp.name[syscall_func[0]]

    def _reachable_nodes(self, func, callgraph, node_level,
                         only_system_relevant=True):
        """Return the reachable nodes starting from func.

        It uses the callgraph for searching. The node_level specifies what
        level should be returned. only_system_relevant restricts the returned
        nodes to system relevant _and_ the entry function.
        """
        cg_func = callgraph.vertex(self.vp.call_graph_link[func])
        oc = label_out_component(callgraph, cg_func)
        reachable_cg = graph_tool.GraphView(callgraph, vfilt=oc)
        if only_system_relevant:
            e = reachable_cg.copy_property(
                reachable_cg.vp.syscall_category_every
            )
            e[cg_func] = True
            reachable_cg = graph_tool.GraphView(
                reachable_cg,
                vfilt=e
            )

        for sub_func in reachable_cg.vertices():
            cfg_func = reachable_cg.vp.function[sub_func]
            for entity in {
                NodeLevel.function: [cfg_func],
                NodeLevel.abb: self.get_abbs(cfg_func),
                NodeLevel.bb: self.get_function_bbs(cfg_func)
            }[node_level]:
                yield entity

    def reachable_functs(self, func, callgraph, only_system_relevant=True):
        """Generator about all reachable Functions starting at func."""
        return self._reachable_nodes(func, callgraph, NodeLevel.function,
                                     only_system_relevant=only_system_relevant)

    def reachable_abbs(self, func, callgraph, only_system_relevant=True):
        """Generator about all reachable ABBs starting at func."""
        return self._reachable_nodes(func, callgraph, NodeLevel.abb,
                                     only_system_relevant=only_system_relevant)

    def reachable_bbs(self, func, callgraph, only_system_relevant=True):
        """Generator about all reachable BBs starting at func."""
        return self._reachable_nodes(func, callgraph, NodeLevel.bb,
                                     only_system_relevant=only_system_relevant)

    def get_call_targets(self, abb, func=True):
        """Generator about all call targets for a given call abb.

        Keyword arguments:
        func -- If set, return the called functions, otherwise the called
                function entry ABBs.
        """
        assert self.vp.type[abb] in [ABBType.call, ABBType.syscall]

        for edge in abb.out_edges():
            if self.ep.type[edge] == CFType.icf:
                if func:
                    yield self.get_function(edge.target())
                else:
                    yield edge.target


class CFGView(graph_tool.GraphView):
    """Class to get CFG functions for a filtered CFG."""
    def __init__(self, graph, **kwargs):
        graph_tool.GraphView.__init__(self, graph, **kwargs)

    def get_llvm_obj(self, *args, **kwargs):
        return self.base.get_llvm_obj(*args, **kwargs)

    def get_function_by_name(self, *args, **kwargs):
        return self.base.get_function_by_name(*args, **kwargs)

    def get_function(self, *args, **kwargs):
        return self.base.get_function(*args, **kwargs)

    def get_abbs(self, *args, **kwargs):
        return self.base.get_abbs(*args, **kwargs)

    def get_entry_abb(self, *args, **kwargs):
        return self.base.get_entry_abb(*args, **kwargs)

    def get_exit_abb(self, *args, **kwargs):
        return self.base.get_exit_abb(*args, **kwargs)

    def get_syscall_name(self, *args, **kwargs):
        return self.base.get_syscall_name(*args, **kwargs)


class Callgraph(graph_tool.Graph):
    """ Callgraph on which nodes represents functions and edges function calls.
    """
    def __init__(self, cfg):
        super().__init__()

        #vertex properties
        self.vertex_properties["function"] = self.new_vp("long")
        self.vertex_properties["function_name"] = self.new_vp("string")
        self.vertex_properties["svf_vlink"] = self.new_vp("int64_t")
        self.vertex_properties["recursive"] = self.new_vp("bool")
        self._map_syscall_categories()
        #edge properties
        self.edge_properties["callsite"] = self.new_ep("long")
        self.edge_properties["callsite_name"] = self.new_ep("string")
        self.edge_properties["svf_elink"] = self.new_ep("int64_t")

        self.graph_properties["cfg"] = self.new_gp("object", cfg)

    def _map_syscall_categories(self):
        for syscat in SyscallCategory:
            property_name = "syscall_category_" + syscat.name
            self.vertex_properties[property_name] = self.new_vp("bool")

    def get_edge_for_callsite(self, callsite):
        for edge in self.edges():
            if self.ep.callsite[edge] == callsite:
                return edge
        return None

    def get_node_with_name(self, name):
        """Find a node specified by its name."""
        node = graph_tool.util.find_vertex(self, self.vp["function_name"], name)
        if len(node) == 0:
            return None
        assert len(node) == 1
        return node[0]

    def get_syscalls(self):
        """Return a filter Callgraph that contains only syscall nodes."""
        # TODO convert this the vertex_type once multios is merged
        return graph_tool.GraphView(self, vfilt=self.vp.syscall_category_every)


class MSTGraph(graph_tool.Graph):
    """The Multi state transition graph"""
    def __init__(self):
        super().__init__()
        # vertex properties
        self.vertex_properties["state"] = self.new_vp("object")
        self.vertex_properties["type"] = self.new_vp("int")  # StateType
        self.vertex_properties["cpu_id"] = self.new_vp("int")  # only for StateType.metastate
        self.edge_properties["type"] = self.new_ep("int")  # MSTType
        self.edge_properties["cpu_id"] = self.new_ep("int")
        self.edge_properties["bcet"] = self.new_ep("int64_t", val=-1)
        self.edge_properties["wcet"] = self.new_ep("int64_t", val=-1)

    def get_metastates(self):
        return graph_tool.GraphView(self, vfilt=self.vp.type.fa == StateType.metastate)

    def get_sync_points(self, exit=False):
        if exit:
            return graph_tool.GraphView(self, vfilt=self.vp.type.fa == StateType.exit_sync)
        return graph_tool.GraphView(self, vfilt=self.vp.type.fa == StateType.entry_sync)

    def edge_type(self, msttype):
        """Return a GraphView with this special edge type filter."""
        return graph_tool.GraphView(
            self,
            efilt=(self.ep.type.fa == msttype)
        )

    def get_metastate(self, state):
        """Return the metastate that belongs to a state."""
        m2s = self.edge_type(MSTType.m2s)
        return self.vertex(single_check(m2s.vertex(state).in_neighbors()))

    def get_entry_cp(self, exit_cp):
        """Return the entry_cp that belongs to an exit_cp."""
        fu = self.edge_type(MSTType.follow_up)
        return self.vertex(single_check(fu.vertex(exit_cp).in_neighbors()))


class InstanceGraph(graph_tool.Graph):
    """Tracks all instances (nodes) with its flow insensitive interactions
    (edges).
    """
    def __init__(self):
        super().__init__()
        # vertex properties
        # ATTENTION: If you modify this values, you also have to update
        # cgraph/graph.cpp and cgraph/graph.h.
        self.vertex_properties["label"] = self.new_vp("string")
        self.vertex_properties["obj"] = self.new_vp("object")
        self.vertex_properties["id"] = self.new_vp("string")
        self.vertex_properties["branch"] = self.new_vp("bool")
        self.vertex_properties["usually_taken"] = self.new_vp("bool")
        self.vertex_properties["loop"] = self.new_vp("bool")
        self.vertex_properties["recursive"] = self.new_vp("bool")
        self.vertex_properties["after_scheduler"] = self.new_vp("bool")
        self.vertex_properties["unique"] = self.new_vp("bool")
        self.vertex_properties["soc"] = self.new_vp("long")
        self.vertex_properties["llvm_soc"] = self.new_vp("int64_t")
        self.vertex_properties["is_control"] = self.new_vp("bool")
        self.vertex_properties["file"] = self.new_vp("string")
        self.vertex_properties["line"] = self.new_vp("int")
        self.vertex_properties["specialization_level"] = self.new_vp("string")

        self.edge_properties["label"] = self.new_ep("string")
        self.edge_properties["type"] = self.new_ep("int")  # OS specific type
        self.edge_properties["syscall"] = self.new_ep("int")  # ABB vertex ID
        self.edge_properties["number"] = self.new_ep("int64_t")  # not distinguishable interactions: increment number field instead of add a new edge

    def get_controls(self):
        return graph_tool.GraphView(self, vfilt=self.vp.is_control)

    def get(self, instance_type):
        """Generator over all instances with a specific type.

        Returns a tuple containing the vertex and instance object.
        """
        for inst in self.vertices():
            obj = self.vp.obj[inst]
            if isinstance(obj, instance_type):
                yield inst, obj

    def get_node(self, instance):
        """Get the vertex belonging to a specific instance."""
        for inst in self.vertices():
            if instance == self.vp.obj[inst]:
                return inst

    def iterate_control_entry_points(self):
        """Return a generator over all tasks in the instance graph.

        Return a tuple of the cfg function and the instance vertex.
        """
        for inst in self.get_controls().vertices():
            inst = self.vertex(inst)
            obj = self.vp.obj[inst]
            if obj.artificial:
                continue
            yield obj.function, inst

class Graph:
    """Container for all data that ARA uses from multiple steps.

    Mainly, this are subgraphs.

    Additionally, an LLVM module is stored but only for access from the
    C++ side.
    """

    def _init_cfg(self):
        self.cfg = CFG()

    # the following needs to be properties, since they must be reevaluated with
    # every invocation
    # WARNING: When you are using this properties you must create a locale
    # reference, see https://git.skewed.de/count0/graph-tool/-/issues/685
    @property
    def functs(self):
        return CFGView(self.cfg,
                       vfilt=self.cfg.vp.level.fa == NodeLevel.function)

    @property
    def abbs(self):
        return CFGView(self.cfg, vfilt=self.cfg.vp.level.fa == NodeLevel.abb)

    @property
    def bbs(self):
        return CFGView(self.cfg, vfilt=self.cfg.vp.level.fa == NodeLevel.bb)

    @property
    def icfg(self):
        return CFGView(self.abbs, efilt=self.cfg.ep.type.fa == CFType.icf)

    @property
    def lcfg(self):
        return CFGView(self.abbs, efilt=self.cfg.ep.type.fa == CFType.lcf)

    def __init__(self):
        # should be used only from C++, see graph.h
        self._graph_data = PyGraphData()
        # persitent data for of the value analyzer
        self._va_system_objects = {}
        self._init_cfg()
        self.callgraph = Callgraph(self.cfg)
        self.os = None
        self.instances = InstanceGraph()
        self.step_data = {}
        self.file_cache = {}
