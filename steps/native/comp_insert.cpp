// vim: set noet ts=4 sw=4:

#include "comp_insert.h"

#include <list>
#include <iostream>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Instructions.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Support/Casting.h>
#include "llvm_common.h"

namespace step {
	using namespace llvm;

	std::string CompInsert::get_description() {
		return "Insert a nop (computation block) after calls so that every call is followed by a non call."
			   "\n"
			   "Insert the nop only, if the call is followed by another call or at the end. ";
	}

	std::vector<std::string> CompInsert::get_dependencies() {
		return {"IRReader"};
	}

	void CompInsert::run(graph::Graph& graph) {
		auto module = graph.get_llvm_module();
		unsigned nop_count = 0;
		for (auto &function : *module) {
			for (BasicBlock& bb : function) {
				bool found_call = false;
				for (Instruction& i : bb) {
					if ((isa<InvokeInst>(&i) || isa<CallInst>(&i)) && !isCallToLLVMIntrinsic(&i)) {
						if (found_call) {
							// second call found
							insertNop(&i);
							nop_count++;
							found_call = false;
						} else {
							found_call = true;
						}
					}
				}
				if (found_call) {
					insertNop(&bb);
					nop_count++;
				}
			}
		}
		logger.debug() << "Inserted " << nop_count << " NOPs." << std::endl;
	}
} // namespace step
