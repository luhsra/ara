#include "llvm.h"

#include <string>
#include <iostream>

namespace passage {

	std::string LLVMPassage::get_name() {
		return "LLVMPassage";
	}

	std::string LLVMPassage::get_description() {
		return "Extracts out of LLVM.";
	}

	void LLVMPassage::run(graph::Graph graph) {
		std::cout << "Run " << get_name() << std::endl;
	}

	std::vector<std::string> LLVMPassage::get_dependencies() {
		return {"OilPassage"};
	}
}
