# distutils: language = c++

cimport cpass
cimport llvm
cimport graph

cdef class SuperPassage:
    def get_dependencies(self):
        return []

    def get_name(self) -> str:
        pass

    def get_description(self):
        pass

    def run(self, graph.PyGraph g):
        raise("Not implemented.")

class Passage(SuperPassage):
    def __init__(self, config):
        self._config = config

    def get_name(self):
        return self.__class__.__name__

    def get_description(self) -> str:
        return self.__doc__

ctypedef enum passages:
    LLVM_PASSAGE

cdef class NativePassage(SuperPassage):

    cdef cpass.Passage* _c_pass

    def __cinit__(self, config: dict, passages passage_cls):
        if passage_cls == LLVM_PASSAGE:
            self._c_pass = <cpass.Passage*> new llvm.LLVMPassage(config)
        else:
            raise("Unknown pass class")

        if self._c_pass is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._c_pass is not NULL:
            del self._c_pass

    def get_dependencies(self):
        # doing this in one line leads to a compiler error
        deps = self._c_pass.get_dependencies()
        return [x.decode('UTF-8') for x in deps]

    def run(self, graph.PyGraph g):
        self._c_pass.run(g._c_graph)

    def get_name(self) -> str:
        return self._c_pass.get_name().decode('UTF-8')

    def get_description(self):
        return self._c_pass.get_description()

def provide_passages(config: dict):
    return [NativePassage(config, LLVM_PASSAGE)]
