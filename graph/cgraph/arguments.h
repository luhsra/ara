#pragma once

#include "common/exceptions.h"

#include <functional>
#include <llvm/IR/Instructions.h>
#include <pyllco.h>
#include <vector>

namespace ara {

	class Argument {
	  public:
		using CallPath = std::vector<const llvm::Instruction*>;

	  private:
		llvm::AttributeSet attrs;
		// key = call_path (list of call instructions)
		// value = the constant that is retrieved when following this path
		std::map<CallPath, const llvm::Constant&> consts;

	  public:
		Argument(llvm::AttributeSet attrs, const llvm::Constant& l_const) : attrs(attrs), consts() {
			consts.insert(std::pair<CallPath, const llvm::Constant&>({}, l_const));
		}

		void add_variant(CallPath& key, const llvm::Constant& value) {
			consts.insert(std::pair<CallPath, const llvm::Constant&>(key, value));
		}

		llvm::AttributeSet get_attrs() { return attrs; }

		const llvm::Constant& get_constant(CallPath key = {}) { return consts.at(key); }

		auto begin() noexcept { return consts.begin(); }
		auto begin() const noexcept { return consts.begin(); }
		auto cbegin() const noexcept { return consts.cbegin(); }

		auto end() noexcept { return consts.end(); }
		auto end() const noexcept { return consts.end(); }
		auto cend() const noexcept { return consts.cend(); }
	};

	using MetaArguments = std::vector<Argument>;

	class Arguments : public MetaArguments {
	  private:
		inline void py_throw(bool condition) {
			if (condition) {
				PyErr_Print();
				throw PythonError();
			}
		}

	  public:
		/**
		 * Return the current Arguments vector as Python list. The list is a new object and contains only references to
		 * currently existing constants. It is _not_ updated, if the Arguments object is extended.
		 *
		 * The function does _not_ create a list of the ARA Argument Python class but instead use builtin data types. It
		 * returns a list of tuples where the first tuple element defines the attribute set and the second element a
		 * list of constant. This list consists again of tuples that have as key a list of basic block pointers (to the
		 * call basic blocks) and as value the constant object.
		 *
		 * That means one argument with the Constant: llvm.ConstantPointerNull under the CallPath '123 -> 345' is stored
		 * as:
		 * [
		 *     (AttributeSet(),
		 *      [
		 *          ([123, 345], llvm.ConstantPointerNull)
		 *      ]
		 *     )
		 * ]
		 */
		PyObject* get_python_list() {
			PyObject* list = PyList_New(0);
			py_throw(list == nullptr);
			for (auto& arg : *this) {
				int ret;

				PyObject* tup = PyTuple_New(2);
				py_throw(tup == nullptr);

				llvm::AttributeSet attrs = arg.get_attrs();

				PyObject* attrs_obj = get_obj_from_attr_set(attrs);
				py_throw(attrs_obj == nullptr);

				ret = PyTuple_SetItem(tup, 0, attrs_obj);
				py_throw(ret != 0);

				PyObject* consts = PyList_New(0);
				py_throw(consts == nullptr);

				for (auto it = arg.begin(); it != arg.end(); ++it) {
					// handle the path
					PyObject* call_path = PyList_New(0);
					py_throw(call_path == nullptr);

					Argument::CallPath cp = it->first;
					for (const llvm::Instruction* i : cp) {
						static_assert(sizeof(size_t) == sizeof(const llvm::BasicBlock*));
						PyObject* bb = PyLong_FromSize_t(reinterpret_cast<size_t>(i->getParent()));
						ret = PyList_Append(call_path, bb);
						py_throw(ret != 0);
						Py_DECREF(bb);
					}

					// handle the constant
					const llvm::Constant& constant = it->second;
					const llvm::Value* v = llvm::dyn_cast<const llvm::Value>(&constant);

					// now the pain begins. We have to give the const Value to Python and Python/Cython with consts is
					// nearly impossible. We either have to castrate our Python interface to support only const methods
					// or have to leave the land of const correctness. We are doing the latter...
					PyObject* val_obj = get_obj_from_value(const_cast<llvm::Value*>(v));
					py_throw(val_obj == nullptr);

					PyObject* cconst = PyTuple_New(2);
					py_throw(cconst == nullptr);

					ret = PyTuple_SetItem(cconst, 0, call_path);
					py_throw(ret != 0);

					ret = PyTuple_SetItem(cconst, 1, val_obj);
					py_throw(ret != 0);

					ret = PyList_Append(consts, cconst);
					py_throw(ret != 0);
					Py_DECREF(cconst);
				}

				ret = PyTuple_SetItem(tup, 1, consts);
				py_throw(ret != 0);

				ret = PyList_Append(list, tup);
				py_throw(ret != 0);
				Py_DECREF(tup);
			}
			return list;
		}
	};

} // namespace ara
