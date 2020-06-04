// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class CDummy : public Step {
	  private:
		option::TOption<option::Integer> dummy_option{"dummy_option", "This is the help for dummy_option."};
		option::TOption<option::Choice<3>> dummy_option2{"dummy_option2", "This is an option with default.",
		                                                 /* ty = */ option::makeChoice("A", "B", "C"),
		                                                 /* default_value = */ "B"};
		virtual void fill_options() override;

	  public:
		virtual std::string get_name() const override { return "CDummy"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
