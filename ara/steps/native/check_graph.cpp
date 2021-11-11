// vim: set noet ts=4 sw=4:

#include "check_graph.h"

namespace ara::step {
	namespace {
		template <typename Graph>
		void check_graph(Graph& g, graph::CFG& cfg, Logger& logger) {
			for (auto e : boost::make_iterator_range(boost::edges(g))) {
				logger.warn() << "Edge: (" << boost::source(e, g) << ", " << boost::target(e, g) << ")" << std::endl;
			}
		}
	} // namespace

	std::string CheckGraph::get_description() { return "Check validity of various graphs"; }

	void CheckGraph::run() {
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { check_graph(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
