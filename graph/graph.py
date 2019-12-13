import pyllco

import graph_tool

import enum

from .mix import ABBType, CFType


class Graph:
    """Container for all data that ARA uses from multiple steps.

    Mainly, this are subgraphs.

    Additionally, an LLVM module is stored but only for access from the
    C++ side.
    """

    def _init_cfg(self):
        self.cfg = graph_tool.Graph()
        # vertex properties
        self.cfg.vertex_properties["name"] = self.cfg.new_vp("string")
        self.cfg.vertex_properties["type"] = self.cfg.new_vp("int")
        self.cfg.vertex_properties["is_function"] = self.cfg.new_vp("bool")
        # vertex properties for ABB nodes
        # TODO: this stores a pointer, make this target architecture aware
        self.cfg.vertex_properties["entry_bb"] = self.cfg.new_vp("int64_t")
        self.cfg.vertex_properties["exit_bb"] = self.cfg.new_vp("int64_t")
        # vertex properties for Function nodes
        self.cfg.vertex_properties["implemented"] = self.cfg.new_vp("bool")
        self.cfg.vertex_properties["syscall"] = self.cfg.new_vp("bool")
        self.cfg.vertex_properties["function"] = self.cfg.new_vp("int64_t")

        # edge properties
        self.cfg.edge_properties["type"] = self.cfg.new_ep("int")
        # Function to ABB edges
        self.cfg.edge_properties["is_entry"] = self.cfg.new_ep("bool")

        self.functs = graph_tool.GraphView(self.cfg,
                                           vfilt=self.cfg.vp.is_function)

    def __init__(self):
        # should be used only from C++, see graph.h
        self._llvm = pyllco.Module()
        self._init_cfg()
