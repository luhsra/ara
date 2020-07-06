// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class IRWriter : public ConfStep<IRWriter> {
	  private:
		using ConfStep<IRWriter>::ConfStep;
		const static inline option::TOption<option::String> ir_file_option_template{"ir_file",
		                                                                            "Filename to write ir code into",
		                                                                            /* ty = */ option::String(),
		                                                                            /* default = */ "dumps/dumped.ir"};
		option::TOptEntity<option::String> ir_file_option;
		virtual void init_options() override;

	  public:
		static std::string get_name() { return "IRWriter"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {ir_file_option_template}; }

		virtual void run() override;
	};
} // namespace ara::step
