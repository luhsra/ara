// vim: set noet ts=4 sw=4:

#include "value_analysis_core.h"

#include "common/llvm_common.h"
#include "value_analyzer.h"

#include <boost/property_tree/json_parser.hpp>
#include <boost/python.hpp>

using namespace boost::property_tree;

namespace ara::step {
	namespace {
		template <typename Graph>
		void get_values(Graph& g, graph::CFG& cfg, Logger& logger, bool dump_stats, const std::string& prefix,
		                const std::string& entry_point) {
			using Vertex = typename boost::graph_traits<Graph>::vertex_descriptor;
			Vertex entry_func;

			try {
				entry_func = cfg.get_function_by_name(g, entry_point);
			} catch (FunctionNotFound&) {
				std::stringstream ss;
				ss << "Bad entry point given: " << entry_point << ". Could not be found.";
				logger.error() << ss.str();
				throw StepError("ICFG", ss.str());
			}

			ValueAnalyzer va(logger);
			ptree stats;

			std::function<void(const Graph&, graph::CFG&, Vertex)> do_with_abb = [&](const Graph&, graph::CFG& lcfg,
			                                                                         Vertex abb) {
				if (lcfg.type[abb] == graph::ABBType::syscall) {
					// get call of abb
					llvm::BasicBlock* bb = reinterpret_cast<llvm::BasicBlock*>(lcfg.entry_bb[abb]);
					llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&bb->front());
					if (called_func) {
						std::pair<Arguments, std::vector<std::vector<unsigned>>> args_pair =
						    va.get_values(*called_func);
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
							std::string abb_name = lcfg.name[abb];
							stats.add_child(abb_name, arg_stats);
						}

						lcfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
						logger.debug() << "Retrieved " << args.size() << " arguments for call " << *called_func
						               << std::endl;
					} else {
						logger.warn() << "Something went wrong. Cannot retrieve called function." << std::endl;
					}
					if (dump_stats) {
						json_parser::write_json(prefix + "value_analysis_statistics.json", stats);
					}
				}
			};
			cfg.execute_on_reachable_abbs(g, entry_func, do_with_abb);
		}
	} // namespace

	llvm::json::Array ValueAnalysisCore::get_configured_dependencies() {
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");
		return llvm::json::Array{llvm::json::Object{{{"name", "Syscall"}, {"entry_point", *entry_point_name}}}};
	}

	std::string ValueAnalysisCore::get_description() {
		return "Perform a value analysis for all system calls (core step).";
	}

	void ValueAnalysisCore::init_options() {
		EntryPointStep<ValueAnalysisCore>::init_options();
		dump_stats = dump_stats_template.instantiate(get_name());
		opts.emplace_back(dump_stats);
	}

	void ValueAnalysisCore::run() {
		graph::CFG cfg = graph.get_cfg();
		const auto& dopt = dump_stats.get();
		const auto& prefix = dump_prefix.get();
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		graph_tool::gt_dispatch<>()(
		    [&](auto& g) { get_values(g, cfg, logger, dopt && *dopt, *prefix, *entry_point_name); },
		    graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
