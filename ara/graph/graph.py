
import graph_tool
import graph_tool.util

import enum

from collections import deque

from .graph_data import PyGraphData
from .mix import ABBType, CFType, SyscallCategory, NodeLevel

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
        self.vertex_properties["is_exit"] = self.new_vp("bool") # BB/ABB
        self.vertex_properties["is_exit_loop_head"] = self.new_vp("bool") # BB/ABB
        self.vertex_properties["part_of_loop"] = self.new_vp("bool") # BB/ABB
        self.vertex_properties["file"] = self.new_vp("string") # BB/call ABB
        self.vertex_properties["line"] = self.new_vp("int") # BB/call ABB
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

    def get_entry_abb(self, function):
        """Return the entry_abb of the given function."""
        function = self.vertex(function)

        def is_entry(abb):
            return self.ep.is_entry[abb] and self.ep.type[abb] == CFType.f2a

        entry = list(filter(is_entry, function.out_edges()))
        assert len(entry) == 1
        return entry[0].target()

    def get_exit_abb(self, function):
        function = self.vertex(function)

        def is_exit(abb):
            return self.vp.is_exit[abb] and self.vp.level[abb] == NodeLevel.abb

        entry = list(filter(is_exit, function.out_neighbors()))
        if entry:
            assert len(entry) == 1, f"Multiple exits in function {self.vp.name[function]}"
            return entry[0]
        return None

    def get_syscall_name(self, abb):
        """Return the called syscall name for a given abb."""
        abb = self.vertex(abb)
        if not self.vp.type[abb] == ABBType.syscall:
            print("no syscall", abb)
            return ''
        syscall = [x.target() for x in abb.out_edges()
                   if self.ep.type[x] == CFType.icf]
        assert len(syscall) >= 1, f"ABB {abb} calls no function!"

        def get_func(syscall):
            syscall_funcs = [x.source() for x in syscall.in_edges()
                if self.ep.type[x] == CFType.f2a]
            assert len(syscall_funcs) == 1
            return syscall_funcs[0]

        syscall_func = list(map(get_func, syscall))
        assert len(syscall) == len(syscall_func)
        if len(syscall_func) > 1:
            # Filter for the actual syscall
            actual_syscall_func = list(filter(lambda func: self.vp.sysfunc[func], syscall_func))
            assert len(actual_syscall_func) >= 1, "Error in filter function!"
            assert len(actual_syscall_func) == 1, "Detected multiple syscalls! This is not implemented yet!"
            syscall_func = actual_syscall_func
        return self.vp.name[syscall_func[0]]

    def _reachable_nodes(self, func, return_abbs):
        funcs_queue = deque([func])
        funcs_done = set()

        while funcs_queue:
            cur_func = funcs_queue.popleft()
            if cur_func in funcs_done:
                continue
            funcs_done.add(cur_func)
            if not return_abbs:
                yield cur_func
            for abb in self.get_abbs(cur_func):
                # find other functions
                if self.vp.type[abb] in [ABBType.syscall, ABBType.call]:
                    for edge in abb.out_edges():
                        if self.ep.type[edge] == CFType.icf:
                            new_func = self.get_function(edge.target())
                            funcs_queue.append(new_func)
                if return_abbs:
                    yield abb

    def reachable_functs(self, func):
        """Generator about all reachable Functions starting at func."""
        return self._reachable_nodes(func, return_abbs=False)

    def reachable_abbs(self, func):
        """Generator about all reachable ABBs starting at func."""
        return self._reachable_nodes(func, return_abbs=True)

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
    """ TODO comment on functionality
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


class InstanceGraph(graph_tool.Graph):
    """Tracks all instances (nodes) with its flow insensitive interactions
    (edges).
    """
    def __init__(self):
        super().__init__()
        # vertex properties
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
        self.vertex_properties["file"] = self.new_vp("string")
        self.vertex_properties["line"] = self.new_vp("int")
        self.vertex_properties["specialization_level"] = self.new_vp("string")

        self.edge_properties["label"] = self.new_ep("string")


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
