// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>
#include <string>

namespace ara::step {
	class LLVMOptimization : public ConfStep<LLVMOptimization> {
	  private:
		using ConfStep<LLVMOptimization>::ConfStep;
		const static inline option::TOption<option::String> pass_list_template{
		    "pass_list", "List of LLVM Passes to be executed.\nFor Syntax see: "
		                 "https://llvm.org/doxygen/PassBuilder_8h_source.html#l00410\nFor the list of available passes "
		                 "see: https://github.com/llvm/llvm-project/blob/release/9.x/llvm/lib/Passes/PassRegistry.def"
		                 " and http://llvm.org/docs/Passes.html"};
		option::TOptEntity<option::String> pass_list;

		virtual void init_options() override;

	  public:
		static std::string get_name() { return "LLVMOptimization"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {pass_list_template}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"RemoveSysfuncBody"}; }

		virtual void run() override;
	};
} // namespace ara::step
