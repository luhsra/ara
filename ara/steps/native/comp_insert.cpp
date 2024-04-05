// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "comp_insert.h"

#include <common/llvm_common.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/Casting.h>
#include <llvm/Support/raw_os_ostream.h>
#include <ostream>

namespace ara::step {
	using namespace llvm;

	std::string CompInsert::get_description() {
		return "Insert a nop (computation block) after calls so that every call is followed by a non call."
		       "\n"
		       "Insert the nop only, if the call is followed by another call or at the end. ";
	}

	std::vector<std::string> CompInsert::get_single_dependencies() { return {"CFGOptimize", "SVFTransformation"}; }

	bool is_call(const Instruction& i) { return isa<CallBase>(&i) && !is_call_to_intrinsic(i); }

	void CompInsert::run() {
		llvm::Module& module = graph.get_module();
		unsigned nop_count = 0;
		for (auto& function : module) {
			for (BasicBlock& bb : function) {
				bool found_call = false;
				for (Instruction& i : bb) {
					if (is_call(i)) {
						if (found_call) {
							// second call found
							// insert nop before it and leave found_call untouched (a third call can come)
							insertNop(&i);
							nop_count++;
						} else {
							found_call = true;
						}
					} else {
						found_call = false;
					}
				}
				if (found_call) {
					// call at the end of the BasicBlock
					// We have to cases then:
					// 1. Standard call, just insert a nop
					// 2. Invoke with branch (it can branch to two locations). Insert the nop at the beginning of the
					// next BB
					Instruction* call = bb.getTerminator();
					if (isa<CallInst>(call)) {
						insertNop(&bb);
						nop_count++;
					} else if (auto* invoke = dyn_cast<InvokeInst>(call)) {
						for (BasicBlock* next_bb : {invoke->getNormalDest(), invoke->getUnwindDest()}) {
							Instruction& front = next_bb->front();
							if (is_call(front)) {
								insertNop(&front);
								nop_count++;
							}
						}
					}
				}
			}
		}
		logger.debug() << "Inserted " << nop_count << " NOPs." << std::endl;
	}
} // namespace ara::step
