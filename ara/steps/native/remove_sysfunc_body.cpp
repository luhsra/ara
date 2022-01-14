
#include "remove_sysfunc_body.h"

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

#include <os.h>
#include <pyllco.h>
#include <vector>

namespace ara::step {
	using namespace llvm;

	std::string RemoveSysfuncBody::get_description() {
		return "Remove function bodies of system functions that the OS model interprets.\n"
		       "This cleans unnecessary information in different graphs.\n";
	}

	void RemoveSysfuncBody::init_options() {
		drop_llvm_suffix_option = drop_llvm_suffix_option_template.instantiate(get_name());
		opts.emplace_back(drop_llvm_suffix_option);
	}

	/**
	 * @brief Print an error message and quit the program if the condition cond is not true.
	 *
	 * 	Python Exceptions are shown in the terminal.
	 *  If you provide the error_with_obj obj then this function prints the python Type of this object.
	 *  (Only if cond is false)
	 *
	 * @param cond condition to check
	 * @param msg error msg
	 * @param error_with_obj this function prints the python Type of this argument on error. Optional.
	 */
	void RemoveSysfuncBody::py_assert(bool cond, const std::string& msg, const PyObject* error_with_obj = nullptr) {
		if (!cond) {
			logger.err() << msg << std::endl;
			if (PyErr_Occurred())
				PyErr_Print();
			if (error_with_obj != nullptr) {
				PyTypeObject* type = error_with_obj->ob_type;
				const char* type_str = type->tp_name;
				logger.err() << "The Type of the object involved was: " << type_str << std::endl;
			}
			abort();
		}
	}

	/**
	 * @brief Call ara.os.get_oses() and return all OS objects in a vector.
	 *
	 * @return std::vector<ara::os::OS> all os objects.
	 */
	std::vector<ara::os::OS> RemoveSysfuncBody::py_get_oses() {

		PyObject* ara_os = PyImport_ImportModule("ara.os");
		this->py_assert(ara_os != nullptr, "ara.os python module not found!");

		PyObject* get_oses = PyObject_GetAttrString(ara_os, "get_oses");
		this->py_assert(get_oses != nullptr, "ara.os.get_oses() python function not found!");
		this->py_assert(PyFunction_Check(get_oses), "ara.os.get_oses() is not a python function!", get_oses);

		// Call ara.os.get_oses()
		PyObject* os_list = PyObject_CallObject(get_oses, NULL);
		this->py_assert(os_list != nullptr, "Error while calling ara.os.get_oses() python function!");

		PyObject* os_iter = PyObject_GetIter(os_list);
		this->py_assert(os_iter != nullptr,
		                "ara.os.get_oses() python function returned an object that cannot be cast to an Iterator!",
		                os_list);

		// Map Python OS Model -> ara::os::OS
		std::vector<ara::os::OS> os_vec;
		PyObject* os;
		while ((os = PyIter_Next(os_iter))) {
			this->py_assert(PyObject_HasAttrString(os, "detected_syscalls"),
			                "os object has no detected_syscalls() attribute!", os);
			os_vec.emplace_back(os);
			Py_DECREF(os);
		}

		// handle error
		if (PyErr_Occurred()) {
			PyErr_Print();
			abort();
		}

		// Clean up Python objects
		Py_DECREF(os_iter);
		Py_DECREF(os_list);
		Py_DECREF(get_oses);
		Py_DECREF(ara_os);

		return os_vec;
	}

	/*
	    Returns the syscall map (name -> SysCall) of the current OS.
	    Detects the current OS if --os is not set.
	*/

	/**
	 * @brief Return the syscall map (name -> SysCall) of the current OS.
	 *
	 * Detects the current OS if runtime argument --os is not set.
	 *
	 * @return syscall_map All syscall names with their aliases of the current OS in the form (name -> SysCall).
	 */
	syscall_map RemoveSysfuncBody::get_os_syscalls() {

		if (this->graph.has_os_set()) {
			return this->graph.get_os().detected_syscalls();
		}

		// Find first sysfunc to detect OS.
		std::vector<ara::os::OS> oses = this->py_get_oses();
		Module& module = graph.get_module();
		for (const ara::os::OS& os : oses) {
			syscall_map os_syscalls = os.detected_syscalls();
			for (const auto& syscall : os_syscalls) {
				if (module.getFunction(StringRef(syscall.first)) != nullptr) { // if function found
					logger.debug() << "Detected " << os.get_name() << " OS." << std::endl;
					return os_syscalls;
				}
			}
		}

		logger.err() << "No Syscalls detected!" << std::endl;
		abort();
	}

	/**
	 * @brief Required to get the argument drop_llvm_suffix_func for the function drop_llvm_suffix
	 *
	 * @return PyObject* Python function ara.util.drop_llvm_suffix_func()
	 */
	PyObject* RemoveSysfuncBody::get_drop_llvm_suffix_func() {
		PyObject* ara_util = PyImport_ImportModule("ara.util");
		this->py_assert(ara_util != nullptr, "ara.util python module not found!");

		PyObject* drop_llvm_suffix_func = PyObject_GetAttrString(ara_util, "drop_llvm_suffix");
		this->py_assert(drop_llvm_suffix_func != nullptr, "ara.util.drop_llvm_suffix() python function not found!");
		this->py_assert(PyFunction_Check(drop_llvm_suffix_func),
		                "ara.util.drop_llvm_suffix() is not a python function!", drop_llvm_suffix_func);

		Py_DECREF(ara_util);
		return drop_llvm_suffix_func;
	}

	/**
	 * @brief Remove the llvm suffix from a name.
	 *
	 * E.g. sleep.5 -> sleep
	 *
	 * This function calls the python function ara.util.drop_llvm_suffix_func()
	 *
	 * @param drop_llvm_suffix_func The python function ara.util.drop_llvm_suffix_func(). Use
	 * get_drop_llvm_suffix_func() to generate this object.
	 * @param func_name function name to drop the llvm suffix from.
	 * @return PyObject* Unicode/str object that holds the name without llvm suffix.
	 */
	PyObject* RemoveSysfuncBody::drop_llvm_suffix(PyObject* drop_llvm_suffix_func, const llvm::StringRef& func_name) {
		// Call ara.util.drop_llvm_suffix()
		PyObject* name = PyObject_CallFunctionObjArgs(
		    drop_llvm_suffix_func, PyUnicode_FromStringAndSize(func_name.data(), func_name.size()), NULL);
		this->py_assert(name != nullptr, "Error while calling ara.util.drop_llvm_suffix() python function!");
		this->py_assert(PyUnicode_Check(name),
		                "ara.util.drop_llvm_suffix() python function not returned a unicode/str object!", name);
		return name;
	}

	void RemoveSysfuncBody::run() {

		syscall_map os_syscalls = this->get_os_syscalls();

		// Delete the body of all system functions
		Module& module = graph.get_module();
		if (drop_llvm_suffix_option.get().value_or(false)) {
			PyObject* drop_llvm_suffix_func = this->get_drop_llvm_suffix_func();
			for (Function& func : module) { // Iterate over all functions

				// Delete the body if function name equals a syscall name (with or without llvm suffix e.g. sleep.3)
				PyObject* py_name = this->drop_llvm_suffix(drop_llvm_suffix_func, func.getName());
				const char* name = PyUnicode_AsUTF8(py_name);
				this->py_assert(name != nullptr, "Unicode py_name cannot be cast to UTF-8 name!");
				if (os_syscalls.find(name) != os_syscalls.end()) {
					logger.debug() << "Remove function body of " << func.getName().str() << std::endl;
					func.deleteBody();
				}
				Py_DECREF(py_name);
			}
			Py_DECREF(drop_llvm_suffix_func);
		} else {
			for (const auto& syscall : os_syscalls) {

				// Delete the body if the function exists
				Function* func = module.getFunction(StringRef(syscall.first));
				if (func != nullptr) {
					logger.debug() << "Remove function body of " << syscall.first << std::endl;
					func->deleteBody();
				}
			}
		}

		// Dump modified LLVM IR
		if (*dump.get()) {
			std::string ir_file = *dump_prefix.get() + "ll";
			llvm::json::Value ir_printer_conf(llvm::json::Object{{"name", "IRWriter"}, {"ir_file", ir_file}});
			step_manager.chain_step(ir_printer_conf);
		}
	}
} // namespace ara::step