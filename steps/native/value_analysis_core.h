// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

#define VERSION_BKP VERSION
#undef VERSION
#include <MSSA/SVFG.h>
#include <Util/BasicTypes.h>
#include <Util/VFGNode.h>
#include <WPA/Andersen.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

namespace ara::step {
	class ValueAnalysisCore : public EntryPointStep<ValueAnalysisCore> {
	  private:
		using EntryPointStep<ValueAnalysisCore>::EntryPointStep;

		const static inline option::TOption<option::Bool> dump_stats_template{
		    "dump_stats", "Export JSON statistics about the value-analysis depth."};
		option::TOptEntity<option::Bool> dump_stats;

		virtual void init_options() override;

		void retrieve_value(const SVFG& vfg, const llvm::Value& value);
		void collectUsesOnVFG(const SVFG& vfg, const llvm::CallBase& call);

		template <typename Graph>
		void get_values(Graph& g, const SVFG& vfg) {
			cfg = graph->get_cfg();
			// ptree stats;
			for (auto abb :
			     boost::make_iterator_range(boost::vertices(filter_by_abb(graph::ABBType::syscall, g, cfg)))) {
				llvm::BasicBlock* bb = reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[abb]);
				llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&bb->front());
				if (called_func) {
					llvm::Function* func = called_func->getCalledFunction();
					if (func) {
						this->logger.debug() << "Function name: " << func->getName().str() << std::endl;
						this->logger.debug() << "Number of args: " << func->arg_size() << std::endl;
						collectUsesOnVFG(vfg, *called_func);
					}

					// std::pair<Arguments, std::vector<std::vector<unsigned>>> args_pair = va.get_values(*called_func);
					// Arguments& args = args_pair.first;

					// // statistic printing
					// if (dump_stats) {
					// 	ptree arg_stats;
					// 	arg_stats.put("basic_block", bb->getName().str());
					// 	llvm::Function* func = called_func->getCalledFunction();
					// 	if (func) {
					// 		arg_stats.put("called_function", func->getName().str());
					// 	}
					// 	int i = 0;
					// 	for (auto& numbers : args_pair.second) {
					// 		std::stringstream ss;
					// 		ss << "argument " << i++;
					// 		ptree stat_list;
					// 		for (unsigned num : numbers) {
					// 			stat_list.push_back(std::make_pair("", ptree(std::to_string(num))));
					// 		}
					// 		arg_stats.add_child(ss.str(), stat_list);
					// 	}
					// 	std::string abb_name = cfg.name[abb];
					// 	stats.add_child(abb_name, arg_stats);
					// }

					// cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
					this->logger.debug() << "Retrieved " // << args.size() << " arguments for call " << *called_func
					                     << std::endl;
				} else {
					this->logger.warn() << "Something went wrong." << std::endl;
					this->logger.debug() << "In function: " << bb->getParent()->getName().str() << std::endl;
					this->logger.debug() << "Basicblock: " << *bb << std::endl;
				}
			}
			// if (dump_stats) {
			// 	json_parser::write_json(prefix + "value_analysis_statistics.json", stats);
			// }
		}

	  public:
		static std::string get_name() { return "ValueAnalysisCore"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {dump_stats_template}; }

		virtual llvm::json::Array get_configured_dependencies() override;
		virtual void run() override;
	};
} // namespace ara::step
