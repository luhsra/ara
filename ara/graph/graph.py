
import graph_tool
import graph_tool.util

import enum

from collections import deque

from .graph_data import PyGraphData
from .mix import ABBType, CFType

class CFG(graph_tool.Graph):
    """Describe the local, interprocedural and global control flow.

    Contains ABBs and functions that can be differentiated by the "is_function"
    property.

    The ABBs itself can have different types, set by the "type" property
    containing an ABBType.

    A function is connected with all its ABBs with CFType.f2a edges (see "type"
    property). A connection back is given with CFType.a2f. Local,
    interprocedural and global control flow is marked with CFType.lcf,
    CFType.icf and CFType.gcf.

    The is_entry property indicates that the edge points to the entry ABB of
    the function.
    """
    def __init__(self):
        super().__init__()
        # properties
        # ATTENTION: If you modify this values, you also have to update
        # cgraph/graph.cpp and cgraph/graph.h.

        # vertex properties
        self.vertex_properties["name"] = self.new_vp("string")
        self.vertex_properties["type"] = self.new_vp("int")
        self.vertex_properties["is_function"] = self.new_vp("bool")
        # vertex properties for ABB nodes
        # TODO: this stores a pointer, make this target architecture aware
        self.vertex_properties["entry_bb"] = self.new_vp("int64_t")
        self.vertex_properties["exit_bb"] = self.new_vp("int64_t")
        self.vertex_properties["is_exit"] = self.new_vp("bool")
        self.vertex_properties["is_loop_head"] = self.new_vp("bool")
        # vertex properties for Function nodes
        self.vertex_properties["implemented"] = self.new_vp("bool")
        self.vertex_properties["syscall"] = self.new_vp("bool")
        self.vertex_properties["function"] = self.new_vp("int64_t")
        self.vertex_properties["arguments"] = self.new_vp("object")
        self.vertex_properties["call_graph_link"] = self.new_vp("long")

        # edge properties
        self.edge_properties["type"] = self.new_ep("int")
        # Function to ABB edges
        self.edge_properties["is_entry"] = self.new_ep("bool")

    def get_function_by_name(self, name: str):
        """Find a specific function."""
        func = graph_tool.util.find_vertex(self, self.vp["name"], name)
        assert len(func) == 1 and self.vp.is_function[func[0]]
        return func[0]

    def get_function(self, abb):
        """Get the function node for an ABB."""
        abb = self.vertex(abb)

        def is_func(abb):
            return self.ep.type[abb] == CFType.a2f

        entry = list(filter(is_func, abb.out_edges()))
        assert len(entry) == 1
        return entry[0].target()

    def get_abbs(self, function):
        for edge in self.vertex(function).out_edges():
            if self.ep.type[edge] == CFType.f2a:
                yield edge.target()

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
            return self.vp.is_exit[abb]

        entry = list(filter(is_exit, function.out_neighbors()))
        if entry:
            assert len(entry) == 1
            return entry[0]
        else:
            return None

    def get_syscall_name(self, abb):
        """Return the called syscall name for a given abb."""
        abb = self.vertex(abb)
        if not self.vp.type[abb] == ABBType.syscall:
            print("no syscall", abb)
            return ''
        syscall = [x.target() for x in abb.out_edges()
                   if self.ep.type[x] == CFType.icf]
        assert len(syscall) == 1
        syscall_func = [x.target() for x in syscall[0].out_edges()
                        if self.ep.type[x] == CFType.a2f]
        assert len(syscall_func) == 1
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

    def reachable_funcs(self, func):
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
        self.vertex_properties["system_relevant"] = self.new_vp("bool")
        #edge properties
        self.edge_properties["callsite"] = self.new_ep("long")
        self.edge_properties["callsite_name"] = self.new_ep("string")
        self.edge_properties["svf_elink"] = self.new_ep("int64_t")

        self.graph_properties["cfg"] = self.new_gp("object", cfg)

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


class Graph:
    """Container for all data that ARA uses from multiple steps.

    Mainly, this are subgraphs.

    Additionally, an LLVM module is stored but only for access from the
    C++ side.
    """

    def _init_cfg(self):
        self.cfg = CFG()

        self.functs = graph_tool.GraphView(self.cfg,
                                           vfilt=self.cfg.vp.is_function)

    def __init__(self):
        # should be used only from C++, see graph.h
        self._graph_data = PyGraphData()
        self._init_cfg()
        self.callgraph = Callgraph(self.cfg)
        self.os = None
        #self.call_graphs = {}
        self.instances = None
        self.step_data = {}
