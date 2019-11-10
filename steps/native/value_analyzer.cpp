#include "value_analyzer.h"

#include "common/exceptions.h"
#include "common/llvm_common.h"

#include <llvm/Analysis/AliasAnalysis.h>
#include <llvm/Analysis/MemorySSA.h>
#include <llvm/Analysis/OrderedBasicBlock.h>
#include <llvm/Transforms/IPO.h>

using namespace llvm;

namespace ara {

	bool ValueAnalyzer::dump_argument(std::stringstream& debug_out, argument_data* argument_container,
	                                  const Value* carg, std::vector<const Instruction*>* already_visited) {

		// TODO this is a horrible hack and should be eliminated ASAP
		// speak with the author of this code, if you see this comment
		Value* arg = const_cast<Value*>(carg);

		if (arg == nullptr)
			return false;

		// check if the value is an argument of the function
		if (Argument* argument = dyn_cast<Argument>(arg)) {
			return load_function_argument(debug_out, argument_container, argument->getParent(), already_visited,
			                              argument->getArgNo());
		}

		// check generell if arg is one of the arguments
		if (Instruction* instr = dyn_cast<Instruction>(arg)) {
			const Function* function = already_visited->back()->getParent()->getParent();

			int arg_counter = 0;
			for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i) {
				auto sUse = (*i).user_begin();
				auto sEnd = (*i).user_end();

				// iterate about the user of the allocation
				for (; sUse != sEnd; ++sUse) {

					if (const StoreInst* store = dyn_cast<const StoreInst>(*sUse)) {
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

		Type* Ty = arg->getType();

		// check if argument is an instruction
		if (Instruction* instr = dyn_cast<Instruction>(arg)) {
			debug_out << "INSTRUCTION"
			          << "\n";
			// check if argument is a load instruction
			if (LoadInst* load = dyn_cast<LoadInst>(instr)) {
				debug_out << "LOAD INSTRUCTION"
				          << "\n";
				// check if argument is a global variable
				if (GlobalVariable* global_var = dyn_cast<GlobalVariable>(load->getOperand(0))) {
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
						dump_success =
						    dump_argument(debug_out, argument_container, load->getOperand(0), already_visited);
				}
				// check if instruction is an alloca instruction
			} else if (AllocaInst* alloca = dyn_cast<AllocaInst>(instr)) {
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
					raw_string_ostream rso(type_str);
					alloca->getType()->print(rso);
					argument_container->any_list.emplace_back(rso.str());
					argument_container->value_list.emplace_back(alloca);
					argument_container->argument_calles_list.emplace_back(*already_visited);
					dump_success = true;
				}
			} else if (CastInst* cast = dyn_cast<CastInst>(instr)) {
				debug_out << "CAST INSTRUCTION"
				          << "\n";
				dump_success = dump_argument(debug_out, argument_container, cast->getOperand(0), already_visited);
				debug_out << print_argument(cast);

			} else if (StoreInst* store = dyn_cast<StoreInst>(instr)) {
				debug_out << "STORE INSTRUCTION"
				          << "\n";
				dump_success = load_value(debug_out, argument_container, store->getOperand(0), arg, already_visited);
				debug_out << print_argument(store);

			} else if (auto* geptr = dyn_cast<GetElementPtrInst>(instr)) {
				debug_out << "ELEMENTPTRINST INSTRUCTION"
				          << "\n";
				debug_out << print_argument(geptr);
				dump_success = get_element_ptr(debug_out, geptr, argument_container, already_visited);
			} else if (auto* call = dyn_cast<CallInst>(instr)) {
				debug_out << "CALLINSTRUCTION"
				          << "\n";
				debug_out << print_argument(call);

				for (auto user : call->users()) { // U is of type User*
					// get all users of get pointer element instruction
					if (auto store = dyn_cast<StoreInst>(user)) {
						if (store->getOperand(0) == call) {
							if (auto* geptr = dyn_cast<GetElementPtrInst>(store->getOperand(1))) {
								debug_out << print_type(geptr->getSourceElementType()) << "\n";
								if (check_function_class_reference_type(geptr->getFunction(),
								                                        geptr->getOperand(0)->getType())) {
									debug_out << "CLASSTYPE"
									          << "\n";
									argument_container->any_list.emplace_back(geptr->getName().str());
									argument_container->value_list.emplace_back(geptr);
									argument_container->argument_calles_list.emplace_back(*already_visited);
									dump_success = true;
								}
							}
						}
					}
				}
			} else if (BinaryOperator* binop = dyn_cast<BinaryOperator>(arg)) {

				argument_data operand_0;
				argument_data operand_1;
				// std::cerr << print_argument(binop) << std::endl;

				std::any value;
				if (dump_argument(debug_out, &operand_0, binop->getOperand(0), already_visited) &&
				    dump_argument(debug_out, &operand_1, binop->getOperand(1), already_visited)) {

					if (binop->getOpcode() == Instruction::BinaryOps::Or) {
						double value_0;
						double value_1;

						std::string string_value_0;
						std::string string_value_1;

						// std::cerr << print_argument(binop) << std::endl;
						if (!operand_0.multiple && !operand_1.multiple && !operand_0.any_list.empty() &&
						    !operand_1.any_list.empty()) {

							if (typeid(long).hash_code() == operand_0.any_list.front().type().hash_code() &&
							    typeid(long).hash_code() == operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_double(operand_0.any_list.front(), value_0) &&
								    cast_any_to_double(operand_1.any_list.front(), value_1)) {
									dump_success = true;
									value = (long)value_0 | (long)value_1;
									argument_container->any_list.emplace_back(value);
								}
							} else if (typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code() &&
							           typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_string(operand_0.any_list.front(), string_value_0) &&
								    cast_any_to_string(operand_1.any_list.front(), string_value_1)) {
									dump_success = true;
									value = (std::string)string_value_0 + "(OR)" + (std::string)string_value_1;

									// std::cerr <<  (std::string)string_value_0 <<"(OR)"<< (std::string)string_value_1
									// << std::endl;
									argument_container->any_list.emplace_back(value);
								}
							}
						};
					} else if (binop->getOpcode() == Instruction::BinaryOps::And) {
						double value_0;
						double value_1;

						std::string string_value_0;
						std::string string_value_1;

						// std::cerr << print_argument(binop) << std::endl;
						if (!operand_0.multiple && !operand_1.multiple && !operand_0.any_list.empty() &&
						    !operand_1.any_list.empty()) {

							if (typeid(long).hash_code() == operand_0.any_list.front().type().hash_code() &&
							    typeid(long).hash_code() == operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_double(operand_0.any_list.front(), value_0) &&
								    cast_any_to_double(operand_1.any_list.front(), value_1)) {
									dump_success = true;
									value = (long)value_0 & (long)value_1;
									argument_container->any_list.emplace_back(value);
								}
							} else if (typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code() &&
							           typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_string(operand_0.any_list.front(), string_value_0) &&
								    cast_any_to_string(operand_1.any_list.front(), string_value_1)) {
									dump_success = true;
									value = (std::string)string_value_0 + "(AND)" + (std::string)string_value_1;
									argument_container->any_list.emplace_back(value);
								}
							}
						}
					} else if (binop->getOpcode() == Instruction::BinaryOps::Add) {
						double value_0;
						double value_1;

						std::string string_value_0;
						std::string string_value_1;

						// std::cerr << print_argument(binop) << std::endl;
						if (!operand_0.multiple && !operand_1.multiple && !operand_0.any_list.empty() &&
						    !operand_1.any_list.empty()) {

							if (typeid(long).hash_code() == operand_0.any_list.front().type().hash_code() &&
							    typeid(long).hash_code() == operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_double(operand_0.any_list.front(), value_0) &&
								    cast_any_to_double(operand_1.any_list.front(), value_1)) {
									dump_success = true;
									value = (long)value_0 + (long)value_1;
									argument_container->any_list.emplace_back(value);
								}
							} else if (typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code() &&
							           typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_string(operand_0.any_list.front(), string_value_0) &&
								    cast_any_to_string(operand_1.any_list.front(), string_value_1)) {
									dump_success = true;
									value = (std::string)string_value_0 + "(ADD)" + (std::string)string_value_1;
									argument_container->any_list.emplace_back(value);
								}
							}
						}
					} else if (binop->getOpcode() == Instruction::BinaryOps::Mul) {
						double value_0;
						double value_1;

						std::string string_value_0;
						std::string string_value_1;

						// std::cerr << print_argument(binop) << std::endl;
						if (!operand_0.multiple && !operand_1.multiple && !operand_0.any_list.empty() &&
						    !operand_1.any_list.empty()) {

							if (typeid(long).hash_code() == operand_0.any_list.front().type().hash_code() &&
							    typeid(long).hash_code() == operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_double(operand_0.any_list.front(), value_0) &&
								    cast_any_to_double(operand_1.any_list.front(), value_1)) {
									dump_success = true;
									value = (long)value_0 * (long)value_1;
									argument_container->any_list.emplace_back(value);
								}
							} else if (typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code() &&
							           typeid(std::string).hash_code() ==
							               operand_0.any_list.front().type().hash_code()) {

								if (cast_any_to_string(operand_0.any_list.front(), string_value_0) &&
								    cast_any_to_string(operand_1.any_list.front(), string_value_1)) {
									dump_success = true;
									value = (std::string)string_value_0 + "(MUL)" + (std::string)string_value_1;
									argument_container->any_list.emplace_back(value);
								}
							}
						}
					}

					// TODO set more binary operators
				}
				argument_container->value_list.emplace_back(binop);
				argument_container->argument_calles_list.emplace_back(*already_visited);
			}
		} // check if argument is a constant integer
		else if (ConstantInt* CI = dyn_cast<ConstantInt>(arg)) {
			debug_out << "CONSTANT INT"
			          << "\n";
			argument_container->any_list.emplace_back(CI->getSExtValue());
			argument_container->value_list.emplace_back(CI);
			argument_container->argument_calles_list.emplace_back(*already_visited);
			dump_success = true;
		} // check if argument is a constant floating point
		else if (ConstantFP* constant_fp = dyn_cast<ConstantFP>(arg)) {
			debug_out << "CONSTANT FP"
			          << "\n";
			argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble());
			argument_container->value_list.emplace_back(constant_fp);
			argument_container->argument_calles_list.emplace_back(*already_visited);
			dump_success = true;

		} // check if argument is a pointer
		else if (PointerType* PT = dyn_cast<PointerType>(Ty)) {
			debug_out << "POINTER"
			          << "\n";
			Type* elementType = PT->getElementType();
			// check if arg is a null ptr
			if (check_nullptr(argument_container, arg, debug_out, already_visited)) {

				return true;
			}
			// check if pointer points to function
			if (FunctionType* FT = dyn_cast<FunctionType>(elementType)) { // check pointer to function
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
			else if (GlobalVariable* global_var = dyn_cast<GlobalVariable>(arg)) {
				debug_out << "POINTER TO GLOBAL"
				          << "\n";
				dump_success = load_value(debug_out, argument_container, arg, arg, already_visited);

			} else if (Constant* constant = dyn_cast<ConstantExpr>(arg)) { // check if value is a constant value
				// check if the constant value is global global variable
				if (GlobalVariable* global_var = dyn_cast<GlobalVariable>(constant->getOperand(0))) {
					debug_out << "POINTER TO CONSTANT GLOBAL"
					          << "\n";
					dump_success =
					    load_value(debug_out, argument_container, constant->getOperand(0), arg, already_visited);
				}

			} else {

				// TODO
				debug_out << print_argument(arg);
			}
		} else {
			std::string type_str;
			raw_string_ostream rso(type_str);
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

	bool ValueAnalyzer::load_value(std::stringstream& debug_out, argument_data* argument_container, Value* arg,
	                               Value* prior_arg, std::vector<const Instruction*>* already_visited) {

		// debug data
		debug_out << "ENTRYLOAD"
		          << "\n";

		std::string type_str;
		raw_string_ostream rso(type_str);

		bool load_success = false;

		// check if arg is a null ptr
		if (check_nullptr(argument_container, arg, debug_out, already_visited)) {
			return true;
		}
		if (GlobalVariable* global_var = dyn_cast<GlobalVariable>(arg)) {

			debug_out << "GLOBALVALUE"
			          << "\n";
			debug_out << print_argument(global_var);

			// check if the global variable has a loadable value
			if (global_var->hasInitializer()) {
				debug_out << "HASINITIALIZER"
				          << "\n";

				if (ConstantData* constant_data = dyn_cast<ConstantData>(global_var->getInitializer())) {
					debug_out << "CONSTANTDATA"
					          << "\n";
					if (ConstantDataSequential* constant_sequential = dyn_cast<ConstantDataSequential>(constant_data)) {
						debug_out << "CONSTANTDATASEQUIENTIAL"
						          << "\n";
						if (ConstantDataArray* constant_array = dyn_cast<ConstantDataArray>(constant_sequential)) {
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
					else if (ConstantInt* constant_int = dyn_cast<ConstantInt>(constant_data)) {
						debug_out << "CONSTANTDATAINT"
						          << "\n";

						argument_container->any_list.emplace_back(constant_int->getSExtValue());
						argument_container->value_list.emplace_back(constant_int);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;

					} // check if global variable is contant floating point
					else if (ConstantFP* constant_fp = dyn_cast<ConstantFP>(constant_data)) {
						debug_out << "CONSTANTDATAFLOATING"
						          << "\n";

						argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble());
						argument_container->value_list.emplace_back(constant_fp);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;
					} // check if global variable is contant null pointer
					else if (ConstantPointerNull* null_ptr = dyn_cast<ConstantPointerNull>(constant_data)) {
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
				} else if (ConstantExpr* constant_expr = dyn_cast<ConstantExpr>(global_var->getInitializer())) {
					debug_out << "CONSTANTEXPRESSION"
					          << "\n";
					// check if value is from type value
					if (Value* tmp_arg = dyn_cast<Value>(constant_expr)) {
						// get the value
						load_success = dump_argument(debug_out, argument_container, tmp_arg, already_visited);
					}

					// check if global variable is from type constant aggregate
				} else if (ConstantAggregate* constant_aggregate =
				               dyn_cast<ConstantAggregate>(global_var->getInitializer())) {
					// check if global variable is from type constant array
					debug_out << "CONSTANTAGGREGATE"
					          << "\n";
					if (ConstantArray* constant_array = dyn_cast<ConstantArray>(constant_aggregate)) {

						if (User* user = dyn_cast<User>(prior_arg)) {

							Value* N = user->getOperand(2);
							// Value * M =user->getOperand(3);
							// TODO make laoding of array indizes more generel
							int index_n = load_index(N);
							// int index_m =load_index(N);
							debug_out << "\n" << index_n << "\n";

							// constant_array->getOperand(index_n)->print(rso);
							Value* aggregate_operand = constant_array->getOperand(index_n);

							load_success =
							    dump_argument(debug_out, argument_container, aggregate_operand, already_visited);
						}

					} // check if global variable is from type constant struct
					else if (ConstantStruct* constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)) {
						debug_out << "Constant Struct";
					} // check if global variable is from type constant vector
					else if (ConstantVector* constant_vector = dyn_cast<ConstantVector>(constant_aggregate)) {
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

			if (ConstantAggregate* constant_aggregate = dyn_cast<ConstantAggregate>(arg)) {
				debug_out << "CONSTANTAGGREGATE";
				// check if global variable is from type constant array
				if (ConstantArray* constant_array = dyn_cast<ConstantArray>(constant_aggregate)) {
					debug_out << "Constant Array";

				} // check if global variable is from type constant struct
				else if (ConstantStruct* constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)) {
					debug_out << "Constant Struct";

					Constant* content = constant_struct->getAggregateElement(0u);

					for (unsigned int i = 1; content != nullptr; i++) {

						if (ConstantInt* CI = dyn_cast<ConstantInt>(content)) {
							debug_out << "CONSTANT INT"
							          << "\n";

							argument_container->any_list.emplace_back(CI->getSExtValue());
							argument_container->value_list.emplace_back(CI);
							argument_container->argument_calles_list.emplace_back(*already_visited);
							load_success = true;
						} // check if argument is a constant floating point
						else if (ConstantFP* constant_fp = dyn_cast<ConstantFP>(content)) {
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
				else if (ConstantVector* constant_vector = dyn_cast<ConstantVector>(constant_aggregate)) {
					debug_out << "Constant Vector";
				}
			}
		}

		debug_out << "EXITLOAD: " << load_success << "\n";
		return load_success;
	}

	/**
	 * @brief dump all call instructions, which calls the function or have the function as argument
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param function llvm function of the arg
	 * @param already_visited list of all instructions, which were already visited
	 * @param arg_counter index of the value in call instruction of calling function
	 */
	bool ValueAnalyzer::load_function_argument(std::stringstream& debug_out, argument_data* argument_container,
	                                           const Function* function,
	                                           std::vector<const Instruction*>* already_visited, int arg_counter) {

		auto sUse = function->user_begin();
		auto sEnd = function->user_end();

		bool success = true;
		// iterate about the user of the allocation
		for (; sUse != sEnd; ++sUse) {

			// check if instruction is a store instruction
			if (const Instruction* instr = dyn_cast<const Instruction>(*sUse)) {
				bool flag = true;
				for (const auto* element : *already_visited) {
					if (element == instr) {
						flag = false;
						break;
					}
				}

				// instruction was already visited
				if (!flag)
					continue;

				std::vector<const Instruction*> tmp_already_visited = *already_visited;

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

	bool ValueAnalyzer::get_store_instruction(std::stringstream& debug_out, Instruction* inst,
	                                          argument_data* argument_container,
	                                          std::vector<const Instruction*>* already_visited) {

		bool success = false;

		// get control flow information of the function
		Function& tmp_function = *inst->getFunction();
		DominatorTree dominator_tree = DominatorTree(tmp_function);
		dominator_tree.updateDFSNumbers();

		Triple ModuleTriple(sys::getDefaultTargetTriple());
		TargetLibraryInfoImpl TLII = TargetLibraryInfoImpl(ModuleTriple);
		TargetLibraryInfo TLI = TargetLibraryInfo(TLII);
		AAResults results = AAResults(TLI);

		// memory walker llvm class
		MemorySSA ssa = MemorySSA(tmp_function, &results, &dominator_tree);
		ssa.verifyMemorySSA();
		MemorySSAWalker* walker = ssa.getWalker();

		MemoryAccess* access = walker->getClobberingMemoryAccess(inst);

		// check if an access of the data structure was successfully
		if (access != nullptr) {
			if (auto def_access = dyn_cast<MemoryDef>(access)) {

				// check if the load and the store instructions addresses the same memory
				// TODO memory walke class seems sometimes to return no valid results
				if (StoreInst* store_inst = dyn_cast<StoreInst>(def_access->getMemoryInst())) {
					if (store_inst->getOperand(1) == inst->getOperand(0))
						success =
						    dump_argument(debug_out, argument_container, store_inst->getOperand(0), already_visited);
				}
			}
		}

		bool pointer_flag = true;
		Instruction* store_inst = nullptr;

		// check if memory walker class does not return a acceptable load instruction
		if (success == false) {

			// get the nearest dominating store instruction of the load instruction
			if (AllocaInst* alloca_instruction = dyn_cast<AllocaInst>(inst->getOperand(0))) {
				Value::user_iterator sUse = alloca_instruction->user_begin();
				Value::user_iterator sEnd = alloca_instruction->user_end();

				// iterate about the user of the allocation
				for (; sUse != sEnd; ++sUse) {

					// check if instruction is a store instruction
					if (StoreInst* tmp_instruction = dyn_cast<StoreInst>(*sUse)) {

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

	bool ValueAnalyzer::get_element_ptr(std::stringstream& debug_out, Instruction* inst,
	                                    argument_data* argument_container,
	                                    std::vector<const Instruction*>* already_visited) {

		bool success = false;
		// check if this is a element ptr
		if (auto* get_pointer_element = dyn_cast<GetElementPtrInst>(inst)) { // U is of type User*
			std::vector<size_t> indizes;
			// get indizes of the element ptr
			for (auto i = get_pointer_element->idx_begin(), ie = get_pointer_element->idx_end(); i != ie; ++i) {
				Value* tmp = ((*i).get());
				if (ConstantInt* CI = dyn_cast<ConstantInt>(tmp)) {
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
	 * @brief function checks if the function is a class method(first argument this) and the type is the same of the
	 * class
	 * @param function vector reference which contains get element ptr instruction indizes
	 * @param type get element ptr instruction, which is compared to the referenced indizes
	 */
	bool ValueAnalyzer::check_function_class_reference_type(Function* function, Type* type) {
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

	bool ValueAnalyzer::cast_any_to_double(std::any any_value, double& double_value) {
		if (any_value.type().hash_code() == typeid(int).hash_code()) {
			double_value = std::any_cast<long>(any_value);
			return true;
		} else if (any_value.type().hash_code() == typeid(double).hash_code()) {
			double_value = std::any_cast<double>(any_value);
			return true;
		}
		return false;
	}

	bool ValueAnalyzer::cast_any_to_string(std::any any_value, std::string& string_value) {
		if (any_value.type().hash_code() == typeid(std::string).hash_code()) {
			string_value = std::any_cast<std::string>(any_value);
			return true;
		}
		return false;
	}

	bool ValueAnalyzer::check_nullptr(argument_data* argument_container, Value* arg, std::stringstream& debug_out,
	                                  std::vector<const Instruction*>* already_visited) {
		bool load_success = false;
		if (ConstantPointerNull* constant_data = dyn_cast<ConstantPointerNull>(arg)) {
			debug_out << "CONSTANTPOINTERNULL" << std::endl;
			std::string tmp = "&$%NULL&$%";
			argument_container->any_list.emplace_back(tmp);
			argument_container->value_list.emplace_back(constant_data);
			argument_container->argument_calles_list.emplace_back(*already_visited);
			load_success = true;
		}
		return load_success;
	}

	int ValueAnalyzer::load_index(Value* arg) {
		int index = 0;
		// check if argument is a constant int
		if (ConstantInt* CI = dyn_cast<ConstantInt>(arg)) {

			index = CI->getSExtValue();
		} // check if argument is a constant floating point
		else if (ConstantFP* constant_fp = dyn_cast<ConstantFP>(arg)) {

			index = constant_fp->getValueAPF().convertToDouble();
		}
		return index;
	}

	bool ValueAnalyzer::get_class_attribute_value(std::stringstream& debug_out, Instruction* inst,
	                                              argument_data* argument_container,
	                                              std::vector<const Instruction*>* already_visited,
	                                              std::vector<size_t>* indizes) {
		bool success = true;
		bool flag = false;
		// get module
		Module* mod = inst->getFunction()->getParent();
		// iterate about the module
		for (auto& function : *mod) {
			// iterate about the arguments of the function
			for (auto i = function.arg_begin(), ie = function.arg_end(); i != ie; ++i) {
				// check if the function is a method of the class
				if ((*i).getType() == inst->getType()) {
					// iterate about the basic blocks of the function
					for (BasicBlock& bb : function) {
						// iterate about the instructions of the function
						for (Instruction& instr : bb) {
							// get pointerelement instruction
							if (auto* get_pointer_element = dyn_cast<GetElementPtrInst>(&instr)) { // U is of type User*
								// check if the get pointer operand instruction is a load instruction
								if (check_function_class_reference_type(instr.getFunction(),
								                                        get_pointer_element->getPointerOperandType()) &&
								    check_get_element_ptr_indizes(indizes, get_pointer_element)) {

									// just allow the Analysis of global variables, which are stored with just
									// two instructions -> one for nullptr initialization and one for storing the value
									// in the global variable
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
												if (dyn_cast<ConstantPointerNull>(
												        argument_container->value_list.back())) {
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
											debug_out << "USERWITHSAMEPOINTERINDIZES-NOSTOREINSTRUCTIONFOUND"
											          << std::endl;
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

	bool ValueAnalyzer::instruction_before(Instruction* InstA, Instruction* InstB, DominatorTree* DT) {
		DenseMap<BasicBlock*, std::unique_ptr<OrderedBasicBlock>> OBBMap;
		if (InstA->getParent() == InstB->getParent()) {
			BasicBlock* IBB = InstA->getParent();
			auto OBB = OBBMap.find(IBB);
			if (OBB == OBBMap.end())
				OBB = OBBMap.insert({IBB, make_unique<OrderedBasicBlock>(IBB)}).first;
			return OBB->second->dominates(InstA, InstB);
		}

		DomTreeNode* DA = DT->getNode(InstA->getParent());

		DomTreeNode* DB = DT->getNode(InstB->getParent());

		// std::cout << "debug not same parents" <<  DA->getDFSNumIn() << ":" <<  DB->getDFSNumIn() << std::endl;
		return DA->getDFSNumIn() < DB->getDFSNumIn();
	}

	bool ValueAnalyzer::check_get_element_ptr_indizes(std::vector<size_t>* reference, GetElementPtrInst* instr) {
		int counter = 0;
		for (auto i = instr->idx_begin(), ie = instr->idx_end(); i != ie; ++i) {
			int index = -1;
			if (ConstantInt* CI = dyn_cast<ConstantInt>(((*i).get()))) {
				index = CI->getLimitedValue();
			};
			if (index != reference->at(counter))
				return false;
			++counter;
		}
		return true;
	}

	ValueAnalyzer::call_data ValueAnalyzer::dump_instruction(Function* func, const CallBase* instruction,
	                                                         std::vector<shared_warning>* warning_list) {

		// empty call data container
		ValueAnalyzer::call_data call;

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
			std::vector<const Instruction*> already_visited;
			already_visited.emplace_back(instruction);
			// get argument
			Value* arg = instruction->getArgOperand(i);

			argument_data argument_container;

			// dump argument and check if it was successfull
			if (dump_argument(debug_out, &argument_container, arg, &already_visited)) {

				// dump was successfull
				if (argument_container.any_list.size() > 1)
					argument_container.multiple = true;

				// argument container lists shall not have different sizes
				if (argument_container.any_list.size() != argument_container.value_list.size() ||
				    argument_container.any_list.size() != argument_container.argument_calles_list.size() ||
				    argument_container.argument_calles_list.size() != argument_container.value_list.size()) {

					// error in argument dump
					auto warning = std::make_shared<DumbArgumentWarning>(i, *instruction);
					warning_list->emplace_back(warning);
				}

				// store the dumped argument in the abb with corresponding llvm type
				arguments.emplace_back(argument_container);

			} else {

				// dump was not successfull
				auto warning = std::make_shared<DumbArgumentWarning>(i, *instruction);
				warning_list->emplace_back(warning);
			}

			logger.debug() << "Values dumped, debug log is: " << debug_out.str() << std::endl;
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

		return call;
	}

	Arguments ValueAnalyzer::get_values(const CallBase& cb) {
		if (isCallToLLVMIntrinsic(&cb)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}

		Function* func = cb.getCalledFunction();

		// static function pointer
		if (!func) {
			if (llvm::Constant* constant = dyn_cast<llvm::Constant>(cb.getCalledValue())) {
				if (llvm::Function* tmp_func = dyn_cast<llvm::Function>(constant->getOperand(0))) {
					func = tmp_func;
				}
			}
		}

		if (!func) {
			throw ValuesUnknown("Called function cannot be determined.");
		}

		std::vector<shared_warning> warning_list;

		// get and store the called arguments values
		ValueAnalyzer::call_data data = dump_instruction(func, &cb, &warning_list);

		// repack Values into Arguments class
		Arguments args;

		for (auto& a : data.arguments) {
			if (a.value_list.size() == 0) {
				assert(data.arguments.size() == 1);
				break;
			}
			assert(a.value_list.size() == 1);

			const llvm::Constant* c = dyn_cast<llvm::Constant>(a.value_list[0]);
			assert(c != nullptr);
			args.emplace_back(*c);
		}

		return args;
	}
} // namespace ara
