// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "common/llvm_common.h"
#include "test.h"

#include <graph.h>
#include <iostream>
#include <llvm/IR/Instructions.h>
#include <llvm/Support/Casting.h>
#include <stdexcept>
#include <string>

namespace ara::step {
	std::string CFGOptimizeTest::get_name() { return "CFGOptimizeTest"; }

	std::string CFGOptimizeTest::get_description() { return "Step for testing the CFGOptimize step"; }

	void CFGOptimizeTest::run() {
		assert(input_file.get());
		std::string file = *input_file.get();
		assert(file == "appl/freertos-optimization.ll");

		bool main_found = false, number_found = false;
		llvm::Module& module = graph.get_module();
		for (auto& f : module) {
			for (auto& b : f) {
				for (auto& i : b) {
					if (llvm::ReturnInst* r = llvm::dyn_cast<llvm::ReturnInst>(&i)) {
						if (llvm::ConstantInt* ci = llvm::dyn_cast<llvm::ConstantInt>(r->getReturnValue())) {
							if (f.getName() == "main") {
								assert(ci->getSExtValue() == 10 && "main value incorrect");
								main_found = true;
							}
							if (f.getName() == "_Z6numberv") {
								assert(ci->getSExtValue() == 4 && "number value incorrect");
								number_found = true;
							}
						}
					}
				}
			}
		}
		assert(main_found && number_found && "main or number not found");
	}

	void CFGOptimizeTest::init_options() {
		input_file = input_file_template.instantiate(get_name());
		opts.emplace_back(input_file);
	}

	std::vector<std::string> CFGOptimizeTest::get_single_dependencies() { return {"CFGOptimize"}; }
} // namespace ara::step
