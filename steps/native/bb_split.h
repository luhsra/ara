// vim: set noet ts=4 sw=4:

#pragma once

#include "graph.h"
#include "step.h"

#include <string>

namespace step {

	class BBSplit : public Step {
	  public:
		BBSplit(PyObject* config) : Step(config) {}

		virtual std::string get_name() override { return "BBSplit"; }
		virtual std::string get_description() override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step
