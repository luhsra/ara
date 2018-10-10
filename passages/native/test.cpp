// vim: set noet ts=4 sw=4:

#include "test.h"

#include <string>
#include <iostream>

namespace passage {

	std::string Test0Passage::get_name() {
		return "Test0Passage";
	}

	std::string Test0Passage::get_description() {
		return "Passage for testing purposes";
	}

	void Test0Passage::run(graph::Graph graph) {
		std::cout << "Run " << get_name() << std::endl;
	}

	std::vector<std::string> Test0Passage::get_dependencies() {
		return {};
	}

	std::string Test2Passage::get_name() {
		return "Test2Passage";
	}

	std::string Test2Passage::get_description() {
		return "Passage for testing purposes";
	}

	void Test2Passage::run(graph::Graph graph) {
		std::cout << "Run " << get_name() << std::endl;
	}

	std::vector<std::string> Test2Passage::get_dependencies() {
		return {"Test1Passage"};
	}
}
