#include "option.h"

using namespace ara::option;

void Integer::from_pointer(PyObject* obj, std::string name) {
	if (!PyLong_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not an integer." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	this->value = PyLong_AsLongLong(obj);
	this->valid = true;
}

void Float::from_pointer(PyObject* obj, std::string name) {
	if (!PyFloat_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not a floating point number." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	this->value = PyLong_AsDouble(obj);
	assert(this->value != -1.0 || PyErr_Occurred() == NULL);
	this->valid = true;
}

void Bool::from_pointer(PyObject* obj, std::string name) {
	if (!PyBool_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not a boolean." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	this->value = PyObject_IsTrue(obj);
	this->valid = true;
}

void String::from_pointer(PyObject* obj, std::string name) {
	if (!PyUnicode_Check(obj)) {
		std::stringstream ss;
		ss << name << " is not a string." << std::flush;
		throw std::invalid_argument(ss.str());
	}
	this->value = std::string(PyUnicode_AsUTF8(obj));
	this->valid = true;
}
