// vim: set noet ts=4 sw=4:

#include "cdummy.h"

namespace ara::step {

	// ATTENTION: put in anonymous namespace to get an unique symbol
	namespace {
		template <typename Graph>
		void do_graph_stuff(Graph& g, graph::CFG& cfg, Logger& logger) {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				logger.debug() << "Vertex: " << cfg.name[v] << std::endl;
			}
		}
	} // namespace

	std::string CDummy::get_description() const {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void CDummy::fill_options() { opts.emplace_back(dummy_option); }

	void CDummy::run(graph::Graph& graph) {
		logger.info() << "Execute CDummy step." << std::endl;

		const std::optional<int64_t>& dopt = dummy_option.get();
		if (dopt) {
			logger.info() << "Dummy option is " << *dopt << '.' << std::endl;
		}
		const auto& dopt2 = dummy_option2.get();
		assert(dopt2);
		logger.info() << "Dummy option 2 is " << *dopt2 << '.' << std::endl;

		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { do_graph_stuff(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
