# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph
from carguments cimport Argument, CallPath
from os cimport SysCall as CSysCall

from libcpp cimport bool
from libcpp.memory cimport shared_ptr
from libcpp.map cimport map as cppmap
from libcpp.string cimport string

cdef extern from "cy_helper.h" namespace "ara::graph":
    cgraph.SigType to_sigtype(int i)
    object safe_get_value(shared_ptr[Argument], const CallPath&)
    void insert_in_map(cppmap[const string, CSysCall]&, string&, CSysCall)
