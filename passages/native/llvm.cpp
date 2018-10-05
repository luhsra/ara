#include "llvm.h"

#include <string>
#include <iostream>

namespace pass {

	std::string LLVMPass::get_name() {
		return "LLVMPass";
	}

	std::string LLVMPass::get_description() {
		return "Extracts out of LLVM.";
	}

	void LLVMPass::run(graph::Graph graph) {
		std::cout << "Run " << get_name() << std::endl;
	}
}
