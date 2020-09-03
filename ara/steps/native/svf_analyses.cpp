// vim: set noet ts=4 sw=4:

#include "svf_analyses.h"

#include "common/util.h"

#include <Graphs/VFGNode.h>
#include <SVF-FE/PAGBuilder.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>

using namespace SVF;

namespace ara::step {
	std::string SVFAnalyses::get_description() { return "Run SVF analyses."; }

	/**
	 * Check if a caller_type of function pointer fits to a given candidate function.
	 * Currently, this only checks for the same amount of arguments.
	 */
	bool SVFAnalyses::is_valid_call_target(const llvm::FunctionType& caller_type,
	                                       const llvm::Function& candidate) const {
		if (candidate.empty() || candidate.isIntrinsic()) {
			return false;
		}
		// TODO this can be improved. It should also be sound, if the bitsize is the same for all types.
		if (candidate.getFunctionType()->getNumParams() == caller_type.getNumParams()) {
			return true;
		}
		return false;
	}

	void SVFAnalyses::resolve_function_pointer(const CallBlockNode& cbn, PTACallGraph& callgraph,
	                                           SVFModule& svfModule) {
		// first try: match all function signatures. This is slightly better that using all
		// functions as possible pointer target but of course not exact
		const llvm::CallBase* call_inst = llvm::cast<llvm::CallBase>(cbn.getCallSite());
		logger.debug() << "Unresolved call to function pointer. Callsite: " << *call_inst << std::endl;
		const llvm::FunctionType* call_type = call_inst->getFunctionType();

		for (const llvm::Function& candidate : graph.get_module()) {
			if (is_valid_call_target(safe_deref(call_type), candidate)) {

				// modify the SVF Callgraph
				const SVFFunction* callee = svfModule.getSVFFunction(&candidate);
				if (0 == callgraph.getIndCallMap()[&cbn].count(callee)) {
					callgraph.getIndCallMap()[&cbn].insert(callee);
					callgraph.addIndirectCallGraphEdge(&cbn, cbn.getCaller(), callee);
				}

				logger.info() << "Link " << *call_inst << " with " << candidate.getName().str() << std::endl;
			}
		}
	}

	void SVFAnalyses::resolve_indirect_function_pointers(ICFG& icfg, PTACallGraph& callgraph, SVFModule& svfModule) {
		for (ICFG::iterator it = icfg.begin(); it != icfg.end(); ++it) {
			if (CallBlockNode* cbn = llvm::dyn_cast<CallBlockNode>(it->second)) {
				if (!callgraph.hasCallGraphEdge(cbn)) {
					// callblock with unresolved function pointer
					resolve_function_pointer(safe_deref(cbn), callgraph, svfModule);
				}
			}
		}
	}

	void SVFAnalyses::run() {
		logger.info() << "Building SVF graphs." << std::endl;
		SVFModule* svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(graph.get_module());
		assert(svfModule != nullptr && "SVF Module is null");

		PAGBuilder builder;
		PAG* pag = builder.build(svfModule);
		assert(pag != nullptr && "PAG is null");

		Andersen* ander = AndersenWaveDiff::createAndersenWaveDiff(pag);

		SVFGBuilder svfBuilder;
		std::unique_ptr<SVFG> svfg(svfBuilder.buildFullSVFG(ander));

		graph.get_llvm_data().initialize_svfg(std::move(svfg));

		ICFG* icfg = pag->getICFG();
		PTACallGraph* callgraph = ander->getPTACallGraph();

		logger.info() << "Resolve indirect function pointers." << std::endl;
		resolve_indirect_function_pointers(safe_deref(icfg), safe_deref(callgraph), safe_deref(svfModule));

		// resolve indirect pointer in the icfg
		icfg->updateCallGraph(callgraph);

		// we don't need to store anything here, since all SVF datastructures are stored in singletons

		if (*dump.get()) {
			std::string uuid = step_manager.get_execution_id();
			std::string dot_file = *dump_prefix.get() + uuid;

			icfg->dump(dot_file + ".svf-icfg");
			callgraph->dump(dot_file + ".svf-callgraph");
		}
	}
} // namespace ara::step
