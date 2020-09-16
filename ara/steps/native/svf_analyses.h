// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <Graphs/ICFG.h>
#include <Graphs/PTACallGraph.h>
#include <graph.h>

namespace ara::step {
	class SVFAnalyses : public ConfStep<SVFAnalyses> {
	  private:
		llvm::DataLayout dl;
		std::map<const llvm::FunctionType*, std::vector<std::reference_wrapper<llvm::Function>>> signature_to_func;

		void link_indirect_pointer(const SVF::CallBlockNode& cbn, SVF::PTACallGraph& callgraph,
		                           const llvm::Function& target, SVF::SVFModule& svfModule);
		bool is_valid_call_target(const llvm::FunctionType& caller_type, const llvm::Function& candidate) const;
		void resolve_function_pointer(const SVF::CallBlockNode& cbn, SVF::PTACallGraph& callgraph,
		                              SVF::SVFModule& svfModule);
		void resolve_indirect_function_pointers(SVF::ICFG& icfg, SVF::PTACallGraph& callgraph,
		                                        SVF::SVFModule& svfModule);

	  public:
		SVFAnalyses(PyObject* py_logger, graph::Graph graph, PyObject* py_step_manager)
		    : ConfStep<SVFAnalyses>(py_logger, graph, py_step_manager), dl(&graph.get_module()) {}

		static std::string get_name() { return "SVFAnalyses"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"LLVMMap"}; }

		virtual void run() override;
	};
} // namespace ara::step
