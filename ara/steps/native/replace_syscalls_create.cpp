// vim: set noet ts=4 sw=4:

#include "replace_syscalls_create.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/TypeFinder.h"

#include <boost/graph/filtered_graph.hpp>
#include <boost/python.hpp>
#include <boost/range/iterator_range_core.hpp>

using namespace ara::graph;
using namespace boost::python;

namespace ara::step {
	using namespace llvm;

	/* xTaskCreate() may take a reference parameter which needs to be filled here */
	PyObject* ReplaceSyscallsCreate::handle_tcb_ref_param(IRBuilder<>& Builder, Value* tcb_ref, Value* the_tcb) {
		if (Constant* CI = dyn_cast<Constant>(tcb_ref)) {
			if (!CI->isZeroValue()) {
				logger.debug() << "handle != 0: " << std::endl;
				Value* handle = Builder.CreatePointerCast(tcb_ref, PointerType::get(the_tcb->getType(), 0));
				Builder.CreateStore(the_tcb, handle);
			} else {
				logger.debug() << "handle == 0 --> nothing to do" << std::endl;
			}
		} else if (GetElementPtrInst* EP = dyn_cast<GetElementPtrInst>(tcb_ref)) {
			logger.debug() << "storing getelementptr: " << *EP << std::endl;
			Value* the_tcb_casted = Builder.CreatePointerCast(the_tcb, EP->getType()->getPointerElementType(), "cst");
			Builder.CreateStore(the_tcb_casted, EP);
		} else if (AllocaInst* AL = dyn_cast<AllocaInst>(tcb_ref)) {
			logger.debug() << "storing local AllocaInst: " << *AL << std::endl;
			Value* the_tcb_casted = Builder.CreatePointerCast(the_tcb, AL->getType()->getElementType(), "casted");
			Builder.CreateStore(the_tcb_casted, tcb_ref);
		} else {
			// TODO: use ret value. check if handle != null, set handle
			logger.error()
			    << "NOT IMLEMENTED: Need to generate runtime checking code for task_handle in xTaskCreate call for "
			    << *the_tcb << " with " << *tcb_ref << std::endl;
			return PyErr_Format(PyExc_NotImplementedError,
			                    "Need to generate runtime checking code for task_handle in xTaskCreate call");
		}
		Py_RETURN_NONE;
	}

	PyObject* ReplaceSyscallsCreate::replace_call_with_true(CallBase* call) {
		// return true;
		Value* pdTrue = ConstantInt::get(call->getFunctionType()->getReturnType(), true, false);
		call->replaceAllUsesWith(pdTrue);
		// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling
		// piniter wit failing assert: "Use still stuck around after Def is destroyed"
		call->eraseFromParent();
		Py_RETURN_NONE;
	}

	Function* ReplaceSyscallsCreate::get_fn(const char* name) {
		Function* fn = graph.get_module().getFunction(name);
		if (fn != nullptr) {
			logger.debug() << "found '" << name << "' candidate: " << fn->getName().str() << std::endl;
			return fn;
		}
		logger.error() << "function declaration '" << name << "' not found!: Candidates are:\n";
		for (auto& fn : graph.get_module().getFunctionList()) {
			logger.error() << fn.getName().str() << "\n";
		}
		logger.error() << std::endl;
		logger.error() << "function declaration '" << name << "' not found!" << std::endl;
		return nullptr;
	}

	PyObject* ReplaceSyscallsCreate::change_linkage_to_global(GlobalVariable* gv) {
		// GlobalVariable * gv = graph.get_module().getGlobalVariable(name, true);
		logger.debug() << "change linkage of " << *gv << " from " << gv->getLinkage() << " to external" << std::endl;
		if (gv == nullptr) {
			logger.info() << "global is nullptr" << std::endl;
			Py_RETURN_NONE;
		}
		gv->setLinkage(GlobalValue::ExternalLinkage);
		Py_RETURN_NONE;
	}

	template <class Graph>
	void create_bb_dispatched(Graph g, graph::CFG& cfg, int64_t abb, BasicBlock*& llvm_bb) {
		llvm_bb = cfg.get_llvm_bb<Graph>(cfg.get_entry_bb(g, abb));
	}

	BasicBlock* ReplaceSyscallsCreate::create_bb(object task) {
		graph::CFG cfg = graph.get_cfg();
		BasicBlock* ret_bb = nullptr;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) { create_bb_dispatched(g, cfg, extract<int64_t>(task.attr("abb")), ret_bb); },
		    graph_tool::always_directed())(cfg.graph.get_graph_view());
		return ret_bb;
	}

	PyObject* ReplaceSyscallsCreate::replace_call_with_activate(CallBase* call, Value* tcb) {

		Function* activate_fn = get_fn("__ara_vTaskActivate");
		// Function* activate_fn = get_fn("vTaskResume" /*"__ara_vTaskActivate" */);
		if (activate_fn == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "__ara_vTaskActivate not found");
		}
		SmallVector<Value*, 1> new_args(1);
		new_args[0] = {tcb};

		IRBuilder<> Builder(graph.get_module().getContext());
		Builder.SetInsertPoint(call);
		Value* success = Builder.CreateCall(activate_fn, new_args);
		if (success == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "failed to create __ara_vTaskActivate call");
		}

		replace_call_with_true(call);
		Py_RETURN_NONE;
	}

	PyObject* ReplaceSyscallsCreate::replace_queue_create_static(object queue) {
		Module& module = graph.get_module();
		BasicBlock* bb = create_bb(queue);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueGenericCreate" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			return PyErr_Format(PyExc_RuntimeError, "wrong function found. Expected xQueueGenericCreate.");
		}
		Function* create_static_fn = get_fn("xQueueGenericCreateStatic");
		if (create_static_fn == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "xQueueCenericStatic not found");
		}

		std::string name_str = extract<std::string>(queue.attr("impl").attr("head").attr("name"));
		GlobalVariable* queue_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(3))->getElementType(),
		    // get_type(module, logger, freertos_types::queue_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr, // initializer
		    name_str,
		    nullptr, // insertBefore
		    GlobalVariable::NotThreadLocal,
		    0,      // AddressSpace
		    false); // isExternallyInitialized
		queue_meta_data_val->setDSOLocal(true);
		Value* queue_data_val;
		auto queue_data_ty = dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(2));
		std::string symbol_storage = extract<std::string>(queue.attr("impl").attr("data").attr("name"));
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
		Py_RETURN_NONE;
	}

	PyObject* ReplaceSyscallsCreate::replace_mutex_create_static(object mutex) {
		Module& module = graph.get_module();
		BasicBlock* bb = create_bb(mutex);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueCreateMutex" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			return PyErr_Format(PyExc_RuntimeError, "wrong function found. Expected xQueueGenericCreate.");
		}
		Function* create_static_fn = get_fn("xQueueCreateMutexStatic");
		if (create_static_fn == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "xQueueCreateMutexStatic not found");
		}

		std::string name_str = extract<std::string>(mutex.attr("impl").attr("head").attr("name"));
		GlobalVariable* mutex_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(1))->getElementType(),
		    // get_type(module, logger, freertos_types::mutex_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr, // initializer
		    name_str,
		    nullptr, // insertBefore
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
		Py_RETURN_NONE;
	}

	PyObject* ReplaceSyscallsCreate::replace_mutex_create_initialized(object mutex) {
		Module& module = graph.get_module();
		BasicBlock* bb = create_bb(mutex);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueCreateMutex" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << " expected: xQueueCreateMutex"
			               << std::endl;
			return PyErr_Format(PyExc_RuntimeError, "wrong function found. Expected xQueueGenericCreate.");
		}
		Function* create_static_fn = get_fn("xQueueCreateMutexStatic");
		if (create_static_fn == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "xQueueCreateMutexStatic not found");
		}

		llvm::IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);

		std::string name_str = extract<std::string>(mutex.attr("impl").attr("head").attr("name"));
		GlobalVariable* mutex_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(1))->getElementType(),
		    // get_type(module, logger, freertos_types::mutex_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr, // initializer
		    name_str,
		    nullptr, // insertBefore
		    GlobalVariable::NotThreadLocal,
		    0,      // AddressSpace
		    false); // isExternallyInitialized
		mutex_meta_data_val->setDSOLocal(true);
		Value* handle = Builder.CreatePointerCast(mutex_meta_data_val, old_func->getFunctionType()->getReturnType());
		old_create_call->replaceAllUsesWith(handle);
		// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling piniter
		// wit failing assert: "Use still stuck around after Def is destroyed"
		old_create_call->eraseFromParent();
		Py_RETURN_NONE;
	}

	PyObject* ReplaceSyscallsCreate::replace_queue_create_initialized(object queue) {
		Module& module = graph.get_module();
		BasicBlock* bb = create_bb(queue);
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		assert(old_func != nullptr && "Missing call target");

		if ("xQueueGenericCreate" != old_func->getName().str()) {
			logger.error() << "wrong function found: " << old_func->getName().str() << " expected: xQueueGenericCreate"
			               << std::endl;
			return PyErr_Format(PyExc_RuntimeError, "wrong function found. Expected xQueueGenericCreate.");
		}
		Function* create_static_fn = get_fn("xQueueGenericCreateStatic");
		if (create_static_fn == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "xQueueGenericCreateStatic not found");
		}

		llvm::IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);

		std::string name_str = extract<std::string>(queue.attr("impl").attr("head").attr("name"));
		GlobalVariable* queue_meta_data_val = new GlobalVariable(
		    module, // module
		    dyn_cast<PointerType>(create_static_fn->getFunctionType()->getParamType(3))->getElementType(),
		    // get_type(module, logger, freertos_types::queue_metadata), // type
		    false, // isConstant
		    GlobalValue::ExternalLinkage,
		    nullptr, // initializer
		    name_str,
		    nullptr, // insertBefore
		    GlobalVariable::NotThreadLocal,
		    0,      // AddressSpace
		    false); // isExternallyInitialized
		queue_meta_data_val->setDSOLocal(true);
		Value* handle = Builder.CreatePointerCast(queue_meta_data_val, old_func->getFunctionType()->getReturnType());
		old_create_call->replaceAllUsesWith(handle);
		// NOTE: It is eraseFromParent() rather than removeFromParent() since remove doesn't delete --> dangling piniter
		// wit failing assert: "Use still stuck around after Def is destroyed"
		old_create_call->eraseFromParent();
		Py_RETURN_NONE;
	}

	PyObject* ReplaceSyscallsCreate::replace_task_create_static(object task) {
		Module& module = graph.get_module();
		BasicBlock* bb = create_bb(task);
		std::string tcb_name = extract<std::string>(task.attr("impl").attr("tcb").attr("name"));
		std::string stack_name = extract<std::string>(task.attr("impl").attr("stack").attr("name"));
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		logger.info() << "replace to xTaskCreateStatic: " << tcb_name << std::endl;

		if ("xTaskCreate" != old_func->getName().str()) {
			if ("vTaskStartScheduler" == old_func->getName().str()) {
				logger.info() << "skipping idle task" << std::endl;
				Py_RETURN_NONE;
			}
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			return PyErr_Format(PyExc_RuntimeError, "wrong function");
		}

		Function* create_static_fn = get_fn("xTaskCreateStatic");
		if (create_static_fn == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "xTaskCreateStatic not found");
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

		if (new_args[2]->getType() != create_static_fn->getFunctionType()->getParamType(2)) {
			logger.warning() << "fixing type of " << *new_args[2] << std::endl;
			CastInst* casted_stacksize =
			    CastInst::CreateIntegerCast(new_args[2], create_static_fn->getFunctionType()->getParamType(2), false,
			                                "casted_stacksize", old_create_call);
			new_args[2] = casted_stacksize;
		}

		IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);
		Value* new_ret = Builder.CreateCall(create_static_fn, new_args, "static_handle");
		if (new_ret == nullptr) {
			return PyErr_Format(PyExc_RuntimeError, "failed to create xTaskCreateStattic call");
		}
		logger.debug() << "handle: " << *old_create_call->getArgOperand(5) << std::endl;

		if (!handle_tcb_ref_param(Builder, old_create_call->getArgOperand(5), task_tcb)) {
			return nullptr;
		}

		if (!replace_call_with_true(old_create_call)) {
			return nullptr;
		}
		Py_RETURN_NONE;
	}

	PyObject* ReplaceSyscallsCreate::replace_task_create_initialized(object task) {
		Module& module = graph.get_module();
		BasicBlock* bb = create_bb(task);
		std::string tcb_name = extract<std::string>(task.attr("impl").attr("tcb").attr("name"));
		CallBase* old_create_call = dyn_cast<CallBase>(&bb->front());
		Function* old_func = old_create_call->getCalledFunction();

		if ("xTaskCreate" != old_func->getName().str()) {
			if ("vTaskStartScheduler" == old_func->getName().str()) {
				// skip idle task
				Py_RETURN_NONE;
			}
			logger.error() << "wrong function found: " << old_func->getName().str() << std::endl;
			return PyErr_Format(PyExc_RuntimeError, "wrong function found %s", old_func->getName().str().data());
		}
		// make task function linkable for the tcb and stack
		graph::CFG cfg = graph.get_cfg();
		Function* taskFN;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    using Graph = typename std::remove_reference<decltype(g)>::type;
			    auto f = extract<typename boost::graph_traits<Graph>::vertex_descriptor>(task.attr("function"));
			    taskFN = cfg.get_llvm_function<Graph>(f);
		    },
		    graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (!taskFN->hasExternalLinkage()) {
			taskFN->setLinkage(GlobalValue::ExternalLinkage);
		}

		IRBuilder<> Builder(module.getContext());
		Builder.SetInsertPoint(old_create_call);

		GlobalVariable* task_tcb = new GlobalVariable(
		    module, old_func->getFunctionType()->getParamType(5)->getPointerElementType()->getPointerElementType(),
		    false, GlobalValue::ExternalLinkage, nullptr, tcb_name, nullptr, GlobalVariable::NotThreadLocal, 0, false);

		if (!handle_tcb_ref_param(Builder, old_create_call->getArgOperand(5), task_tcb)) {
			return nullptr;
		}
		if (extract<bool>(task.attr("after_scheduler"))) {
			logger.debug() << "create call is after_scheduler:" << *old_create_call << std::endl;
			if (!replace_call_with_activate(old_create_call, task_tcb)) {
				return nullptr;
			}
		} else {
			logger.debug() << "create is before_scheduler: " << old_create_call << std::endl;
			if (!replace_call_with_true(old_create_call)) {
				return nullptr;
			}
		}
		object py_task_parameters = extract<object>(task.attr("parameters"));
		if (! py_task_parameters.is_none()) {
			if (GlobalVariable* gv = dyn_cast_or_null<GlobalVariable>(get_value_from_obj(py_task_parameters.ptr()))) {
				change_linkage_to_global(gv);
			}
		}
		Py_RETURN_NONE;
		return PyErr_Format(PyExc_RuntimeError, "moin");
		PyErr_SetString(PyExc_RuntimeError, "hello exception");
		return NULL;
	}

	PyObject* ReplaceSyscallsCreate::replace_task_create(object task) {
		try {
			logger.debug() << "the task: " << task << std::endl;
			object impl = task.attr("impl");
			str init_type = extract<str>(task.attr("specialization_level"));
			if (init_type == "static") {
				return replace_task_create_static(task);
			} else if (init_type == "initialized") {
				return replace_task_create_initialized(task);
			} else if (init_type == "unchanged") {
				Py_RETURN_NONE;
			} else {
				logger.error() << "unknown init type"
				               // << init_type
				               << std::endl;
			}
			Py_RETURN_NONE;
		} catch (const error_already_set&) {
			PyObject *e, *v, *t;
			PyErr_Fetch(&e, &v, &t);
			PyErr_Restore(e, v, t);
			return NULL;
		}
	}
	PyObject* ReplaceSyscallsCreate::replace_queue_create(object queue) {
		try {
			logger.debug() << "the queue: " << queue << std::endl;
			object impl = queue.attr("impl");
			str init_type = extract<str>(queue.attr("specialization_level"));
			if (init_type == "static") {
				return replace_queue_create_static(queue);
			} else if (init_type == "initialized") {
				return replace_queue_create_initialized(queue);
			} else if (init_type == "unchanged") {
				Py_RETURN_NONE;
			} else {
				logger.error() << "unknown init type" << std::endl;
			}
			Py_RETURN_NONE;
		} catch (const error_already_set&) {
			PyObject *e, *v, *t;
			PyErr_Fetch(&e, &v, &t);
			PyErr_Restore(e, v, t);
			return NULL;
		}
	}

	PyObject* ReplaceSyscallsCreate::replace_mutex_create(object mutex) {
		try {
			logger.debug() << "the mutex: " << mutex << std::endl;
			object impl = mutex.attr("impl");
			str init_type = extract<str>(mutex.attr("specialization_level"));
			if (init_type == "static") {
				return replace_mutex_create_static(mutex);
			} else if (init_type == "initialized") {
				return replace_mutex_create_initialized(mutex);
			} else if (init_type == "unchanged") {
				Py_RETURN_NONE;
			} else {
				logger.error() << "unknown init type" << std::endl;
			}
			Py_RETURN_NONE;
		} catch (const error_already_set&) {
			PyObject *e, *v, *t;
			PyErr_Fetch(&e, &v, &t);
			PyErr_Restore(e, v, t);
			return NULL;
		}
	}

	std::string ReplaceSyscallsCreate::get_description() {
		return "Replace Create-syscalls with their static pendants.";
	}

	void ReplaceSyscallsCreate::run() {
		graph::InstanceGraph instances = graph.get_instances();
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    object freertos = import("ara.os.freertos");
			    object task_cls = freertos.attr("Task");
			    object queue_cls = freertos.attr("Queue");
			    object mutex_cls = freertos.attr("Mutex");
			    for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				    boost::python::object inst = instances.obj[v];
				    if (PyObject_IsInstance(inst.ptr(), task_cls.ptr())) {
					    replace_task_create(inst);
				    } else if (PyObject_IsInstance(inst.ptr(), queue_cls.ptr())) {
					    replace_queue_create(inst);
				    } else if (PyObject_IsInstance(inst.ptr(), mutex_cls.ptr())) {
					    replace_mutex_create(inst);
				    } else {
					    logger.error() << "unknown instance: " << inst << std::endl;
				    }
			    }
		    },
		    graph_tool::always_directed())(instances.graph.get_graph_view());
	}
} // namespace ara::step
