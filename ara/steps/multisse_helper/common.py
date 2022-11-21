from ara.os.os_base import ExecState
from ara.graph import StateType, MSTType

import enum

from dataclasses import dataclass
from graph_tool import Vertex, GraphView
from graph_tool.topology import label_out_component
from itertools import product


@dataclass(frozen=True, eq=True)
class FakeEdge:
    """Represents an edge that don't exist in the graph."""
    src: Vertex
    tgt: Vertex

    def source(self):
        return self.src

    def target(self):
        return self.tgt

    def __repr__(self):
        def none_or_int(v):
            if v:
                return int(v)
            return None

        return f"FakeEdge({none_or_int(self.src)}, {none_or_int(self.tgt)})"

    def __hash__(self):
        """Generate a hash based on the input vertices."""
        # It is utterly important that the hash is equal for the same set of
        # vertices. Normally, this should happen automatically by the dataclass
        # decorator but we provide a function just to be save.
        return hash((int(self.src), int(self.tgt)))


@dataclass(frozen=True)
class Range:
    """A range between two vertices."""
    start: Vertex
    end: Vertex

    def __repr__(self):
        def none_or_int(v):
            if v:
                return int(v)
            return None

        return ("Range("
                f"start: {none_or_int(self.start)}, "
                f"end: {none_or_int(self.end)})")


@dataclass(frozen=True)
class SPRange:
    root: Vertex
    range: Range

    def __repr__(self):
        return ("SPRange(" f"root: {int(self.root)}, " f"range: {self.range})")


class CrossExecState(enum.IntEnum):
    """Execution state of an MSTG state.

    It extends the normal ExecState.
    """
    idle = ExecState.idle
    computation = ExecState.computation
    waiting = ExecState.waiting

    with_time = ExecState.with_time

    call = ExecState.call
    syscall = ExecState.syscall

    __max = max(int(x) for x in ExecState).bit_length()
    cross_syscall = 1 << __max
    cross_irq = 1 << __max + 1
    irq = 1 << __max + 2

    no_time = ExecState.no_time | cross_syscall


@dataclass(frozen=True)
class TimeRange:
    """Represent a time range.

    Normally, this is a range between BCET (best-case execution time) and WCET
    (worst-case execution time).
    Sometimes, it is also a range between BCST (best-case starting time) and
    WCST (worst-case starting time). In this range the ABB or SP definitely
    starts.
    """
    up: int
    to: int

    def get_overlap(self, other: "TimeRange") -> "TimeRange":
        """Return a new TimeRange specifying the overlap between two ranges."""
        new_up = max(self.up, other.up)
        new_to = min(self.to, other.to)
        if new_to > new_up:
            return TimeRange(up=new_up, to=new_to)
        return None

    def __add__(self, other: "TimeRange"):
        return TimeRange(up=self.up + other.up, to=self.to + other.to)


def get_reachable_states(mstg, entry_state, exit_state=None):
    """Return a graph of all reachable states given an entry_state.

    The search applies only to state within the same metastate.
    If an exit state is given only states are returned which have a path
    to this exit state.
    """
    outs = label_out_component(mstg, mstg.vertex(entry_state))
    outs[entry_state] = True

    if exit_state:
        rs2s = GraphView(mstg, reversed=True)
        ins = label_out_component(rs2s, rs2s.vertex(exit_state))
        ins[exit_state] = True
        outs.fa &= ins.fa

    return GraphView(mstg, vfilt=outs)


def _find_cross(mstg, type_map, metastate, entry, cross_type):
    """Find all states of type cross_type coming for a given metastate
    coming from entry.
    """
    s2s = mstg.vertex_type(StateType.state)

    # the algorithm works a follows:
    # 1. Mark all reachable states coming from entry (within the same
    #    metastate).
    # 2. Filter this set for the given cross_type.
    oc = label_out_component(s2s, s2s.vertex(entry))
    oc[metastate] = True

    type_filtered = GraphView(
        mstg,
        vfilt=(((mstg.vp.type.fa == StateType.metastate) +
                (type_map.fa & cross_type) > 0)),
    )
    reachable_filtered = GraphView(type_filtered, vfilt=oc)

    return list(reachable_filtered.vertex(metastate).out_neighbors())


def find_cross_syscalls(mstg, type_map, metastate, entry):
    """Return all syscalls that possibly affect other cores."""
    return _find_cross(mstg, type_map, metastate, entry,
                       CrossExecState.cross_syscall)


def find_irqs(mstg, type_map, state, entry):
    """Return all IRQs that possibly affect other cores."""
    ists = _find_cross(mstg, type_map, state, entry,
                       CrossExecState.cross_irq | CrossExecState.irq)
    st2sy = mstg.edge_type(MSTType.st2sy)
    out = []
    for irq_state in ists:
        # every state must have be evaluated before
        # so check their irqs iterating the out edges
        irq = set([mstg.ep.irq[e]
                   for e in st2sy.vertex(irq_state).out_edges()]) - {-1}
        out.extend(product([irq_state], irq))
    return out
