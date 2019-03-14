#ifndef LLVM_COMMON
#define LLVM_COMMON

#include "llvm/IR/Instructions.h"

#include <memory>

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

	llvm::Function* getCalledFunction() {
		if (c)
			return c->getCalledFunction();
		if (v)
			return v->getCalledFunction();
		return nullptr;
	}

	llvm::Value* getCalledValue() {
		if (c)
			return c->getCalledValue();
		if (v)
			return v->getCalledValue();
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

#endif
