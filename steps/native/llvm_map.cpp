// vim: set noet ts=4 sw=4:

#include "llvm_map.h"

namespace step {
	std::string LLVMMap::get_description() {
		return "Map llvm::Basicblock and llvm::Function to OS::ABB and OS::Function."
		       "\n"
		       "Maps in a one to one mapping.";
	}

	void LLVMMap::run(graph::Graph& graph) { logger.info() << "Execute C++ dummy step." << std::endl; }
} // namespace step
