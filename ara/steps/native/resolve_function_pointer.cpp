// SPDX-FileCopyrightText: 2020 Yannick Loeck
// SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "resolve_function_pointer.h"

#include "Graphs/PTACallGraph.h"
#include "common/llvm_common.h"

#include <Util/SVFUtil.h>
#include <WPA/Andersen.h>
#include <boost/range/adaptor/indexed.hpp>
#include <fstream>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/TypeFinder.h>

namespace ara::step {

	using namespace SVF;

	void ResolveFunctionPointer::FuzzyFuncTypeIterator::increment() {
		bool has_fuzzy_type = false;
		bool overflow = false;
		for (const auto& elem : fft.types | boost::adaptors::indexed(0)) {
			size_t& pos = positions[elem.index()];
			if (std::holds_alternative<std::vector<llvm::Type*>>(elem.value())) {
				overflow = false;
				has_fuzzy_type = true;
				if (std::get<std::vector<llvm::Type*>>(elem.value()).size() > pos + 1) {
					++pos;
					break;
				} else {
					pos = 0;
					overflow = true;
				}
			}
		}
		if (overflow || !has_fuzzy_type) {
			end = true;
		}
	}

	llvm::FunctionType* ResolveFunctionPointer::FuzzyFuncTypeIterator::dereference() const {
		std::vector<llvm::Type*> fixed_types;
		for (const auto& elem : fft.types | boost::adaptors::indexed(0)) {
			if (std::holds_alternative<std::vector<llvm::Type*>>(elem.value())) {
				const auto& choices = std::get<std::vector<llvm::Type*>>(elem.value());
				fixed_types.emplace_back(choices[positions[elem.index()]]);
			} else {
				fixed_types.emplace_back(std::get<llvm::Type*>(elem.value()));
			}
		}
		return llvm::FunctionType::get(fft.return_type, llvm::ArrayRef<Type*>(fixed_types), false);
	}

	ResolveFunctionPointer::FuzzyFuncType::FuzzyFuncType(const llvm::FunctionType& ty, const TypeMap& t_map)
	    : return_type(ty.getReturnType()) {
		for (auto it = ty.param_begin(); it != ty.param_end(); ++it) {
			if (PointerType* ptr = llvm::dyn_cast<PointerType>(*it)) {
				const auto o_it = t_map.find(ptr->getPointerElementType());
				std::set<llvm::Type*> o_types;
				if (o_it != t_map.end()) {
					o_types = t_map.at(ptr->getPointerElementType());
				}
				std::vector<Type*> alter_types;
				alter_types.emplace_back(ptr);
				for (llvm::Type* type : o_types) {
					alter_types.emplace_back(llvm::PointerType::get(type, ptr->getAddressSpace()));
				}
				types.emplace_back(alter_types);
			} else {
				types.emplace_back(*it);
			}
		}
		/*
		// debug printing
		llvm::errs() << "Types: ";
		for (const auto& elem : types) {
		    if (std::holds_alternative<std::vector<llvm::Type*>>(elem)) {
		        const auto& choices = std::get<std::vector<llvm::Type*>>(elem);
		        for (const auto& ty : choices) {
		            llvm::errs() << "|" << *ty << "|";
		        }
		        llvm::errs() << ", ";
		    } else {
		        llvm::errs() << *std::get<llvm::Type*>(elem) << ", ";
		    }
		}
		llvm::errs() << "\n";
		*/
	}

	ResolveFunctionPointer::FuzzyFuncTypeIterator ResolveFunctionPointer::FuzzyFuncType::begin() {
		return ResolveFunctionPointer::FuzzyFuncTypeIterator(*this);
	}

	ResolveFunctionPointer::FuzzyFuncTypeIterator ResolveFunctionPointer::FuzzyFuncType::end() {
		return ResolveFunctionPointer::FuzzyFuncTypeIterator(*this, /*end=*/true);
	}

	std::string ResolveFunctionPointer::get_description() {
		return "Resolve all function pointers that are not already resolved by SVF.\n"
		       "This step modifies only SVF datastructures.";
	}

	void ResolveFunctionPointer::init_options() {
		EntryPointStep<ResolveFunctionPointer>::init_options();
		accept_list = accept_list_template.instantiate(get_name());
		block_list = block_list_template.instantiate(get_name());
		translation_map = translation_map_template.instantiate(get_name());
		use_only_translation_map = use_only_translation_map_template.instantiate(get_name());
		opts.emplace_back(accept_list);
		opts.emplace_back(block_list);
		opts.emplace_back(translation_map);
		opts.emplace_back(use_only_translation_map);
	}

	Step::OptionVec ResolveFunctionPointer::get_local_options() {
		return {accept_list_template, block_list_template, translation_map_template, use_only_translation_map_template};
	}

	void ResolveFunctionPointer::clear_svf_callgraph(const CallICFGNode& cbn, PTACallGraph& callgraph) {
		std::vector<PTACallGraphEdge*> call_edges(callgraph.getCallEdgeBegin(&cbn), callgraph.getCallEdgeEnd(&cbn));
		for (auto edge : call_edges) {
			callgraph.removeInDirectCallGraphEdge(edge);
		}
	}

	void ResolveFunctionPointer::link_indirect_pointer(const CallICFGNode& cbn, PTACallGraph& callgraph,
	                                                   const llvm::Function& target, const LLVMModuleSet& module) {
		// modify the SVF Callgraph
		const SVFFunction* callee = module.getSVFFunction(&target);
		const llvm::CallBase* call_inst = llvm::cast<llvm::CallBase>(cbn.getCallSite()->getLLVMInstruction());
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

	void ResolveFunctionPointer::init_compatible_types() {
		llvm::TypeFinder s_types;
		s_types.run(graph.get_module(), true);

		bool changed = false;

		do {
			for (llvm::StructType* ty : s_types) {
				for (auto it = ty->element_begin(); it != ty->element_end(); ++it) {
					if (llvm::StructType* sty = llvm::dyn_cast<llvm::StructType>(*it)) {
						size_t old_size = compatible_types[sty].size();
						compatible_types[sty].insert(ty);
						compatible_types[sty].insert(compatible_types[ty].begin(), compatible_types[ty].end());
						changed = (old_size != compatible_types[sty].size());
					}
				}
				// Handle a special case where Clang generate two types for one C++ class with a vTable.
				// Clang introduces padding in classes with vTables.
				// If this class is a base class then Clang dublicates it in a class with (original name) and without
				// padding (name suffixed with ".base") and uses the one without padding to embed it in the child
				// classes.
				if (ty->hasName() && ty->getName().endswith(".base")) {
					auto n_ty_name = ty->getName().drop_back(5); // drop ".base"
#if LLVM_VERSION_MAJOR <= 11
					StructType* n_ty = graph.get_module().getTypeByName(n_ty_name);
#else
					StructType* n_ty = llvm::StructType::getTypeByName(graph.get_module().getContext(), n_ty_name);
#endif
					if (n_ty) {
						auto& compat_1 = compatible_types[ty];
						auto& compat_2 = compatible_types[n_ty];
						size_t c1_size = compat_1.size();
						size_t c2_size = compat_2.size();
						// create union of both sets
						compat_1.insert(compat_2.begin(), compat_2.end());
						compat_2.insert(compat_1.begin(), compat_1.end());
						changed = changed || (c1_size != compat_1.size() || c2_size != compat_2.size());
					}
				}
			}
		} while (changed);
	}

	void
	ResolveFunctionPointer::get_atf_from_value(const llvm::Value& value,
	                                           std::vector<std::reference_wrapper<const llvm::Function>>& functions) {
		if (const llvm::Function* fv = llvm::dyn_cast<llvm::Function>(&value)) {
			functions.emplace_back(*fv);
			logger.debug() << "Found address taken function: " << fv->getName().str() << std::endl;
		} else if (const auto* ca = llvm::dyn_cast<llvm::ConstantAggregate>(&value)) {
			get_atf_from_user(*ca, functions);
		} else if (const auto* bc = llvm::dyn_cast<llvm::BitCastOperator>(&value)) {
			get_atf_from_user(*bc, functions);
		}
	}

	void
	ResolveFunctionPointer::get_atf_from_user(const llvm::User& user,
	                                          std::vector<std::reference_wrapper<const llvm::Function>>& functions) {
		for (const llvm::Value* value : user.operand_values()) {
			get_atf_from_value(safe_deref(value), functions);
		}
	}

	std::vector<std::reference_wrapper<const llvm::Function>> ResolveFunctionPointer::get_address_taken_functions() {
		auto& l_module = graph.get_module();
		std::vector<std::reference_wrapper<const llvm::Function>> ret;
		// iterate every instruction
		for (const auto& func : l_module) {
			for (const auto& bb : func) {
				for (const auto& i : bb) {
					if (llvm::isa<llvm::CallInst>(i)) {
						continue;
					}
					get_atf_from_user(i, ret);
				}
			}
		}
		// iterate initialized global variables (like vTables)
		for (const llvm::GlobalVariable& global : l_module.globals()) {
			get_atf_from_user(global, ret);
		}
		return ret;
	}

	std::vector<const llvm::Function*> ResolveFunctionPointer::resolve_function_pointer(const CallICFGNode& cbn,
	                                                                                    PTACallGraph& callgraph,
	                                                                                    const LLVMModuleSet& module) {
		std::vector<const llvm::Function*> ret;
		const llvm::CallBase* call_inst = llvm::cast<llvm::CallBase>(cbn.getCallSite()->getLLVMInstruction());
		if (is_call_to_intrinsic(*call_inst)) {
			return ret;
		}

		logger.info() << "Resolve call to function pointer. Callsite: " << *call_inst << std::endl;

		// automatic resolving

		// create a map between FunctionType and the list of corresponding functions
		if (signature_to_func.size() == 0) {
			for (const llvm::Function& func : get_address_taken_functions()) {
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

		// fill compatible types map
		if (compatible_types.size() == 0) {
			init_compatible_types();
		}

		/*
		// debug printing
		for (const auto& [key, value] : compatible_types) {
		    logger.warn() << "Key: " << *key << ":";
		    for (const auto& elem : value) {
		        logger.warn() << " " << *elem;
		    }
		    logger.warn() << std::endl;
		}
		*/

		// find all compatible types for this specific signature
		FuzzyFuncType fft(safe_deref(call_inst->getFunctionType()), compatible_types);
		logger.debug() << "Original type: " << *call_inst->getFunctionType() << std::endl;

		// iterate the cross product of all compatible types and link
		bool found_candidate = false;
		unsigned i = 0;
		for (const auto func_type : fft) {
			logger.debug() << "New type: " << *func_type << std::endl;
			const auto& match = signature_to_func.find(func_type);
			if (match != signature_to_func.end()) {
				found_candidate = true;
				for (const llvm::Function& func : match->second) {
					link_indirect_pointer(cbn, callgraph, func, module);
					ret.emplace_back(&func);
					++i;
				}
			}
		}

		// 20 is an arbitrary constant
		if (i > 20) {
			logger.warn() << "At Callsite: " << *call_inst << std::endl;
			logger.warn() << "More than 20 candidates found. Found " << i << " candidates." << std::endl;
		}

		if (!found_candidate) {
			logger.warn() << "At Callsite: " << *call_inst << std::endl;
			logger.warn() << "Unresolved function pointer!" << std::endl;
		}
		return ret;
	}

	void ResolveFunctionPointer::resolve_indirect_function_pointers(ICFG& icfg, PTACallGraph& callgraph,
	                                                                const LLVMModuleSet& module,
	                                                                std::string entry_point) {
		int handled_blocks = 0;
		llvm::Function* entry = graph.get_module().getFunction(entry_point);
		option_fail_if(entry == nullptr, "entry_point", "Not a valid LLVM function.");

		std::set<const llvm::Function*> handled_functions;
		std::queue<const llvm::Function*> unhandled_functions;
		unhandled_functions.push(entry);

		while (!unhandled_functions.empty()) {
			const llvm::Function* current_function = unhandled_functions.front();
			unhandled_functions.pop();
			if (handled_functions.find(current_function) != handled_functions.end()) {
				continue;
			}
			handled_functions.insert(current_function);

			logger.debug() << "Analyzing function: " << current_function->getName().str() << std::endl;

			for (const auto& bb : *current_function) {
				for (const auto& i : bb) {
					const auto* svf_inst = module.getSVFInstruction(&i);
					if (SVFUtil::isCallSite(&i) && SVFUtil::isNonInstricCallSite(svf_inst)) {
						CallICFGNode* cbn = icfg.getCallICFGNode(svf_inst);
						const llvm::CallBase* call_inst =
						    llvm::cast<llvm::CallBase>(cbn->getCallSite()->getLLVMInstruction());

						// handle user defined translation map
						try {
							const auto& [source, line] = get_source_location(*call_inst);
							auto c_source = std::filesystem::canonical(source);
							logger.debug() << "Try to resolve " << *call_inst << std::endl;
							logger.debug() << "Callsite is in " << c_source << " line: " << line << std::endl;
							const auto& entry = pointer_targets.find(std::make_pair(c_source, line));
							if (entry != pointer_targets.end()) {
								logger.info() << "Link with predefined functions from translation map: " << *call_inst
								              << std::endl;
								logger.info() << "File: " << c_source << " line: " << line << std::endl;
								if (callgraph.hasCallGraphEdge(cbn)) {
									logger.info() << "Override SVF found values." << std::endl;
									clear_svf_callgraph(*cbn, callgraph);
								}
								for (const auto& func_name : entry->second) {
									const llvm::Function* func = graph.get_module().getFunction(func_name);
									option_fail_if(!func, "translation_map",
									              std::string("missing function ") + func_name);
									link_indirect_pointer(*cbn, callgraph, *func, module);
									unhandled_functions.push(func);
								}
								continue;
							}
						} catch (const LLVMError& e) {
							logger.warn() << "Cannot find source code location of callsite " << call_inst << std::endl;
						}

						if (callgraph.hasCallGraphEdge(cbn)) {
							// add all following functions to unhandled_functions
							for (auto it = callgraph.getCallEdgeBegin(cbn); it != callgraph.getCallEdgeEnd(cbn); ++it) {
								PTACallGraphNode* call_node = (*it)->getDstNode();
								unhandled_functions.push(call_node->getFunction()->getLLVMFun());
							}
						} else {
							// callblock with unresolved function pointer
							if (*use_only_translation_map.get()) {
								logger.debug() << "Callsite not found in translation map, skipping..." << std::endl;
								ignored_calls++;
								continue;
							}
							for (auto func : resolve_function_pointer(safe_deref(cbn), callgraph, module)) {
								unhandled_functions.push(func);
							}
							handled_blocks++;
						}
					}
				}
			}
		}

		logger.info() << "Handled " << handled_blocks << " blocks with unresolved function pointers\n" << std::endl;
	}

	void ResolveFunctionPointer::run() {
		dl = DataLayout(&graph.get_module());
		SVF::PAG* pag = SVF::PAG::getPAG();
		SVF::ICFG* icfg = safe_deref(pag).getICFG();

		helper::TranslationMapParser tmp(*this);
		tmp.parse_list("accept_list", accept_list, accept_names);
		tmp.parse_list("block_list", block_list, block_names);
		tmp.parse_translation_map("translation_map", translation_map, pointer_targets);

		// this is actually a singleton, so the creation was done in SVFAnalyses
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* callgraph = safe_deref(ander).getPTACallGraph();

		SVF::LLVMModuleSet* module = SVF::LLVMModuleSet::getLLVMModuleSet();

		auto entry_point_name = this->entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		logger.info() << "Analyzing entry point: '" << *entry_point_name << "'" << std::endl;

		resolve_indirect_function_pointers(safe_deref(icfg), safe_deref(callgraph), safe_deref(module),
		                                   *entry_point_name);

		icfg->updateCallGraph(callgraph);

		if (*use_only_translation_map.get()) {
			logger.warn() << "Ignored function pointers: " << ignored_calls << std::endl;
		}
	}
} // namespace ara::step
