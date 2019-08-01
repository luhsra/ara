// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "step.h"

#include <llvm/IR/Module.h>
#include <string>

namespace step {

	class IRReader : public Step {
	  private:
		/**
		 * Load the file with path FN handled by Context.
		 * @return LLVM Module on success or null on error.
		 */
		std::unique_ptr<llvm::Module> load_file(const std::string& FN, llvm::LLVMContext& Context);

		ara::option::TOption<ara::option::List<ara::option::String>> input_files{"input_files", "Get input files."};

		virtual void fill_options(std::vector<option_ref>& opts) override { opts.emplace_back(input_files); }

	  public:
		virtual std::string get_name() const override { return "IRReader"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step
