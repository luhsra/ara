// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>
#include <string>

namespace ara::step {
	class LLVMOptimization : public Step {
	  private:
		option::TOption<option::String> pass_list{
		    "pass_list", "List of LLVM Passes to be executed.\nFor Syntax see: "
		                 "https://llvm.org/doxygen/PassBuilder_8h_source.html#l00410\nFor the list of available passes "
		                 "see: https://github.com/llvm/llvm-project/blob/release/9.x/llvm/lib/Passes/PassRegistry.def"};
		virtual void fill_options() override;

	  public:
		virtual std::string get_name() const override { return "LLVMOptimization"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step