#include "value_analyzer.h"

#include "common/exceptions.h"
#include "common/llvm_common.h"

#include <llvm/Analysis/AliasAnalysis.h>
#include <llvm/Analysis/MemorySSA.h>
#include <llvm/Analysis/OrderedBasicBlock.h>
#include <llvm/Transforms/IPO.h>

using namespace llvm;

namespace ara {

	Logger::LogStream& ValueAnalyzer::debug(unsigned level) {
		auto& log = logger.debug();
		for (unsigned i = 0; i < level; ++i) {
			log << ' ';
		}
		return log;
	}

	bool ValueAnalyzer::dump_argument(unsigned level, argument_data* argument_container, const Value* carg,
	                                  std::vector<const Instruction*>* already_visited) {

		// TODO this is a horrible hack and should be eliminated ASAP
		// speak with the author of this code, if you see this comment
		Value* arg = const_cast<Value*>(carg);

		debug(level) << "DUMP_ARGUMENT: " << *arg << std::endl;

		if (arg == nullptr)
			return false;

		// check if the value is an argument of the function
		if (llvm::Argument* argument = dyn_cast<llvm::Argument>(arg)) {
			return load_function_argument(level + 1, argument_container, argument->getParent(), already_visited,
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
							return load_function_argument(level + 1, argument_container, function, already_visited,
							                              arg_counter);
					}
				}
				++arg_counter;
			}
		}

		debug(level) << "ENTRYDUMP" << std::endl;
		bool dump_success = false;

		Type* Ty = arg->getType();

		// check if argument is an instruction
		if (Instruction* instr = dyn_cast<Instruction>(arg)) {
			debug(level) << "INSTRUCTION" << std::endl;
			// check if argument is a load instruction
			if (LoadInst* load = dyn_cast<LoadInst>(instr)) {
				debug(level) << "LOAD INSTRUCTION" << std::endl;
				// check if argument is a global variable
				if (isa<GlobalVariable>(load->getOperand(0))) {
					debug(level) << "LOAD GLOBAL" << std::endl;
					// load the global information
					dump_success = load_value(level + 1, argument_container, load->getOperand(0), arg, already_visited);
				} else if (instr->getNumOperands() == 1) {
					debug(level) << "ONEOPERAND" << std::endl;

					if (isa<AllocaInst>(load->getOperand(0))) {
						debug(level) << "ALLOCAINSTRUCTIONLOAD" << std::endl;
						dump_success = get_store_instruction(level + 1, load, argument_container, already_visited);
					} else
						debug(level) << "  from: " << *load << std::endl;
					debug(level) << "  to: " << *load->getOperand(0) << std::endl;
					dump_success = dump_argument(level + 1, argument_container, load->getOperand(0), already_visited);
				}
				// check if instruction is an alloca instruction
			} else if (AllocaInst* alloca = dyn_cast<AllocaInst>(instr)) {
				debug(level) << "ALLOCA INSTRUCTION" << std::endl;
				if (alloca->hasName()) {
					// dump_success = get_store_instruction(level + 1,alloca,any_list,value_list,already_visited );
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
				debug(level) << "CAST INSTRUCTION" << std::endl;
				dump_success = dump_argument(level + 1, argument_container, cast->getOperand(0), already_visited);
				debug(level) << *cast;

			} else if (StoreInst* store = dyn_cast<StoreInst>(instr)) {
				debug(level) << "STORE INSTRUCTION" << std::endl;
				dump_success = load_value(level + 1, argument_container, store->getOperand(0), arg, already_visited);
				debug(level) << *store;

			} else if (auto* geptr = dyn_cast<GetElementPtrInst>(instr)) {
				debug(level) << "ELEMENTPTRINST INSTRUCTION" << std::endl;
				debug(level) << *geptr << std::endl;
				dump_success = get_element_ptr(level + 1, geptr, argument_container, already_visited);
			} else if (auto* call = dyn_cast<CallInst>(instr)) {
				debug(level) << "CALLINSTRUCTION" << std::endl;
				debug(level) << "  call: " << *call << std::endl;

				for (auto user : call->users()) { // U is of type User*
					// get all users of get pointer element instruction
					if (auto store = dyn_cast<StoreInst>(user)) {
						if (store->getOperand(0) == call) {
							if (auto* geptr = dyn_cast<GetElementPtrInst>(store->getOperand(1))) {
								debug(level) << "  user: " << *store << std::endl;
								debug(level) << "  operand: " << *geptr << std::endl;
								debug(level) << "  type: " << print_type(geptr->getSourceElementType()) << std::endl;
								auto& stream = debug(level);
								stream << "  call chain:";
								for (auto& elem : *already_visited) {
									stream << " | " << *elem << " (func: " << elem->getFunction()->getName().str()
									       << ")";
								}
								stream << std::endl;
								if (check_function_class_reference_type(geptr->getFunction(),
								                                        geptr->getOperand(0)->getType())) {
									debug(level) << "CLASSTYPE" << std::endl;
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
				if (dump_argument(level + 1, &operand_0, binop->getOperand(0), already_visited) &&
				    dump_argument(level + 1, &operand_1, binop->getOperand(1), already_visited)) {

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
			debug(level) << "CONSTANT INT" << std::endl;
			argument_container->any_list.emplace_back(CI->getSExtValue());
			argument_container->value_list.emplace_back(CI);
			argument_container->argument_calles_list.emplace_back(*already_visited);
			dump_success = true;
		} // check if argument is a constant floating point
		else if (ConstantFP* constant_fp = dyn_cast<ConstantFP>(arg)) {
			debug(level) << "CONSTANT FP" << std::endl;
			argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble());
			argument_container->value_list.emplace_back(constant_fp);
			argument_container->argument_calles_list.emplace_back(*already_visited);
			dump_success = true;

		} // check if argument is a pointer
		else if (PointerType* PT = dyn_cast<PointerType>(Ty)) {
			debug(level) << "POINTER" << std::endl;
			Type* elementType = PT->getElementType();
			// check if arg is a null ptr
			if (check_nullptr(argument_container, arg, level + 1, already_visited)) {

				return true;
			}
			// check if pointer points to function
			if (isa<FunctionType>(elementType)) { // check pointer to function
				// check if argument has a name
				if (arg->hasName()) {
					debug(level) << "POINTER TO FUNCTION" << std::endl;
					argument_container->any_list.emplace_back(arg->getName().str());
					argument_container->value_list.emplace_back(arg);
					argument_container->argument_calles_list.emplace_back(*already_visited);
					dump_success = true;
				}
			} // check if pointer points to pointer
			else if (PT->getContainedType(0)->isPointerTy()) {

				debug(level) << "POINTER TO POINTER" << std::endl;

				// load the global information
				dump_success = load_value(level + 1, argument_container, arg, arg, already_visited);

			} // check if value is a constant value
			else if (isa<GlobalVariable>(arg)) {
				debug(level) << "POINTER TO GLOBAL" << std::endl;
				dump_success = load_value(level + 1, argument_container, arg, arg, already_visited);

			} else if (Constant* constant = dyn_cast<ConstantExpr>(arg)) { // check if value is a constant value
				// check if the constant value is global global variable
				if (isa<GlobalVariable>(constant->getOperand(0))) {
					debug(level) << "POINTER TO CONSTANT GLOBAL" << std::endl;
					dump_success =
					    load_value(level + 1, argument_container, constant->getOperand(0), arg, already_visited);
				}

			} else {

				// TODO
				debug(level) << *arg;
			}
		} else {
			std::string type_str;
			raw_string_ostream rso(type_str);
			arg->getType()->print(rso);
			debug(level) << rso.str() << std::endl;

			dump_success = load_value(level + 1, argument_container, arg, arg, already_visited);
			if (!dump_success)
				debug(level) << "Kein Load/Instruction/Pointer" << std::endl;
		}

		if (!dump_success) {
			std::string arg_name = arg->getName().str();

			if (arg_name.length() > 0) {
				debug(level) << "DEFAULTNAME" << std::endl;
				debug(level) << *arg << std::endl;
				argument_container->any_list.emplace_back(arg_name);
				argument_container->value_list.emplace_back(arg);
				argument_container->argument_calles_list.emplace_back(*already_visited);
				dump_success = true;
			}
		}
		debug(level) << "EXITDUMP: " << dump_success << std::endl;
		return dump_success;
	}

	bool ValueAnalyzer::load_value(unsigned level, argument_data* argument_container, Value* arg, Value* prior_arg,
	                               std::vector<const Instruction*>* already_visited) {

		// debug data
		debug(level) << "ENTRYLOAD" << std::endl;

		std::string type_str;
		raw_string_ostream rso(type_str);

		bool load_success = false;

		// check if arg is a null ptr
		if (check_nullptr(argument_container, arg, level + 1, already_visited)) {
			return true;
		}
		if (GlobalVariable* global_var = dyn_cast<GlobalVariable>(arg)) {

			debug(level) << "GLOBALVALUE" << std::endl;
			debug(level) << *global_var;

			// check if the global variable has a loadable value
			if (global_var->hasInitializer()) {
				debug(level) << "HASINITIALIZER" << std::endl;

				if (ConstantData* constant_data = dyn_cast<ConstantData>(global_var->getInitializer())) {
					debug(level) << "CONSTANTDATA" << std::endl;
					if (ConstantDataSequential* constant_sequential = dyn_cast<ConstantDataSequential>(constant_data)) {
						debug(level) << "CONSTANTDATASEQUIENTIAL" << std::endl;
						if (ConstantDataArray* constant_array = dyn_cast<ConstantDataArray>(constant_sequential)) {
							debug(level) << "CONSTANTDATAARRAY" << std::endl;
							// global variable is a constant array
							if (constant_array->isCString()) {
								argument_container->any_list.emplace_back(constant_array->getAsCString().str());
								argument_container->value_list.emplace_back(constant_array);
								argument_container->argument_calles_list.emplace_back(*already_visited);
								load_success = true;
							} else
								debug(level) << "Keine konstante sequentielle Date geladen" << std::endl;
						}
					} // check if global variable is contant integer
					else if (ConstantInt* constant_int = dyn_cast<ConstantInt>(constant_data)) {
						debug(level) << "CONSTANTDATAINT" << std::endl;

						argument_container->any_list.emplace_back(constant_int->getSExtValue());
						argument_container->value_list.emplace_back(constant_int);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;

					} // check if global variable is contant floating point
					else if (ConstantFP* constant_fp = dyn_cast<ConstantFP>(constant_data)) {
						debug(level) << "CONSTANTDATAFLOATING" << std::endl;

						argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble());
						argument_container->value_list.emplace_back(constant_fp);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;
					} // check if global variable is contant null pointer
					else if (isa<ConstantPointerNull>(constant_data)) {
						debug(level) << "CONSTANTPOINTERNULL" << std::endl;
						// print name of null pointer because there is no other content
						if (global_var->hasName()) {
							argument_container->any_list.emplace_back(global_var->getName().str());
							argument_container->value_list.emplace_back(global_var);
							argument_container->argument_calles_list.emplace_back(*already_visited);
							load_success = true;

						} else {
							debug(level) << "Globaler Null Ptr hat keinen Namen" << std::endl;
						}
					} else {
						argument_container->any_list.emplace_back(global_var->getName().str());
						argument_container->value_list.emplace_back(global_var);
						argument_container->argument_calles_list.emplace_back(*already_visited);
						load_success = true;
						debug(level) << "CONSTANTUNDEF/TOKENNONE" << std::endl;
					}
					// check if global varialbe is a constant expression
				} else if (ConstantExpr* constant_expr = dyn_cast<ConstantExpr>(global_var->getInitializer())) {
					debug(level) << "CONSTANTEXPRESSION" << std::endl;
					// check if value is from type value
					if (Value* tmp_arg = dyn_cast<Value>(constant_expr)) {
						// get the value
						load_success = dump_argument(level + 1, argument_container, tmp_arg, already_visited);
					}

					// check if global variable is from type constant aggregate
				} else if (ConstantAggregate* constant_aggregate =
				               dyn_cast<ConstantAggregate>(global_var->getInitializer())) {
					// check if global variable is from type constant array
					debug(level) << "CONSTANTAGGREGATE" << std::endl;
					if (ConstantArray* constant_array = dyn_cast<ConstantArray>(constant_aggregate)) {

						if (User* user = dyn_cast<User>(prior_arg)) {

							Value* N = user->getOperand(2);
							// Value * M =user->getOperand(3);
							// TODO make laoding of array indizes more generel
							int index_n = load_index(N);
							// int index_m =load_index(N);
							debug(level) << index_n << std::endl;

							// constant_array->getOperand(index_n)->print(rso);
							Value* aggregate_operand = constant_array->getOperand(index_n);

							load_success =
							    dump_argument(level + 1, argument_container, aggregate_operand, already_visited);
						}

					} // check if global variable is from type constant struct
					else if (isa<ConstantStruct>(constant_aggregate)) {
						debug(level) << "Constant Struct";
					} // check if global variable is from type constant vector
					else if (isa<ConstantVector>(constant_aggregate)) {
						debug(level) << "Constant Vector";
					}
				} else {
					debug(level) << "GLOBALVALUE" << std::endl;
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
					debug(level) << "Nicht ladbare globale Variable hat keinen Namen";
			}

		} else {

			if (ConstantAggregate* constant_aggregate = dyn_cast<ConstantAggregate>(arg)) {
				debug(level) << "CONSTANTAGGREGATE";
				// check if global variable is from type constant array
				if (isa<ConstantArray>(constant_aggregate)) {
					debug(level) << "Constant Array";

				} // check if global variable is from type constant struct
				else if (ConstantStruct* constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)) {
					debug(level) << "Constant Struct";

					Constant* content = constant_struct->getAggregateElement(0u);

					for (unsigned int i = 1; content != nullptr; i++) {

						if (ConstantInt* CI = dyn_cast<ConstantInt>(content)) {
							debug(level) << "CONSTANT INT" << std::endl;

							argument_container->any_list.emplace_back(CI->getSExtValue());
							argument_container->value_list.emplace_back(CI);
							argument_container->argument_calles_list.emplace_back(*already_visited);
							load_success = true;
						} // check if argument is a constant floating point
						else if (ConstantFP* constant_fp = dyn_cast<ConstantFP>(content)) {
							debug(level) << "CONSTANT FP" << std::endl;

							argument_container->any_list.emplace_back(constant_fp->getValueAPF().convertToDouble());
							argument_container->value_list.emplace_back(constant_fp);
							argument_container->argument_calles_list.emplace_back(*already_visited);
							load_success = true;
						}
						content = constant_struct->getAggregateElement(i);
					}

				} // check if global variable is from type constant vector
				else if (isa<ConstantVector>(constant_aggregate)) {
					debug(level) << "Constant Vector";
				}
			}
		}

		debug(level) << "EXITLOAD: " << load_success << std::endl;
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
	bool ValueAnalyzer::load_function_argument(unsigned level, argument_data* argument_container,
	                                           const Function* function,
	                                           std::vector<const Instruction*>* already_visited, int arg_counter) {

		debug(level) << "LOAD FUNCTION ARGUMENT of function " << function->getName().str() << std::endl;

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
						debug(level) << "LOADFUNCTIONARGUMENT: " << arg_counter << " " << *instr << std::endl;
						debug(level) << "function:: " << instr->getFunction()->getName().str() << std::endl;
						if (!dump_argument(level + 1, argument_container, instr->getOperand(arg_counter),
						                   &tmp_already_visited))
							success = false;
					} else {

						// function is probably an argument of the call instruction
						int counter = 0;

						// load argument
						for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i) {
							if (arg_counter == counter) {
								debug(level) << "ARGUMENT" << i->getName().str() << std::endl;
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
		debug(level) << "ENDLOADFUNKTIONARGUMENT" << std::endl;
		return success;
	}

	bool ValueAnalyzer::get_store_instruction(unsigned level, Instruction* inst, argument_data* argument_container,
	                                          std::vector<const Instruction*>* already_visited) {
		debug(level) << "GETSTOREINSTRUCTION: " << *inst << std::endl;

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
					if (store_inst->getOperand(1) == inst->getOperand(0)) {
						debug(level) << " store candidate: " << *store_inst << std::endl;
						success =
						    dump_argument(level + 1, argument_container, store_inst->getOperand(0), already_visited);
					}
				}
			}
		}

		Instruction* store_inst = nullptr;

		// check if memory walker class does not return a acceptable load instruction
		if (success == false) {

			debug(level) << "  nothing found" << std::endl;

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
					debug(level) << "  found store: " << *store_inst << std::endl;
					success = dump_argument(level + 1, argument_container, store_inst->getOperand(0), already_visited);
				}
			}
		}
		return success;
	}

	bool ValueAnalyzer::get_element_ptr(unsigned level, Instruction* inst, argument_data* argument_container,
	                                    std::vector<const Instruction*>* already_visited) {

		debug(level) << "GET ELEMENT PTR" << std::endl;
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
			debug(level) << "  indizes:";
			for (auto i : indizes) {
				debug(level) << " " << i;
			}
			debug(level) << std::endl;
			// get operand of the GetElementPtrInst
			if (auto load = dyn_cast<LoadInst>(get_pointer_element->getPointerOperand())) {

				debug(level) << "  operand: " << *load << std::endl;

				// check if the address is a class specific address
				if (check_function_class_reference_type(inst->getFunction(),
				                                        get_pointer_element->getPointerOperandType())) {

					debug(level) << "GETCLASSATTRIBUTE" << std::endl;
					// get store instructions
					success = get_class_attribute_value(level + 1, load, argument_container, already_visited, &indizes);
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

	bool ValueAnalyzer::check_nullptr(argument_data* argument_container, Value* arg, unsigned level,
	                                  std::vector<const Instruction*>* already_visited) {
		bool load_success = false;
		if (ConstantPointerNull* constant_data = dyn_cast<ConstantPointerNull>(arg)) {
			assert(constant_data != nullptr);
			debug(level) << "CONSTANTPOINTERNULL" << std::endl;
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

	std::vector<llvm::CallBase*> ValueAnalyzer::hacky_find_users(unsigned level, GlobalAlias* alias) {
		std::vector<llvm::CallBase*> v;

		Module* module = alias->getParent();
		for (auto& function : *module) {
			if (function.getName().str().find("cxx_global_var_init") != std::string::npos) {
				debug(level) << function.getName().str() << std::endl;
			}
			for (auto& bb : function) {
				for (auto& inst : bb) {
					if (auto* call = dyn_cast<CallBase>(&inst)) {
						if (call->getCalledFunction() != nullptr) {
							std::string name = call->getCalledFunction()->getName().str();
							if (name.find("DisplayDriver") != std::string::npos) {
								debug(level) << "Call: " << *call << std::endl;
								debug(level) << "alias: " << *alias << std::endl;
							}
							// if (call->getCalledFunction() == alias) {
							// 	v.emplace_back(*call);
							// }
						}
					}
				}
			}
		}
		return v;
	}

	std::vector<llvm::Value*> ValueAnalyzer::get_this_instances(unsigned level, llvm::LoadInst* this_usage) {
		auto& this_arg = *this_usage->getFunction()->arg_begin();
		llvm::Value* tmp_value = this_usage->getPointerOperand();

		while (&this_arg != tmp_value) {
			for (auto u : tmp_value->users()) {
				if (auto si = dyn_cast<StoreInst>(u)) {
					tmp_value = si->getValueOperand();
					goto after_assert;
				}
			}
			assert(false && "Value cannot be converted to argument.");
		after_assert:;
		}
		assert(isa<llvm::Argument>(tmp_value) && "Expected an argument.");
		debug(level) << "GET THIS INSTANCES, argument: " << *tmp_value << std::endl;

		std::vector<llvm::Value*> v;
		for (auto u : dyn_cast<llvm::Argument>(tmp_value)->getParent()->users()) {
			if (GlobalAlias* gu = dyn_cast<GlobalAlias>(u)) {
				bool has_users = false;
				for (auto u2 : gu->users()) {
					v.emplace_back(u2->getOperand(0));
					has_users = true;
				}
				if (!has_users) {
					// sometimes some users aka direct call sites are not found, unclear why
					for (auto u2 : hacky_find_users(level, gu)) {
						v.emplace_back(u2->getOperand(0));
					}
				}
			} else if (isa<CallBase>(u)) {
				v.emplace_back(u->getOperand(0));
			}
		}
		return v;
	}

	bool ValueAnalyzer::get_class_attribute_value(unsigned level, Instruction* inst, argument_data* argument_container,
	                                              std::vector<const Instruction*>* already_visited,
	                                              std::vector<size_t>* indizes) {
		bool success = true;
		bool flag = false;

		debug(level) << "GET CLASS ATTRIBUTE VALUE: " << *inst << std::endl;
		// get module
		Module* mod = inst->getFunction()->getParent();
		// iterate about all instruction of functions belonging to the same class than inst
		for (auto& function : *mod) {
			for (auto i = function.arg_begin(), ie = function.arg_end(); i != ie; ++i) {
				// check if the function is a method of the class
				// at least, the this arguments must be equal
				if ((*i).getType() == inst->getType()) {
					for (BasicBlock& bb : function) {
						for (Instruction& instr : bb) {

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
											debug(level) << "USERWITHSAMEPOINTERINDIZESSTORE" << std::endl;
											debug(level) << *user << std::endl;

											// TODO, this is a very basic check, that the load and store are connected,
											// follow them in a correct way
											assert(isa<LoadInst>(inst) && "inst has to be a load instruction");

											// possible assignment (store)
											assert(isa<GetElementPtrInst>(store->getOperand(1)) &&
											       "Store instruction does not follow the expected use chain.");
											llvm::Value* tmp_load =
											    dyn_cast<GetElementPtrInst>(store->getOperand(1))->getPointerOperand();
											assert(isa<LoadInst>(tmp_load) && "Store instruction did not follow the "
											                                  "expected use chain. Has to be a load");

											bool match_found = true;
											auto instances1 = get_this_instances(level, dyn_cast<LoadInst>(inst));
											auto instances2 = get_this_instances(level, dyn_cast<LoadInst>(tmp_load));

											if (instances1.size() == 0 || instances2.size() == 0) {
												logger.err()
												    << "Instance of store candicate cannot be retrieved." << std::endl;
												logger.err() << "This basically renders this check useless and "
												                "violates soundness of this analysis."
												             << std::endl;
											} else {
												assert(instances1.size() == instances2.size() &&
												       instances1.size() > 0 && "Cannot found any instances");

												for (auto instance : instances1) {
													debug(level)
													    << "instance: " << instance << " " << *instance << std::endl;
													bool local_match_found = false;
													for (auto instance2 : instances2) {
														debug(level) << "instance2: " << instance2 << " " << *instance2
														             << std::endl;
														if (instance2 == instance) {
															local_match_found = true;
															break;
														}
													}
													if (!local_match_found) {
														match_found = false;
														break;
													}
												}
												if (!match_found) {
													logger.err() << "Instance of store candicate and instance of load "
													                "do not match."
													             << std::endl;
													logger.err() << "This basically renders this check useless and "
													                "violates soundness of this analysis."
													             << std::endl;
												}

												flag = true;
												// std::cerr << "user" << std::endl;
												debug(level) << "first operand: " << *store->getOperand(0) << std::endl;
												if (!dump_argument(level + 1, argument_container, store->getOperand(0),
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
									}

									// TODO check inital creation of class element
									// check if no store instruction to the class memory address exists
									if (false == success) {
										for (auto user : get_pointer_element->users()) { // U is of type User*
											// get all users of get pointer element instruction
											debug(level)
											    << "USERWITHSAMEPOINTERINDIZES-NOSTOREINSTRUCTIONFOUND" << std::endl;
											// debug(level) << print_argument(user)<< std::endl;
											if (isa<LoadInst>(user)) {
												// flag = true;
												// std::cerr << "user" << std::endl;
												// if(!dump_argument(level + 1,argument_container,
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
			long int index = -1;
			if (ConstantInt* CI = dyn_cast<ConstantInt>(((*i).get()))) {
				index = CI->getLimitedValue();
			};
			assert(reference->at(counter) <= LONG_MAX);
			if (index != static_cast<long>(reference->at(counter)))
				return false;
			++counter;
		}
		return true;
	}

	ValueAnalyzer::call_data ValueAnalyzer::dump_instruction(Function* func, const CallBase* instruction,
	                                                         std::vector<shared_warning>* warning_list) {

		logger.debug() << "---- dumping: " << func->getName().str() << " in " << *instruction << std::endl;
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
			logger.debug() << "--------------- instruction " << i << "--------------" << std::endl;

			std::vector<const Instruction*> already_visited;
			already_visited.emplace_back(instruction);
			// get argument
			Value* arg = instruction->getArgOperand(i);

			argument_data argument_container;

			// dump argument and check if it was successfull
			if (dump_argument(0, &argument_container, arg, &already_visited)) {

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

	llvm::Value* ValueAnalyzer::get_handler(const llvm::Instruction& instruction, unsigned int argument_index) {
		// check if call instruction has one user
		if (instruction.hasOneUse()) {
			// get the user of the call instruction
			const llvm::User* user = instruction.user_back();
			// check if user is store instruction
			if (isa<StoreInst>(user)) {
				return user->getOperand(argument_index);
			} else if (llvm::isa<BitCastInst>(user)) {
				return get_handler(*llvm::cast<Instruction>(user), argument_index);
			}
		}

		return nullptr;
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

		if (func->getName() == "xQueueGenericSend") {
			std::cout << "IN CORRECT FUNCTION" << std::endl;
			llvm::errs() << "CB " << &cb << " " << cb << '\n';
		}

		std::vector<shared_warning> warning_list;

		// get and store the called arguments values
		ValueAnalyzer::call_data data = dump_instruction(func, &cb, &warning_list);

		// return value
		llvm::Value* return_value = get_handler(cb, 1);

		// repack Values into Arguments class
		Arguments args;

		const llvm::ConstantTokenNone* token = llvm::ConstantTokenNone::get(cb.getContext());
		const llvm::Constant* none_c = dyn_cast<llvm::Constant>(token);

		unsigned i = 0;
		for (auto& a : data.arguments) {
			if (a.value_list.size() == 0) {
				assert(data.arguments.size() == 1);
				break;
			}

			AttributeSet s = cb.getAttributes().getAttributes(i + 1);

			if (a.value_list.size() != 1) {
				Argument arg(s, *none_c);
				logger.info() << "Analysis has found an ambiguous value:" << std::endl;
				logger.info() << "  CallBase: " << cb << std::endl;
				unsigned v_count = 0;
				for (const llvm::Value* v : a.value_list) {
					assert(v != nullptr && "Value must not be null");
					// omit first element in a.argument_calles_list[v_count]. This is always the call itself.
					auto& tmp = a.argument_calles_list[v_count];
					logger.debug() << "  Call chain:";
					for (auto& elem : tmp) {
						logger.debug() << " " << *elem << " (func: " << elem->getFunction()->getName().str() << ")";
					}
					logger.debug() << std::endl;
					assert(tmp.at(0) == &cb && "First argument in call list in not the call itself");
					std::vector<const llvm::Instruction*> reduced_list(tmp.begin() + 1, tmp.end());
					arg.add_variant(reduced_list, *v);
					logger.info() << "  Value " << v_count++ << ": " << *v << std::endl;
				}
				args.emplace_back(std::move(arg));
			} else {
				const llvm::Value* v = a.value_list[0];
				assert(v != nullptr && "Value must not be null");
				args.emplace_back(Argument(s, *v));
			}
			i++;
		}

		if (return_value != nullptr) {
			args.set_return_value(make_unique<Argument>(llvm::AttributeSet(), *return_value));
		} else {
			args.set_return_value(make_unique<Argument>(llvm::AttributeSet(), *none_c));
		}

		return args;
	}
} // namespace ara
