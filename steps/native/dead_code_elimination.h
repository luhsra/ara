// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class DeadCodeElimination : public Step {
	  /*private:
		option::TOption<option::Integer> dummy_option{"dummy_option", "This is the help for dummy_option."};
		virtual void fill_options() override;*/

	  public:
		virtual std::string get_name() const override { return "DeadCodeElimination"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
