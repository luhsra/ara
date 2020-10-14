// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>

namespace ara::step {
	class LLVMMap : public ConfStep<LLVMMap> {
	  private:
		using ConfStep<LLVMMap>::ConfStep;
		const static inline option::TOption<option::Bool> llvm_dump_template{"llvm_dump",
		                                                                     "Dump all llvm functions into dot files."};
		option::TOptEntity<option::Bool> llvm_dump;

		const static inline option::TOption<option::String> llvm_dump_prefix_template{
		    "llvm_dump_prefix", "Prefix string for the dot files.",
		    /* ty = */ option::String(),
		    /* default = */ "dumps/llvm-func."};
		option::TOptEntity<option::String> llvm_dump_prefix;

		const static inline option::TOption<option::Choice<3>> source_loc_template{
		    "source_loc", "Get source location.",
		    /* ty = */ option::makeChoice("never", "calls", "all"), /* default_value = */ "calls"};
		option::TOptEntity<option::Choice<3>> source_loc;

		virtual void init_options() override;

	  public:
		static std::string get_name() { return "LLVMMap"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		virtual std::vector<std::string> get_single_dependencies() override {
			return {"FnSingleExit", "FakeEntryPoint"};
		}

		virtual void run() override;
	};
} // namespace ara::step
