// vim: set noet ts=4 sw=4:

#include "cdummy.h"

namespace step {
	std::string CDummy::get_description() const {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void CDummy::fill_options(std::vector<option_ref>& opts) { opts.emplace_back(dummy_option); }

	void CDummy::run(graph::Graph& graph) {
		logger.info() << "Execute C++ dummy step";

		std::pair<int64_t, bool> dopt = dummy_option.get();
		if (dopt.second) {
			logger.info() << " with option value: " << dopt.first;
		}

		logger.info() << std::endl;
	}
} // namespace step
