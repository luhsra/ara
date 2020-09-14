# cython: language_level=3
# vim: set et ts=4 sw=4:

from libcpp cimport bool
from libcpp.memory cimport shared_ptr
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map

from ir cimport Value, AttributeSet

from .cgraph cimport CallGraph

ctypedef Value& value_ref

cdef extern from "arguments.h" namespace "ara::graph":
    cdef cppclass CallPath:
        string print(bool, bool, bool)
        void add_call_site(object, object)
        object py_at(size_t)
        size_t size()
        void pop_back()
        void pop_front()
        size_t hash()
        bool operator==(const CallPath&)

    cdef cppclass Argument:
        ctypedef unordered_map[CallPath, value_ref].iterator iterator
        bool is_determined()
        bool is_constant()
        bool has_value(CallPath&)
        Value get_value(CallPath&)
        AttributeSet& get_attrs()
        size_t size()
        iterator begin()
        iterator end()

    cdef cppclass Arguments:
        ctypedef vector[shared_ptr[Argument]].size_type size_type

        @staticmethod
        shared_ptr[Arguments] get()

        size_type size()
        shared_ptr[Argument] at(size_type)
