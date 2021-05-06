
#include "remove_syscall_body.h"

#include <Python.h>
#include <pyllco.h>
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"

namespace ara::step {
	using namespace llvm;

	std::string RemoveSyscallBody::get_description() {
		return "Removes the libc function body of syscalls which should be interpreted by the OS Model. Currently only the POSIX OS Model is supported.";
	}

    /*
        Prints an Error Message and quits the program if the condition cond is not true.
        Python Exceptions are shown in the terminal.
        If you provide the error_with_obj obj then will this function print the python Type of this object. (Only if cond == false)
    */
    void RemoveSyscallBody::py_assert(bool cond, std::string msg, PyObject* error_with_obj = nullptr) {
        if(!cond) {
            logger.err() << msg << std::endl;
            if(PyErr_Occurred())
                PyErr_Print();
            if(error_with_obj != nullptr) {
                PyTypeObject* type = error_with_obj->ob_type;
                const char* type_str = type->tp_name;
                logger.err() << "The Type of the object involved was: " << type_str << std::endl;
            }
            abort();
        }
    }

	void RemoveSyscallBody::run() {

        PyObject* ara_os = PyImport_ImportModule("ara.os");
        py_assert(ara_os != nullptr, "ara.os python module not found!");

        PyObject* get_syscalls = PyObject_GetAttrString(ara_os, "get_posix_syscalls");
        py_assert(get_syscalls != nullptr, "ara.os.get_posix_syscalls() python function not found!");
        py_assert(PyFunction_Check(get_syscalls), "ara.os.get_posix_syscalls() is not a python function!", get_syscalls);

        // Call ara.os.get_posix_syscalls()
        PyObject* syscall_list = PyObject_CallObject(get_syscalls, NULL);
        py_assert(syscall_list != nullptr, "Error while calling ara.os.get_posix_syscalls() python function!");

        PyObject* syscall_iter = PyObject_GetIter(syscall_list);
        py_assert(syscall_iter != nullptr, "ara.os.get_posix_syscalls() python function returned an object that cannot be cast to an Iterator!", syscall_list);

        // Delete the body of all syscall functions
        PyObject* syscall;
        Module& module = graph.get_module();
        while((syscall = PyIter_Next(syscall_iter))) {

            py_assert(PyUnicode_Check(syscall), "syscall obj in syscall_list is not a python Unicode object!", syscall);

            PyObject* syscall_unicode = PyUnicode_AsEncodedString(syscall, "utf-8", "strict");
            py_assert(syscall_unicode != nullptr, "Cannot cast python string in syscall_list to unicode byte object!");

            const char* syscall_name = PyBytes_AsString(syscall_unicode);
            py_assert(syscall_name != nullptr, "Error in PyBytes_AsString(syscall_unicode);");

            // Delete the body if the function exists
            Function* func = module.getFunction(StringRef(syscall_name));
            if(func != nullptr) {
                func->deleteBody();
            }
            //else {
            //    logger.err() << "Could not find function with name \'" << syscall_name << "\' in LLVM IR." << std::endl;
            //}

            // Clean up Python objects
            Py_DECREF(syscall_unicode);
            Py_DECREF(syscall);

        }

        // handle error
        if(PyErr_Occurred()) {
            PyErr_Print();
            abort();
        }

        // Clean up Python objects
        Py_DECREF(syscall_iter);
        Py_DECREF(syscall_list);
        Py_DECREF(get_syscalls);
        Py_DECREF(ara_os);

        // Dump modified LLVM IR 
        if (*dump.get()) {
            std::string ir_file = *dump_prefix.get() + "ll";
        	llvm::json::Value ir_printer_conf(llvm::json::Object{{"name", "IRWriter"},
			                                                     {"ir_file", ir_file}});
			step_manager.chain_step(ir_printer_conf);
		}

	}
} // namespace ara::step