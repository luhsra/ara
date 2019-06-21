// vim: set noet ts=4 sw=4:

#include "cdummy.h"

namespace step {
	std::string CDummy::get_description() {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void CDummy::run(graph::Graph& graph) { logger.info() << "Execute C++ dummy step." << std::endl; }
} // namespace step
