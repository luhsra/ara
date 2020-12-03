// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <boost/functional/hash.hpp>
#include <boost/iterator/iterator_facade.hpp>
#include <filesystem>
#include <graph.h>
#include <optional>

namespace ara::step {
	/**
	 * Resolve function pointer. The algorithm works with multiple steps:
	 * Do for every function pointer:
	 *   1. If a translation_map is given, use always this.
	 *   2. Match the signature with respect to C++ inheritance.
	 *      C++ realizes inheritance with vTables and compound types that simple include their base classes as data
	 * member. There an indirect call with a base class pointer can call a function that takes a subclass pointer.
	 * Therefore the algorithm has some substeps: 2.1 calculate a map between "function signature" (key) and "list of
	 * fitting functions" (value) 2.2 calculate a list of compatible pointers, especially "base*" is compatible with
	 * "derived*". 2.3 iterate over all signatures of possible combinations of these pointers and match with the map of
	 * step 2.1
	 *
	 * If a signature is found that fits and is either in the accept_list if given or not in
	 * the block_list if given, then the call target is valid.
	 *
	 * The format of the accept_list and block_list is either a file path pointing to a valid file with a string or
	 * directly a string that can be interpreted as JSON list. The list must be in the format
	 * [ "function_name_1", "function_name_2" ].
	 * The function names are the mangled names (if C++ is used as source).
	 *
	 * The translation map is a file path pointing to a valid file that can be interpreted as JSON list with the
	 * following format:
	 * [
	 *     {
	 *         "source_file": "/path/to/source_file.c",
	 *         "line_number": 5,
	 *         "call_targets": [ "function_name_1", "function_name_2" ]
	 *     }
	 * ]
	 * Interpreted as: The callsite in /path/to/source_file.c line 5 calls either function_name_1 or function_name_2.
	 * The source_file path must either be absolute or relative to the directory, where the JSON file lays.
	 */
	class ResolveFunctionPointer : public ConfStep<ResolveFunctionPointer> {
	  private:
		using TypeMap = std::map<llvm::Type*, std::set<llvm::Type*>>;

		class FuzzyFuncType;

		class FuzzyFuncTypeIterator
		    : public boost::iterator_facade<FuzzyFuncTypeIterator, llvm::FunctionType*,
		                                    boost::incrementable_traversal_tag, llvm::FunctionType*> {
		  private:
			friend class FuzzyFuncType;
			friend class boost::iterator_core_access;
			FuzzyFuncTypeIterator(FuzzyFuncType& fft, bool end = false)
			    : fft(fft), positions(std::vector<size_t>(fft.getNumArguments(), 0)), end(end) {}

			void increment();

			bool equal(const FuzzyFuncTypeIterator& other) const {
				return end == other.end && fft == other.fft && positions == other.positions;
			}

			llvm::FunctionType* dereference() const;

			FuzzyFuncType& fft;
			std::vector<size_t> positions;
			bool end;
		};

		class FuzzyFuncType {
			std::vector<std::variant<llvm::Type*, std::vector<llvm::Type*>>> types;
			llvm::Type* return_type;
			friend class FuzzyFuncTypeIterator;

		  public:
			FuzzyFuncType(const llvm::FunctionType&, const TypeMap&);

			FuzzyFuncTypeIterator begin();
			FuzzyFuncTypeIterator end();

			bool operator==(const FuzzyFuncType& other) { return types == other.types; }

			size_t getNumArguments() { return types.size(); }
		};

		const static inline option::TOption<option::String> accept_list_template{
		    "accept_list", "Filepath or JSON list with valid call targets for function pointer."};
		option::TOptEntity<option::String> accept_list;

		const static inline option::TOption<option::String> block_list_template{
		    "block_list", "Filepath or JSON list with invalid call targets for function pointer."};
		option::TOptEntity<option::String> block_list;

		const static inline option::TOption<option::String> translation_map_template{
		    "translation_map", "Filepath or JSON dictionary with a manual function pointer mapping.\n"
		                       "For the format see resolve_function_pointer.h"};
		option::TOptEntity<option::String> translation_map;

		const static inline option::TOption<option::Bool> use_only_translation_map_template{
		    "use_only_translation_map", "Use only the translation_map for pointer resolving and nothing else.",
		    /* ty = */ option::Bool(),
		    /* default = */ false};
		option::TOptEntity<option::Bool> use_only_translation_map;

		virtual void init_options() override;

		std::optional<llvm::DataLayout> dl;
		// FunctionType pointers are guaranteed to be unique, see llvm-sources/lib/IR/Types.cpp
		std::unordered_map<llvm::FunctionType*, std::vector<std::reference_wrapper<llvm::Function>>> signature_to_func;
		TypeMap compatible_types;
		std::set<std::string> block_names;
		std::set<std::string> accept_names;
		std::map<std::pair<std::filesystem::path, unsigned>, std::set<std::string>> pointer_targets;
		unsigned ignored_calls = 0;

		/**
		 * Initialize a map of compatible types.
		 *
		 * That are types where their pointer can be used interchangeable.
		 * Especially this is the case for C++ subclass pointer, that can be used interchangeable with their
		 * superclasses.
		 */
		void init_compatible_types();

		void link_indirect_pointer(const SVF::CallBlockNode& cbn, SVF::PTACallGraph& callgraph,
		                           const llvm::Function& target, const SVF::LLVMModuleSet& svfModule);
		bool is_valid_call_target(const llvm::FunctionType& caller_type, const llvm::Function& candidate) const;
		void resolve_function_pointer(const SVF::CallBlockNode& cbn, SVF::PTACallGraph& callgraph,
		                              const SVF::LLVMModuleSet& svfModule);
		void resolve_indirect_function_pointers(SVF::ICFG& icfg, SVF::PTACallGraph& callgraph,
		                                        const SVF::LLVMModuleSet& module);

		// const T& obj not possible since operator bool for llvm::Expected is not const
		template <class T, class String>
		void fail_if_empty(T& obj, const char* opt_name, String additional_message) {
			if (!obj) {
				std::stringstream ss;
				ss << opt_name << ": " << additional_message;
				fail(ss.str());
			}
		}

		void parse_json(const char* opt_name, option::TOptEntity<option::String>& option,
		                std::function<void(const llvm::json::Array&)> do_with_array);
		void parse_list(const char* opt_name, option::TOptEntity<option::String>& option,
		                std::set<std::string>& target);
		void parse_translation_map(const char* opt_name, option::TOptEntity<option::String>& option);

	  public:
		ResolveFunctionPointer(PyObject* py_logger, graph::Graph graph, PyObject* py_step_manager)
		    : ConfStep<ResolveFunctionPointer>(py_logger, graph, py_step_manager), dl(std::nullopt) {}

		static std::string get_name() { return "ResolveFunctionPointer"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		virtual std::vector<std::string> get_single_dependencies() override { return {"SVFAnalyses"}; }

		virtual void run() override;
	};
} // namespace ara::step
