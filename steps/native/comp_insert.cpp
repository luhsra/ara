// vim: set noet ts=4 sw=4:

#include "comp_insert.h"

#include "common/llvm_common.h"

#include <iostream>
#include <list>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/Casting.h>
#include <llvm/Support/raw_os_ostream.h>

namespace step {
	using namespace llvm;

	std::string CompInsert::get_description() const {
		return "Insert a nop (computation block) after calls so that every call is followed by a non call."
		       "\n"
		       "Insert the nop only, if the call is followed by another call or at the end. ";
	}

	std::vector<std::string> CompInsert::get_dependencies() { return {"IRReader"}; }

	void CompInsert::run(graph::Graph& graph) {
		llvm::Module& module = graph.new_graph.get_module();
		unsigned nop_count = 0;
		for (auto& function : module) {
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
					} else {
						found_call = false;
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
