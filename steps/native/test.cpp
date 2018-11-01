// vim: set noet ts=4 sw=4:

#include "test.h"

#include <string>
#include <iostream>

namespace step {

	std::string Test0Step::get_name() {
		return "Test0Step";
	}

	std::string Test0Step::get_description() {
		return "Step for testing purposes";
	}

	void Test0Step::run(graph::Graph& graph) {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
		
		
	}

	std::vector<std::string> Test0Step::get_dependencies() {
		return {};
	}

	std::string Test2Step::get_name() {
		return "Test2Step";
	}

	std::string Test2Step::get_description() {
		return "Step for testing purposes";
	}

	void Test2Step::run(graph::Graph& graph) {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
	}

	std::vector<std::string> Test2Step::get_dependencies() {
		return {"Test1Step"};
	}
}
