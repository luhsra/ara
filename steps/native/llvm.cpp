// vim: set noet ts=4 sw=4:

#include "llvm.h"
#include "FreeRTOSinstances.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/TypeFinder.h"
#include "llvm/Pass.h"
#include <cassert>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/Analysis/Loads.h"
#include "llvm/Analysis/MemorySSA.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/TypeFinder.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO.h"

using namespace llvm;

#define PRINT_NAME(x) std::cout << #x << " - " << typeid(x).name() << '\n'

static llvm::LLVMContext context;

bool dump_argument(std::stringstream &debug_out, argument_data *argument_container, Value *arg,
                   std::vector<llvm::Instruction *> *already_visited);

/**
 * @brief get string representation of llvm value
 * @param argument llvm value variable to print
 */
std::string print_argument(llvm::Value *argument) {
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() + "\"\n";
}

/**
 * @brief get string representation of llvm type
 * @param argument llvm::type to print
 */
std::string print_type(llvm::Type *argument) {
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() + "\"\n";
}

/**
 * @brief check and cast any variable to double variable
 * @param any_value reference to the any variable
 * @param double_value reference to the double variable
 */
bool cast_any_to_double(std::any any_value, double &double_value) {
	if (any_value.type().hash_code() == typeid(int).hash_code()) {
		double_value = std::any_cast<long>(any_value);
		return true;
	} else if (any_value.type().hash_code() == typeid(double).hash_code()) {
		double_value = std::any_cast<double>(any_value);
		return true;
	}
	return false;
}

/**
 * @brief check and cast any variable to string variable
 * @param any_value reference to the any variable
 * @param string_value reference to the string variable
 */
bool cast_any_to_string(std::any any_value, std::string &string_value) {
	if (any_value.type().hash_code() == typeid(std::string).hash_code()) {
		string_value = std::any_cast<std::string>(any_value);
		return true;
	}
	return false;
}

/**
 * @brief check if the instruction is just llvm specific
 * @param instr instrucion to analyze
 */
static bool isCallToLLVMIntrinsic(Instruction *inst) {
	if (CallInst *callInst = dyn_cast<CallInst>(inst)) {
		Function *func = callInst->getCalledFunction();
		if (func && func->getName().startswith("llvm.")) {
			return true;
		}
	}
	return false;
}

/**
 * @brief check if the instruction A is before instruction B
 * @param InstA first instruction
 * @param InstB last instruction
 * @param DT dominator tree of the function
 */
bool instruction_before(Instruction *InstA, Instruction *InstB, DominatorTree *DT) {
	DenseMap<BasicBlock *, std::unique_ptr<OrderedBasicBlock>> OBBMap;
	if (InstA->getParent() == InstB->getParent()) {
		BasicBlock *IBB = InstA->getParent();
		auto OBB = OBBMap.find(IBB);
		if (OBB == OBBMap.end())
			OBB = OBBMap.insert({IBB, make_unique<OrderedBasicBlock>(IBB)}).first;
		return OBB->second->dominates(InstA, InstB);
	}

	DomTreeNode *DA = DT->getNode(InstA->getParent());

	DomTreeNode *DB = DT->getNode(InstB->getParent());

	// std::cout << "debug not same parents" <<  DA->getDFSNumIn() << ":" <<  DB->getDFSNumIn() << std::endl;
	return DA->getDFSNumIn() < DB->getDFSNumIn();
}

/**
 * @brief check if seed is in vector
 * @param seed seed to analyze
 * @param vector which contains reference seeds
 */
bool visited(size_t seed, std::vector<size_t> *vector) {
	bool found = false;
	for (unsigned i = 0; i < vector->size(); i++) {
		if (vector->at(i) == seed) {
			found = true;
			break;
		}
	}
	return found;
}

/**
 * @brief load the value of integer of floating point variable
 * @param arg value which is analyzed
 */
int load_index(Value *arg) {

	int index = 0;
	// check if argument is a constant int
	if (ConstantInt *CI = dyn_cast<ConstantInt>(arg)) {

		index = CI->getSExtValue();
	} // check if argument is a constant floating point
	else if (ConstantFP *constant_fp = dyn_cast<ConstantFP>(arg)) {

		index = constant_fp->getValueAPF().convertToDouble();
	}
	return index;
}

/**
 * @brief check if instuction is an pointer to a constant null
 * @param debug_out stringstream which contains the logical history of the argument dump
 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction call
 * history)
 * @param inst get elementptr instruction, which corresponding loaded value should be determined
 * @param already_visited list of all instructions, which were already visited
 * @param arg value which is analyzed
 */
bool check_nullptr(argument_data *argument_container, llvm::Value *arg, std::stringstream &debug_out,
                   std::vector<llvm::Instruction *> *already_visited) {
	bool load_success = false;
	if (ConstantPointerNull *constant_data = dyn_cast<ConstantPointerNull>(arg)) {
		debug_out << "CONSTANTPOINTERNULL" << std::endl;
		std::string tmp = "&$%NULL&$%";
		argument_container->any_list.emplace_back(tmp);
		argument_container->value_list.emplace_back(constant_data);
		argument_container->argument_calles_list.emplace_back(*already_visited);
		load_success = true;
	}
	return load_success;
}

/**
 * @brief function checks if the function is a class method(first argument this) and the type is the same of the class
 * @param function vector reference which contains get element ptr instruction indizes
 * @param type get element ptr instruction, which is compared to the referenced indizes
 */
bool check_function_class_reference_type(llvm::Function *function, llvm::Type *type) {
	if (type == nullptr || function == nullptr)
		return false;

	for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i) {
		if ((*i).getType() == type && (*i).getName().str() == "this") {
			return true;
		} else {
			return false;
		}
	}
	return false;
}

/**
 * @brief check if the reference indizes are equal to the indizes of the transmitted instruction
 * @param reference vector reference which contains get element ptr instruction indizes
 * @param instr get element ptr instruction, which is compared to the referenced indizes
 */
bool check_get_element_ptr_indizes(std::vector<size_t> *reference, llvm::GetElementPtrInst *instr) {
	int counter = 0;
	for (auto i = instr->idx_begin(), ie = instr->idx_end(); i != ie; ++i) {
		int index = -1;
		if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(((*i).get()))) {
			index = CI->getLimitedValue();
		};
		if (index != reference->at(counter))
			return false;
		++counter;
	}
	return true;
}

/**
 * @brief get all store instructions which store values in the specific class attribute variable
 * @param debug_out stringstream which contains the logical history of the argument dump
 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction call
 * history)
 * @param inst get elementptr instruction, which corresponding loaded value should be determined
 * @param already_visited list of all instructions, which were already visited
 * @param indizes indizes to distinguish between the class attribute variables
 */
bool get_class_attribute_value(std::stringstream &debug_out, llvm::Instruction *inst, argument_data *argument_container,
                               std::vector<llvm::Instruction *> *already_visited, std::vector<size_t> *indizes) {
	bool success = true;
	bool flag = false;
	// get module
	llvm::Module *mod = inst->getFunction()->getParent();
	// iterate about the module
	for (auto &function : *mod) {
		// iterate about the arguments of the function
		for (auto i = function.arg_begin(), ie = function.arg_end(); i != ie; ++i) {
			// check if the function is a method of the class
			if ((*i).getType() == inst->getType()) {
				// iterate about the basic blocks of the function
				for (llvm::BasicBlock &bb : function) {
					// iterate about the instructions of the function
					for (llvm::Instruction &instr : bb) {
						// get pointerelement instruction
						if (auto *get_pointer_element =
						        dyn_cast<llvm::GetElementPtrInst>(&instr)) { // U is of type User*
							// check if the get pointer operand instruction is a load instruction
							if (check_function_class_reference_type(instr.getFunction(),
							                                        get_pointer_element->getPointerOperandType()) &&
							    check_get_element_ptr_indizes(indizes, get_pointer_element)) {

								// just allow the Analysis of global variables, which are stored with just
								// two instructions -> one for nullptr initialization and one for storing the value in
								// the global variable
								bool store_flag = false;
								bool nullptr_flag = false;
								for (auto user : get_pointer_element->users()) { // U is of type User*

									// get all users of get pointer element instruction

									if (auto store = dyn_cast<StoreInst>(user)) {
										debug_out << "USERWITHSAMEPOINTERINDIZESSTORE" << std::endl;
										debug_out << print_argument(user) << std::endl;
										flag = true;
										// std::cerr << "user" << std::endl;
										if (!dump_argument(debug_out, argument_container, store->getOperand(0),
										                   already_visited)) {
											success = false;
											break;
										} else {
											if (store_flag == true && nullptr_flag == true) {
												success = false;
												break;
											}
											if (dyn_cast<ConstantPointerNull>(argument_container->value_list.back())) {
												nullptr_flag = true;
												// TODO
											} else {
												store_flag = true;
											}
										}
									}
								}

								// TODO check inital creation of class element
								// check if no store instruction to the class memory address exists
								if (false == success) {
									for (auto user : get_pointer_element->users()) { // U is of type User*
										// get all users of get pointer element instruction
										debug_out << "USERWITHSAMEPOINTERINDIZES-NOSTOREINSTRUCTIONFOUND" << std::endl;
										// debug_out << print_argument(user)<< std::endl;
										if (auto load = dyn_cast<LoadInst>(user)) {
											// flag = true;
											// std::cerr << "user" << std::endl;
											// if(!dump_argument(debug_out,argument_container,
											// store->getOperand(0),already_visited))success = false;
										}
									}
								}
							}
						}
					}
				}
				// function is not a method of the class
			} else
				break;
		}
	}
	if (!flag)
		return false;
	else
		return success;
}

/**
 * @brief dumpt the value of the GetElementPtrInst with corresponding indizes (important for class values)
 * @param debug_out stringstream which contains the logical history of the argument dump
 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction call
 * history)
 * @param inst get elementptr instruction, which corresponding loaded value should be determined
 * @param already_visited list of all instructions, which were already visited
 */
bool get_element_ptr(std::stringstream &debug_out, llvm::Instruction *inst, argument_data *argument_container,
                     std::vector<llvm::Instruction *> *already_visited) {

	bool success = false;
	// check if this is a element ptr
	if (auto *get_pointer_element = dyn_cast<llvm::GetElementPtrInst>(inst)) { // U is of type User*
		std::vector<size_t> indizes;
		// get indizes of the element ptr
		for (auto i = get_pointer_element->idx_begin(), ie = get_pointer_element->idx_end(); i != ie; ++i) {
			llvm::Value *tmp = ((*i).get());
			if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(tmp)) {
				indizes.emplace_back(CI->getLimitedValue());
			};
		};
		// get operand of the GetElementPtrInst
		if (auto load = dyn_cast<LoadInst>(get_pointer_element->getPointerOperand())) {

			// check if the address is a class specific address
			if (check_function_class_reference_type(inst->getFunction(),
			                                        get_pointer_element->getPointerOperandType())) {

				debug_out << "GETCLASSATTRIBUTE" << std::endl;
				// get store instructions
				success = get_class_attribute_value(debug_out, load, argument_container, already_visited, &indizes);
			}
		};
	}
	return success;
}

/**
 * @brief dump the nearest dominating store instruction of the load instruction to get the loaded value of the load
 * @param debug_out stringstream which contains the logical history of the argument dump
 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction call
 * history)
 * @param inst load instruction, which corresponding loaded value should be determined
 * @param already_visited list of all instructions, which were already visited
 */
bool get_store_instruction(std::stringstream &debug_out, llvm::Instruction *inst, argument_data *argument_container,
                           std::vector<llvm::Instruction *> *already_visited) {

	bool success = false;

	// get control flow information of the function
	llvm::Function &tmp_function = *inst->getFunction();
	DominatorTree dominator_tree = DominatorTree(tmp_function);
	dominator_tree.updateDFSNumbers();

	Triple ModuleTriple(llvm::sys::getDefaultTargetTriple());
	TargetLibraryInfoImpl TLII = TargetLibraryInfoImpl(ModuleTriple);
	TargetLibraryInfo TLI = TargetLibraryInfo(TLII);
	AAResults results = AAResults(TLI);

	// memory walker llvm class
	MemorySSA ssa = MemorySSA(tmp_function, &results, &dominator_tree);
	ssa.verifyMemorySSA();
	MemorySSAWalker *walker = ssa.getWalker();

	MemoryAccess *access = walker->getClobberingMemoryAccess(inst);

	// check if an access of the data structure was successfully
	if (access != nullptr) {
		if (auto def_access = dyn_cast<MemoryDef>(access)) {

			// check if the load and the store instructions addresses the same memory
			// TODO memory walke class seems sometimes to return no valid results
			if (StoreInst *store_inst = dyn_cast<StoreInst>(def_access->getMemoryInst())) {
				if (store_inst->getOperand(1) == inst->getOperand(0))
					success = dump_argument(debug_out, argument_container, store_inst->getOperand(0), already_visited);
			}
		}
	}

	bool pointer_flag = true;
	llvm::Instruction *store_inst = nullptr;

	// check if memory walker class does not return a acceptable load instruction
	if (success == false) {

		// get the nearest dominating store instruction of the load instruction
		if (AllocaInst *alloca_instruction = dyn_cast<AllocaInst>(inst->getOperand(0))) {
			Value::user_iterator sUse = alloca_instruction->user_begin();
			Value::user_iterator sEnd = alloca_instruction->user_end();

			// iterate about the user of the allocation
			for (; sUse != sEnd; ++sUse) {

				// check if instruction is a store instruction
				if (StoreInst *tmp_instruction = dyn_cast<StoreInst>(*sUse)) {

					// check if the instruction are in the same function
					if (tmp_instruction->getFunction() != inst->getFunction())
						continue;

					// check if user is before of the original call
					if (instruction_before(tmp_instruction, inst, &dominator_tree)) {
						pointer_flag = false;
						// check if the store instruction is before the original call
						if (dominator_tree.dominates(tmp_instruction, inst)) {
							if (store_inst == nullptr) {
								store_inst = tmp_instruction;
							} else {
								// check if the tmp_store instruction is behind the store_instruction
								if (instruction_before(store_inst, tmp_instruction, &dominator_tree))
									store_inst = tmp_instruction;
							}
						} else {
							// check if the tmp_instruction is behind the store_instruction

							if (store_inst == nullptr)
								continue;
							if (tmp_instruction == nullptr)
								continue;

							if (instruction_before(store_inst, tmp_instruction, &dominator_tree))
								store_inst = nullptr;
						}
					}

				} else {
					
					// std::cout << "local variable was set after value" << std::endl;
				}
				// no load between allocation and call reference
			}
			// check if a valid store instruction could be found
			if (store_inst != nullptr) {
				success = dump_argument(debug_out, argument_container, store_inst->getOperand(0), already_visited);
			}
		}
	}
	return success;
}

/**
 * @brief dump all call instructions, which calls the function or have the function as argument
 * @param debug_out stringstream which contains the logical history of the argument dump
 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction call
 * history)
 * @param function llvm function of the arg
 * @param already_visited list of all instructions, which were already visited
 * @param arg_counter index of the value in call instruction of calling function
 */
bool load_function_argument(std::stringstream &debug_out, argument_data *argument_container, Function *function,
                            std::vector<llvm::Instruction *> *already_visited, int arg_counter) {

	auto sUse = function->user_begin();
	auto sEnd = function->user_end();

	bool success = true;
	// iterate about the user of the allocation
	for (; sUse != sEnd; ++sUse) {

		// check if instruction is a store instruction
		if (Instruction *instr = dyn_cast<Instruction>(*sUse)) {
			bool flag = true;
			for (auto *element : *already_visited) {
				if (element == instr) {
					flag = false;
					break;
				}
			}

			// instruction was already visited
			if (!flag)
				continue;

			std::vector<llvm::Instruction *> tmp_already_visited = *already_visited;

			// check if instruction is a call instruction
			if (isa<CallInst>(instr)) {
				// check if the call instruction calls the function
				if (cast<CallInst>(instr)->getCalledFunction() == function) {
					tmp_already_visited.emplace_back(instr);

					// dump the call instruction
					debug_out << "LOADFUNKTIONARGUMENT " << arg_counter << "\n";
					if (!dump_argument(debug_out, argument_container, instr->getOperand(arg_counter),
					                   &tmp_already_visited))
						success = false;
				} else {

					// function is probably an argument of the call instruction
					int counter = 0;

					// load argument
					for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i) {
						if (arg_counter == counter) {
							debug_out << "ARGUMENT" << i->getName().str() << "\n";
							argument_container->any_list.emplace_back(i->getName().str());
							argument_container->value_list.emplace_back(i);
							argument_container->argument_calles_list.emplace_back(*already_visited);
							success = true;
							break;
						}
						++counter;
					}
				}
			}
		}
	}
	debug_out << "ENDLOADFUNKTIONARGUMENT"
	          << "\n";
	return success;
}

/**
 * @brief load the std::any and llvm value of the global llvm arg
 * @param debug_out stringstream which contains the logical history of the argument dump
 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction call
 * history)
 * @param arg argument which has to be dumped
 * @param prior_arg predecessor of the current arg
 * @param already_visited list of all instructions, which were already visited
 */
bool load_value(std::stringstream &debug_out, argument_data *argument_container, Value *arg, Value *prior_arg,
                std::vector<llvm::Instruction *> *already_visited) {

	// debug data
	debug_out << "ENTRYLOAD"
	          << "\n";

	std::string type_str;
	llvm::raw_string_ostream rso(type_str);

	bool load_success = false;

	// check if arg is a null ptr
	if (check_nullptr(argument_container, arg, debug_out, already_visited)) {
		return true;
	}
	if (GlobalVariable *global_var = dyn_cast<GlobalVariable>(arg)) {

		debug_out << "GLOBALVALUE"
		          << "\n";
		debug_out << print_argument(global_var);

		// check if the global variable has a loadable value
		if (global_var->hasInitializer()) {
			debug_out << "HASINITIALIZER"
			          << "\n";

			if (ConstantData *constant_data = dyn_cast<ConstantData>(global_var->getInitializer())) {
				debug_out << "CONSTANTDATA"
				          << "\n";
				if (ConstantDataSequential *constant_sequential = dyn_cast<ConstantDataSequential>(constant_data)) {
					debug_out << "CONSTANTDATASEQUIENTIAL"
					          << "\n";
					if (ConstantDataArray *constant_array = dyn_cast<ConstantDataArray>(constant_sequential)) {
						debug_out << "CONSTANTDATAARRAY"
						          << "\n";
						// global variable is a constant array
						if (constant_array->isCString()) {
							argument_container->any_list.emplace_back(constant_array->getAsCString().str());
							argument_container->value_list.emplace_back(constant_array);
							argument_container->argument_calles_list.emplace_back(*already_visited);
							load_success = true;
						} else
							debug_out << "Keine konstante sequentielle Date geladen"
							          << "\n";
					}
				} // check if global variable is contant integer
				else if (ConstantInt *constant_int = dyn_cast<ConstantInt>(constant_data)) {
					debug_out << "CONSTANTDATAINT"
					          << "\n";

					argument_container->any_list.emplace_back(constant_int->getSExtValue());
					argument_container->value_list.emplace_back(constant_int);
					argument_container->argument_calles_list.emplace_back(*already_visited);
					load_success = true;

				} // check if global variable is contant floating point
				else if (ConstantFP *constant_fp = dyn_cast<ConstantFP>(constant_data)) {
					debug_out << "CONSTANTDATAFLOATING"
					          << "\n";

					argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble());
					argument_container->value_list.emplace_back(constant_fp);
					argument_container->argument_calles_list.emplace_back(*already_visited);
					load_success = true;
				} // check if global variable is contant null pointer
				else if (ConstantPointerNull *null_ptr = dyn_cast<ConstantPointerNull>(constant_data)) {
					debug_out << "CONSTANTPOINTERNULL"
					          << "\n";
					// print name of null pointer because there is no other content
					if (global_var->hasName()) {
						argument_container->any_list.emplace_back(global_var->getName().str());
						argument_container->value_list.emplace_back(global_var);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;

					} else {
						debug_out << "Globaler Null Ptr hat keinen Namen"
						          << "\n";
					}
				} else {
					argument_container->any_list.emplace_back(global_var->getName().str());
					argument_container->value_list.emplace_back(global_var);
					argument_container->argument_calles_list.emplace_back(*already_visited);
					load_success = true;
					debug_out << "CONSTANTUNDEF/TOKENNONE"
					          << "\n";
				}
				// check if global varialbe is a constant expression
			} else if (ConstantExpr *constant_expr = dyn_cast<ConstantExpr>(global_var->getInitializer())) {
				debug_out << "CONSTANTEXPRESSION"
				          << "\n";
				// check if value is from type value
				if (Value *tmp_arg = dyn_cast<Value>(constant_expr)) {
					// get the value
					load_success = dump_argument(debug_out, argument_container, tmp_arg, already_visited);
				}

				// check if global variable is from type constant aggregate
			} else if (ConstantAggregate *constant_aggregate =
			               dyn_cast<ConstantAggregate>(global_var->getInitializer())) {
				// check if global variable is from type constant array
				debug_out << "CONSTANTAGGREGATE"
				          << "\n";
				if (ConstantArray *constant_array = dyn_cast<ConstantArray>(constant_aggregate)) {

					if (User *user = dyn_cast<User>(prior_arg)) {

						Value *N = user->getOperand(2);
						// Value * M =user->getOperand(3);
						// TODO make laoding of array indizes more generel
						int index_n = load_index(N);
						// int index_m =load_index(N);
						debug_out << "\n" << index_n << "\n";

						// constant_array->getOperand(index_n)->print(rso);
						Value *aggregate_operand = constant_array->getOperand(index_n);

						load_success = dump_argument(debug_out, argument_container, aggregate_operand, already_visited);
					}

				} // check if global variable is from type constant struct
				else if (ConstantStruct *constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)) {
					debug_out << "Constant Struct";
				} // check if global variable is from type constant vector
				else if (ConstantVector *constant_vector = dyn_cast<ConstantVector>(constant_aggregate)) {
					debug_out << "Constant Vector";
				}
			} else {
				debug_out << "GLOBALVALUE"
				          << "\n";
			}

		} else {
			// check if the global variable has a name
			if (global_var->hasName()) {
				// save the name
				argument_container->any_list.emplace_back(global_var->getName().str());
				argument_container->value_list.emplace_back(global_var);
				argument_container->argument_calles_list.emplace_back(*already_visited);
				load_success = true;
			} else
				debug_out << "Nicht ladbare globale Variable hat keinen Namen";
		}

	} else {

		if (ConstantAggregate *constant_aggregate = dyn_cast<ConstantAggregate>(arg)) {
			debug_out << "CONSTANTAGGREGATE";
			// check if global variable is from type constant array
			if (ConstantArray *constant_array = dyn_cast<ConstantArray>(constant_aggregate)) {
				debug_out << "Constant Array";

			} // check if global variable is from type constant struct
			else if (ConstantStruct *constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)) {
				debug_out << "Constant Struct";

				Constant *content = constant_struct->getAggregateElement(0u);

				for (unsigned int i = 1; content != nullptr; i++) {

					if (ConstantInt *CI = dyn_cast<ConstantInt>(content)) {
						debug_out << "CONSTANT INT"
						          << "\n";

						argument_container->any_list.emplace_back(CI->getSExtValue());
						argument_container->value_list.emplace_back(CI);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;
					} // check if argument is a constant floating point
					else if (ConstantFP *constant_fp = dyn_cast<ConstantFP>(content)) {
						debug_out << "CONSTANT FP"
						          << "\n";

						argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble());
						argument_container->value_list.emplace_back(constant_fp);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;
					}
					content = constant_struct->getAggregateElement(i);
				}

			} // check if global variable is from type constant vector
			else if (ConstantVector *constant_vector = dyn_cast<ConstantVector>(constant_aggregate)) {
				debug_out << "Constant Vector";
			}
		}
	}

	debug_out << "EXITLOAD: " << load_success << "\n";
	return load_success;
}

/**
 * @brief set all possbile argument values and corresponding call history in a data structure. This
 * data structure is then stored in the abb.
 * @param debug_out stringstream which contains the logical history of the argument dump
 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction call
 * history)
 * @param arg argument which has to be dumped
 * @param already_visited list of all instructions, which were already visited
 */
bool dump_argument(std::stringstream &debug_out, argument_data *argument_container, Value *arg,
                   std::vector<Instruction *> *already_visited) {

	if (arg == nullptr)
		return false;

	// check if the value is an argument of the function
	if (Argument *argument = dyn_cast<Argument>(arg)) {
		return load_function_argument(debug_out, argument_container, argument->getParent(), already_visited,
		                              argument->getArgNo());
	}

	// check generell if arg is one of the arguments
	if (Instruction *instr = dyn_cast<Instruction>(arg)) {
		llvm::Function *function = already_visited->back()->getParent()->getParent();

		int arg_counter = 0;
		for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i) {
			auto sUse = (*i).user_begin();
			auto sEnd = (*i).user_end();

			// iterate about the user of the allocation
			for (; sUse != sEnd; ++sUse) {

				if (StoreInst *store = dyn_cast<StoreInst>(*sUse)) {
					// std::cerr << "store" << print_argument(store);
					if (store->getOperand(0) == &(*i) && store->getOperand(1) == instr->getOperand(0))
						return load_function_argument(debug_out, argument_container, function, already_visited,
						                              arg_counter);
				}
			}
			++arg_counter;
		}
	}

	debug_out << "ENTRYDUMP"
	          << "\n";
	bool dump_success = false;

	Type *Ty = arg->getType();

	// check if argument is an instruction
	if (Instruction *instr = dyn_cast<Instruction>(arg)) {
		debug_out << "INSTRUCTION"
		          << "\n";
		// check if argument is a load instruction
		if (LoadInst *load = dyn_cast<LoadInst>(instr)) {
			debug_out << "LOAD INSTRUCTION"
			          << "\n";
			// check if argument is a global variable
			if (GlobalVariable *global_var = dyn_cast<GlobalVariable>(load->getOperand(0))) {
				debug_out << "LOAD GLOBAL"
				          << "\n";
				// load the global information
				dump_success = load_value(debug_out, argument_container, load->getOperand(0), arg, already_visited);
			} else if (instr->getNumOperands() == 1) {
				debug_out << "ONEOPERAND"
				          << "\n";

				if (isa<AllocaInst>(load->getOperand(0))) {
					debug_out << "ALLOCAINSTRUCTIONLOAD"
					          << "\n";
					dump_success = get_store_instruction(debug_out, load, argument_container, already_visited);
				} else
					dump_success = dump_argument(debug_out, argument_container, load->getOperand(0), already_visited);
			}
			// check if instruction is an alloca instruction
		} else if (AllocaInst *alloca = dyn_cast<AllocaInst>(instr)) {
			debug_out << "ALLOCA INSTRUCTION"
			          << "\n";
			if (alloca->hasName()) {
				// dump_success = get_store_instruction(debug_out,alloca,any_list,value_list,already_visited );
				argument_container->any_list.emplace_back(alloca->getName().str());
				argument_container->value_list.emplace_back(alloca);
				argument_container->argument_calles_list.emplace_back(*already_visited);
				dump_success = true;
			} else {
				// return type of allocated space/*
				std::string type_str;
				llvm::raw_string_ostream rso(type_str);
				alloca->getType()->print(rso);
				argument_container->any_list.emplace_back(rso.str());
				argument_container->value_list.emplace_back(alloca);
				argument_container->argument_calles_list.emplace_back(*already_visited);
				dump_success = true;
			}
		} else if (CastInst *cast = dyn_cast<CastInst>(instr)) {
			debug_out << "CAST INSTRUCTION"
			          << "\n";
			dump_success = dump_argument(debug_out, argument_container, cast->getOperand(0), already_visited);
			debug_out << print_argument(cast);

		} else if (StoreInst *store = dyn_cast<StoreInst>(instr)) {
			debug_out << "STORE INSTRUCTION"
			          << "\n";
			dump_success = load_value(debug_out, argument_container, store->getOperand(0), arg, already_visited);
			debug_out << print_argument(store);
		
        }else if(auto *geptr  = dyn_cast<llvm::GetElementPtrInst>(instr)){
            debug_out << "ELEMENTPTRINST INSTRUCTION" << "\n";
            debug_out << print_argument(geptr);
            dump_success  = get_element_ptr(debug_out,geptr, argument_container, already_visited);
        }else if(auto *call  = dyn_cast<llvm::CallInst>(instr)){
            debug_out << "CALLINSTRUCTION" << "\n";
            debug_out << print_argument(call);
            
            for(auto user : call->users()){  // U is of type User*
                //get all users of get pointer element instruction
                if (auto store = dyn_cast<StoreInst>(user)){
                    if(store->getOperand(0) == call){
                        if(auto *geptr  = dyn_cast<llvm::GetElementPtrInst>(store->getOperand(1))){
                            debug_out << print_type(geptr->getSourceElementType()) << "\n";
                            if(check_function_class_reference_type(geptr->getFunction(), geptr->getOperand(0)->getType())){
                                debug_out << "CLASSTYPE" << "\n";
                                argument_container->any_list.emplace_back(geptr->getName().str());
                                argument_container->value_list.emplace_back(geptr);
                                argument_container->argument_calles_list.emplace_back(*already_visited);
                                dump_success = true;
                            }
                        }
                    }
                }
            }
        }
        else if (BinaryOperator *binop = dyn_cast<BinaryOperator>(arg)) {

            argument_data operand_0;
            argument_data operand_1;
            //std::cerr << print_argument(binop) << std::endl;
            
            
            std::any value;
            if(dump_argument(debug_out,&operand_0,binop->getOperand(0), already_visited) && dump_argument(debug_out,&operand_1,binop->getOperand(1), already_visited)){
                
                
                
                
                if (binop->getOpcode() == Instruction::BinaryOps::Or) {
                    double value_0;
                    double value_1;
                    
                    
                    std::string string_value_0;
                    std::string string_value_1;
                    
                    //std::cerr << print_argument(binop) << std::endl;
                    if(!operand_0.multiple && !operand_1.multiple && !operand_0.any_list.empty() && !operand_1.any_list.empty()){

                        if(typeid(long).hash_code() == operand_0.any_list.front().type().hash_code() && typeid(long).hash_code() == operand_0.any_list.front().type().hash_code()){
                            
                            if(cast_any_to_double(operand_0.any_list.front(), value_0) &&  cast_any_to_double(operand_1.any_list.front(), value_1)){
                                dump_success = true;
                                value = (long)value_0 | (long)value_1;
                                argument_container->any_list.emplace_back(value);
                            }
                        }else if(typeid(std::string).hash_code() == operand_0.any_list.front().type().hash_code() && typeid(std::string).hash_code() == operand_0.any_list.front().type().hash_code()){
                            
                            if(cast_any_to_string(operand_0.any_list.front(), string_value_0) &&  cast_any_to_string(operand_1.any_list.front(), string_value_1)){
                                dump_success = true;
                                value = (std::string)string_value_0 + "(OR)" + (std::string)string_value_1;
                                
                                //std::cerr <<  (std::string)string_value_0 <<"(OR)"<< (std::string)string_value_1 << std::endl;
                                argument_container->any_list.emplace_back(value);
                            }
                            
                        }
                    }
                
                }
//                 else if (binop->getOpcode() == Instruction::BinaryOps::Add){
//                     double value_0;
//                     double value_1;
//                     if(!operand_0.multiple && !operand_1.multiple){
//                         if(cast_any_to_double(operand_0.any_list.front(), value_0) &&  cast_any_to_double(operand_1.any_list.front(), value_1)){
//                             dump_success = true;
//                             value = value_0 + value_1;
//                             argument_container->any_list.emplace_back(value);
//                         }
//                     }
//                 }else if (binop->getOpcode() == Instruction::BinaryOps::Mul){
//                     double value_0;
//                     double value_1;
//                     if(!operand_0.multiple && !operand_1.multiple){
//                         if(cast_any_to_double(operand_0.any_list.front(), value_0) &&  cast_any_to_double(operand_1.any_list.front(), value_1)){
//                             dump_success = true;
//                             value = value_0 * value_1;
//                             argument_container->any_list.emplace_back(value);
//                         }
//                     }
//                         
//                 }else if (binop->getOpcode() == Instruction::BinaryOps::Sub){
//                                 double value_0;
//                     double value_1;
//                     if(!operand_0.multiple && !operand_1.multiple){
//                         if(cast_any_to_double(operand_0.any_list.front(), value_0) &&  cast_any_to_double(operand_1.any_list.front(), value_1)){
//                             dump_success = true;
//                             value = value_0 - value_1;
//                             argument_container->any_list.emplace_back(value);
//                         }
//                     }
//                 }else if (binop->getOpcode() == Instruction::BinaryOps::UDiv){
//                     double value_0;
//                     double value_1;
//                     if(!operand_0.multiple && !operand_1.multiple){
//                         if(cast_any_to_double(operand_0.any_list.front(), value_0) &&  cast_any_to_double(operand_1.any_list.front(), value_1)){
//                             dump_success = true;
//                             value = value_0 /value_1;
//                             argument_container->any_list.emplace_back(value);
//                         }
//                     }
//                 }
            }
            argument_container->value_list.emplace_back(binop);
            argument_container->argument_calles_list.emplace_back(*already_visited);
            
        }
    }//check if argument is a constant integer
    else if (ConstantInt * CI = dyn_cast<ConstantInt>(arg)) {
        debug_out << "CONSTANT INT" << "\n";
        argument_container->any_list.emplace_back(CI->getSExtValue());
        argument_container->value_list.emplace_back(CI);
        argument_container->argument_calles_list.emplace_back(*already_visited);
        dump_success = true;
    }//check if argument is a constant floating point
    else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(arg)){
        debug_out << "CONSTANT FP" << "\n";
        argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble ());
        argument_container->value_list.emplace_back(constant_fp);
        argument_container->argument_calles_list.emplace_back(*already_visited);
        dump_success = true;
        
    }//check if argument is a pointer
    else if (PointerType * PT = dyn_cast<PointerType>(Ty)) {       
        debug_out << "POINTER" << "\n";
        Type* elementType = PT->getElementType();
		//check if arg is a null ptr
		if(check_nullptr(argument_container,arg,debug_out,already_visited)){

			return true;
		}
		// check if pointer points to function
		if (FunctionType *FT = dyn_cast<FunctionType>(elementType)) { // check pointer to function
			// check if argument has a name
			if (arg->hasName()) {
				debug_out << "POINTER TO FUNCTION"
				          << "\n";
				argument_container->any_list.emplace_back(arg->getName().str());
				argument_container->value_list.emplace_back(arg);
				argument_container->argument_calles_list.emplace_back(*already_visited);
				dump_success = true;
			}
		} // check if pointer points to pointer
		else if (PT->getContainedType(0)->isPointerTy()) {

			debug_out << "POINTER TO POINTER"
			          << "\n";

			// load the global information
			dump_success = load_value(debug_out, argument_container, arg, arg, already_visited);

		} // check if value is a constant value
		else if (GlobalVariable *global_var = dyn_cast<GlobalVariable>(arg)) {
			debug_out << "POINTER TO GLOBAL"
			          << "\n";
			dump_success = load_value(debug_out, argument_container, arg, arg, already_visited);

		} else if (Constant *constant = dyn_cast<ConstantExpr>(arg)) { // check if value is a constant value
			// check if the constant value is global global variable
			if (GlobalVariable *global_var = dyn_cast<GlobalVariable>(constant->getOperand(0))) {
				debug_out << "POINTER TO CONSTANT GLOBAL"
				          << "\n";
				dump_success = load_value(debug_out, argument_container, constant->getOperand(0), arg, already_visited);
			}

		} else {

			// TODO
			debug_out << print_argument(arg);
		}
	} else {
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		arg->getType()->print(rso);
		debug_out << rso.str() << "\n";

		dump_success = load_value(debug_out, argument_container, arg, arg, already_visited);
		if (!dump_success)
			debug_out << "Kein Load/Instruction/Pointer"
			          << "\n";
	}

	if (!dump_success) {
		std::string arg_name = arg->getName().str();

		if (arg_name.length() > 0) {
			debug_out << "DEFAULTNAME"
			          << "\n";
			debug_out << print_argument(arg) << std::endl;
			argument_container->any_list.emplace_back(arg_name);
			argument_container->value_list.emplace_back(arg);
			argument_container->argument_calles_list.emplace_back(*already_visited);
			dump_success = true;
		}
	}
	debug_out << "EXITDUMP: " << dump_success << "\n";
	return dump_success;
}

/**
 * function exists twice, one for invoke, one for call instructions->the call instruction parent class of both
 * instructions could not use ?!
 * @brief set all possbile argument std::any and llvm values of the abb call in a data structure. This
 * data structure is then stored in each abb for each call.
 * @param abb abb, which contains the call
 * @param func llvm function, of the call instruction
 * @param instruction call instruction, which is analyzed
 * @param warning_list list to store warning
 */
void dump_instruction(OS::shared_abb abb,llvm::Function * func , llvm::CallInst  * instruction,std::vector<shared_warning>* warning_list){
    
    //empty call data container
    call_data call;
    
	//store the name of the called function

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

		std::vector<llvm::Value *> value_list;
		std::vector<llvm::Instruction *> already_visited;
		already_visited.emplace_back(instruction);
		// get argument
		Value *arg = instruction->getArgOperand(i);

		
        
        argument_data argument_container;
    
		//dump argument and check if it was successfull
		if(dump_argument(debug_out,&argument_container, arg,&already_visited)){
            
            //dump was successfull
            if(argument_container.any_list.size() > 1)argument_container.multiple = true;
            
            //argument container lists shall not have different sizes
            if(argument_container.any_list.size() != argument_container.value_list.size() || argument_container.any_list.size() != argument_container.argument_calles_list.size() || argument_container.argument_calles_list.size() != argument_container.value_list.size()){
                
                //error in argument dump
                auto warning = std::make_shared<DumbArgumentWarning>(i, abb);
                warning_list->emplace_back(warning);
            }
            
			//store the dumped argument in the abb with corresponding llvm type
			arguments.emplace_back(argument_container);
            
    
		}else{
			
            //dump was not successfull
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

/**
 * @brief set all possbile argument std::any and llvm values of the abb call in a data structure. This
 * data structure is then stored in each abb for each call.
 * @param abb abb, which contains the call
 * @param func llvm function, of the call instruction
 * @param instruction call instruction, which is analyzed
 * @param warning_list list to store warning
 */
void dump_instruction(OS::shared_abb abb,llvm::Function * func , llvm::InvokeInst  * instruction,std::vector<shared_warning>* warning_list){
    
    //empty call data container
    call_data call;
    
	//store the name of the called function

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

		std::vector<llvm::Value *> value_list;
		std::vector<llvm::Instruction *> already_visited;
		already_visited.emplace_back(instruction);
		// get argument
		Value *arg = instruction->getArgOperand(i);

		
        
        argument_data argument_container;
    
		//dump argument and check if it was successfull
		if(dump_argument(debug_out,&argument_container, arg,&already_visited)){
            
            //dump was successfull
            if(argument_container.any_list.size() > 1)argument_container.multiple = true;
            
            //argument container lists shall not have different sizes
            if(argument_container.any_list.size() != argument_container.value_list.size() || argument_container.any_list.size() != argument_container.argument_calles_list.size() || argument_container.argument_calles_list.size() != argument_container.value_list.size()){
                
               //dump was not successfull
                auto warning = std::make_shared<DumbArgumentWarning>(i, abb);
                warning_list->emplace_back(warning);
            }
            
			//store the dumped argument in the abb with corresponding llvm type
			arguments.emplace_back(argument_container);
		}else{
			
            //dump was not successfull
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

/**
 * @brief set the arguments std::any and llvm values of the abb
 * @param abb abb, which should be analyzed
 * @param warning_list list to store warning
 */
void set_arguments(OS::shared_abb abb,std::vector<shared_warning>* warning_list){


	int bb_count = 0;

	// iterate about the basic blocks of the abb
	for (auto &bb : *abb->get_BasicBlocks()) {

		int call_count = 0;
		++bb_count;

		// call found flag
		bool call_found = false;

		// iterate about the instructions of the bb
		for (auto &inst : *bb) {
			// check if instruction is a call instruction
			if (isa<CallInst>(inst)) {
				CallInst *call = (CallInst *)&inst;
				Function *func = call->getCalledFunction();
				if (func && !isCallToLLVMIntrinsic(call)) {
					call_found = true;
                    
					//get and store the called arguments values
					dump_instruction(abb,func , call,warning_list);

					++call_count;
				}
			} else if (InvokeInst *invoke = dyn_cast<InvokeInst>(&inst)) {
				Function *func = invoke->getCalledFunction();

				if (func == nullptr) {
					auto tmp_value = invoke->getCalledValue();
					if (llvm::Constant *constant = dyn_cast<llvm::Constant>(tmp_value)) {
						if (llvm::Function *tmp_func = dyn_cast<llvm::Function>(constant->getOperand(0))) {
							func = tmp_func;
						}
					}
				}

				if (func && !isCallToLLVMIntrinsic(invoke)) {
					call_found = true;

					//get and store the called arguments values
					dump_instruction(abb,func , invoke,warning_list);

					++call_count;
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

/**
 * @brief  generates all abbs of the transmitted graph function. All abbs are conntected with the
 * CFG predecessors and successors
 * @param graph project data structure
 * @param function graph function, which contains the llvm function reference
 * @param warning_list list to store warning
 */

void abb_generation(graph::Graph *graph, OS::shared_function function , std::vector<shared_warning>* warning_list) {

	llvm::Function *llvm_reference_function = function->get_llvm_reference();

	// create ABB
	auto abb = std::make_shared<OS::ABB>(graph, function, llvm_reference_function->front().getName());

	// store coresponding basic block in ABB
	abb->set_BasicBlock(&(llvm_reference_function->getEntryBlock()));
	abb->set_exit_bb(&(llvm_reference_function->getEntryBlock()));
	abb->set_entry_bb(&(llvm_reference_function->getEntryBlock()));

	function->set_atomic_basic_block(abb);

	// queue for new created ABBs
	std::deque<OS::shared_abb> queue;

	// store abb in graph
	graph->set_vertex(abb);

    
    set_arguments(abb,warning_list);
	
    queue.push_back(abb);

    //queue with information, which abbs were already analyzed
    std::vector<size_t> visited_abbs;
	
	//store the first abb as front abb of the function

	function->set_entry_abb(queue.front());

	// iterate about the ABB queue
	while (!queue.empty()) {

		// get first element of the queue
		OS::shared_abb old_abb = queue.front();
		queue.pop_front();

		// iterate about the successors of the ABB
		std::list<llvm::BasicBlock *>::iterator it;

		// iterate about the basic block of the abb
		for (llvm::BasicBlock *bb : *old_abb->get_BasicBlocks()) {

			// iterate about the successors of the abb
			for (auto it = succ_begin(bb); it != succ_end(bb); ++it) {

				// get sucessor basicblock reference
				llvm::BasicBlock *succ = *it;

				// create temporary basic block
				auto new_abb = std::make_shared<OS::ABB>(graph, function, succ->getName());

				// check if the successor abb is already stored in the list
				if (!visited(new_abb->get_seed(), &visited_abbs)) {
					if (succ->getName().str().empty()) {
						std::cerr << "ERROR: basic block has no name" << '\n';
						std::cerr << print_argument(succ) << '\n';
						abort();
					} else {
						for (auto &tmp_bb : *llvm_reference_function) {
							if (succ->getName().str() == tmp_bb.getName().str()) {
								succ = &tmp_bb;
								break;
							}
						}
					}
					// store new abb in graph
					graph->set_vertex(new_abb);

					function->set_atomic_basic_block(new_abb);

					// set abb predecessor reference and bb reference
					new_abb->set_BasicBlock(succ);
					new_abb->set_exit_bb(succ);
					new_abb->set_entry_bb(succ);

					new_abb->set_ABB_predecessor(old_abb);

					// set successor reference of old abb
					old_abb->set_ABB_successor(new_abb);

					// update the lists
					queue.push_back(new_abb);

					visited_abbs.push_back(new_abb->get_seed());

					//set the abb call`s argument values and types
					set_arguments(new_abb,warning_list);
					
                }else{
					
                    //get the alread existing abb from the graph

					std::shared_ptr<graph::Vertex> vertex = graph->get_vertex(new_abb->get_seed());
					std::shared_ptr<OS::ABB> existing_abb = std::dynamic_pointer_cast<OS::ABB>(vertex);

					// connect the abbs via reference
					existing_abb->set_ABB_predecessor(old_abb);
					old_abb->set_ABB_successor(existing_abb);
				}
			}
		}
	}
}

/**
 * @brief splits all bbs of the transmitted function, so that there is just on call in each bb
 * @param function llvm function which is analyzed
 * @param split_counter counter, whichs stores the number of splitted bbs
 */
void split_basicblocks(llvm::Function &function, unsigned &split_counter) {
	// store the basic blocks in a list
	std::list<llvm::BasicBlock *> bbs;
	for (llvm::BasicBlock &bb : function) {
		bbs.push_back(&bb);
	}
	// iterate about the basic blocks
	for (llvm::BasicBlock *bb : bbs) {

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

/**
 * @brief loads the .ll file and returns the parsed llvm module
 * @param FN path to the .ll file
 * @param Context llvm module context
 * @return unique module pointer of the parsed .ll file
 */
std::unique_ptr<Module> LoadFile(const std::string &FN, LLVMContext &Context) {
	SMDiagnostic Err;
	// if (Verbose) errs() << "Loading '" << FN << "'\n";

	std::unique_ptr<Module> Result = 0;
	Result = parseIRFile(FN, Err, Context);
	if (Result)
		return Result;

	// Err.print(argv0, errs());
	return NULL;
}

/**
 * @brief connect each abb and function which the called function by inserting a edge in the graph
 * @param graph project data structure
 */

void set_called_functions(graph::Graph &graph) {

	// set called function for each abb
	std::list<graph::shared_vertex> vertex_list = graph.get_type_vertices(typeid(OS::ABB).hash_code());
	for (auto &vertex : vertex_list) {

		// cast vertex to abb
		auto abb = std::dynamic_pointer_cast<OS::ABB>(vertex);

		if (abb->get_call_type() != has_call)
			continue;
		// get call instr of the abb
		auto *instr = abb->get_call_instruction_reference();

		if (CallInst *call = dyn_cast<CallInst>((instr))) {

			llvm::Function *llvm_function = call->getCalledFunction();
			std::hash<std::string> hash_fn;
			// get function which is addressed by call
			graph::shared_vertex vertex =
			    graph.get_vertex(hash_fn(llvm_function->getName().str() + typeid(OS::Function).name()));
			if (vertex != nullptr) {

				if (vertex->get_name() == "_ZN12GPSDataModelC2Ev")
					std::cerr << "ERROR" << print_argument(call) << std::endl;

				auto function = std::dynamic_pointer_cast<OS::Function>(vertex);
				abb->set_called_function(function, instr);
				abb->get_parent_function()->set_called_function(function, abb);
			}
		} else if (InvokeInst *invoke = dyn_cast<InvokeInst>((instr))) {

			llvm::Function *llvm_function = invoke->getCalledFunction();
			std::hash<std::string> hash_fn;

			if (llvm_function == nullptr) {
				auto tmp_value = invoke->getCalledValue();
				if (llvm::Constant *constant = dyn_cast<llvm::Constant>(tmp_value)) {
					if (llvm::Function *tmp_func = dyn_cast<llvm::Function>(constant->getOperand(0))) {
						llvm_function = tmp_func;
					}
				}
			}
			graph::shared_vertex vertex =
			    graph.get_vertex(hash_fn(llvm_function->getName().str() + typeid(OS::Function).name()));
			if (vertex != nullptr) {
				// std::cout << "success" <<  vertex->get_name() << std::endl;

				if (vertex->get_name() == "_ZN12GPSDataModelC2Ev")
					std::cerr << "ERROR" << print_argument(invoke) << std::endl;

				auto function = std::dynamic_pointer_cast<OS::Function>(vertex);
				abb->set_called_function(function, instr);

				abb->get_parent_function()->set_called_function(function, abb);
			}
		}
	}
}

/**
 * @brief detects and set for each function in the graph an exit abb
 * @param graph project data structure
 * @param split_counter counter of all yet splitted bbs
 */
void set_exit_abb(graph::Graph &graph, unsigned int &split_counter) {

	// set an exit abb for each function
	auto vertex_list = graph.get_type_vertices(typeid(OS::Function).hash_code());
	for (auto &vertex : vertex_list) {

		// cast vertex to abb
		auto function = std::dynamic_pointer_cast<OS::Function>(vertex);

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

namespace step {

	std::string LLVMStep::get_description() {

		return "Extracts initial objects out of the ll-files.\n"
		       "Initializes all functions and unmerged ABBs. Also tries to extract all arguments out of function "
		       "calls.";
	}

        
	/**
	 * @brief the run method of the llvm pass. This pass linkes all .ll files and collects all application raw
	 * information (functions and their containing abbs) and store them in the graph data structure. Also
	 * @param graph project data structure
	 */
	void LLVMStep::run(graph::Graph &graph) {

        std::vector<shared_warning>* warning_list = &(this->warnings);
          
		// get file arguments from config
		std::vector<std::string> files;
		PyObject *input_files = PyDict_GetItemString(config, "input_files");
		assert(input_files != nullptr && PyList_Check(input_files));
		for (Py_ssize_t i = 0; i < PyList_Size(input_files); ++i) {
			PyObject *elem = PyList_GetItem(input_files, i);
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

		// resolve link errors
		for (unsigned i = 1; i < files.size(); ++i) {
			auto M = LoadFile(files.at(i), context);
			if (M.get() == 0) {
				std::cerr << "error loading file '" << files.at(i) << "'\n";
				abort();
			}

			for (auto it = M->global_begin(); it != M->global_end(); ++it) {
				GlobalVariable &gv = *it;
				if (!gv.isDeclaration())
					gv.setLinkage(GlobalValue::LinkOnceAnyLinkage);
			}

			for (auto it = M->alias_begin(); it != M->alias_end(); ++it) {
				GlobalAlias &ga = *it;
				if (!ga.isDeclaration())
					ga.setLinkage(GlobalValue::LinkOnceAnyLinkage);
			}

			// set linkage information of all functions
			for (auto &F : *M) {
				StringRef Name = F.getName();
				// leave library functions alone because their presence or absence
				// could affect the behaviour of other passes
				if (F.isDeclaration())
					continue;
				F.setLinkage(GlobalValue::WeakAnyLinkage);
			}

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

		for (auto &func : *shared_module) {

			// check if llvm function has definition
			if (!func.empty()) {

				auto graph_function = std::make_shared<OS::Function>(&graph, func.getName().str());

				// extract arguments
				llvm::FunctionType *argList = func.getFunctionType();
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
				for (auto &bb : func) {

					// name all basic blocks
					if (!bb.getName().startswith("BB")) {
						std::stringstream ss;
						ss << "BB" << split_counter++;
						bb.setName(ss.str());
					}
				}
				// store the generated function in the graph datastructure
				graph.set_vertex(graph_function);

				
				//generate and store the abbs of the function in the graph datatstructure
				abb_generation(&graph, graph_function,warning_list );

			}
		}
		// connect the abbs and functions with the called function
		set_called_functions(graph);

		// detect and set for each function one exit abb
		set_exit_abb(graph, split_counter);
	}

	std::vector<std::string> LLVMStep::get_dependencies() { return {}; }
} // namespace step
