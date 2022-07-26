
from datetime import datetime
from ara.visualization.trace.trace_components import BaseTraceElement
from dataclasses import dataclass
from pathlib import Path
from typing import List
from ara.graph.graph import CFG, SVFG, Callgraph, InstanceGraph

from ara.visualization.trace.trace_type import AlgorithmTrace
from ara.steps.step import Step


@dataclass
class Entity:
    #id: int
	name: str

@dataclass
class GraphNode:
    node_id: int
    graph: type
    def __str__(self):
        return f"node {self.node_id} in {self.graph.__name__}"

class Path:
    pass

class Tracer:
    def __init__(self, trace_name: str, callgraph, cfg, instances, svfg, low_level_trace:AlgorithmTrace=None):
        self.trace_name = trace_name
        if low_level_trace == None:
            self.low_level_trace = AlgorithmTrace(callgraph, cfg, instances, svfg)
        else:
            self.low_level_trace = low_level_trace

    def _format_trace_output(self, entity: Entity, output: str):
        line = f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} {self.trace_name:{10}} {entity.name:{15}} {output}\n"
        print(line, end='')
        return line

    def _format_node_output(self, ent: Entity, nodes: List[GraphNode], msg: str) -> str:
        output_str = ""
        for node in nodes:
            output_str += self._format_trace_output(ent, msg + str(node))
        return output_str

    def get_entity(self, name: str):
        """Creates a new entity on this trace"""
        return Entity(name)

    def entity_on_node(self, ent: Entity, nodes: List[GraphNode]):
        if type(nodes) != List:
            nodes = [nodes]
        self.low_level_trace.add_element(None, self._format_node_output(ent, nodes, "is on "))

    def entity_is_looking_at(self, ent: Entity, paths: List[Path]):
        pass

    def get_subtrace(self, name: str):
        return Tracer(self.trace_name + ":" + name, None, None, None, None, low_level_trace=self.low_level_trace)

    def add_element(self, element:BaseTraceElement, log_message:str=None):
        """Direct interface to low level trace API.
        
        Just calls self.low_level_trace.add_element().
        """
        return self.low_level_trace.add_element(element, log_message)


def init_fast_trace(step: Step, name:str=None):
    """Same as init_trace() but without graph copies"""
    if name == None:
        name = step.get_name()
    graph = step._graph
    step.trace = Tracer(name, graph.callgraph, graph.cfg, graph.instances, graph.svfg)

def init_trace(step: Step, name:str=None):
    """Initializes a new visualization trace. Called on startup of traceable steps.
    Call it with the current step that is running e.g. ini_trace(self)"""
    if name == None:
        name = step.get_name()
    graph = step._graph
    step.trace = Tracer(name, Callgraph(graph.cfg, graph=CFG(graph.callgraph)), CFG(graph.cfg), InstanceGraph(graph.instances), SVFG(graph.svfg))
