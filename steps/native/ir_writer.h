// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class IRWriter : public Step {
	private:
	  option::TOption<option::String> ir_file_option{"ir_file", "Filename to write ir code into",
													   /* ty = */ option::String(),
													   /* default = */ "dumps/dumped.ir"};
		virtual void fill_options() override;

	  public:
		virtual std::string get_name() const override { return "IRWriter"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
