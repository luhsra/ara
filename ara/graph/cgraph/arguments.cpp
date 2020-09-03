#include "arguments.h"

namespace ara {
	bool Argument::is_constant() const {
		for (const auto& value : values) {
			if (!llvm::isa<llvm::Constant>(value.second)) {
				return false;
			}
		}
		return true;
	}

	const llvm::Value& Argument::get_value(CallPath key) const {
		if (is_determined() && key.size() == 0) {
			return values.begin()->second;
		}
		return values.at(key);
	}

	PyObject* Arguments::get_python_list() const {
		// PyObject* list = PyList_New(0);
		// py_throw(list == nullptr);
		// for (size_t i = 0; i < this->size() + 1; ++i) {
		// 	const Argument* arg = nullptr;
		// 	int ret;
		// 	if (i == 0) {
		// 		if (!this->has_return_value()) {
		// 			ret = PyList_Append(list, Py_None);
		// 			py_throw(ret != 0);
		// 			continue;
		// 		}
		// 		arg = return_value.get();
		// 	} else {
		// 		arg = &this->at(i - 1);
		// 	}

		// 	PyObject* tup = PyTuple_New(2);
		// 	py_throw(tup == nullptr);

		// 	llvm::AttributeSet attrs = arg->get_attrs();

		// 	PyObject* attrs_obj = get_obj_from_attr_set(attrs);
		// 	py_throw(attrs_obj == nullptr);

		// 	ret = PyTuple_SetItem(tup, 0, attrs_obj);
		// 	py_throw(ret != 0);

		// 	PyObject* values = PyList_New(0);
		// 	py_throw(values == nullptr);

		// 	for (auto it = arg->begin(); it != arg->end(); ++it) {
		// 		// handle the path
		// 		PyObject* call_path = PyList_New(0);
		// 		py_throw(call_path == nullptr);

		// 		Argument::CallPath cp = it->first;
		// 		for (const llvm::Instruction* i : cp) {
		// 			static_assert(sizeof(size_t) == sizeof(const llvm::BasicBlock*));
		// 			PyObject* bb = PyLong_FromSize_t(reinterpret_cast<size_t>(i->getParent()));
		// 			ret = PyList_Append(call_path, bb);
		// 			py_throw(ret != 0);
		// 			Py_DECREF(bb);
		// 		}

		// 		// handle the value
		// 		const llvm::Value& v = it->second;

		// 		// now the pain begins. We have to give the const Value to Python and Python/Cython with values is
		// 		// nearly impossible. We either have to castrate our Python interface to support only const methods
		// 		// or have to leave the land of const correctness. We are doing the latter...
		// 		PyObject* val_obj = get_obj_from_value(const_cast<llvm::Value&>(v));
		// 		py_throw(val_obj == nullptr);

		// 		PyObject* cconst = PyTuple_New(2);
		// 		py_throw(cconst == nullptr);

		// 		ret = PyTuple_SetItem(cconst, 0, call_path);
		// 		py_throw(ret != 0);

		// 		ret = PyTuple_SetItem(cconst, 1, val_obj);
		// 		py_throw(ret != 0);

		// 		ret = PyList_Append(values, cconst);
		// 		py_throw(ret != 0);
		// 		Py_DECREF(cconst);
		// 	}

		// 	ret = PyTuple_SetItem(tup, 1, values);
		// 	py_throw(ret != 0);

		// 	ret = PyList_Append(list, tup);
		// 	py_throw(ret != 0);
		// 	Py_DECREF(tup);
		// }
		// return list;
		return nullptr;
	}
} // namespace ara
