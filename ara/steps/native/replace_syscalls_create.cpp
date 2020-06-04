// vim: set noet ts=4 sw=4:

#include "replace_syscalls_create.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/TypeFinder.h"

#include <boost/graph/filtered_graph.hpp>
using namespace ara::graph;

namespace ara::step {
	using namespace llvm;

	// ATTENTION: put in anonymous namespace to get an unique symbol
	namespace {
		bool handle_tcb_ref_param(IRBuilder<>& Builder, Value* tcb_ref, Value* the_tcb, Logger& logger) {
			if (Constant* CI = dyn_cast<Constant>(tcb_ref)) {
				if (!CI->isZeroValue()) {
					logger.debug() << "handle != 0: " << std::endl;
					Value* handle = Builder.CreatePointerCast(tcb_ref, PointerType::get(the_tcb->getType(), 0));
					Builder.CreateStore(the_tcb, handle);
				} else {
					logger.debug() << "handle == 0 --> nothing to do" << std::endl;
				}
			} else {
				// TODO: use ret value. check if handle != null, set handle
				logger.error()
				    << "NOT IMLEMENTED: Need to generate runtime checking code for task_handle in xTaskCreate call"
				    << std::endl;
				return false;
			}
			return true;
		}

		bool replace_call_with_true(CallBase* call) {
			// return true;
			Value* pdTrue = ConstantInt::get(call->getFunctionType()->getReturnType(), true, false);
			call->replaceAllUsesWith(pdTrue);
			// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling
			// piniter wit failing assert: "Use still stuck around after Def is destroyed"
			call->eraseFromParent();
			return true;
		}

		Function* get_fn(Module& module, Logger& logger, const char* name) {
			Function* fn = module.getFunction(name);
			if (fn != nullptr) {
				logger.debug() << "found '" << name << "' candidate: " << *fn << std::endl;
				return fn;
			}
			logger.error() << "function declaration '" << name << "' not found!" << std::endl;
			return nullptr;
		}

	} // namespace

	std::string ReplaceSyscallsCreate::get_description() const {
		return "Replace Create-syscalls with their static pendants";
	}

	void ReplaceSyscallsCreate::fill_options() {}

	void ReplaceSyscallsCreate::run(graph::Graph& graph) {
		(void)graph;
		logger.error() << "this should never happen" << std::endl;
		exit(1);
		return;
	}

	bool ReplaceSyscallsCreate::replace_queue_create_static(graph::Graph& graph, uintptr_t where, char* symbol_metadata,
	                                                        char* symbol_storage) {
		Module& module = graph.get_module();
		BasicBlock* bb = reinterpret_cast<BasicBlock*>(where);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueGenericCreate" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			exit(1);
		}
		Function* create_static_fn = get_fn(module, logger, "xQueueGenericCreateStatic");
		if (create_static_fn == nullptr) {
			return false;
		}

		GlobalVariable* queue_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(3))->getElementType(),
		    // get_type(module, logger, freertos_types::queue_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr,         // initializer
		    symbol_metadata, // name
		    nullptr,         // insertBefore
		    GlobalVariable::NotThreadLocal,
		    0,      // AddressSpace
		    false); // isExternallyInitialized
		queue_meta_data_val->setDSOLocal(true);
		Value* queue_data_val;
		auto queue_data_ty = dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(2));
		if (symbol_storage == std::string("nullptr")) {
			queue_data_val = ConstantPointerNull::get(queue_data_ty);
		} else {
			auto data = new GlobalVariable(module,                          // modulea
			                               queue_data_ty->getElementType(), // type
			                               false,                           // isConstant
			                               GlobalValue::ExternalLinkage,
			                               nullptr,        // initializer
			                               symbol_storage, // name
			                               nullptr,        // insertBefore
			                               GlobalVariable::NotThreadLocal,
			                               0,      // AddressSpace
			                               false); // isExternallyInitialized
			data->setDSOLocal(true);
			queue_data_val = data;
		}

		SmallVector<Value*, 5> new_args;
		new_args.push_back(old_create_call->getArgOperand(0));
		new_args.push_back(old_create_call->getArgOperand(1));
		new_args.push_back(queue_data_val);
		new_args.push_back(queue_meta_data_val);
		new_args.push_back(old_create_call->getArgOperand(2));

		llvm::IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);
		Value* new_ret = Builder.CreateCall(create_static_fn, new_args, "static_queue");
		logger.debug() << "new ret: " << *new_ret << std::endl;
		old_create_call->replaceAllUsesWith(new_ret);
		// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling piniter
		// wit failing assert: "Use still stuck around after Def is destroyed"
		old_create_call->eraseFromParent();
		return true;
	}

	bool ReplaceSyscallsCreate::replace_mutex_create_static(graph::Graph& graph, uintptr_t where,
	                                                        char* symbol_metadata) {
		Module& module = graph.get_module();
		BasicBlock* bb = reinterpret_cast<BasicBlock*>(where);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueCreateMutex" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			exit(1);
		}
		Function* create_static_fn = get_fn(module, logger, "xQueueCreateMutexStatic");
		if (create_static_fn == nullptr) {
			return false;
		}

		GlobalVariable* mutex_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(1))->getElementType(),
		    // get_type(module, logger, freertos_types::mutex_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr,         // initializer
		    symbol_metadata, // name
		    nullptr,         // insertBefore
		    GlobalVariable::NotThreadLocal,
		    0,      // AddressSpace
		    false); // isExternallyInitialized
		mutex_meta_data_val->setDSOLocal(true);

		SmallVector<Value*, 2> new_args;
		new_args.push_back(old_create_call->getArgOperand(0));
		new_args.push_back(mutex_meta_data_val);
		logger.debug() << "args created" << std::endl;

		llvm::IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);
		Value* new_ret = Builder.CreateCall(create_static_fn, new_args, "static_mutex");
		logger.debug() << "new ret: " << *new_ret << std::endl;
		old_create_call->replaceAllUsesWith(new_ret);
		// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling piniter
		// wit failing assert: "Use still stuck around after Def is destroyed"
		old_create_call->eraseFromParent();
		return true;
	}

	bool ReplaceSyscallsCreate::replace_mutex_create_initialized(graph::Graph& graph, uintptr_t where,
	                                                             char* symbol_metadata) {
		Module& module = graph.get_module();
		BasicBlock* bb = reinterpret_cast<BasicBlock*>(where);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueCreateMutex" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << " expected: xQueueCreateMutex"
			               << std::endl;
			exit(1);
		}
		Function* create_static_fn = get_fn(module, logger, "xQueueCreateMutexStatic");
		if (create_static_fn == nullptr) {
			return false;
		}

		llvm::IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);

		GlobalVariable* mutex_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(1))->getElementType(),
		    // get_type(module, logger, freertos_types::mutex_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr,         // initializer
		    symbol_metadata, // name
		    nullptr,         // insertBefore
		    GlobalVariable::NotThreadLocal,
		    0,      // AddressSpace
		    false); // isExternallyInitialized
		mutex_meta_data_val->setDSOLocal(true);
		Value* handle = Builder.CreatePointerCast(mutex_meta_data_val, old_func->getFunctionType()->getReturnType());
		old_create_call->replaceAllUsesWith(handle);
		// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling piniter
		// wit failing assert: "Use still stuck around after Def is destroyed"
		old_create_call->eraseFromParent();
		return true;
	}

	bool ReplaceSyscallsCreate::replace_queue_create_initialized(graph::Graph& graph, uintptr_t where,
	                                                             char* symbol_metadata) {
		Module& module = graph.get_module();
		BasicBlock* bb = reinterpret_cast<BasicBlock*>(where);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueGenericCreate" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << " expected: xQueueGenericCreate"
			               << std::endl;
			exit(1);
		}
		Function* create_static_fn = get_fn(module, logger, "xQueueGenericCreateStatic");
		if (create_static_fn == nullptr) {
			return false;
		}

		llvm::IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);

		GlobalVariable* queue_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(3))->getElementType(),
		    // get_type(module, logger, freertos_types::queue_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr,         // initializer
		    symbol_metadata, // name
		    nullptr,         // insertBefore
		    GlobalVariable::NotThreadLocal,
		    0,      // AddressSpace
		    false); // isExternallyInitialized
		queue_meta_data_val->setDSOLocal(true);
		Value* handle = Builder.CreatePointerCast(queue_meta_data_val, old_func->getFunctionType()->getReturnType());
		old_create_call->replaceAllUsesWith(handle);
		// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling piniter
		// wit failing assert: "Use still stuck around after Def is destroyed"
		old_create_call->eraseFromParent();
		return true;
	}

	bool ReplaceSyscallsCreate::replace_task_create_static(graph::Graph& graph, uintptr_t where, char* tcb_name,
	                                                       char* stack_name) {
		Module& module = graph.get_module();
		BasicBlock* bb = reinterpret_cast<BasicBlock*>(where);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		if ("xTaskCreate" != old_func->getName().str()) {
			if ("vTaskStartScheduler" == old_func->getName().str()) {
				logger.info() << "skipping idle task" << std::endl;
				return true;
			}
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			return false;
		}

		Function* create_static_fn = get_fn(module, logger, "xTaskCreateStatic");
		if (create_static_fn == nullptr) {
			return false;
		}

		GlobalVariable* task_tcb = new GlobalVariable(
		    module, dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(6))->getElementType(),
		    false, GlobalValue::ExternalLinkage, nullptr, tcb_name, nullptr, GlobalVariable::NotThreadLocal, 0, false);
		GlobalVariable* task_stack = new GlobalVariable(
		    module, dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(5))->getElementType(),
		    false, GlobalValue::ExternalLinkage, nullptr, stack_name, nullptr, GlobalVariable::NotThreadLocal, 0,
		    false);

		SmallVector<Value*, 7> new_args(7);
		new_args[0] = old_create_call->getArgOperand(0);
		new_args[1] = old_create_call->getArgOperand(1);
		new_args[2] = old_create_call->getArgOperand(2);
		new_args[3] = old_create_call->getArgOperand(3);
		new_args[4] = old_create_call->getArgOperand(4);
		new_args[5] = task_stack;
		new_args[6] = task_tcb;

		IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);
		Value* new_ret = Builder.CreateCall(create_static_fn, new_args, "static_handle");
		if (new_ret == nullptr) {
			return false;
		}
		logger.debug() << "handle: " << *old_create_call->getArgOperand(5) << std::endl;

		if (!handle_tcb_ref_param(Builder, old_create_call->getArgOperand(5), task_tcb, logger)) {
			return false;
		}

		if (!replace_call_with_true(old_create_call)) {
			return false;
		}
		return true;
	}

	bool ReplaceSyscallsCreate::replace_task_create_initialized(graph::Graph& graph, uintptr_t where, char* tcb_name) {
		Module& module = graph.get_module();
		BasicBlock* bb = reinterpret_cast<BasicBlock*>(where);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		if ("xTaskCreate" != old_func->getName().str()) {
			if ("vTaskStartScheduler" == old_func->getName().str()) {
				// skip idle task
				return true;
			}
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			return false;
		}

		IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);

		GlobalVariable* task_tcb = new GlobalVariable(
		    module, dyn_cast<PointerType>(old_func->getFunctionType()->getParamType(5))->getElementType(), false,
		    GlobalValue::ExternalLinkage, nullptr, tcb_name, nullptr, GlobalVariable::NotThreadLocal, 0, false);

		if (!handle_tcb_ref_param(Builder, old_create_call->getArgOperand(5), task_tcb, logger)) {
			return false;
		}
		if (!replace_call_with_true(old_create_call)) {
			return false;
		}
		return true;
	}

} // namespace ara::step
