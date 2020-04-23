// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>
#include <llvm/IR/Value.h>

namespace ara::step {
	class ReplaceSyscallsCreate : public Step {
	  private:
		virtual void fill_options() override;

	  public:
		virtual std::string get_name() const override { return "ReplaceSyscallsCreate"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
		bool replace_queue_create_static(graph::Graph& graph, int where, char* symbol_metadata, char* symbol_storage);
	};
} // namespace ara::step
