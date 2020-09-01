#pragma once
#include "common/exceptions.h"

#include <Graphs/PTACallGraph.h>
#include <Python.h>
#include <functional>
#include <llvm/IR/Instructions.h>
#include <pyllco.h>
#include <vector>

namespace ara::graph {
	using CallPath = std::vector<const SVF::PTACallGraphEdge*>;
	/**
	 * Stores all data for an argument. Mainly, this is the list of possible values dependend on its callpaths.
	 *
	 * An Argument can either have a single (callpath independent) value or multiple (callpath dependent) values.
	 */
	class Argument {
	  private:
		llvm::AttributeSet attrs;
		// key = call_path (list of call instructions)
		// value = the value that is retrieved when following this path
		std::map<CallPath, const llvm::Value&> values;

	  public:
		Argument(const llvm::AttributeSet& attrs) : attrs(attrs), values() {}
		Argument(const llvm::AttributeSet& attrs, const llvm::Value& value) : attrs(attrs), values() {
			values.insert(std::pair<CallPath, const llvm::Value&>({}, value));
		}

		/**
		 * Set a single value.
		 */
		void set_value(const llvm::Value& value) { values.insert(std::pair<CallPath, const llvm::Value&>({}, value)); }

		/**
		 * Set a callpath dependent value.
		 */
		void add_variant(CallPath& key, const llvm::Value& value) {
			values.insert(std::pair<CallPath, const llvm::Value&>(key, value));
		}

		/**
		 * Is there a unique determined value?
		 */
		bool is_determined() const { return values.size() == 1; }
		/**
		 * Are all values constants?
		 */
		bool is_constant() const;

		/**
		 * Get the AttributeSet that belongs to this argument.
		 */
		llvm::AttributeSet get_attrs() const { return attrs; }

		/**
		 * Get the value at a specific call path. Per default it returns the unique determined value.
		 * If the Argument is determined, the unique value will be returned, regardless what the key is.
		 */
		const llvm::Value& get_value(CallPath key = {}) const;

		/**
		 * Common iterators that return a std::pair<CallPath, const llvm::Value&>.
		 */
		auto begin() noexcept { return values.begin(); }
		auto begin() const noexcept { return values.begin(); }
		auto cbegin() const noexcept { return values.cbegin(); }

		auto end() noexcept { return values.end(); }
		auto end() const noexcept { return values.end(); }
		auto cend() const noexcept { return values.cend(); }
	};

    /* TODO
     * Argument: value and its path
     * Arguments: list of those
     * entry function where? as member of Argument?
     */
	using MetaArguments = std::vector<Argument>;

	class Arguments : public MetaArguments {
	  private:
		std::unique_ptr<Argument> return_value = nullptr;

		inline void py_throw(bool condition) const {
			if (condition) {
				PyErr_Print();
				throw PythonError();
			}
		}

        std::string entry_fun = "";

	  public:
		bool has_return_value() const { return return_value != nullptr; }
		const Argument& get_return_value() const {
			assert(has_return_value());
			return *return_value;
		}
		void set_return_value(std::unique_ptr<Argument> return_value) { this->return_value = std::move(return_value); }

        void set_entry_fun(std::string name) { this->entry_fun = name; }
        std::string get_entry_fun() { return this->entry_fun; }

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
		 *
		 * The first element (index 0) in the list is the return value or None, if not present.
		 */
		PyObject* get_python_list() const;
	};

    using EntryArguments = std::map<std::string, Arguments>;

} // namespace ara::graph
