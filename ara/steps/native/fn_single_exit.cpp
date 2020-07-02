// vim: set noet ts=4 sw=4:

#include "fn_single_exit.h"

#include "common/llvm_common.h"

#include <iostream>
#include <list>
#include <llvm/Analysis/LoopInfo.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/Casting.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Transforms/Utils/BasicBlockUtils.h>
#include <llvm/Transforms/Utils/UnifyFunctionExitNodes.h>

namespace ara::step {
	using namespace llvm;

	std::string FnSingleExit::get_description() { return "Find unique exit BB and endless loops for functions."; }

	inline void FnSingleExit::fill_unreachable_and_exit(BasicBlock*& unreachable, BasicBlock*& exit,
	                                                    BasicBlock& probe) const {
		for (Instruction& i : probe) {
			if (isa<ReturnInst>(i)) {
				exit = &probe;
				break;
			}
			if (isa<UnreachableInst>(i)) {
				unreachable = &probe;
				break;
			}
		}
	}

	void FnSingleExit::run() {
		graph::LLVMData& llvm_data = graph.get_llvm_data();
		for (auto& function : llvm_data.get_module()) {
			if (function.empty() || function.isIntrinsic()) {
				continue;
			}

			// Execute LLVM's UnifyFunctionExitNodes pass
			Module& module = graph.get_module();
			legacy::FunctionPassManager fpm(&module);
			fpm.add(createUnifyFunctionExitNodesPass());

			if (fpm.run(function)) {
				logger.debug() << function.getName().str() << ": UnifyFunctionExitNodes has modified something."
				               << std::endl;
			}

			// exit block detection
			// an exit block is a block with no successors
			BasicBlock* exit_block = nullptr;
			for (BasicBlock& _bb : function) {
				if (succ_begin(&_bb) == succ_end(&_bb)) {
					if (exit_block != nullptr) {
						// one block is probably unreachable
						BasicBlock* unreachable = nullptr;
						BasicBlock* exit = nullptr;
						fill_unreachable_and_exit(unreachable, exit, *exit_block);
						fill_unreachable_and_exit(unreachable, exit, _bb);
						if (unreachable != nullptr && exit != nullptr && unreachable != exit) {
							// link unreachable block to exit block
							// Technically, we create a branch instruction after an unreachable instruction
							// This my break LLVM in some cases. The spec is unclear theryby.
							// The other fix is to make ARA aware of ignoring unreachable instructions.
							BranchInst::Create(exit, unreachable);
						} else {

							logger.err() << "Function: " << function.getName().str() << " has multiple exit blocks."
							             << std::endl;
							logger.debug() << "Basicblock 1 with exit: " << *exit_block << std::endl;
							logger.debug() << "Basicblock 2 with exit: " << _bb << std::endl;
							logger.debug() << "Whole function: " << function << std::endl;
							assert(false && "Something with the UnifyFunctionExitNodes went wrong.");
						}
					}
					exit_block = &_bb;
				}
			}
			llvm_data.functions[&function].exit_block = exit_block;
			llvm_data.basic_blocks[exit_block].is_exit_block = true;

			// endless loop detection
			DominatorTree dom_tree = DominatorTree(function);
			LoopInfoBase<BasicBlock, Loop> loop_info;

			dom_tree.updateDFSNumbers();
			loop_info.analyze(dom_tree);

			bool loop_found = false;
			for (const Loop* loop : loop_info) {
				SmallVector<BasicBlock*, 6> vec;
				loop->getExitBlocks(vec);
				if (vec.size() != 0) {
					continue;
				}
				// we have an endless loop
				llvm_data.functions[&function].endless_loops.emplace_back(loop->getHeader());
				llvm_data.basic_blocks[loop->getHeader()].is_loop_head = true;
				loop_found = true;
			}

			// some nice printing
			if (exit_block) {
				if (loop_found) {
					logger.debug() << "Function " << function.getName().str()
					               << " has a regular exit and endless loops." << std::endl;
				} else {
					logger.debug() << "Function " << function.getName().str() << " has exactly one regular exit."
					               << std::endl;
				}
			} else {
				if (loop_found) {
					logger.debug() << "Function " << function.getName().str() << " ends in an endless loop."
					               << std::endl;
				} else {
					logger.warn() << "Function " << function.getName().str()
					              << " neither has an exit block nor ends in an endless loop." << std::endl;
				}
			}
		}
	}
} // namespace ara::step
