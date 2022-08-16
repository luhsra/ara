from .common import CPRange, Range
from ara.util import has_path

from collections import defaultdict
from graph_tool import GraphView
from graph_tool.search import bfs_search, BFSVisitor, StopSearch


def _check_barriers(graph, new_barriers, old_barriers):
    """Check, if new_barriers are tighter than old_barriers.

    Internally, this work by calculating a path from old_barriers to
    new_barriers for each core. If such a path exists new_barriers is not
    tighter.

    The function corrects this directly in new_barriers.
    """
    for cpu, new in new_barriers.items():
        old = old_barriers[cpu]
        if old is not None:
            if has_path(graph, old, new):
                new_barriers[cpu] = old


def get_constrained_sps(g, core_map, cores, new_range, old_sps=None):
    """Get the SPs that restricted by new_range.

    Arguments:
    g --         A graph of SPs.
    cores --     All affected cores (to respect only SPs that include these
                 cores.
    new_range -- A range of SPs within the search must take place.
    old_sps --   An already restricted set of SPs

    Example:
    cores={0,1,2}
    new_range={start=SP4, end=None}
    old_sps:
    { 0: CPRange(root=SP1, range=(start=SP2, end=None),
      1: CPRange(root=SP1, range=(start=SP2, end=None),
      2: CPRange(root=SP1, range=(start=SP1, end=None) }

    Given this history:

    SP1: [ 0 | 1 | 2 | 3 ]
               |
               v
    SP2: [ 0 | 1 ]
               |         <- Here are the "bounds" of old_sps
               v
    SP3:     [ 1 | 2 ]
                   |
                   v
    SP4:         [ 2 | 3 ]

    the result would be a new dict of SPs:
    { 0: CPRange(root=SP1, range=(start=SP2, end=None),
      1: CPRange(root=SP1, range=(start=SP3, end=None),
      2: CPRange(root=SP1, range=(start=SP4, end=None) }

    The algorithm works by doing a BFS from the start point of the new
    range backwards and a BFS from the end point of the range forward until
    it has found an SP for all affected cores to find all new bounds.
    """
    if old_sps is None:
        old_sps = defaultdict(
            lambda: CPRange(root=None, range=Range(start=None, end=None)))

    unbound = {*cores}
    new_starts = {}
    new_ends = defaultdict(lambda: None)

    class Constraints(BFSVisitor):
        def __init__(self, sp_map, sp_list):
            self.sp_map = sp_map
            self.sp_list = sp_list

        def discover_vertex(self, u):
            if len(unbound) == 0:
                raise StopSearch
            u_cores = set(self.sp_map[u]) & unbound
            for core in u_cores:
                self.sp_list[core] = u
                unbound.remove(core)

    # first find the new starting SPs
    rsync = GraphView(g, reversed=True)
    bfs_search(rsync,
               source=new_range.start,
               visitor=Constraints(core_map, new_starts))

    # TODO, check why this is necessary
    _check_barriers(
        rsync, new_starts,
        dict([(x, old_sps[x].range.start) for x in cores]))

    # then find the new ending SPs, if necessary
    if new_range.end:
        bfs_search(g,
                   source=new_range.end,
                   visitor=Constraints(core_map, new_ends))

        _check_barriers(
            g, new_ends, dict([(x, old_sps[x].range.end) for x in cores]))

    return dict([(x,
                  CPRange(root=old_sps[x].root,
                          range=Range(start=new_starts[x],
                                      end=new_ends[x])))
                 for x in cores])
