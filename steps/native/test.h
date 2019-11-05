// vim: set noet ts=4 sw=4:

#ifndef TEST_STEP_H
#define TEST_STEP_H

#include "step.h"

#include <graph.h>
#include <string>

namespace ara::step {
	class Test0Step : public Step {
	  public:
		virtual std::string get_name() const override;
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;
		virtual void run(graph::Graph& graph) override;
	};

	class Test2Step : public Step {
	  public:
		virtual std::string get_name() const override;
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;
		virtual void run(graph::Graph& graph) override;
	};

	class BBSplitTest : public Step {
	  public:
		virtual std::string get_name() const override;
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;
		virtual void run(graph::Graph& graph) override;
	};

	class CompInsertTest : public Step {
	  public:
		virtual std::string get_name() const override;
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;
		virtual void run(graph::Graph& graph) override;
	};

	class FnSingleExitTest : public Step {
	  public:
		virtual std::string get_name() const override;
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};

	class LLVMMapTest : public Step {
	  public:
		virtual std::string get_name() const override;
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step

#endif // TEST_STEP_H
