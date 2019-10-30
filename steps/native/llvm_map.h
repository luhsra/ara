// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>

namespace step {
	class LLVMMap : public Step {
	  public:
		virtual std::string get_name() const override { return "LLVMMap"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {"FnSingleExit"}; }

		virtual void run(ara::graph::Graph& graph) override;
	};
} // namespace step
