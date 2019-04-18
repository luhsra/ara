// vim: set noet ts=4 sw=4:

#include "llvm.h"

#include "FreeRTOSinstances.h"
#include "llvm_common.h"
#include "llvm_dumper.h"

#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/Loads.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/MemorySSA.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/TypeFinder.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Support/raw_os_ostream.h"

#include <cassert>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

using namespace llvm;

#define PRINT_NAME(x) std::cout << #x << " - " << typeid(x).name() << '\n'

static llvm::LLVMContext context;

/**
 * @brief check if the instruction is just llvm specific
 * @param instr instrucion to analyze
 */
static bool isCallToLLVMIntrinsic(Instruction* inst) {
	if (CallInst* callInst = dyn_cast<CallInst>(inst)) {
		Function* func = callInst->getCalledFunction();
		if (func && func->getName().startswith("llvm.")) {
			return true;
		}
	}
	return false;
}

/**
 * @brief check if seed is in vector
 * @param seed seed to analyze
 * @param vector which contains reference seeds
 */
bool visited(size_t seed, std::vector<size_t>* vector) {
	bool found = false;
	for (unsigned i = 0; i < vector->size(); i++) {
		if (vector->at(i) == seed) {
			found = true;
			break;
		}
	}
	return found;
}

namespace step {

	/**
	 * @brief set the arguments std::any and llvm values of the abb
	 * @param abb abb, which should be analyzed
	 * @param warning_list list to store warning
	 */
	void LLVMStep::set_arguments(OS::shared_abb abb, std::vector<shared_warning>* warning_list) {

		int bb_count = 0;

		call_data call_info;

		// iterate about the basic blocks of the abb
		for (auto& bb : *abb->get_BasicBlocks()) {

			int call_count = 0;
			++bb_count;

			// call found flag
			bool call_found = false;

			// iterate about the instructions of the bb
			for (auto& inst : *bb) {

				// if( bb->getName().str() == "BB51") std::cerr << print_argument(&inst) << std::endl;
				// check if instruction is a call instruction
				if (isa<CallInst>(inst)) {
					CallInst* call = (CallInst*)&inst;
					if (!isCallToLLVMIntrinsic(call)) {
						Function* func = call->getCalledFunction();
						call_found = true;

						if (func) {
							// get and store the called arguments values
							dump_instruction(abb, func, call, warning_list);

							++call_count;
						} else {
							// store the name of the called function
							call_info.call_name = print_argument(call->getCalledValue());
							// store the llvm call instruction reference
							call_info.call_instruction = call;
							abb->set_call(&call_info);
						}
					}
				} else if (InvokeInst* invoke = dyn_cast<InvokeInst>(&inst)) {

					if (!isCallToLLVMIntrinsic(invoke)) {

						call_found = true;
						Function* func = invoke->getCalledFunction();

						if (func == nullptr) {
							auto tmp_value = invoke->getCalledValue();
							if (llvm::Constant* constant = dyn_cast<llvm::Constant>(tmp_value)) {
								if (llvm::Function* tmp_func = dyn_cast<llvm::Function>(constant->getOperand(0))) {
									func = tmp_func;
								}
							}
						}
						if (func) {
							// get and store the called arguments values
							dump_instruction(abb, func, invoke, warning_list);
							++call_count;
						} else {
							// store the name of the called function
							call_info.call_name = print_argument(invoke->getCalledValue());
							// store the llvm call instruction reference
							call_info.call_instruction = invoke;
							abb->set_call(&call_info);
						}
					}
				}
			}
			if (call_count > 1) {
				std::cerr << abb->get_name() << " has more than one call instructions: " << call_count << std::endl;
				abort();
			}
			if (call_found) {
				abb->set_call_type(has_call);
			} else
				abb->set_call_type(computation);
		}
		if (bb_count > 1) {
			std::cerr << abb->get_name() << " has more than one llvm basic block: " << bb_count << std::endl;
			abort();
		}
	}

	std::string LLVMStep::get_description() {

		return "Extracts initial objects out of the ll-files.\n"
		       "Initializes all functions and unmerged ABBs. Also tries to extract all arguments out of function "
		       "calls.";
	}

	void LLVMStep::abb_generation(graph::Graph* graph, OS::shared_function function,
	                              std::vector<shared_warning>* warning_list) {

		logger.debug() << "Generate ABBs for " << *function << std::endl;
		llvm::Function* llvm_reference_function = function->get_llvm_reference();

		std::map<const llvm::BasicBlock*, std::shared_ptr<OS::ABB>> bb_map;

		bool first_run = true;
		for (auto& bb : *llvm_reference_function) {
			auto abb = std::make_shared<OS::ABB>(graph, function, bb.getName());
			abb->set_BasicBlock(&bb);
			abb->set_exit_bb(&bb);
			abb->set_entry_bb(&bb);

			set_arguments(abb, warning_list);

			bb_map.insert(std::pair<llvm::BasicBlock*, std::shared_ptr<OS::ABB>>(&bb, abb));

			bool single = true;
			// connect already mapped successors and predecessors
			for (const BasicBlock* succ_b : successors(&bb)) {
				if (bb_map.find(succ_b) != bb_map.end()) {
					abb->set_ABB_successor(bb_map[succ_b]);
					single = false;
				}
			}
			for (const BasicBlock* pred_b : predecessors(&bb)) {
				if (bb_map.find(pred_b) != bb_map.end()) {
					abb->set_ABB_predecessor(bb_map[pred_b]);
					single = false;
				}
			}

			if (!single || first_run) {
				graph->set_vertex(abb);
				function->set_atomic_basic_block(abb);
			}
			first_run = false;
		}
		function->set_entry_abb(bb_map[&llvm_reference_function->front()]);
	}

	void LLVMStep::split_basicblocks(llvm::Function& function, unsigned& split_counter) {
		// store the basic blocks in a list
		std::list<llvm::BasicBlock*> bbs;
		for (llvm::BasicBlock& bb : function) {
			bbs.push_back(&bb);
		}
		// iterate about the basic blocks
		for (llvm::BasicBlock* bb : bbs) {

			// iterate about the instruction
			llvm::BasicBlock::iterator it = bb->begin();
			while (it != bb->end()) {
				// check if the instruction is a call instruction
				if (llvm::isa<llvm::InvokeInst>(*it) || llvm::isa<llvm::CallInst>(*it)) {
					// check if call is targete is an artifical function (e.g. @llvm.dbg.metadata)
					if (isCallToLLVMIntrinsic(&*it)) {
						++it;
						continue;
					}
					// split the basic block and rename it
					std::stringstream ss;
					ss << "BB" << split_counter++;
					bb = bb->splitBasicBlock(it, ss.str());
					it = bb->begin();
				}
				++it;
			}
		}
	}

	std::unique_ptr<Module> LLVMStep::LoadFile(const std::string& FN, LLVMContext& Context) {
		SMDiagnostic Err;
		// if (Verbose) errs() << "Loading '" << FN << "'\n";

		std::unique_ptr<Module> Result = 0;
		Result = parseIRFile(FN, Err, Context);
		if (Result)
			return Result;

		// Err.print(argv0, errs());
		return NULL;
	}

	void LLVMStep::set_called_functions(graph::Graph& graph) {

		std::hash<std::string> hash_fn;

		// set called function for each abb
		for (auto& abb : graph.get_type_vertices<OS::ABB>()) {
			if (abb->get_call_type() != has_call) {
				continue;
			}
			// get call instr of the abb
			auto* instr = abb->get_call_instruction_reference();

			// TODO: with newer llvm: if (std::unique_ptr<CallBase> call = dyn_cast<CallBase>(instr)) {
			if (std::unique_ptr<FakeCallBase> call = FakeCallBase::create(instr)) {
				llvm::Function* llvm_function = call->getCalledFunction();
				if (llvm_function == nullptr) {
					// get function which is addressed with function pointer
					auto tmp_value = call->getCalledValue();
					std::stringstream debug_out;
					std::vector<llvm::Instruction*> already_visited;
					already_visited.emplace_back(instr);
					argument_data argument_container;
					if (dumper.dump_argument(debug_out, &argument_container, tmp_value, &already_visited)) {
						if (argument_container.value_list.size() == 1) {
							if (Function* tmp_function = dyn_cast<Function>(argument_container.value_list.front()))
								llvm_function = tmp_function;
						};
					};
				}
				if (llvm_function != nullptr) {
					// get function which is addressed by call
					graph::shared_vertex vertex =
					    graph.get_vertex(hash_fn(llvm_function->getName().str() + typeid(OS::Function).name()));
					if (vertex != nullptr) {
						auto function = std::dynamic_pointer_cast<OS::Function>(vertex);
						abb->set_called_function(function, instr);
						abb->get_parent_function()->set_called_function(function, abb);
					}
				}
			}
		}
	}

	void LLVMStep::set_exit_abb(graph::Graph& graph, unsigned int& split_counter) {
		// set an exit abb for each function
		for (auto& function : graph.get_type_vertices<OS::Function>()) {
			std::list<OS::shared_abb> return_abbs;

			// detect all abb with no sucessors(exit abbs)
			for (auto abb : function->get_atomic_basic_blocks()) {
				if (abb->get_ABB_successors().size() == 0) {
					return_abbs.emplace_back(abb);
				}
			}

			if (return_abbs.size() > 1) {
				// if more then one abbs with no successors are detected, create a new abb
				// as exit abb, which is connected with all "real" exit abbs
				std::stringstream ss;
				ss << "BB" << split_counter++;
				auto new_abb = std::make_shared<OS::ABB>(&graph, function, ss.str());
				graph.set_vertex(new_abb);
				function->set_atomic_basic_block(new_abb);
				for (auto ret : return_abbs) {
					ret->set_ABB_successor(new_abb);
					new_abb->set_ABB_predecessor(ret);
				}
				function->set_exit_abb(new_abb);
			} else {
				// set the abb as exit abb of the function
				if (return_abbs.size() == 1) {
					function->set_exit_abb(return_abbs.front());
				}
			}
		}
	}

	/**
	 * @brief the run method of the llvm pass. This pass linkes all .ll files and collects all application raw
	 * information (functions and their containing abbs) and store them in the graph data structure.
	 * @param graph project data structure
	 */
	void LLVMStep::run(graph::Graph& graph) {

		std::vector<shared_warning>* warning_list = &(this->warnings);

		// get file arguments from config
		std::vector<std::string> files;
		PyObject* input_files = PyDict_GetItemString(config, "input_files");
		assert(input_files != nullptr && PyList_Check(input_files));
		for (Py_ssize_t i = 0; i < PyList_Size(input_files); ++i) {
			PyObject* elem = PyList_GetItem(input_files, i);
			assert(PyUnicode_Check(elem));
			files.push_back(std::string(PyUnicode_AsUTF8(elem)));
		}

		std::string ErrorMessage;

		// link the modules
		// use first module a main module
		auto Composite = LoadFile(files.at(0), context);
		if (Composite.get() == 0) {
			std::cerr << "error loading file '" << files.at(0) << "'\n";
			abort();
		}

		Linker L(*Composite);

		llvm::raw_os_ostream llog(std::cout);

		// resolve link errors
		for (unsigned i = 1; i < files.size(); ++i) {
			auto M = LoadFile(files.at(i), context);
			if (M.get() == 0) {
				std::cerr << "error loading file '" << files.at(i) << "'\n";
				abort();
			}

			for (auto it = M->global_begin(); it != M->global_end(); ++it) {
				GlobalVariable& gv = *it;
				if (!gv.isDeclaration() && !gv.hasPrivateLinkage())
				   gv.setLinkage(GlobalValue::AvailableExternallyLinkage);
			}

			//for (auto it = M->alias_begin(); it != M->alias_end(); ++it) {
			//	GlobalAlias& ga = *it;
			//	if (!ga.isDeclaration())
			//		ga.setLinkage(GlobalValue::LinkOnceAnyLinkage);
			//}

			//// set linkage information of all functions
			//for (auto& F : *M) {
			//	StringRef Name = F.getName();
			//	// leave library functions alone because their presence or absence
			//	// could affect the behaviour of other passes
			//	if (F.isDeclaration())
			//		continue;
			//	F.setLinkage(GlobalValue::WeakAnyLinkage);
			//}

			if (L.linkInModule(std::move(M))) {
				std::cerr << "link error in '" << files.at(i);
				abort();
			}
		}

		// convert unique_ptr to shared_ptr
		std::shared_ptr<llvm::Module> shared_module = std::move(Composite);
		graph.set_llvm_module(shared_module);

		// create and store the OS instance in the graph
		auto rtos = std::make_shared<OS::RTOS>(&graph, "RTOS");
		graph.set_vertex(rtos);

		// count the amount of basic blocks, name the basic block with the split_counter
		unsigned int split_counter = 0;

		for (auto& func : *shared_module) {
			if (!func.empty()) {
				auto graph_function = std::make_shared<OS::Function>(&graph, func.getName().str());

				// extract argument types
				llvm::FunctionType* argList = func.getFunctionType();
				for (unsigned int i = 0; i < argList->getNumParams(); i++) {
					graph_function->set_argument_type(argList->getParamType(i));
				}

				// extract return type
				graph_function->set_return_type(func.getReturnType());

				// split llvm basic blocks, so that just one call exits per instance
				split_basicblocks(func, split_counter);

				// store llvm function reference
				graph_function->set_llvm_reference(&(func));

				// update dominator tree and postdominator tree
				graph_function->initialize_dominator_tree(&(func));
				graph_function->initialize_postdominator_tree(&(func));
				// name BB if not already done
				for (auto& bb : func) {

					// name all basic blocks
					if (!bb.getName().startswith("BB")) {
						std::stringstream ss;
						ss << "BB" << split_counter++;
						bb.setName(ss.str());
					}
				}
				// store the generated function in the graph datastructure
				graph.set_vertex(graph_function);

				// generate and store the abbs of the function in the graph datatstructure
				abb_generation(&graph, graph_function, warning_list);
			}
		}
		// connect the abbs and functions with the called function
		set_called_functions(graph);

		// detect and set for each function one exit abb
		set_exit_abb(graph, split_counter);
	}

	void LLVMStep::dump_instruction(OS::shared_abb abb, Function* func, CallInst* instruction,
	                                std::vector<shared_warning>* warning_list) {

		// empty call data container
		call_data call;

		// store the name of the called function

		call.call_name = func->getName().str();

		// store the llvm call instruction reference
		call.call_instruction = instruction;
		std::vector<argument_data> arguments;

		// iterate about the arguments of the call
		for (unsigned i = 0; i < instruction->getNumArgOperands(); ++i) {

			// debug string
			std::stringstream debug_out;
			debug_out << func->getName().str() << "\n";

			std::vector<std::any> any_list;

			std::vector<Value*> value_list;
			std::vector<Instruction*> already_visited;
			already_visited.emplace_back(instruction);
			// get argument
			Value* arg = instruction->getArgOperand(i);

			argument_data argument_container;

			// dump argument and check if it was successfull
			if (dumper.dump_argument(debug_out, &argument_container, arg, &already_visited)) {

				// dump was successfull
				if (argument_container.any_list.size() > 1)
					argument_container.multiple = true;

				// argument container lists shall not have different sizes
				if (argument_container.any_list.size() != argument_container.value_list.size() ||
				    argument_container.any_list.size() != argument_container.argument_calles_list.size() ||
				    argument_container.argument_calles_list.size() != argument_container.value_list.size()) {

					// error in argument dump
					auto warning = std::make_shared<DumbArgumentWarning>(i, abb);
					warning_list->emplace_back(warning);
				}

				// store the dumped argument in the abb with corresponding llvm type
				arguments.emplace_back(argument_container);

			} else {

				// dump was not successfull
				auto warning = std::make_shared<DumbArgumentWarning>(i, abb);
				warning_list->emplace_back(warning);
			}

			// 		if(abb->get_name() == "BB93"){
			//
			//             std::cerr << debug_out.str() << std::endl;
			//
			//         }
			//
		}

		// check if call has no arguments
		if (arguments.size() == 0) {
			// generate empty argument container, if call has no arguments
			argument_data tmp_arguments;
			arguments.emplace_back(tmp_arguments);
		}

		// store arguments
		call.arguments = arguments;

		assert(call.call_instruction != nullptr);

		abb->set_call(&call);
	}

	void LLVMStep::dump_instruction(OS::shared_abb abb, Function* func, InvokeInst* instruction,
	                                std::vector<shared_warning>* warning_list) {

		// empty call data container
		call_data call;

		// store the name of the called function

		call.call_name = func->getName().str();

		// store the llvm call instruction reference
		call.call_instruction = instruction;

		std::vector<argument_data> arguments;

		// iterate about the arguments of the call
		for (unsigned i = 0; i < instruction->getNumArgOperands(); ++i) {

			// debug string
			std::stringstream debug_out;
			debug_out << func->getName().str() << "\n";

			std::vector<std::any> any_list;

			std::vector<Value*> value_list;
			std::vector<Instruction*> already_visited;
			already_visited.emplace_back(instruction);
			// get argument
			Value* arg = instruction->getArgOperand(i);

			argument_data argument_container;

			// dump argument and check if it was successfull
			if (dumper.dump_argument(debug_out, &argument_container, arg, &already_visited)) {

				// dump was successfull
				if (argument_container.any_list.size() > 1)
					argument_container.multiple = true;

				// argument container lists shall not have different sizes
				if (argument_container.any_list.size() != argument_container.value_list.size() ||
				    argument_container.any_list.size() != argument_container.argument_calles_list.size() ||
				    argument_container.argument_calles_list.size() != argument_container.value_list.size()) {

					// dump was not successfull
					auto warning = std::make_shared<DumbArgumentWarning>(i, abb);
					warning_list->emplace_back(warning);
				}

				// store the dumped argument in the abb with corresponding llvm type
				arguments.emplace_back(argument_container);
			} else {

				// dump was not successfull
				auto warning = std::make_shared<DumbArgumentWarning>(i, abb);
				warning_list->emplace_back(warning);
			}
		}

		// check if call has no arguments
		if (arguments.size() == 0) {
			// generate empty argument container, if call has no arguments
			argument_data tmp_arguments;
			arguments.emplace_back(tmp_arguments);
		}

		// store arguments
		call.arguments = arguments;

		assert(call.call_instruction != nullptr);
		abb->set_call(&call);
	}

} // namespace step
