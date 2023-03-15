# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# cython: language_level=3
# vim: set et ts=4 sw=4:

from graph_data cimport GraphData

from libcpp.memory cimport unique_ptr

cdef extern from "graph.h" namespace "ara::graph":
    cdef cppclass Graph:
        Graph()
        Graph(object, GraphData&)

    cdef cppclass CallGraph:
        @staticmethod
        CallGraph get(object)

    cdef cppclass SigType:
        pass
