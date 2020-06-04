// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class LoadOSConfig : public Step {
	  private:
		virtual void fill_options() override;

	  public:
		virtual std::string get_name() const override { return "LoadOSConfig"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {"Syscall"}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace ara::step
