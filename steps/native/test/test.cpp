// vim: set noet ts=4 sw=4:

#include "test.h"

#include <graph.h>
#include <iostream>
#include <string>

namespace step {

	std::string Test0Step::get_name() const { return "Test0Step"; }

	std::string Test0Step::get_description() const { return "Step for testing purposes"; }

	void Test0Step::run(graph::Graph& graph) {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
	}

	std::vector<std::string> Test0Step::get_dependencies() { return {}; }

	std::string Test2Step::get_name() const { return "Test2Step"; }

	std::string Test2Step::get_description() const { return "Step for testing purposes"; }

	void Test2Step::run(graph::Graph& graph) {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
	}

	std::vector<std::string> Test2Step::get_dependencies() { return {"Test1Step"}; }
} // namespace step
