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
 		auto module = graph.get_llvm_module();
 		unsigned split_counter = 0;

 		for (auto &function : *module) {
			std::list<BasicBlock *> exit_blocks;
			for (BasicBlock& _bb : function) {
				if (succ_begin(&_bb) == succ_end(&_bb)) {
					exit_blocks.push_back(&_bb);
				}
 			}

			if (exit_blocks.size() > 1) {
				logger.debug() << "Function has " << exit_blocks.size() << " exit blocks: " << function.getName().str() << std::endl;
				for (BasicBlock* bb: exit_blocks) {
					// no predecessors
					auto start = pred_begin(bb);
					auto end  = pred_end(bb);
					if (pred_begin(bb) == pred_end(bb)) {
						DeleteDeadBlock(bb);
						exit_blocks.remove(bb);
					}
				}
				function.viewCFG();
				asm("int $3");
				assert((exit_blocks.size() == 1) && "There are leftover double-ending functions");
			}
		}
	}
} // namespace step
