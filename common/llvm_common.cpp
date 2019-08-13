#include "common/llvm_common.h"

using namespace llvm;

struct FakeCallBase::make_shared_enabler : public FakeCallBase {
	template <typename... Args>
	make_shared_enabler(Args&&... args) : FakeCallBase(std::forward<Args>(args)...) {}
};

std::unique_ptr<FakeCallBase> FakeCallBase::create(const Instruction* inst) {
	if (const CallInst* c = dyn_cast<CallInst>(inst)) {
		return std::make_unique<make_shared_enabler>(c, nullptr);
	}
	if (const InvokeInst* v = dyn_cast<InvokeInst>(inst)) {
		return std::make_unique<make_shared_enabler>(nullptr, v);
	}
	return nullptr;
}

const llvm::Function* FakeCallBase::getCalledFunction() const {
	if (c)
		return c->getCalledFunction();
	if (v)
		return v->getCalledFunction();
	assert(false);
	return nullptr;
}

const llvm::Value* FakeCallBase::getCalledValue() const {
	if (c)
		return c->getCalledValue();
	if (v)
		return v->getCalledValue();
	assert(false);
	return nullptr;
}

// copied from LLVM
bool FakeCallBase::isIndirectCall() const {
	const llvm::Value *V = getCalledValue();
	if (llvm::isa<llvm::Function>(V) || llvm::isa<llvm::Constant>(V))
		return false;
	if (c && c->isInlineAsm())
		return false;
	return true;
}

bool FakeCallBase::isInlineAsm() const {
	if (c)
		return c->isInlineAsm();
	if (v)
		assert(false);
		return false;
	assert(false);
	return false;
}

std::string print_argument(Value* argument) {
	std::string type_str;
	raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() + "\"\n";
}

std::string print_type(Type* argument) {
	std::string type_str;
	raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() + "\"\n";
}

bool isCallToLLVMIntrinsic(const Instruction* inst) {
	if (auto call = FakeCallBase::create(inst)) {
		const Function* func = call->getCalledFunction();
		if (func && func->isIntrinsic()) {
			return true;
		}
	}
	return false;
}

bool isInlineAsm(const Instruction* inst) {
	if (auto call = FakeCallBase::create(inst)) {
		return call->isInlineAsm();
	}
	return false;
}
