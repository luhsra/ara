# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# cython: language_level=3
# vim: set et ts=4 sw=4:

cdef extern from "os.h" namespace "ara::os":
    cdef cppclass SysCall:
        SysCall(object, object)
