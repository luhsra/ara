#pragma once

#include "arguments.h"
#include "logging.h"
#include "warning.h"

#include <any>
#include <llvm/IR/Dominators.h>
#include <vector>

namespace ara {

	class ValueAnalyzer {
	  private:
		struct argument_data {
			std::vector<std::any> any_list;
			std::vector<const llvm::Value*> value_list;
			std::vector<std::vector<const llvm::Instruction*>> argument_calles_list;
			bool multiple = false;
			std::vector<unsigned> backtrack_depth;
		};

		struct call_data {
			std::string call_name; // Name des Sycalls
			std::vector<argument_data> arguments;
			const llvm::CallBase* call_instruction;
			bool sys_call = false;
		};

		Logger& logger;

		Logger::LogStream& debug(unsigned level);

		void count_backtrack(argument_data* argument_container, bool new_value);

		call_data dump_instruction(llvm::Function* func, const llvm::CallBase* instruction,
		                           std::vector<shared_warning>* warning_list);

		/**
		 * @brief set all possbile argument values and corresponding call history in a data structure. This
		 * data structure is then stored in the abb.
		 * @param argument_container data structure where the dump result is stored(std::any value, llvm value,
		 * instruction call history)
		 * @param arg argument which has to be dumped
		 * @param already_visited list of all instructions, which were already visited
		 */
		bool dump_argument(unsigned level, argument_data* argument_container, const llvm::Value* arg,
		                   std::vector<const llvm::Instruction*>* already_visited);

		/**
		 * @brief load the std::any and llvm value of the global llvm arg
		 * @param argument_container data structure where the dump result is stored(std::any value, llvm value,
		 * instruction call history)
		 * @param arg argument which has to be dumped
		 * @param prior_arg predecessor of the current arg
		 * @param already_visited list of all instructions, which were already visited
		 */
		bool load_value(unsigned level, argument_data* argument_container, llvm::Value* arg, llvm::Value* prior_arg,
		                std::vector<const llvm::Instruction*>* already_visited);

		/**
		 * @brief dump all call instructions, which calls the function or have the function as argument
		 * @param argument_container data structure where the dump result is stored(std::any value, llvm value,
		 * instruction call history)
		 * @param function llvm function of the arg
		 * @param already_visited list of all instructions, which were already visited
		 * @param arg_counter index of the value in call instruction of calling function
		 */
		bool load_function_argument(unsigned level, argument_data* argument_container, const llvm::Function* function,
		                            std::vector<const llvm::Instruction*>* already_visited, int arg_counter);

		/**
		 * @brief dump the nearest dominating store instruction of the load instruction to get the loaded value of the
		 * load
		 * @param argument_container data structure where the dump result is stored(std::any value, llvm value,
		 * instruction call history)
		 * @param inst load instruction, which corresponding loaded value should be determined
		 * @param already_visited list of all instructions, which were already visited
		 */
		bool get_store_instruction(unsigned level, llvm::Instruction* inst, argument_data* argument_container,
		                           std::vector<const llvm::Instruction*>* already_visited);

		/**
		 * @brief dumpt the value of the GetElementPtrInst with corresponding indizes (important for class values)
		 * @param argument_container data structure where the dump result is stored(std::any value, llvm value,
		 * instruction call history)
		 * @param inst get elementptr instruction, which corresponding loaded value should be determined
		 * @param already_visited list of all instructions, which were already visited
		 */
		bool get_element_ptr(unsigned level, llvm::Instruction* inst, argument_data* argument_container,
		                     std::vector<const llvm::Instruction*>* already_visited);

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
		 * @param argument_container data structure where the dump result is stored(std::any value, llvm value,
		 * instruction call history)
		 * @param inst get elementptr instruction, which corresponding loaded value should be determined
		 * @param already_visited list of all instructions, which were already visited
		 * @param arg value which is analyzed
		 */
		bool check_nullptr(argument_data* argument_container, llvm::Value* arg, unsigned level,
		                   std::vector<const llvm::Instruction*>* already_visited);

		/**
		 * @brief load the value of integer of floating point variable
		 * @param arg value which is analyzed
		 */
		int load_index(llvm::Value* arg);

		/**
		 * Find all users of the GlobalAlias. This should normally work with alias->users(), but does not always.
		 * Unclear why.
		 */
		std::vector<llvm::CallBase*> hacky_find_users(unsigned level, llvm::GlobalAlias* alias);

		/**
		 * Get for an IR load instruction of the form:
		 * this1 = load ...;
		 * the list of values that the this pointer has in the calling function.
		 */
		std::vector<llvm::Value*> get_this_instances(unsigned level, llvm::LoadInst* this_usage);

		/**
		 * @brief get all store instructions which store values in the specific class attribute variable
		 * @param argument_container data structure where the dump result is stored(std::any value, llvm value,
		 * instruction call history)
		 * @param inst get elementptr instruction, which corresponding loaded value should be determined
		 * @param already_visited list of all instructions, which were already visited
		 * @param indizes indizes to distinguish between the class attribute variables
		 */
		bool get_class_attribute_value(unsigned level, llvm::Instruction* inst, argument_data* argument_container,
		                               std::vector<const llvm::Instruction*>* already_visited,
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

		/**
		 * @brief returns the handler, which is one argument of the call
		 * @param instruction instruction where the handler is an argument
		 * @param argument_index argument index
		 * @return llvm_handler
		 */
		llvm::Value* get_handler(const llvm::Instruction& instruction, unsigned int argument_index);

	  public:
		ValueAnalyzer(Logger& logger) : logger(logger) {}

		std::pair<Arguments, std::vector<std::vector<unsigned>>> get_values(const llvm::CallBase& cb);
	};

} // namespace ara