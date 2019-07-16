// vim: set noet ts=4 sw=4:

#include "fn_single_exit.h"

#include <list>
#include <iostream>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Instructions.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Support/Casting.h>
#include <llvm/Transforms/Utils/BasicBlockUtils.h>

namespace step {
	using namespace llvm;

	std::string FnSingleExit::get_description() {
		return "Insert empty exit BB for functions having multiple exit BBs";
	}

	std::vector<std::string> FnSingleExit::get_dependencies() {
		return {"BBSplit"};
	}

	void FnSingleExit::run(graph::Graph& graph) {
		llvm::Module& module = graph.new_graph.get_module();
		unsigned insert_counter = 0;

		for (auto& function : module) {
			std::list<BasicBlock *> exit_blocks;
			for (BasicBlock& _bb : function) {
				if (succ_begin(&_bb) == succ_end(&_bb)) {
					exit_blocks.push_back(&_bb);
				}
 			}

			if (exit_blocks.size() > 1) {
				logger.debug() << "Function has " << exit_blocks.size() << " exit blocks: " << function.getName().str() << std::endl;
				if (exit_blocks.size() > 1) {
					LLVMContext &C = function.getContext();
					BasicBlock *new_exit = BasicBlock::Create(C, "combined_exit", &function, NULL);
					new UnreachableInst(C, new_exit);
					for (auto &EB : exit_blocks) {
						BranchInst::Create(new_exit, EB);
					}
					insert_counter++;
				}
			}
		}
		logger.debug() << "Inserted " << insert_counter << " new common exit blocks." << std::endl;
	}
} // namespace step
