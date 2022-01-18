from enum import Enum


class GraphTypes(Enum):
    ABB = "Abb"
    INSTANCE = "Instance"
    CALLGRAPH = "CallGraph"


class StepMode:
    DEFAULT = 1
    TRACE = 2