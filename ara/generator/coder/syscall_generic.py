from .base import BaseCoder
from .elements import Function, FunctionCall, FunctionDeclaration, Statement

class GenericSystemCalls(BaseCoder):
    def __init__(self):
        self._init = Function('_init', 'void', [], extern_c=True,
                              attributes=['__attribute__((weak))'])


