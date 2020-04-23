// vim: set noet ts=4 sw=4:

#include "replace_syscalls_create.h"


#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/TypeFinder.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/GlobalVariable.h"

#include <boost/graph/filtered_graph.hpp>
using namespace ara::graph;


namespace ara::step {
	using namespace llvm;

	// ATTENTION: put in anonymous namespace to get an unique symbol
	namespace {

		Type* get_queue_meta_data_type(Module& module, Logger& logger) {
			static Type* ty = nullptr;
			if (ty != nullptr) {
				return ty;
			}
			// queue meta data Storage: search for "struct xSTATIC_QUEUE"
			llvm::TypeFinder type_finder;
			type_finder.run(module, true);
			for (llvm::StructType *sTy: type_finder) {
				if (sTy->getName() == "struct.xSTATIC_QUEUE") {
					ty = sTy;
					logger.debug() << "queue_meta_data_ty found: " << *sTy << std::endl;
					return ty;
				}
			}
			if (ty == nullptr) { // not found --> create opaque type
				ty = llvm::StructType::create(module.getContext(), "struct.xSTATIC_QUEUE");
				logger.debug() << "Created struct.xSTATIC_QUEUE type: " << *ty << std::endl;
			}
			return ty;
		}

		Function* get_queue_generic_create_static_fn(Module &module, Logger &logger) {
			static Function* fn = module.getFunction("xQueueGenericCreateStatic");
			if (fn != nullptr) {
				return fn;
			}
			FunctionType *old_ft = module.getFunction("xQueueGenericCreate")->getFunctionType();
			SmallVector<llvm::Type*, 5> new_args_ty(5);
			new_args_ty[0] = old_ft->getParamType(0);
			new_args_ty[1] = old_ft->getParamType(1);
			new_args_ty[2] = llvm::Type::getInt8PtrTy(module.getContext());//queue_data_ty;
			new_args_ty[3] = llvm::PointerType::get(get_queue_meta_data_type(module, logger), 0);
			new_args_ty[4] = old_ft->getParamType(2);
			FunctionType *new_ft = FunctionType::get(old_ft->getReturnType(), new_args_ty, false /* isVararg */);
			fn = llvm::Function::Create(new_ft, llvm::Function::ExternalLinkage, "xQueueGenericCreateStatic", module);
			logger.debug() << "new xQueueGenericCreateStatic: " << *fn << std::endl;
			return fn;
		}

	} // namespace

	std::string ReplaceSyscallsCreate::get_description() const {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void ReplaceSyscallsCreate::fill_options() { }


	void ReplaceSyscallsCreate::run(graph::Graph& graph) {
		logger.err() << "this should never happen" << std::endl;
		exit(1);
		return;
	}

	bool ReplaceSyscallsCreate::replace_queue_create_static(graph::Graph& graph, int where, char *symbol_metadata, char *symbol_storage) {
		Module &module = graph.get_module();
		BasicBlock *bb = reinterpret_cast<BasicBlock*>(where);
		CallBase *old_create_call = dyn_cast<CallBase>(&bb->front());
		Function *old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueGenericCreate" != old_func->getName().str()) {
			logger.err() <<  "wrong function found: " << old_func->getName().str() << std::endl;
			exit(1);
		}
		assert(old_func->arg_size() == 3 && "Wrong number of parameters");
		for (auto &arg : old_func->args()) {
			logger.debug() << "arg: " << arg <<std::endl;
		}

		GlobalVariable *queue_meta_data_val = new GlobalVariable(module, // module
																 get_queue_meta_data_type(module, logger), // type
																 false, // isConstant
																 GlobalValue::ExternalLinkage,
																 nullptr, // initializer
																 symbol_metadata, // name
																 nullptr, // insertBefore
																 GlobalVariable::NotThreadLocal,
																 0, // AddressSpace
																 false); // isExternallyInitialized
		queue_meta_data_val->setDSOLocal(true);
		GlobalVariable *queue_data_val = new GlobalVariable(module, // module
															Type::getInt8Ty(module.getContext()), // type
															false, // isConstant
															GlobalValue::ExternalLinkage,
															nullptr, // initializer
															symbol_storage, // name
															nullptr, // insertBefore
															GlobalVariable::NotThreadLocal,
															0, // AddressSpace
															false); // isExternallyInitialized
		queue_data_val->setDSOLocal(true);

		SmallVector<Value*, 5> new_args;
		new_args.push_back(old_create_call->getArgOperand(0));
		new_args.push_back(old_create_call->getArgOperand(1));
		new_args.push_back(queue_data_val);
		new_args.push_back(queue_meta_data_val);
		new_args.push_back(old_create_call->getArgOperand(2));

		llvm::IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);
		Value *new_ret = Builder.CreateCall(get_queue_generic_create_static_fn(module, logger), new_args, "static_queue");
		logger.debug() << "new ret: " << *new_ret << std::endl;
		old_create_call->replaceAllUsesWith(new_ret);
		old_create_call->removeFromParent();
		return true;
	}
} // namespace ara::step
