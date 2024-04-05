// SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:
#pragma once
#include <boost/bimap.hpp>
#include <llvm/Support/JSON.h>
#include <llvm/IR/InstrTypes.h>
#include <map>
#include <vector>

namespace ara::graph {
	class CallPath;
}

namespace ara::value_analyzer {

	class ValueLocation {
	  private:
		std::string callsite;
		std::string function;
		std::string callpath;
		unsigned arg_nr;

	  public:
		ValueLocation(const std::string& callsite, const std::string& function, const std::string& callpath,
		              unsigned arg_nr)
		    : callsite(callsite), function(function), callpath(callpath), arg_nr(arg_nr) {}

		ValueLocation(const llvm::CallBase& callsite, const graph::CallPath& callpath, const unsigned argument_nr);
		ValueLocation(const llvm::json::Object& obj);

		bool operator<(const ValueLocation& other) const;

		std::string as_json() const;

	};

	struct FunctionPointerHint {
		std::string name;
		FunctionPointerHint(const std::string& name) : name(name) {}
	};

	/**
	 * hold the state of a ValueAnalyzer (the actual ValueAnalzer is constructed everytime due to the need of a Python
	 * object)
	 */
	struct ValueAnalyzerState {
		/**
		 * Workaround for SVF classes where we need additional attributes.
		 * The tuple conists of the
		 * 1. the SVFG Node (typename boost::graph_traits<SVFGGraphtool>::vertex_descriptor as uint64_t)
		 * 2. a list of offset into a compound type (std::vector<int64_t>)
		 * 3. a context/CallPath (represented as hash due to include loops, std::size_t)
		 */
		using ObjMap = boost::bimap<std::tuple<uint64_t, std::vector<int64_t>, std::size_t>, uint64_t>;
		ObjMap obj_map;

		std::map<ValueLocation, std::variant<FunctionPointerHint>> corrections;
	};

} // namespace ara::value_analyzer
