// SPDX-FileCopyrightText: 2021 Jan Neugebauer
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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

	std::set<std::string> OS::get_syscall_names() const { return py_os_get_syscall_names(obj.ptr()); }
	SysCall OS::get_syscall(const std::string& name) const {
		return SysCall(py_os_get_syscall(obj.ptr(), name), obj.ptr());
	}
} // namespace ara::os
