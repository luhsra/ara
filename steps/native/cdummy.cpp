// vim: set noet ts=4 sw=4:

#include "cdummy.h"

namespace step {
	std::string CDummy::get_description() const {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	std::vector<Option> CDummy::config_help() const {
		return {Option("dummy_option", "Just an option to demonstrate options.")};
	}

	void CDummy::run(graph::Graph& graph) { logger.info() << "Execute C++ dummy step." << std::endl; }
} // namespace step
