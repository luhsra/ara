// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "option.h"

using namespace ara::option;

void Integer::from_pointer(PyObject* obj, std::string name) {
	if (!PyLong_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not an integer." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	int64_t value = PyLong_AsLongLong(obj);
	assert(value != -1 || PyErr_Occurred() == NULL);
	this->value = std::optional(value);
}

void Float::from_pointer(PyObject* obj, std::string name) {
	if (!PyFloat_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not a floating point number." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	double value = PyLong_AsDouble(obj);
	assert(value != -1.0 || PyErr_Occurred() == NULL);
	this->value = std::optional(value);
}

void Bool::from_pointer(PyObject* obj, std::string name) {
	if (!PyBool_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not a boolean." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	this->value = std::optional<bool>(PyObject_IsTrue(obj));
}

void String::from_pointer(PyObject* obj, std::string name) {
	if (!PyUnicode_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not a string." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	this->value = std::optional(std::string(PyUnicode_AsUTF8(obj)));
}
