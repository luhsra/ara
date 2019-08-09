#ifndef LLVM_DUMPER_H
#define LLVM_DUMPER_H

#include "graph.h"

#include "llvm/IR/Instructions.h"

#include <vector>

class LLVMDumper {
  public:
	/**
	 * @brief set all possbile argument values and corresponding call history in a data structure. This
	 * data structure is then stored in the abb.
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param arg argument which has to be dumped
	 * @param already_visited list of all instructions, which were already visited
	 */
	bool dump_argument(std::stringstream& debug_out, argument_data* argument_container, llvm::Value* arg,
	                   std::vector<llvm::Instruction*>* already_visited);

	/**
	 * @brief load the std::any and llvm value of the global llvm arg
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param arg argument which has to be dumped
	 * @param prior_arg predecessor of the current arg
	 * @param already_visited list of all instructions, which were already visited
	 */
	bool load_value(std::stringstream& debug_out, argument_data* argument_container, llvm::Value* arg,
	                llvm::Value* prior_arg, std::vector<llvm::Instruction*>* already_visited);

	/**
	 * @brief dump all call instructions, which calls the function or have the function as argument
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param function llvm function of the arg
	 * @param already_visited list of all instructions, which were already visited
	 * @param arg_counter index of the value in call instruction of calling function
	 */
	bool load_function_argument(std::stringstream& debug_out, argument_data* argument_container,
	                            llvm::Function* function, std::vector<llvm::Instruction*>* already_visited,
	                            int arg_counter);

	/**
	 * @brief dump the nearest dominating store instruction of the load instruction to get the loaded value of the load
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param inst load instruction, which corresponding loaded value should be determined
	 * @param already_visited list of all instructions, which were already visited
	 */
	bool get_store_instruction(std::stringstream& debug_out, llvm::Instruction* inst, argument_data* argument_container,
	                           std::vector<llvm::Instruction*>* already_visited);

	/**
	 * @brief dumpt the value of the GetElementPtrInst with corresponding indizes (important for class values)
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param inst get elementptr instruction, which corresponding loaded value should be determined
	 * @param already_visited list of all instructions, which were already visited
	 */
	bool get_element_ptr(std::stringstream& debug_out, llvm::Instruction* inst, argument_data* argument_container,
	                     std::vector<llvm::Instruction*>* already_visited);

	/**
	 * @brief function checks if the function is a class method(first argument this) and the type is the same of the
	 * class
	 * @param function vector reference which contains get element ptr instruction indizes
	 * @param type get element ptr instruction, which is compared to the referenced indizes
	 */
	bool check_function_class_reference_type(llvm::Function* function, llvm::Type* type);

	/**
	 * @brief check and cast any variable to double variable
	 * @param any_value reference to the any variable
	 * @param double_value reference to the double variable
	 */
	bool cast_any_to_double(std::any any_value, double& double_value);

	/**
	 * @brief check and cast any variable to string variable
	 * @param any_value reference to the any variable
	 * @param string_value reference to the string variable
	 */
	bool cast_any_to_string(std::any any_value, std::string& string_value);

	/**
	 * @brief check if instuction is an pointer to a constant null
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param inst get elementptr instruction, which corresponding loaded value should be determined
	 * @param already_visited list of all instructions, which were already visited
	 * @param arg value which is analyzed
	 */
	bool check_nullptr(argument_data* argument_container, llvm::Value* arg, std::stringstream& debug_out,
	                   std::vector<llvm::Instruction*>* already_visited);

	/**
	 * @brief load the value of integer of floating point variable
	 * @param arg value which is analyzed
	 */
	int load_index(llvm::Value* arg);

	/**
	 * @brief get all store instructions which store values in the specific class attribute variable
	 * @param debug_out stringstream which contains the logical history of the argument dump
	 * @param argument_container data structure where the dump result is stored(std::any value, llvm value, instruction
	 * call history)
	 * @param inst get elementptr instruction, which corresponding loaded value should be determined
	 * @param already_visited list of all instructions, which were already visited
	 * @param indizes indizes to distinguish between the class attribute variables
	 */
	bool get_class_attribute_value(std::stringstream& debug_out, llvm::Instruction* inst,
	                               argument_data* argument_container, std::vector<llvm::Instruction*>* already_visited,
	                               std::vector<size_t>* indizes);

	/**
	 * @brief check if the instruction A is before instruction B
	 * @param InstA first instruction
	 * @param InstB last instruction
	 * @param DT dominator tree of the function
	 */
	bool instruction_before(llvm::Instruction* InstA, llvm::Instruction* InstB, llvm::DominatorTree* DT);

	/**
	 * @brief check if the reference indizes are equal to the indizes of the transmitted instruction
	 * @param reference vector reference which contains get element ptr instruction indizes
	 * @param instr get element ptr instruction, which is compared to the referenced indizes
	 */
	bool check_get_element_ptr_indizes(std::vector<size_t>* reference, llvm::GetElementPtrInst* instr);
};
#endif // LLVM_DUMPER
