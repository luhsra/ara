// vim: set noet ts=4 sw=4:

#include "value_analysis.h"

#include "value_analyzer.h"

namespace ara::step {

	template <typename Graph>
	void do_graph_stuff(Graph& g, graph::CFG& cfg, Logger& logger) {
		ValueAnalyzer va(logger);
		for (auto abb : boost::make_iterator_range(boost::vertices(filter_by_abb(graph::ABBType::syscall, g, cfg)))) {
			llvm::CallBase* called_func =
			    llvm::dyn_cast<llvm::CallBase>(&reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[abb])->front());
			if (called_func) {
				Arguments args = va.get_values(*called_func);
				logger.debug() << "Retrieved " << args.size() << " arguments for call " << *called_func << std::endl;
				for (const llvm::Constant& v : args) {
					logger.debug() << "Retrieved value: " << v << std::endl;
				}
				if (args.size() >= 2) {
					logger.debug() << "First argument is " << args[1] << std::endl;
				}
			} else {
				logger.warn() << "Something went wrong." << std::endl;
			}
		}
	}

	std::string ValueAnalysis::get_description() const { return "Perform a value analysis for all system calls."; }

	void ValueAnalysis::run(graph::Graph& graph) {
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { do_graph_stuff(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
