// vim: set noet ts=4 sw=4:

#include "test.h"
#include "llvm_common.h"

#include "llvm/IR/Instructions.h"
#include "llvm/Support/Casting.h"

#include <iostream>
#include <string>
#include <stdexcept>

#include "graph.h"

namespace step {
	std::string LLVMMapTest::get_name() { return "LLVMMapTest"; }

	std::string LLVMMapTest::get_description() { return "Step for testing the LLVMMap step"; }

	void LLVMMapTest::run(graph::Graph& graph) {
		llvm::Module& module = graph.new_graph.get_module();
	}

	std::vector<std::string> LLVMMapTest::get_dependencies() { return {"LLVMMap"}; }
} // namespace step
