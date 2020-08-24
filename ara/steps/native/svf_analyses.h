// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <Graphs/ICFG.h>
#include <Graphs/PTACallGraph.h>
#include <graph.h>

namespace ara::step {
	class SVFAnalyses : public ConfStep<SVFAnalyses> {
	  private:
		using ConfStep<SVFAnalyses>::ConfStep;

		bool is_valid_call_target(const llvm::FunctionType& caller_type, const llvm::Function& candidate) const;
		void resolve_function_pointer(const SVF::CallBlockNode& cbn, SVF::PTACallGraph& callgraph,
		                              SVF::SVFModule& svfModule);
		void resolve_indirect_function_pointers(SVF::ICFG& icfg, SVF::PTACallGraph& callgraph,
		                                        SVF::SVFModule& svfModule);

	  public:
		static std::string get_name() { return "SVFAnalyses"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"LLVMMap"}; }

		virtual void run() override;
	};
} // namespace ara::step
