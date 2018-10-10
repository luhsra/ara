// vim: set noet ts=4 sw=4:

#ifndef TEST_PASSAGE_H
#define TEST_PASSAGE_H

#include "graph.h"
#include "passage.h"

#include <string>

namespace passage {
	class Test0Passage : public Passage {
	public:
		Test0Passage(PyObject* config) : Passage(config) {}

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph graph) override;
	};

	class Test2Passage : public Passage {
	public:
		Test2Passage(PyObject* config) : Passage(config) {}

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph graph) override;
	};
}

#endif //TEST_PASSAGE_H
