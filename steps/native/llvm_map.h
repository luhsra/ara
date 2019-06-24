// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "step.h"

namespace step {
	class LLVMMap : public Step {
	  public:
		LLVMMap(PyObject* config) : Step(config) {}

		virtual std::string get_name() override { return "LLVMMap"; }
		virtual std::string get_description() override;
		virtual std::vector<std::string> get_dependencies() override { return {"FnSingleExit"}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step
