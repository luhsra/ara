"""
    @file
    @ingroup primitives
    @brief Constructs the source file.
"""


from .IncludeManager import IncludeManager, Include
from .DataObjectManager import DataObjectManager
from .FunctionManager import FunctionManager
from generator import tools

class SourceFile:
    def __init__(self, _log=None):
        self.includes = IncludeManager(_log)
        self.declarations = []
        self.data_manager = DataObjectManager(_log)
        self.function_manager = FunctionManager(_log)
        self.definitions = []
        self._log = _log.getChild(self.__class__.__name__)

    def include(self, filename):
        self.includes.add(Include(filename))

    def source_elements(self):
        return [self.includes.source_elements()] \
            + ["\n"] \
            + [self.function_manager.source_element_declarations()] \
            + [self.data_manager.source_element_declaration()] \
            + [self.data_manager.source_element_allocation()] \
            + [self.declarations]\
            + [self.data_manager.source_element_initializer()] \
            + ["\n"] \
            + [self.function_manager.source_element_definitions()]\
            + [self.definitions]\

    def expand(self, generator):
        # Get the source elements tree
        elements = self.source_elements()
        return tools.format_source_tree(generator, elements)
