// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "option.h"
#include "step.h"

namespace step {
	class CDummy : public Step {
	  private:
		virtual void fill_options(std::vector<option_ref>& opts) override;
		ara::option::TOption<ara::option::Integer> dummy_option{"dummy_option", "This is the help for dummy_option."};

	  public:
		virtual std::string get_name() const override { return "CDummy"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step
