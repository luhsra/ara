// vim: set noet ts=4 sw=4:

#include "value_analysis_core.h"

#include "value_analyzer.h"

#include <boost/python.hpp>

namespace ara::step {

	template <typename Graph>
	void do_graph_stuff(Graph& g, graph::CFG& cfg, Logger& logger) {
		ValueAnalyzer va(logger);
		for (auto abb : boost::make_iterator_range(boost::vertices(filter_by_abb(graph::ABBType::syscall, g, cfg)))) {
			llvm::CallBase* called_func =
			    llvm::dyn_cast<llvm::CallBase>(&reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[abb])->front());
			if (called_func) {
				Arguments args = va.get_values(*called_func);

				// currently, the args object cannot be stored within the system graph, so check that it does not delete
				// data when going out of scope
				assert(!args.owns_objects());

				cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
				logger.debug() << "Retrieved " << args.size() << " arguments for call " << *called_func << std::endl;
			} else {
				logger.warn() << "Something went wrong." << std::endl;
			}
		}
	}

	std::string ValueAnalysisCore::get_description() const { return "Perform a value analysis for all system calls (core step)."; }

	void ValueAnalysisCore::run(graph::Graph& graph) {
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { do_graph_stuff(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step