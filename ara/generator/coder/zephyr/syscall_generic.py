from ..syscall_generic import GenericSystemCalls as _GenericSystemCalls
from ..elements import (DataObjectArray, DataObject, Function, FunctionCall,
                        Statement, Include, CPPStatement, FunctionDeclaration)
from ara.os.zephyr import Mutex, Queue, Thread


class GenericSystemCalls(_GenericSystemCalls):

    def __init__(self):
        pass

