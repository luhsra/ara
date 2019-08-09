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
