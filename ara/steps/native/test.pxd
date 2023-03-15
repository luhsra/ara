# SPDX-FileCopyrightText: 2019 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "test.h" namespace "ara::step":
    cdef cppclass Test0Step:
        pass

    cdef cppclass Test2Step:
        pass

    cdef cppclass BBSplitTest:
        pass

    cdef cppclass CFGOptimizeTest:
        pass

    cdef cppclass CompInsertTest:
        pass

    cdef cppclass FnSingleExitTest:
        pass

    cdef cppclass LLVMMapTest:
        pass

    cdef cppclass PosixClangGlobalTest:
        pass