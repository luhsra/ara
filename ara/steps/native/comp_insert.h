// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>
#include <llvm/IR/Intrinsics.h>
#include <string>

namespace ara::step {
	class CompInsert : public ConfStep<CompInsert> {
	  private:
		/**
		 * Insert a Nop at anchor.
		 * Anchor can be a basic block. in this case the nop is inserted at the end of the basic block.
		 * Anchor can also be an instruction. in this case the nop is inserted before the instruction.
		 *
		 * The inserted nop is a call do llvm.donothing().
		 */
		template <class A>
		void insertNop(A anchor) {
			llvm::Module* m = anchor->getModule();
			llvm::Function* f = llvm::Intrinsic::getDeclaration(m, llvm::Intrinsic::donothing);
			llvm::CallInst::Create(f, {}, "", anchor);
		}
		using ConfStep<CompInsert>::ConfStep;

	  public:
		static std::string get_name() { return "CompInsert"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;

		virtual void run() override;
	};
} // namespace ara::step
