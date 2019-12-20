#pragma once

#include "common/exceptions.h"

#include <functional>
#include <llvm/IR/Instructions.h>
#include <pyllco.h>
#include <vector>

namespace ara {

	using MetaArguments = std::vector<std::reference_wrapper<const llvm::Constant>>;

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

		void push_back(const llvm::Constant& c) { MetaArguments::push_back(c); }

		void push_back(std::unique_ptr<const llvm::Constant> value) {
			MetaArguments::push_back(std::ref(*value));
			owned_values.push_back(std::move(value));
		}

		void emplace_back(const llvm::Constant& c) { MetaArguments::emplace_back(c); }

		void emplace_back(std::unique_ptr<const llvm::Constant> value) {
			MetaArguments::emplace_back(std::ref(*value));
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
			for (const llvm::Constant& constant : *this) {
				const llvm::Value* v = llvm::dyn_cast<const llvm::Value>(&constant);
				// now the pain begins. We have to give the const Value to Python and Python/Cython with consts is
				// nearly impossible. We either have to castrate our Python interface to support only const methods or
				// have to leave the land of const correctness. We are doing the latter...
				PyObject* obj = get_obj(const_cast<llvm::Value*>(v));
				py_throw(obj == nullptr);
				int ret = PyList_Append(list, obj);
				py_throw(ret != 0);
			}
			return list;
		}
	};

} // namespace ara
