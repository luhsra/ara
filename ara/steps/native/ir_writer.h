// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class IRWriter : public ConfStep<IRWriter> {
	  private:
		using ConfStep<IRWriter>::ConfStep;
		const static inline option::TOption<option::String> ir_file_option_template{
		    "ir_file",
		    "Filename to write ir code into, the special name 'log' will write to the logging output with level info.",
		    /* ty = */ option::String(),
		    /* default = */ "{dump_prefix}dumped.ll"};
		option::TOptEntity<option::String> ir_file_option;

		const static inline option::TOption<option::List<option::String>> functions_opt_template{
		    "functions", "Dump IR only for these specific functions (if not specified dump all)"};
		option::TOptEntity<option::List<option::String>> functions_opt;

		virtual void init_options() override;

	  public:
		static std::string get_name() { return "IRWriter"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {ir_file_option_template, functions_opt_template}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"IRReader"}; }

		virtual void run() override;
	};
} // namespace ara::step
