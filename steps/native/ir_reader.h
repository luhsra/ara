// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "step.h"

#include <string>
#include <llvm/IR/Module.h>

namespace step {

	class IRReader : public Step {
	  private:
		/**
		 * Load the file with path FN handled by Context.
		 * @return LLVM Module on success or null on error.
		 */
		std::unique_ptr<llvm::Module> load_file(const std::string& FN, llvm::LLVMContext& Context);

	  public:
		IRReader(PyObject* config) : Step(config) {}

		virtual std::string get_name() override { return "IRReader"; }
		virtual std::string get_description() override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step