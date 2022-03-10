#pragma once

#include "llvm/IR/Module.h"

#include <utility>
#include <initializer_list>
#include <Python.h>
#include <pyllco.h>

// Create a py dict from the given elements, this is a ref stealing
// operation
inline PyObject* py_dict(std::initializer_list<std::pair<const char*, PyObject*>> elements) {
    PyObject* dict = PyDict_New();

    for (auto& element : elements) {
        PyDict_SetItemString(dict, element.first, element.second);
        Py_DecRef(element.second);
    }

    return dict;
}

inline PyObject* py_int(const llvm::APInt& i) {
    if (i.isNegative()) {
        return Py_BuildValue("L", i.getSExtValue());
    } else {
        return Py_BuildValue("K", i.getZExtValue());
    }
}

inline PyObject* py_int(unsigned long long i) { return Py_BuildValue("K", i); }

inline PyObject* py_int_signed(int i) { return Py_BuildValue("i", i); }

inline PyObject* py_str(const char* str) { return PyUnicode_FromString(str); }

inline PyObject* py_str(const llvm::StringRef& str) {
    // Since stringrefs allow slicing, their raw strings may not be null
    // terminated.
    return PyUnicode_FromStringAndSize(str.data(), str.size());
}

inline PyObject* py_none() { Py_RETURN_NONE; }