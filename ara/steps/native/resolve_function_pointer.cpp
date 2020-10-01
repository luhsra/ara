// vim: set noet ts=4 sw=4:

#include "resolve_function_pointer.h"

#include <WPA/Andersen.h>

namespace ara::step {

	using namespace SVF;

	std::string ResolveFunctionPointer::get_description() {
		return "Resolve all function pointers that are not already resolved by SVF.\n"
		       "This step modifies only SVF datastructures.";
	}

	void ResolveFunctionPointer::init_options() {
		accept_list = accept_list_template.instantiate(get_name());
		block_list = block_list_template.instantiate(get_name());
		translation_map = translation_map_template.instantiate(get_name());
		opts.emplace_back(accept_list);
		opts.emplace_back(block_list);
		opts.emplace_back(translation_map);
	}

	Step::OptionVec ResolveFunctionPointer::get_local_options() {
		return {accept_list_template, block_list_template, translation_map_template};
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

		const auto& cand_name = candidate.getName().str();

		if (cand_name == constants::ARA_ENTRY_POINT) {
			return false;
		}

		if (block_names.find(cand_name) != block_names.end()) {
			return false;
		}

		if (accept_names.size() != 0 && accept_names.find(cand_name) == accept_names.end()) {
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

		const auto& begin1 = caller_type.param_begin();
		const auto& end1 = caller_type.param_end();

		const auto& begin2 = candidate_type->param_begin();
		const auto& end2 = candidate_type->param_end();

		auto it1 = begin1;
		auto it2 = begin2;

		for (; it1 != end1 && it2 != end2; ++it1, ++it2) {
			llvm::Type* type1 = *it1;
			llvm::Type* type2 = *it2;
			if (llvm::PointerType* pt1 = llvm::dyn_cast<llvm::PointerType>(type1)) {
				// we need extra care here, the pointer must point to a same sized type
				type1 = pt1->getElementType();
				if (llvm::PointerType* pt2 = llvm::dyn_cast<llvm::PointerType>(type2)) {
					type2 = pt2->getElementType();
				} else {
					return false;
				}
			}
			if (type1 && type2 && type1->isSized() && type2->isSized() &&
			    dl->getTypeAllocSize(type1) == dl->getTypeAllocSize(type2)) {
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

		const auto& debug_loc = call_inst->getDebugLoc();
		if (const auto* scope = llvm::dyn_cast<llvm::DIScope>(debug_loc.getScope())) {
			std::filesystem::path source = std::filesystem::canonical(
			    std::filesystem::path(scope->getDirectory().str()) / std::filesystem::path(scope->getFilename().str()));
			unsigned line = debug_loc.getLine();
			const auto& entry = pointer_targets.find(std::make_pair(source, line));
			if (entry != pointer_targets.end()) {
				logger.info() << "Link with predefined functions from translation map." << std::endl;
				for (const auto& func_name : entry->second) {
					const llvm::Function* func = graph.get_module().getFunction(func_name);
					fail_if_empty(func, "translation_map", std::string("missing function ") + func_name);
					link_indirect_pointer(cbn, callgraph, *func, module);
				}
				return;
			}
		} else {
			logger.warn() << "Cannot find source code location of callsite " << call_inst << std::endl;
		}

		const llvm::FunctionType* call_type = call_inst->getFunctionType();

		if (signature_to_func.size() == 0) {
			for (llvm::Function& func : graph.get_module()) {
				const auto& func_name = func.getName().str();
				if (block_names.find(func_name) != block_names.end()) {
					continue;
				}
				if (accept_names.size() != 0 && accept_names.find(func_name) == accept_names.end()) {
					continue;
				}
				signature_to_func[func.getFunctionType()].emplace_back(func);
			}
		}

		const auto& match = signature_to_func.find(call_type);

		bool found_candidate = false;
		// do the simple check, maybe the same function signature exist somewhere
		if (match != signature_to_func.end()) {
			found_candidate = true;
			for (llvm::Function& func : match->second) {
				link_indirect_pointer(cbn, callgraph, func, module);
			}
		} else {
			// be more generous, only the bit sizes of the arguments must match.
			// This can result is a _lot_ of candidate functions.

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
		int handled_blocks = 0;
		for (ICFG::iterator it = icfg.begin(); it != icfg.end(); ++it) {
			if (CallBlockNode* cbn = llvm::dyn_cast<CallBlockNode>(it->second)) {
				if (!callgraph.hasCallGraphEdge(cbn)) {
					// callblock with unresolved function pointer
					resolve_function_pointer(safe_deref(cbn), callgraph, module);
					handled_blocks++;
				}
			}
		}
		logger.info() << "Handled " << handled_blocks << " blocks with unresolved function pointers\n" << std::endl;
	}

	void ResolveFunctionPointer::parse_json(const char* opt_name, option::TOptEntity<option::String>& option,
	                                        std::function<void(const llvm::json::Array&)> do_with_array) {
		const auto& opt = option.get();
		if (opt) {
			std::string source;
			// check if list is a file or directy a json list
			// TODO replace this with startswith, once we have C++20
			if (opt->find("[") != 0) {
				std::ifstream ifs(*opt);
				source = std::string((std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
			} else {
				source = *opt;
			}

			// actual JSON parsing
			auto val = llvm::json::parse(source);
			fail_if_empty(val, opt_name, "LLVM JSON parsing failed");
			llvm::json::Array* arr = val->getAsArray();
			fail_if_empty(arr, opt_name, "Invalid JSON. Expecting a list.");

			do_with_array(*arr);
		}
	}

	void ResolveFunctionPointer::parse_list(const char* opt_name, option::TOptEntity<option::String>& option,
	                                        std::set<std::string>& target) {
		target.clear();

		std::function<void(const llvm::json::Array&)> do_with_array = [&](const llvm::json::Array& arr) {
			for (const llvm::json::Value& func_val : arr) {
				auto func = func_val.getAsString();
				fail_if_empty(func, opt_name, "Invalid JSON. Expecting a list of strings.");
				target.insert(func->str());
			}
		};
		parse_json(opt_name, option, do_with_array);
	}

	void ResolveFunctionPointer::parse_translation_map(const char* opt_name,
	                                                   option::TOptEntity<option::String>& option) {
		pointer_targets.clear();
		std::function<void(const llvm::json::Array&)> do_with_array = [&](const llvm::json::Array& arr) {
			const auto& opt = option.get();
			for (const llvm::json::Value& entry : arr) {
				auto entry_d = entry.getAsObject();
				fail_if_empty(entry_d, opt_name, "Invalid JSON. Expecting a list of dicts.");
				auto source_file = entry_d->getString("source_file");
				fail_if_empty(source_file, opt_name, "Invalid JSON. Expecting a source_file entry.");
				std::filesystem::path source_path = std::filesystem::canonical(
				    std::filesystem::path(*opt).parent_path() / std::filesystem::path(*source_file));
				auto line_number = entry_d->getInteger("line_number");
				fail_if_empty(line_number, opt_name, "Invalid JSON. Expecting a line_number entry.");
				auto call_targets = entry_d->getArray("call_targets");
				fail_if_empty(call_targets, opt_name, "Invalid JSON. Expecting a call_targets entry.");

				std::set<string> call_t;
				for (const llvm::json::Value& func_val : *call_targets) {
					auto func = func_val.getAsString();
					fail_if_empty(func, opt_name, "Invalid JSON. Expecting a list of strings as call_targets.");
					call_t.insert(func->str());
				}
				pointer_targets[std::make_pair<std::filesystem::path, unsigned>(std::move(source_path), *line_number)] =
				    std::move(call_t);
			}
		};
		parse_json(opt_name, option, do_with_array);
	}

	void ResolveFunctionPointer::run() {
		dl = DataLayout(&graph.get_module());
		SVF::PAG* pag = SVF::PAG::getPAG();
		SVF::ICFG* icfg = safe_deref(pag).getICFG();

		parse_list("accept_list", accept_list, accept_names);
		parse_list("block_list", block_list, block_names);
		parse_translation_map("translation_map", translation_map);

		// this is actually a singleton, so the creation was done in SVFAnalyses
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* callgraph = safe_deref(ander).getPTACallGraph();

		SVF::LLVMModuleSet* module = SVF::LLVMModuleSet::getLLVMModuleSet();

		resolve_indirect_function_pointers(safe_deref(icfg), safe_deref(callgraph), safe_deref(module));

		icfg->updateCallGraph(callgraph);
	}
} // namespace ara::step
