// vim: set noet ts=4 sw=4:

#pragma once

#include "arguments.h"
#include "option.h"
#include "step.h"

#include <Graphs/SVFG.h>
#include <Graphs/VFGNode.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>
#include <cxxabi.h>
#include <graph.h>

namespace ara::step {
	class ValueAnalysisCore : public EntryPointStep<ValueAnalysisCore> {
	  private:
		struct VFGContainer {
			const SVF::VFGNode* node;
			graph::CallPath call_path;

			VFGContainer(const SVF::VFGNode* node, graph::CallPath call_path) : node(node), call_path(call_path) {}
			VFGContainer() {}
		};

		using EntryPointStep<ValueAnalysisCore>::EntryPointStep;

		const static inline option::TOption<option::Bool> dump_stats_template{
		    "dump_stats", "Export JSON statistics about the value-analysis depth."};
		option::TOptEntity<option::Bool> dump_stats;

		virtual void init_options() override;

		/**
		 * demangle a string, for example:
		 * _ZN11MutexLockerC2EP15QueueDefinition to MutexLocker::MutexLocker(QueueDefinition*)
		 */
		std::string demangle(std::string name) {
			int status = -1;
			std::unique_ptr<char, void (*)(void*)> res{abi::__cxa_demangle(name.c_str(), NULL, NULL, &status),
			                                           std::free};
			return (status == 0) ? res.get() : name;
		}

		void retrieve_value(const SVF::SVFG& vfg, const llvm::Value& value, graph::Argument& arg);
		void collectUsesOnVFG(const SVF::SVFG& vfg, const llvm::CallBase& call);

		shared_ptr<graph::Arguments> get_value(const llvm::CallBase& called_func, const SVF::SVFG& vfg);

		template <typename Graph>
		void get_values(Graph& g, const SVF::SVFG& vfg) {
			graph::CFG cfg = graph.get_cfg();
			// ptree stats;
			for (auto abb :
			     boost::make_iterator_range(boost::vertices(cfg.filter_by_abb(g, graph::ABBType::syscall)))) {
				llvm::BasicBlock* bb = cfg.get_entry_bb<Graph>(abb);
				llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&safe_deref(bb).front());
				shared_ptr<graph::Arguments> args = get_value(safe_deref(called_func), vfg);
				// cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
			}
			// if (dump_stats) {
			// 	json_parser::write_json(prefix + "value_analysis_statistics.json", stats);
			// }
		}

	  public:
		static std::string get_name() { return "ValueAnalysisCore"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {dump_stats_template}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"CallGraph"}; }
		virtual llvm::json::Array get_configured_dependencies() override;
		virtual void run() override;
	};
} // namespace ara::step
