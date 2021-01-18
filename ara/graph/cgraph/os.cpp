#include "os.h"

#include "graph_data_pyx_wrapper.h"

namespace ara::os {
	SysCall::SysCall(PyObject* obj, PyObject* os)
	    : obj(boost::python::handle<>(boost::python::borrowed(obj))),
	      os(boost::python::handle<>(boost::python::borrowed(os))) {
		assert(obj != nullptr && os != nullptr && "SysCall cannot be constructed with nullptr.");
	}

	std::string SysCall::get_name() const { return py_syscall_get_name(obj.ptr()); }

	std::vector<graph::SigType> SysCall::get_signature() const { return py_syscall_get_signature(obj.ptr()); }

	OS SysCall::get_os() const { return OS(os); }

	OS::OS(PyObject* obj) : obj(boost::python::handle<>(boost::python::borrowed(obj))) {
		assert(obj != nullptr && "OS cannot be constructed with nullptr.");
	}

	std::string OS::get_name() const { return py_os_get_name(obj.ptr()); }

	std::map<const std::string, SysCall> OS::detected_syscalls() const { return py_os_detected_syscalls(obj.ptr()); }
} // namespace ara::os
