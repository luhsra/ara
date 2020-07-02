// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>
#include <llvm/IR/BasicBlock.h>
#include <string>

namespace ara::step {

	class FnSingleExit : public ConfStep<FnSingleExit> {
	  private:
		void fill_unreachable_and_exit(llvm::BasicBlock*& unreachable, llvm::BasicBlock*& exit,
		                               llvm::BasicBlock& probe) const;
		using ConfStep<FnSingleExit>::ConfStep;

	  public:
		static std::string get_name() { return "FnSingleExit"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override { return {"BBSplit"}; }

		virtual void run() override;
	};
} // namespace ara::step
