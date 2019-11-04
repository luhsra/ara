// vim: set noet ts=4 sw=4:

#include "cdummy.h"

namespace step {

	template <typename Graph>
	void do_graph_stuff(Graph& g, ara::graph::CFG& cfg, Logger& logger) {
		for (auto v : boost::make_iterator_range(boost::vertices(g))) {
			logger.debug() << "Vertex: " << cfg.name[v] << std::endl;
		}
	}

	std::string CDummy::get_description() const {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void CDummy::fill_options() { opts.emplace_back(dummy_option); }

	void CDummy::run(ara::graph::Graph& graph) {
		logger.info() << "Execute CDummy step." << std::endl;

		std::pair<int64_t, bool> dopt = dummy_option.get();
		if (dopt.second) {
			logger.info() << "Option is " << dopt.first << '.' << std::endl;
		}

		ara::graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { do_graph_stuff(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace step
