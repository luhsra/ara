
#include "remove_sysfunc_body.h"

#include "llvm/ADT/StringRef.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

#include <Python.h>
#include <os.h>
#include <pyllco.h>
#include <vector>

namespace ara::step {
	using namespace llvm;

	std::string RemoveSysfuncBody::get_description() {
		return "Removes the libc function body of system functions that the OS model interprets.\n"
		       "This improves the performance of the analysis and cleans the CallGraph.\n"
		       "Warning: This step is only for the analysis!";
	}

	/*
	    Prints an Error Message and quits the program if the condition cond is not true.
	    Python Exceptions are shown in the terminal.
	    If you provide the error_with_obj obj then this function prints the python Type of this object.
	    (Only if cond == false)
	*/
	void RemoveSysfuncBody::py_assert(bool cond, std::string msg, PyObject* error_with_obj = nullptr) {
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

	/*
	    Calls ara.os.get_oses() and returns all OS objects in a vector.
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
			// Py_DECREF(os);
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

	void RemoveSysfuncBody::run() {

		syscall_map os_syscalls = this->get_os_syscalls();

		// Delete the body of all system functions
		Module& module = graph.get_module();
		for (const auto& syscall : os_syscalls) {

			// Delete the body if the function exists
			Function* func = module.getFunction(StringRef(syscall.first));
			if (func != nullptr) {
				logger.debug() << "Remove function body of " << syscall.first << std::endl;
				func->deleteBody();
			}
			// else {
			//    logger.err() << "Could not find function with name \'" << syscall.first << "\' in LLVM IR." <<
			//    std::endl;
			//}
		}

		// Dump modified LLVM IR
		if (*dump.get()) {
			std::string ir_file = *dump_prefix.get() + "ll";
			llvm::json::Value ir_printer_conf(llvm::json::Object{{"name", "IRWriter"}, {"ir_file", ir_file}});
			step_manager.chain_step(ir_printer_conf);
		}
	}
} // namespace ara::step