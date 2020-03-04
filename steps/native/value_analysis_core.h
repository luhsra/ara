// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class ValueAnalysisCore : public Step {
	  private:
		option::TOption<option::Bool> dump_stats{"dump_stats",
		                                         "Export JSON statistics about the value-analysis depth."};
		virtual void fill_options() override { opts.emplace_back(dump_stats); }

	  public:
		virtual std::string get_name() const override { return "ValueAnalysisCore"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {"Syscall"}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
