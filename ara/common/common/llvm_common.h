#ifndef LLVM_COMMON
#define LLVM_COMMON

#include <cassert>
#include <llvm/IR/Instructions.h>
#include <llvm/Support/raw_os_ostream.h>
#include <memory>

namespace ara {

	/**
	 * @brief get string representation of llvm type
	 * @param argument llvm::type to print
	 */
	std::string print_type(llvm::Type* argument);

	/**
	 * @brief print any LLVM object into a std::string
	 */
	template <typename T>
	std::string llvm_to_string(const T& x) {
		std::string out;
		llvm::raw_string_ostream lss(out);
		lss << x;
		return lss.str();
	}

	/**
	 * @brief check if the instruction is just llvm specific
	 * @param instr instrucion to analyze
	 */
	bool is_call_to_intrinsic(const llvm::Instruction& inst);
	bool is_intrinsic(const llvm::Function& func);
} // namespace ara

#endif
