#ifndef LLVM_COMMON
#define LLVM_COMMON

#include "llvm/IR/Instructions.h"

#include <memory>
#include <cassert>

/**
 * wrapper for CallBase that will be introduced with newer LLVM, delete this class once CallBase will exist
 */
class FakeCallBase {
  private:
	llvm::CallInst* c;
	llvm::InvokeInst* v;

	FakeCallBase(llvm::CallInst* c, llvm::InvokeInst* v) : c(c), v(v) {}

	struct make_shared_enabler;

  public:
	friend class std::unique_ptr<FakeCallBase>;
	/**
	 * equivalent to llvm::CallBase* = llvm::dyn_cast<llvm::CallBase>(inst)
	 */
	static std::unique_ptr<FakeCallBase> create(llvm::Instruction* inst);

	static bool isa(const llvm::Instruction* I) {
		return (llvm::isa<llvm::InvokeInst>(I) || llvm::isa<llvm::CallInst>(I));
	}

	static bool isa(const llvm::Instruction& I) {
		return (llvm::isa<llvm::InvokeInst>(I) || llvm::isa<llvm::CallInst>(I));
	}

	llvm::Function* getCalledFunction() const {
		if (c)
			return c->getCalledFunction();
		if (v)
			return v->getCalledFunction();
		assert(true);
		return nullptr;
	}

	llvm::Value* getCalledValue() const {
		if (c)
			return c->getCalledValue();
		if (v)
			return v->getCalledValue();
		assert(true);
		return nullptr;
	}
};

/**
 * @brief get string representation of llvm value
 * @param argument llvm value variable to print
 */
std::string print_argument(llvm::Value* argument);

/**
 * @brief get string representation of llvm type
 * @param argument llvm::type to print
 */
std::string print_type(llvm::Type* argument);

/**
 * @brief check if the instruction is just llvm specific
 * @param instr instrucion to analyze
 */
// TODO make this const
bool isCallToLLVMIntrinsic(llvm::Instruction* inst);

#endif
