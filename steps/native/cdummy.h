// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "step.h"

namespace step {
	class CDummy : public Step {
	  public:
		CDummy(PyObject* config) : Step(config) {}

		virtual std::string get_name() override { return "CDummy"; }
		virtual std::string get_description() override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step
