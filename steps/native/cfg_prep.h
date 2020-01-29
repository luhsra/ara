// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class CFGPreparation : public Step {
	  private:
		option::TOption<option::List<option::String>> pass_list{"pass_list", "List of LLVM Passes to be executed."};
		virtual void fill_options() override;
        // Enum of available Passes that can be specified through the pass_list option
        enum Option { DeadCodeElimination,
                      ConstantPropagation,
                      SparseConditionalConstantPropagation,
                      MemoryToRegister,
                      Invalid 
        };
        Option resolveOption(std::string);
	  public:
		virtual std::string get_name() const override { return "CFGPreparation"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
