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

		ABBFilter filter(ABBType::call | ABBType::syscall, &abbs);
		boost::filtered_graph<ABBGraph, boost::keep_all, ABBFilter> calls(abbs, boost::keep_all(), filter);

		for (auto abbi : boost::make_iterator_range(vertices(calls))) {
			const ara::cfg::ABB& abb = abbs[abbi];

			if (!abb.is_indirect()) {
				auto& func = abbs.get_function_by_name(abb.get_call());
				auto other_abb = func.local_to_global(*(vertices(func).first));
				abbs.add_edge(abbi, other_abb);
				logger.debug() << "Add a direct edge from " << abb << " (" << abbi << ") to " << abbs[other_abb] << " ("
				               << other_abb << ")." << std::endl;
			}
		}
	}
} // namespace step
