// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "step.h"

#include "llvm/IR/Intrinsics.h"

#include <string>

namespace step {
	class CompInsert : public Step {
		private:
		/**
		 * Insert a Nop at anchor.
		 * Anchor can be a basic block. in this case the nop is inserted at the end of the basic block.
		 * Anchor can also be an instruction. in this case the nop is inserted before the instruction.
		 *
		 * The inserted nop is a call do llvm.donothing().
		 */
		template<class A>
		void insertNop(A anchor) {
			llvm::Module* m = anchor->getModule();
			llvm::Function *f = llvm::Intrinsic::getDeclaration(m, llvm::Intrinsic::donothing);
			llvm::CallInst::Create(f, {}, "", anchor);
		}

	  public:
		virtual std::string get_name() const override { return "CompInsert"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;


		virtual void run(graph::Graph& graph) override;
	};
} // namespace step
