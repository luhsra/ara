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

		virtual void init_options();

	  public:
		static std::string get_name() { return "IRReader"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {input_file_template}; }

		virtual void run() override;
	};
} // namespace ara::step
