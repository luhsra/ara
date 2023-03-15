# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# cython: language_level=3

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool

cdef extern from "option.h" namespace "ara::option":
    cdef cppclass Option:
        string get_name()
        string get_help()
        unsigned get_type()
        bool is_global()

    cdef cppclass OptionType:
        pass

cdef extern from "option.h" namespace "ara::option::OptionType":
    cdef OptionType INT
    cdef OptionType FLOAT
    cdef OptionType BOOL
    cdef OptionType STRING
    cdef OptionType CHOICE
    cdef OptionType LIST
    cdef OptionType RANGE

