# distutils: language = c++

cimport cpass
cimport llvm
cimport graph

cdef class SuperPassage:
    def __init__(self, config):
        self._config = config

    def get_dependencies(self):
        return []

    def get_name(self) -> str:
        pass

    def get_description(self):
        pass

    def run(self, graph.PyGraph g):
        raise("Not implemented.")

class Passage(SuperPassage):
    _config = {}

    def get_name(self):
        return self.__class__.__name__

    def get_description(self) -> str:
        return self.__doc__

cdef class NativePassage(SuperPassage):
    cdef cpass.Pass* _c_pass  # Hold a C++ instance which we're wrapping

    def __cinit__(self):
        self._c_pass = <cpass.Pass*> new llvm.LLVMPass()
        if self._c_pass is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._c_pass is not NULL:
            del self._c_pass

    def run(self, graph.PyGraph g):
        self._c_pass.run(g._c_graph)

    def get_name(self) -> str:
        return self._c_pass.get_name()

    def get_description(self):
        return self._c_pass.get_description()
