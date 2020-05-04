// vim: set noet ts=4 sw=4:

#include "value_analysis_core.h"

#include "value_analyzer.h"

#include "common/llvm_common.h"

#include <boost/property_tree/json_parser.hpp>
#include <boost/python.hpp>

using namespace boost::property_tree;

namespace ara::step {

	namespace {
		template <typename Graph>
		void get_values(Graph& g, graph::CFG& cfg, Logger& logger, bool dump_stats, const std::string& prefix) {
			ValueAnalyzer va(logger);
			ptree stats;
			for (auto abb :
			     boost::make_iterator_range(boost::vertices(filter_by_abb(graph::ABBType::syscall, g, cfg)))) {
				llvm::BasicBlock* bb = reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[abb]);
				llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&bb->front());
				if (called_func) {
					std::pair<Arguments, std::vector<std::vector<unsigned>>> args_pair = va.get_values(*called_func);
					Arguments& args = args_pair.first;

					// statistic printing
					if (dump_stats) {
						ptree arg_stats;
						arg_stats.put("basic_block", bb->getName().str());
						llvm::Function* func = called_func->getCalledFunction();
						if (func) {
							arg_stats.put("called_function", func->getName().str());
						}
						int i = 0;
						for (auto& numbers : args_pair.second) {
							std::stringstream ss;
							ss << "argument " << i++;
							ptree stat_list;
							for (unsigned num : numbers) {
								stat_list.push_back(std::make_pair("", ptree(std::to_string(num))));
							}
							arg_stats.add_child(ss.str(), stat_list);
						}
						std::string abb_name = cfg.name[abb];
						stats.add_child(abb_name, arg_stats);
					}

					cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
					logger.debug() << "Retrieved " << args.size() << " arguments for call " << *called_func
					               << std::endl;
				} else {
					logger.warn() << "Something went wrong." << std::endl;
				}
			}
			if (dump_stats) {
				json_parser::write_json(prefix + "value_analysis_statistics.json", stats);
			}
		}

	} // namespace

	std::string ValueAnalysisCore::get_description() const {
		return "Perform a value analysis for all system calls (core step).";
	}

	void ValueAnalysisCore::run(graph::Graph& graph) {
		graph::CFG cfg = graph.get_cfg();
		const auto& dopt = dump_stats.get();
		const auto& prefix = dump_prefix.get();
		graph_tool::gt_dispatch<>()([&](auto& g) { get_values(g, cfg, logger, dopt && *dopt, *prefix); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
