from enum import Enum


class GraphTypes(Enum):
    ABB = "Abb"
    INSTANCE = "Instance"
    SSTG_FULL = "SSTG-Full"
    SSTG_SIMPLE = "SSTG-Simple"
    MULTISTATES = "Multistate"
    CALLGRAPH = "CallGraph"
