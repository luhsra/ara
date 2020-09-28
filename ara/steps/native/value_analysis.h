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
	class ValueAnalysis : public EntryPointStep<ValueAnalysis> {
	  private:
		/**
		 * Convenience datatype, since the Value Analysis does a depth first search about the nodes, but also needs the
		 * call_path.
		 */
		struct VFGContainer {
			const SVF::VFGNode* node;
			graph::CallPath call_path;
			unsigned depth;

			VFGContainer(const SVF::VFGNode* node, graph::CallPath call_path, unsigned depth)
			    : node(node), call_path(call_path), depth(depth) {}
			VFGContainer() {}
		};

		using EntryPointStep<ValueAnalysis>::EntryPointStep;

		inline void pretty_print(const llvm::Value&, Logger::LogStream& ls) const;

		std::map<const std::string, os::SysCall> syscalls;

		/**
		 * Perform a search over the SVFG, until it reaches a constant.
		 */
		void do_backward_value_search(const SVF::SVFG& vfg, const llvm::Value& start, graph::Argument& arg,
		                              graph::SigType hint);

		shared_ptr<graph::Arguments> get_values_for_call(llvm::CallBase& called_func, const SVF::SVFG& vfg);

		template <typename Graph>
		void get_all_values(Graph& g, const SVF::SVFG& vfg, const std::string& entry_point) {
			graph::CFG cfg = graph.get_cfg();

			// TODO, put this into the EntryPoint class. This is copied from ICFG
			typename boost::graph_traits<Graph>::vertex_descriptor entry_func;
			try {
				entry_func = cfg.get_function_by_name(g, entry_point);
			} catch (FunctionNotFound&) {
				std::stringstream ss;
				ss << "Bad entry point given: " << entry_point << ". Could not be found.";
				fail(ss.str());
			}

			std::function<void(const Graph&, ara::graph::CFG&, typename boost::graph_traits<Graph>::vertex_descriptor)>
			    action = [&](const Graph&, graph::CFG& cfg,
			                 typename boost::graph_traits<Graph>::vertex_descriptor abb) {
				    if (cfg.type[abb] != graph::ABBType::syscall) {
					    return;
				    }
				    llvm::BasicBlock* bb = cfg.get_entry_bb<Graph>(abb);
				    llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&safe_deref(bb).front());
				    logger.debug() << "Analyzing: " << cfg.name[abb] << " ("
				                   << safe_deref(called_func->getCalledFunction()).getName().str() << ")" << std::endl;
				    shared_ptr<graph::Arguments> args = get_values_for_call(safe_deref(called_func), vfg);
				    // TODO this is actually inefficient. The arguments object could be updated here, not overwritten
				    cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args->get_python_obj()));
			    };
			cfg.execute_on_reachable_abbs(g, entry_func, action);
		}

	  public:
		static std::string get_name() { return "ValueAnalysis"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"CallGraph"}; }
		virtual llvm::json::Array get_configured_dependencies() override;
		virtual void run() override;
	};
} // namespace ara::step
