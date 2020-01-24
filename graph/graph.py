import pyllco

import graph_tool
import graph_tool.util

import enum

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
        # vertex properties for Function nodes
        self.vertex_properties["implemented"] = self.new_vp("bool")
        self.vertex_properties["syscall"] = self.new_vp("bool")
        self.vertex_properties["function"] = self.new_vp("int64_t")
        self.vertex_properties["arguments"] = self.new_vp("object")

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

    def get_entry_abb(self, function):
        """Return the entry_abb of the given function."""
        function = self.vertex(function)

        def is_entry(abb):
            return self.ep.is_entry[abb] and self.ep.type[abb] == CFType.f2a

        entry = list(filter(is_entry, function.out_edges()))
        assert len(entry) == 1
        return entry[0].target()

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


class CFGView(graph_tool.GraphView):
    """Class to get CFG functions for a filtered CFG."""
    def __init__(self, graph, **kwargs):
        graph_tool.GraphView.__init__(self, graph, **kwargs)

    def get_function_by_name(self, *args, **kwargs):
        return self.base.get_function_by_name(*args, **kwargs)

    def get_function(self, *args, **kwargs):
        return self.base.get_function(*args, **kwargs)

    def get_entry_abb(self, *args, **kwargs):
        return self.base.get_entry_abb(*args, **kwargs)

    def get_syscall_name(self, *args, **kwargs):
        return self.base.get_syscall_name(*args, **kwargs)


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
        self._llvm = pyllco.Module()
        self._init_cfg()
        self.os = None
        self.call_graphs = {}
        self.instances = None
