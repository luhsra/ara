// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>
#include <llvm/IR/Module.h>
#include <string>

namespace ara::step {

	class IRReader : public ConfStep<IRReader> {
	  private:
		using ConfStep<IRReader>::ConfStep;

		static const inline option::TOption<option::String> input_file_template{"input_file", "Get input file."};
		option::TOptEntity<option::String> input_file;

		static const inline option::TOption<option::Bool> no_sysfunc_body_template{
		    "no_sysfunc_body", "Chains the step RemoveSysfuncBody if true. This step has some advantages if the program is linked with libc. "
		                       "See the description of RemoveSysfuncBody. WARNING: Do not use this option for the synthesis!"};
		option::TOptEntity<option::Bool> no_sysfunc_body;

		virtual void init_options();

	  public:
		static std::string get_name() { return "IRReader"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {input_file_template, no_sysfunc_body_template}; }

		virtual void run() override;
	};
} // namespace ara::step
