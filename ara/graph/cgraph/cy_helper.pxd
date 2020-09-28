# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph

cdef extern from "cy_helper.h" namespace "ara::graph":
    cgraph.SigType to_sigtype(int i)
