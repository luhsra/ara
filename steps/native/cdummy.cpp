// vim: set noet ts=4 sw=4:

#include "cdummy.h"

namespace step {
	std::string CDummy::get_description() const {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void CDummy::fill_options() { opts.emplace_back(dummy_option); }

	void CDummy::run(ara::graph::Graph&) {
		logger.info() << "Execute CDummy step." << std::endl;

		std::pair<int64_t, bool> dopt = dummy_option.get();
		if (dopt.second) {
			logger.info() << "Option is " << dopt.first << '.' << std::endl;
		}
	}
} // namespace step
