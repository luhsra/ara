# SPDX-FileCopyrightText: 2021 Jan Neugebauer
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph
from carguments cimport Argument, CallPath
from os cimport SysCall as CSysCall

from libcpp cimport bool
from libcpp.memory cimport shared_ptr

cdef extern from "cy_helper.h" namespace "ara::graph":
    cgraph.SigType to_sigtype(int i)
    object safe_get_value(shared_ptr[Argument], const CallPath&)
