# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""This file contains functions to translate common graphs to there JSON equivalent."""

import os.path

def json_callgraph(callgraph):
    """callgraph -> JSON Callgraph
    
    In this graph only the edges are contained.
    """
    c_edges = []
    for edge in callgraph.edges():
        c_edges.append([callgraph.vp.function_name[edge.source()],
                        callgraph.vp.function_name[edge.target()]])
    return sorted(c_edges)