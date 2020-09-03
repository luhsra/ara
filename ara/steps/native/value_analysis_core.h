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
			CallPath call_path;

			VFGContainer(const SVF::VFGNode* node, CallPath call_path) : node(node), call_path(call_path) {}
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

		/* a list of values and their (hopefully) corresponding paths along which they are retrieved */
		typedef std::tuple<std::vector<const llvm::Constant*>, std::vector<std::vector<const llvm::Instruction*>>>
		    ValPath;

		const llvm::Value* temp_traverse(const SVF::SVFGNode* node, const SVF::SVFG& vfg,
		                                 std::vector<const SVF::SVFGNode*>& visited);
		std::vector<const SVF::SVFGNode*> vstd;

		const llvm::Constant* handle_value(const llvm::Value* value, const SVF::SVFG& vfg, const SVF::VFGNode* node);
		ValPath retrieve_value(const SVF::SVFG& vfg, const llvm::Value& value, Argument& arg);
		std::vector<ValPath> collectUsesOnVFG(const SVF::SVFG& vfg, const llvm::CallBase& call);

		/**
		 * given a function, find its corresponding callgraph node and iterate over
		 * its parents up to the respective root, saving each list of functions
		 * in <curPath> first, and adding it to <paths> when a root node is reached
		 *
		 * this should just be bottom-up DFS
		 */
		void getCallPaths(const llvm::Function* f, std::vector<std::vector<const llvm::Instruction*>>& paths,
		                  std::vector<const llvm::Instruction*>& curPath);

		Arguments get_value(const llvm::CallBase& called_func, const SVF::SVFG& vfg);

		bool handle_stmt_node(const SVF::StmtVFGNode& node);

		template <typename Graph>
		void get_values(Graph& g, const SVF::SVFG& vfg) {
			graph::CFG cfg = graph.get_cfg();
			// ptree stats;
			for (auto abb :
			     boost::make_iterator_range(boost::vertices(cfg.filter_by_abb(g, graph::ABBType::syscall)))) {
				llvm::BasicBlock* bb = cfg.get_entry_bb<Graph>(abb);
				llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&safe_deref(bb).front());
				Arguments args = get_value(safe_deref(called_func), vfg);
				cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
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
