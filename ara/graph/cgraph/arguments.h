// SPDX-FileCopyrightText: 2020 Yannick Loeck
// SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once
#include "callpath.h"
#include "common/exceptions.h"
#include "common/util.h"
#include "graph.h"

#include <Graphs/PTACallGraph.h>
#include <Python.h>
#include <boost/functional/hash.hpp>
#include <boost/range/combine.hpp>
#include <functional>
#include <graph_python_interface.hh>
#include <llvm/IR/Instructions.h>
#include <memory>
#include <unordered_set>
#include <vector>

namespace boost::detail {
	// This only works since graph_tool::GraphInterface::edge_t is a typedef to boost::detail::adj_edge_descriptor. If
	// graph_tool changes this, this hash function needs to be changed, too.
	std::size_t hash_value(const boost::detail::adj_edge_descriptor<long unsigned int>& edge);
} // namespace boost::detail

namespace std {
	template <>
	struct hash<ara::graph::CallPath> {
		std::size_t operator()(const ara::graph::CallPath& cp) const { return cp.hash(); }
	};
} // namespace std

namespace ara::graph {
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
		std::unordered_map<CallPath, llvm::Value&> values;

		Argument(const llvm::AttributeSet& attrs) : attrs(attrs), values() {}
		Argument(const llvm::AttributeSet& attrs, llvm::Value& value) : attrs(attrs), values() {
			values.insert(std::pair<CallPath, llvm::Value&>(CallPath(), value));
		}

		struct ArgumentSharedEnabler;

		friend std::ostream& operator<<(std::ostream& os, const Argument& arg);

	  public:
		using iterator = decltype(values)::iterator;
		using const_iterator = decltype(values)::const_iterator;

		static std::shared_ptr<Argument> get(const llvm::AttributeSet& attrs);
		static std::shared_ptr<Argument> get(const llvm::AttributeSet& attrs, llvm::Value& value);

		/**
		 * Set a single value.
		 */
		void set_value(llvm::Value& value) { values.insert(std::pair<CallPath, llvm::Value&>(CallPath(), value)); }

		/**
		 * Set a callpath dependent value.
		 */
		template <class CP = CallPath>
		void add_variant(CP&& key, llvm::Value& value) {
			values.insert(std::pair<CallPath, llvm::Value&>(key, value));
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
		 * Check if a value at a specific call path exists.
		 */
		bool has_value(const CallPath& key) const;

		/**
		 * Get the value at a specific call path. Per default it returns the unique determined value.
		 * If the Argument is determined, the unique value will be returned, regardless what the key is.
		 */
		llvm::Value& get_value(const CallPath& key = CallPath()) const;

		size_t size() const { return values.size(); }

		/**
		 * Common iterators that return a std::pair<CallPath, llvm::Value&>.
		 */
		iterator begin() noexcept { return values.begin(); }
		const_iterator begin() const noexcept { return values.begin(); }
		const_iterator cbegin() const noexcept { return values.cbegin(); }

		iterator end() noexcept { return values.end(); }
		const_iterator end() const noexcept { return values.end(); }
		const_iterator cend() const noexcept { return values.cend(); }
	};
	std::ostream& operator<<(std::ostream& os, const Argument& arg);

	/* TODO
	 * Argument: value and its path
	 * Arguments: list of those
	 * entry function where? as member of Argument?
	 */
	using MetaArguments = std::vector<std::shared_ptr<Argument>>;

	class Arguments : public MetaArguments, public std::enable_shared_from_this<Arguments> {
	  private:
		std::shared_ptr<Argument> return_value = nullptr;

		std::string entry_fun = "";

		inline void py_throw(bool condition) const {
			if (condition) {
				PyErr_Print();
				throw PythonError();
			}
		}

		Arguments() {}

	  public:
		static std::shared_ptr<Arguments> get() {
			struct MakeSharedEnabler : public Arguments {};
			return std::make_shared<MakeSharedEnabler>();
		}
		bool has_return_value() const { return return_value != nullptr; }
		std::shared_ptr<Argument> get_return_value() const { return return_value; }
		void set_return_value(std::shared_ptr<Argument> return_value) { this->return_value = return_value; }

		void set_entry_fun(std::string name) { this->entry_fun = name; }
		std::string get_entry_fun() { return this->entry_fun; }

		/**
		 * Return the current Arguments vector as correspondent Python object.
		 */
		PyObject* get_python_obj();
	};
	std::ostream& operator<<(std::ostream& os, const Arguments& args);

	using EntryArguments = std::map<std::string, Arguments>;

} // namespace ara::graph
