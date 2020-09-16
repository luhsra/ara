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
		if (candidate.empty() || is_intrinsic(candidate)) {
			return false;
		}

		const auto* candidate_type = candidate.getFunctionType();

		// check for several conditions, try to do this speed optimized
		if (caller_type.getNumParams() != candidate_type->getNumParams()) {
			return false;
		}

		if (caller_type.getNumParams() == 0) {
			return true;
		}

		const auto& begin1 = candidate_type->param_begin();
		const auto& end1 = candidate_type->param_end();

		const auto& begin2 = caller_type.param_begin();
		const auto& end2 = caller_type.param_end();

		auto it1 = begin1;
		auto it2 = begin2;

		for (; it1 != end1 && it2 != end2; ++it1, ++it2) {
			llvm::Type* type1 = *it1;
			llvm::Type* type2 = *it2;
			if (type1 && type2 && type1->isSized() && type2->isSized() &&
			    dl.getTypeAllocSize(type1) == dl.getTypeAllocSize(type2)) {
				return true;
			}
		}
		return false;
	}

	void SVFAnalyses::link_indirect_pointer(const SVF::CallBlockNode& cbn, SVF::PTACallGraph& callgraph,
	                                        const llvm::Function& target, SVF::SVFModule& svfModule) {
		// modify the SVF Callgraph
		const SVFFunction* callee = svfModule.getSVFFunction(&target);
		const llvm::CallBase* call_inst = llvm::cast<llvm::CallBase>(cbn.getCallSite());
		if (target.empty()) {
			logger.warn() << "Possible indirect call to unimplemented function, skipping. Call: " << *call_inst
			              << " Target: " << target.getName().str() << std::endl;
			return;
		}
		if (0 == callgraph.getIndCallMap()[&cbn].count(callee)) {
			callgraph.getIndCallMap()[&cbn].insert(callee);
			callgraph.addIndirectCallGraphEdge(&cbn, cbn.getCaller(), callee);
		}

		logger.debug() << "Link " << *call_inst << " with " << target.getName().str() << std::endl;
	}

	void SVFAnalyses::resolve_function_pointer(const CallBlockNode& cbn, PTACallGraph& callgraph,
	                                           SVFModule& svfModule) {
		const llvm::CallBase* call_inst = llvm::cast<llvm::CallBase>(cbn.getCallSite());
		if (is_call_to_intrinsic(*call_inst)) {
			return;
		}

		logger.info() << "Resolve call to function pointer. Callsite: " << *call_inst << std::endl;
		const llvm::FunctionType* call_type = call_inst->getFunctionType();

		if (signature_to_func.size() == 0) {
			for (llvm::Function& func : graph.get_module()) {
				signature_to_func[func.getFunctionType()].emplace_back(func);
			}
		}

		const auto& match = signature_to_func.find(call_type);

		bool found_candidate = false;
		if (match != signature_to_func.end()) {
			found_candidate = true;
			for (llvm::Function& func : match->second) {
				link_indirect_pointer(cbn, callgraph, func, svfModule);
			}
		} else {
			for (const llvm::Function& func : graph.get_module()) {
				if (is_valid_call_target(safe_deref(call_type), func)) {
					link_indirect_pointer(cbn, callgraph, func, svfModule);
					found_candidate = true;
				}
			}
		}

		if (!found_candidate) {
			logger.error() << "Callsite: " << *call_inst << std::endl;
			fail("Unresolved function pointer.");
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

		SVFGBuilder svfBuilder(true);
		std::unique_ptr<SVFG> svfg(svfBuilder.buildFullSVFG(ander));

		graph.get_graph_data().initialize_svfg(std::move(svfg));

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
