# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Helper functions that are needed in multiple places."""
import os

from contextlib import contextmanager
from functools import lru_cache
from graph_tool.topology import label_out_component, shortest_path, dominator_tree

from ara.graph import NodeLevel, CFType, CFGView
from ara.util import has_path, dominates


def raise_and_error(logger, message, exception=RuntimeError):
    """Error log message and raise it as exception."""
    logger.error(message)
    raise exception(message)


@contextmanager
def open_with_dirs(path, flags="w"):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, flags) as g:
        yield g


class Wrapper:
    def set_wrappee(self, wrappee):
        self.__wrappee = wrappee

    def __getattr__(self, attr):
        return getattr(self.__wrappee, attr)
current_step = Wrapper()


@lru_cache(maxsize=1024)
def is_recursive(callgraph, v):
    """Checks if given vertex v is in a loop => v is recursive"""
    v = callgraph.vertex(v)
    for neighbor in v.out_neighbors():
        vert, edge = shortest_path(callgraph, neighbor, v)
        if vert:
            return True
    return False


@lru_cache(maxsize=32)
def _get_func_cfg(cfg, func):
    """Get LCFG of function"""
    abbs = CFGView(cfg, vfilt=cfg.vp.level.fa == NodeLevel.abb)
    lcfg = CFGView(abbs, efilt=cfg.ep.type.fa == CFType.lcf)
    abb = cfg.get_entry_abb(func)
    comp = label_out_component(lcfg,
                               lcfg.vertex(abb))
    return CFGView(lcfg, vfilt=comp)


@lru_cache(maxsize=32)
def _create_dom_tree(cfg, func, respect_endless_loops=True):
    """Create a dominator tree of the local control flow for func.

    Return the dominator tree and a list of exit blocks for the function.
    """
    func_cfg = _get_func_cfg(cfg, func)
    entry = cfg.get_entry_abb(func)

    # prepare LCFG:
    # If respect_endless_loops is set (the default), endless loops are
    # considered as possible exit blocks.
    # This is done by detecting and replacing them with real exit blocks.
    exit_map = func_cfg.vp.is_exit.copy(full=False)
    keep_edge_map = func_cfg.new_ep("bool", val=True)

    if respect_endless_loops:
        # iterate all exit loops (AKA endless loops)
        loops = CFGView(func_cfg, vfilt=func_cfg.vp.is_exit_loop_head)
        for loop_head in loops.vertices():
            loop_head = func_cfg.vertex(loop_head)
            for e in loop_head.in_edges():
                loop_end = e.source()
                if loop_head == loop_end or \
                   has_path(func_cfg, loop_head, loop_end):
                    # if edge that is a part of the loop
                    # drop it
                    keep_edge_map[e] = False
                    exit_map[loop_end] = True

    patched_func_cfg = CFGView(func_cfg, efilt=keep_edge_map)

    # dom tree creation
    dom_tree = dominator_tree(patched_func_cfg,
                              patched_func_cfg.vertex(entry))
    return dom_tree, CFGView(func_cfg, vfilt=exit_map)


def is_in_condition(cfg, abb, respect_endless_loops=True):
    """Is abb part of a condition?"""
    # Algorithm: abb must not dominate all exits
    func = cfg.get_function(abb)
    dom_tree, exit_abbs = _create_dom_tree(
            cfg, func,
            respect_endless_loops=respect_endless_loops
    )
    return not all(
        [dominates(dom_tree, abb, x) for x in exit_abbs.vertices()])


def is_usually_taken(cfg, abb):
    """Is this abb usually taken?

    Usually taken means that the abb is part of a branch, where all sibling
    branches end in an endless loop.

    Consider this example:
     1o
      |`--.
      |   v
     2o  3o <.
          |  |
          v  |
         4o--´
    The node 2 is usually taken.
    """
    return (is_in_condition(cfg, abb, respect_endless_loops=True) and
            not is_in_condition(cfg, abb, respect_endless_loops=False))
