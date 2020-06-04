// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>
#include <llvm/IR/Module.h>
#include <string>

namespace ara::step {

	class IRReader : public Step {
	  private:
		option::TOption<option::String> input_file{"input_file", "Get input file."};

		virtual void fill_options() override { opts.emplace_back(input_file); }

	  public:
		virtual std::string get_name() const override { return "IRReader"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
