#ifndef LLVM_COMMON
#define LLVM_COMMON

#include "llvm/IR/Instructions.h"

#include <cassert>
#include <memory>

/**
 * wrapper for CallBase that will be introduced with newer LLVM, delete this class once CallBase will exist
 */
class FakeCallBase {
  private:
	const llvm::CallInst* c;
	const llvm::InvokeInst* v;

	FakeCallBase(const llvm::CallInst* c, const llvm::InvokeInst* v) : c(c), v(v) {}

	struct make_shared_enabler;

  public:
	friend class std::unique_ptr<FakeCallBase>;
	/**
	 * equivalent to llvm::CallBase* = llvm::dyn_cast<llvm::CallBase>(inst)
	 */
	static std::unique_ptr<FakeCallBase> create(const llvm::Instruction* inst);

	static bool isa(const llvm::Instruction* I) {
		return (llvm::isa<llvm::InvokeInst>(I) || llvm::isa<llvm::CallInst>(I));
	}

	static bool isa(const llvm::Instruction& I) {
		return (llvm::isa<llvm::InvokeInst>(I) || llvm::isa<llvm::CallInst>(I));
	}

	const llvm::Function* getCalledFunction() const {
		if (c)
			return c->getCalledFunction();
		if (v)
			return v->getCalledFunction();
		assert(false);
		return nullptr;
	}

	const llvm::Value* getCalledValue() const {
		if (c)
			return c->getCalledValue();
		if (v)
			return v->getCalledValue();
		assert(false);
		return nullptr;
	}

	// copied from LLVM
	bool isIndirectCall() const {
		const llvm::Value *V = getCalledValue();
		if (llvm::isa<llvm::Function>(V) || llvm::isa<llvm::Constant>(V))
			return false;
		if (c && c->isInlineAsm())
			return false;
		return true;
	}


	bool isInlineAsm() const {
		if (c)
			return c->isInlineAsm();
		if (v)
			assert(false);
			return false;
		assert(false);
		return false;
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
bool isCallToLLVMIntrinsic(const llvm::Instruction* inst);
bool isInlineAsm(const llvm::Instruction* inst);

#endif
