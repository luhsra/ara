# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from dataclasses import dataclass
from enum import Enum

from ara.graph.mix import GraphType


# The color numbers are used for determining the correct style in the style sheet.
# To add new color, one has to first add the color to the stylesheet.
# For Edge color, see the mapping in trace_util.
class Color(Enum):
    """
        Color enum used to declare the color for the highlighting.
    """
    RED = "1"
    AQUA = "2"
    GREEN = "3"
    ORANGE = "4"


@dataclass(frozen=True)
class TraceElementSetting:
    is_vertex: bool
    graph: GraphType
    obj: any
