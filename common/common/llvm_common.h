#ifndef LLVM_COMMON
#define LLVM_COMMON

#include <cassert>
#include <llvm/IR/Instructions.h>
#include <memory>

/**
 * @brief get string representation of llvm type
 * @param argument llvm::type to print
 */
std::string print_type(llvm::Type* argument);

/**
 * @brief check if the instruction is just llvm specific
 * @param instr instrucion to analyze
 */
bool isCallToLLVMIntrinsic(const llvm::Instruction* inst);
bool isInlineAsm(const llvm::Instruction* inst);

#endif
