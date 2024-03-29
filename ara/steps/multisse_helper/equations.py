# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from .common import TimeRange

from ara.util import get_logger

import graph_tool
import logging
import math

from copy import deepcopy
from scipy.optimize import linprog

log = get_logger("MultiSSE.EQs", inherit=True)


# translation map between the hash of edges and their names
edge_strings = {}


def p_in(edge):
    # do only anything when debugging is active
    if log.getEffectiveLevel() == logging.DEBUG:
        global edge_strings
        edge_strings[hash(edge)] = str(edge)


def e_str(h_edge):
    if log.getEffectiveLevel() == logging.DEBUG:
        global edge_strings
        return edge_strings[h_edge]
    return f"{h_edge}_hashed"


def _to_var(idx):
    """Converts a number into a meaningful string."""
    alphabet = 'abcdefghijklmnopqrstuvwxyz'
    if idx >= len(alphabet):
        return f'v{idx}'
    return alphabet[idx]


class Equations:
    """Equation system for calculation of possible pairing partners."""
    def __init__(self):
        self._bounds = {}
        self._equalities = []
        self._v_map = {}
        self._highest = 0

    def __repr__(self):
        return ("Equations("
                f"_bounds: {self._bounds}, "
                f"_equalities: {self._equalities}, "
                f"_v_map: {self._v_map}, "
                f"_highest: {self._highest})")

    def __str__(self):
        return f"Equations({len(self._bounds.items())}, {len(self._equalities)})"
        ret = "Equations("
        for var, bound in self._bounds.items():
            ret += f"\n  {bound.up} < {_to_var(var)} < {bound.to}"

        for eq in self._equalities:
            left = ' + '.join(
                [_to_var(idx) for idx, elem in enumerate(eq) if elem == 1])
            right = ' + '.join(
                [_to_var(idx) for idx, elem in enumerate(eq) if elem == -1])

            ret += f"\n  {left} = {right}"
        ret += f"\n  Mapping: {[(e_str(e), _to_var(idx)) for e, idx in self._v_map.items()]})"
        return ret

    def _get_variable(self, edge, must_exist=False):
        hedge = hash(edge)
        p_in(edge)
        if hedge not in self._v_map:
            if must_exist:
                assert False, f"Edge {edge} does not exist."
            self._v_map[hedge] = self._highest
            self._highest += 1
            for formula in self._equalities:
                formula.append(0)
        return self._v_map[hedge]

    def _solve_for_var(self, var, minimize=True):
        def inf(num):
            return None if num == math.inf else num

        c = (self._highest) * [0]
        c[var] = int(minimize) * 2 - 1
        b_eq = len(self._equalities) * [0]
        bounds = []
        for i in range(self._highest):
            assert i in self._bounds
            time = self._bounds[i]
            bounds.append((inf(time.up), inf(time.to)))
        return linprog(c, A_eq=self._equalities, b_eq=b_eq, bounds=bounds)

    def solvable(self):
        """Return, if the equation system has a solution."""
        if self._highest == 0:
            return True
        res = self._solve_for_var(0)
        log.debug("The equation system is solvable: %d, %s", res.success, self)
        return res.success

    def _has_equation(self, var):
        for equation in self._equalities:
            if equation[var] != 0:
                return True
        return False

    def _get_minimum(self, var):
        """Return the minimum time for a specific var."""
        min_res = self._solve_for_var(var)
        assert min_res.success or min_res.status == 3
        if min_res.status == 3:
            return math.inf
        else:
            return int(min_res.fun + 0.5)

    def _get_maximum(self, var):
        """Return the minimum time for a specific var."""
        max_res = self._solve_for_var(var, minimize=False)
        assert max_res.success or max_res.status == 3
        # add 0.000001 because of floating point imprecision
        if max_res.status == 3:
            return math.inf
        else:
            return int(max_res.fun * -1 + 0.0001)

    def get_interval_for(self, edge):
        """Return the solution interval for a specific edge."""
        var = self._get_variable(edge, must_exist=True)
        if self._has_equation(var):
            ret = TimeRange(up=self._get_minimum(var),
                            to=self._get_maximum(var))
        else:
            ret = self._bounds[var]
        log.debug("Solution of the equation system for %s: %s\n%s",
                  edge, ret, self)
        return ret

    def add_range(self, edge: graph_tool.Edge, time: TimeRange):
        """Store that the specified edge lives only in the range time.

        Basically store for edge e the equation: up < time_e < to
        """
        assert isinstance(time, TimeRange)
        assert time.to >= time.up and time.up >= 0
        var = self._get_variable(edge)
        self._bounds[var] = time

    def add_equality(self, left_edges, right_edges):
        """Store that the left_edges sum must be equal to the right_edges sum.

        Store an equation like: a_left + b_left + c_left = d_right + e_right
        """
        le = set(left_edges)
        re = set(right_edges)
        common = le & re
        formula = (self._highest) * [0]
        for left in (le - common):
            formula[self._get_variable(left, must_exist=True)] = 1
        for right in (re - common):
            formula[self._get_variable(right, must_exist=True)] = -1
        self._equalities.append(formula)

    def copy(self):
        cp = Equations()
        cp._bounds = deepcopy(self._bounds)
        cp._equalities = deepcopy(self._equalities)
        cp._v_map = dict([(e, idx) for e, idx in self._v_map.items()])
        cp._highest = self._highest
        return cp
