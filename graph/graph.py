import pyllco

import graph_tool

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
        # vertex properties for Function nodes
        self.vertex_properties["implemented"] = self.new_vp("bool")
        self.vertex_properties["syscall"] = self.new_vp("bool")
        self.vertex_properties["function"] = self.new_vp("int64_t")
        self.vertex_properties["arguments"] = self.new_vp("object")

        # edge properties
        self.edge_properties["type"] = self.new_ep("int")
        # Function to ABB edges
        self.edge_properties["is_entry"] = self.new_ep("bool")


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
