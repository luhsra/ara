// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>

namespace ara::step {
	class LLVMMap : public Step {
	  private:
		option::TOption<option::Bool> llvm_dump{"llvm_dump", "Dump all llvm functions into dot files."};
		option::TOption<option::String> llvm_dump_prefix{"llvm_dump_prefix", "Prefix string for the dot files.",
		                                                 /* ty = */ option::String(),
		                                                 /* default = */ "dumps/llvm-func."};
		virtual void fill_options() override;

	  public:
		virtual std::string get_name() const override { return "LLVMMap"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {"FnSingleExit", "FakeEntryPoint"}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
