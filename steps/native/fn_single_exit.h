// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "step.h"

#include <string>

namespace step {

	class FnSingleExit : public Step {
	  public:
		FnSingleExit(PyObject* config) : Step(config) {}

		virtual std::string get_name() const override { return "FnSingleExit"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step
