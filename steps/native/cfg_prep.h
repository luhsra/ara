// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"
#include "option.h"
#include <string>

#include <graph.h>

namespace ara::step {
	class CFGPreparation : public Step {
	  private:
          ara::option::TOption<ara::option::String> pass_list{"pass_list", "List of LLVM Passes to be executed. For Syntax see: https://llvm.org/doxygen/PassBuilder_8h_source.html#l00410"};
		virtual void fill_options() override;
	  public:
		virtual std::string get_name() const override { return "CFGPreparation"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
