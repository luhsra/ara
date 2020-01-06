#pragma once

#include "common/exceptions.h"

#include <functional>
#include <llvm/IR/Instructions.h>
#include <pyllco.h>
#include <vector>

namespace ara {

	using Argument = std::pair<std::reference_wrapper<const llvm::Constant>, llvm::AttributeSet>;
	using MetaArguments = std::vector<Argument>;

	class Arguments : public MetaArguments {
	  private:
		std::vector<std::unique_ptr<const llvm::Constant>> owned_values;

		inline void py_throw(bool condition) {
			if (condition) {
				PyErr_Print();
				throw PythonError();
			}
		}

	  public:
		using MetaArguments::MetaArguments;
		Arguments(const Arguments&) = delete;
		Arguments(Arguments&& o) : MetaArguments(std::move(o)), owned_values(std::move(o.owned_values)) {}

		void push_back(Argument a) { MetaArguments::push_back(a); }

		void push_back(const llvm::Constant& c, llvm::AttributeSet& attrs) {
			this->push_back(std::pair<std::reference_wrapper<const llvm::Constant>, llvm::AttributeSet>(c, attrs));
		}

		void push_back(std::unique_ptr<const llvm::Constant> value, llvm::AttributeSet& attrs) {
			MetaArguments::push_back(std::make_pair(std::ref(*value), attrs));
			owned_values.push_back(std::move(value));
		}

		void emplace_back(Argument a) { MetaArguments::emplace_back(a); }

		void emplace_back(const llvm::Constant& c, llvm::AttributeSet& attrs) {
			this->emplace_back(std::pair<std::reference_wrapper<const llvm::Constant>, llvm::AttributeSet>(c, attrs));
		}

		void emplace_back(std::unique_ptr<const llvm::Constant> value, llvm::AttributeSet& attrs) {
			MetaArguments::emplace_back(std::make_pair(std::ref(*value), attrs));
			owned_values.emplace_back(std::move(value));
		}

		bool owns_objects() { return owned_values.size() > 0; }

		/**
		 * Return the current Arguments vector as Python list. The list is a new object and contains only references to
		 * currently existing constants. It is _not_ updated, if the Arguments object is extended.
		 */
		PyObject* get_python_list() {
			PyObject* list = PyList_New(0);
			py_throw(list == nullptr);
			for (auto& arg : *this) {
				int ret;

				const llvm::Constant& constant = arg.first;
				llvm::AttributeSet& attrs = arg.second;

				const llvm::Value* v = llvm::dyn_cast<const llvm::Value>(&constant);
				// now the pain begins. We have to give the const Value to Python and Python/Cython with consts is
				// nearly impossible. We either have to castrate our Python interface to support only const methods or
				// have to leave the land of const correctness. We are doing the latter...
				PyObject* val_obj = get_obj_from_value(const_cast<llvm::Value*>(v));
				py_throw(val_obj == nullptr);

				PyObject* attrs_obj = get_obj_from_attr_set(attrs);
				py_throw(attrs_obj == nullptr);

				PyObject* tup = PyTuple_New(2);
				py_throw(tup == nullptr);

				ret = PyTuple_SetItem(tup, 0, val_obj);
				py_throw(ret != 0);

				ret = PyTuple_SetItem(tup, 1, attrs_obj);
				py_throw(ret != 0);

				ret = PyList_Append(list, tup);
				py_throw(ret != 0);
				Py_DECREF(tup);
			}
			return list;
		}
	};

} // namespace ara
