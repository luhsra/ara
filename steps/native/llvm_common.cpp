#include "llvm_common.h"

struct FakeCallBase::make_shared_enabler : public FakeCallBase {
	template <typename... Args> make_shared_enabler(Args&&... args) : FakeCallBase(std::forward<Args>(args)...) {}
};

std::unique_ptr<FakeCallBase> FakeCallBase::create(llvm::Instruction* inst) {
	if (llvm::CallInst* c = llvm::dyn_cast<llvm::CallInst>(inst)) {
		return std::make_unique<make_shared_enabler>(c, nullptr);
	}
	if (llvm::InvokeInst* v = llvm::dyn_cast<llvm::InvokeInst>(inst)) {
		return std::make_unique<make_shared_enabler>(nullptr, v);
	}
	return nullptr;
}

std::string print_argument(llvm::Value* argument) {
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() + "\"\n";
}

std::string print_type(llvm::Type* argument) {
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() + "\"\n";
}
