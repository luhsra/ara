// SPDX-FileCopyrightText: 2018 Benedikt Steinmeier
// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "test.h"

#include <graph.h>
#include <iostream>
#include <string>

namespace ara::step {

	std::string Test0Step::get_name() { return "Test0Step"; }

	std::string Test0Step::get_description() { return "Step for testing purposes"; }

	void Test0Step::run() {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
	}

	std::string Test2Step::get_name() { return "Test2Step"; }

	std::string Test2Step::get_description() { return "Step for testing purposes"; }

	void Test2Step::run() {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
	}

	std::vector<std::string> Test2Step::get_single_dependencies() { return {"Test1Step"}; }
} // namespace ara::step
