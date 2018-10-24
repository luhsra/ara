// vim: set noet ts=4 sw=4:

#ifndef TEST_STEP_H
#define TEST_STEP_H

#include "graph.h"
#include "step.h"

#include <string>

namespace step {
	class Test0Step : public Step {
	public:
		Test0Step(PyObject* config) : Step(config) {}

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};

	class Test2Step : public Step {
	public:
		Test2Step(PyObject* config) : Step(config) {}

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
}

#endif //TEST_STEP_H
