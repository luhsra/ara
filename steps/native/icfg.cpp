// vim: set noet ts=4 sw=4:

#include "icfg.h"

#include <boost/graph/filtered_graph.hpp>

using namespace ara::cfg;

namespace step {
	std::string ICFG::get_description() const {
		return "Search all inter-procedural edges."
		       "\n"
		       "Transforming of the ABB CFG to an ABB ICFG.";
	}

	void ICFG::run(graph::Graph& graph) {
		ABBGraph& abbs = graph.new_graph.abbs();

		ABBTypeFilter<ABBGraph> call_filter(ABBType::call | ABBType::syscall, &abbs);
		boost::filtered_graph<ABBGraph, boost::keep_all, ABBTypeFilter<ABBGraph>> calls(abbs, boost::keep_all(),
		                                                                                call_filter);

		ABBTypeFilter<ABBGraph> non_call_filter(~(ABBType::call | ABBType::syscall), &abbs);
		boost::filtered_graph<ABBGraph, boost::keep_all, ABBTypeFilter<ABBGraph>> non_calls(abbs, boost::keep_all(),
		                                                                                    non_call_filter);

		// add edges between functions
		for (auto abbi : boost::make_iterator_range(vertices(calls))) {
			const ara::cfg::ABB& abb = abbs[abbi];

			if (!abb.is_indirect()) {
				auto& func = abbs.get_function_by_name(abb.get_call());
				auto other_abb = func.local_to_global(*(vertices(func).first));
				auto edge = boost::add_edge(abbi, other_abb, abbs);
				abbs[edge.first].type = CFType::icf;
				logger.debug() << "Add an edge from " << abb << " (" << abbi << ") to " << abbs[other_abb] << " ("
				               << other_abb << ")." << std::endl;
			} else {
				// TODO
			}
		}
		// add edges within the same function
		for (auto abbi : boost::make_iterator_range(vertices(non_calls))) {
			auto edge_its = out_edges(abbi, abbs);
			std::vector<ABBGraph::edge_descriptor> edges(edge_its.first, edge_its.second);
			for (auto edge : edges) {
				assert(abbs[edge].type == CFType::lcf);
				auto i_edge = boost::add_edge(abbi, boost::target(edge, abbs), abbs);
				abbs[i_edge.first].type = CFType::icf;
			}
		}
	}
} // namespace step
