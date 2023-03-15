// SPDX-FileCopyrightText: 2021 Jan Neugebauer
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * This is a very lightweight representation of the operating system model.
 */
#pragma once

#include "mix.h" // graph.h is not possible due to circular dependencies

#include <Python.h>
#include <boost/python.hpp>
#include <set>
#include <string>
#include <vector>

namespace ara::os {
	class OS;

	class SysCall {
	  private:
		boost::python::object obj;
		boost::python::object
		    os; // it is quite complicated to get this back from obj, see https://stackoverflow.com/questions/3589311/

	  public:
		explicit SysCall(PyObject* obj, PyObject* os);
		explicit SysCall(boost::python::object obj, boost::python::object os) : obj(obj), os(os){};
		std::string get_name() const;
		OS get_os() const;
		std::vector<graph::SigType> get_signature() const;
	};

	class OS {
	  private:
		boost::python::object obj;

	  public:
		explicit OS(PyObject* obj);
		explicit OS(boost::python::object obj) : obj(obj){};
		std::string get_name() const;

		std::set<std::string> get_syscall_names() const;
		SysCall get_syscall(const std::string& name) const;
	};
} // namespace ara::os
