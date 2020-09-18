// vim: set noet ts=4 sw=4:

#include "resolve_function_pointer.h"

#include <WPA/Andersen.h>

namespace ara::step {

	using namespace SVF;

	std::string ResolveFunctionPointer::get_description() {
		return "Resolve all function pointers that are not already resolved by SVF.\nThis step modifies only SVF "
		       "datastructures.";
	}

	/**
	 * Check if a caller_type of function pointer fits to a given candidate function.
	 * Currently, this only checks for the same amount of arguments.
	 */
	bool ResolveFunctionPointer::is_valid_call_target(const llvm::FunctionType& caller_type,
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

	void ResolveFunctionPointer::link_indirect_pointer(const CallBlockNode& cbn, PTACallGraph& callgraph,
	                                                   const llvm::Function& target, const LLVMModuleSet& module) {
		// modify the SVF Callgraph
		const SVFFunction* callee = module.getSVFFunction(&target);
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

	void ResolveFunctionPointer::resolve_function_pointer(const CallBlockNode& cbn, PTACallGraph& callgraph,
	                                                      const LLVMModuleSet& module) {
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
				link_indirect_pointer(cbn, callgraph, func, module);
			}
		} else {
			// std::vector<const llvm::Function*> functions;

			int i = 0;
			for (const llvm::Function& func : graph.get_module()) {
				if (is_valid_call_target(safe_deref(call_type), func)) {
					// functions.emplace_back(&func);
					link_indirect_pointer(cbn, callgraph, func, module);
					++i;
					found_candidate = true;
				}
			}
			// 20 is an arbitrary constant
			if (i > 20) {
				logger.warn() << "Unknown function pointer. Callsite: " << *call_inst << std::endl;
				logger.warn() << "More than 20 candidates found. Found " << i << " candidates." << std::endl;
			}
			// for (const llvm::Function* func : functions) {
			// 	link_indirect_pointer(cbn, callgraph, *func, module);
			// 	// if (i++ > 1) {
			// 	break;
			// 	//}
			// }
		}

		if (!found_candidate) {
			logger.error() << "Callsite: " << *call_inst << std::endl;
			fail("Unresolved function pointer.");
		}
	}

	void ResolveFunctionPointer::resolve_indirect_function_pointers(ICFG& icfg, PTACallGraph& callgraph,
	                                                                const LLVMModuleSet& module) {
		for (ICFG::iterator it = icfg.begin(); it != icfg.end(); ++it) {
			if (CallBlockNode* cbn = llvm::dyn_cast<CallBlockNode>(it->second)) {
				if (!callgraph.hasCallGraphEdge(cbn)) {
					// callblock with unresolved function pointer
					resolve_function_pointer(safe_deref(cbn), callgraph, module);
				}
			}
		}
	}

	void ResolveFunctionPointer::run() {
		SVF::PAG* pag = SVF::PAG::getPAG();
		SVF::ICFG* icfg = safe_deref(pag).getICFG();

		// this is actually a singleton, so the creation was done in SVFAnalyses
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* callgraph = safe_deref(ander).getPTACallGraph();

		SVF::LLVMModuleSet* module = SVF::LLVMModuleSet::getLLVMModuleSet();

		resolve_indirect_function_pointers(safe_deref(icfg), safe_deref(callgraph), safe_deref(module));

		icfg->updateCallGraph(callgraph);
	}
} // namespace ara::step
