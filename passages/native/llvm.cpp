#include "llvm.h"

#include <string>
#include <iostream>
#include <vector>

#include <cassert>
#include <stdexcept>

namespace passage {

	std::string LLVMPassage::get_name() {
		return "LLVMPassage";
	}

	std::string LLVMPassage::get_description() {
		return "Extracts out of LLVM.";
	}

	void LLVMPassage::run(graph::Graph graph) {
		// get file arguments from config
		std::vector<std::string> files;
		std::cout << "Run " << get_name() << std::endl;
		PyObject* input_files = PyDict_GetItemString(config, "input_files");
		assert(input_files != nullptr && PyList_Check(input_files));
		for (Py_ssize_t i = 0; i < PyList_Size(input_files); ++i) {
			PyObject* elem = PyList_GetItem(input_files, i);
			assert(PyUnicode_Check(elem));
			files.push_back(std::string(PyUnicode_AsUTF8(elem)));
		}

		for (const auto& file : files) {
			std::cout << "File: " << file << std::endl;
		}
	}

	std::vector<std::string> LLVMPassage::get_dependencies() {
		return {"OilPassage"};
	}
}
