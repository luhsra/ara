# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr

cdef extern from "step.h" namespace "ara::step":
    cdef cppclass Step:
        Step() except +
        void apply_config(dict config)
        void run()

    cdef cppclass StepFactory:
        string get_name()
        string get_description()
        unique_ptr[Step] instantiate(object, cgraph.Graph, object)

# all step following

cdef extern from "bb_split.h" namespace "ara::step":
    cdef cppclass BBSplit:
        pass

cdef extern from "cdummy.h" namespace "ara::step":
    cdef cppclass CDummy:
        pass

cdef extern from "comp_insert.h" namespace "ara::step":
    cdef cppclass CompInsert:
        pass

cdef extern from "fake_entry_point.h" namespace "ara::step":
    cdef cppclass FakeEntryPoint:
        pass

cdef extern from "fn_single_exit.h" namespace "ara::step":
    cdef cppclass FnSingleExit:
        pass

cdef extern from "callgraph.h" namespace "ara::step":
    cdef cppclass CallGraph:
        pass

cdef extern from "ir_reader.h" namespace "ara::step":
    cdef cppclass IRReader:
        pass

cdef extern from "ir_writer.h" namespace "ara::step":
    cdef cppclass IRWriter:
        pass

cdef extern from "llvm_map.h" namespace "ara::step":
    cdef cppclass LLVMMap:
        pass

cdef extern from "llvm_optimization.h" namespace "ara::step":
    cdef cppclass LLVMOptimization:
        pass

cdef extern from "load_freertos_config.h" namespace "ara::step":
    cdef cppclass LoadFreeRTOSConfig:
        pass

cdef extern from "replace_syscalls_create.h" namespace "ara::step":
    cdef cppclass ReplaceSyscallsCreate:
        pass

cdef extern from "resolve_function_pointer.h" namespace "ara::step":
    cdef cppclass ResolveFunctionPointer:
        pass

cdef extern from "svf_analyses.h" namespace "ara::step":
    cdef cppclass SVFAnalyses:
        pass

cdef extern from "svf_transformation.h" namespace "ara::step":
    cdef cppclass SVFTransformation:
        pass
