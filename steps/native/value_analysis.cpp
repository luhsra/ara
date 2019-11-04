// vim: set noet ts=4 sw=4:

#include "value_analysis.h"

#include "value_analyzer.h"

namespace step {

	template <typename Graph>
	void do_graph_stuff(Graph& g, ara::graph::CFG& cfg, Logger& logger) {
		ara::ValueAnalyzer va(logger);
		for (auto abb :
		     boost::make_iterator_range(boost::vertices(filter_by_abb(ara::graph::ABBType::syscall, g, cfg)))) {
			llvm::CallBase* called_func =
			    llvm::dyn_cast<llvm::CallBase>(&reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[abb])->front());
			if (called_func) {
				va.get_values(*called_func);
			} else {
				logger.warn() << "Something went wrong." << std::endl;
			}
		}
	}

	std::string ValueAnalysis::get_description() const { return "Perform a value analysis for all system calls."; }

	void ValueAnalysis::run(ara::graph::Graph& graph) {
		ara::graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { do_graph_stuff(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace step
