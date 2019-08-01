// vim: set noet ts=4 sw=4:

#ifndef LLVM_STEP_H
#define LLVM_STEP_H

#include "graph.h"
#include "llvm_dumper.h"
#include "step.h"
#include "warning.h"

#include "llvm/Analysis/OrderedBasicBlock.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Operator.h"
#include "llvm/IR/Use.h"
#include "llvm/IR/User.h"
#include "llvm/Support/raw_ostream.h"

#include <cassert>
#include <iostream>
#include <llvm/Analysis/Interval.h>
#include <llvm/Analysis/LoopInfo.h>
#include <llvm/Config/llvm-config.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/DebugInfoMetadata.h>
#include <llvm/IR/DiagnosticInfo.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Verifier.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Linker/Linker.h>
#include <llvm/Support/CommandLine.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/ManagedStatic.h>
#include <llvm/Support/Path.h>
#include <llvm/Support/PrettyStackTrace.h>
#include <llvm/Support/Signals.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/SystemUtils.h>
#include <llvm/Support/ToolOutputFile.h>

namespace step {

	class LLVMStep : public Step {
	  private:
		std::vector<shared_warning> warnings;
		LLVMDumper dumper;

		/**
		 * @brief  generates all abbs of the transmitted graph function. All abbs are conntected with the
		 * CFG predecessors and successors
		 * @param graph project data structure
		 * @param function graph function, which contains the llvm function reference
		 * @param warning_list list to store warning
		 */

		void abb_generation(graph::Graph* graph, OS::shared_function function,
		                    std::vector<shared_warning>* warning_list);

		/**
		 * @brief splits all bbs of the transmitted function, so that there is just on call in each bb
		 * @param function llvm function which is analyzed
		 * @param split_counter counter, whichs stores the number of splitted bbs
		 */
		void split_basicblocks(llvm::Function& function, unsigned& split_counter);

		/**
		 * @brief loads the .ll file and returns the parsed llvm module
		 * @param FN path to the .ll file
		 * @param Context llvm module context
		 * @return unique module pointer of the parsed .ll file
		 */
		std::unique_ptr<llvm::Module> LoadFile(const std::string& FN, llvm::LLVMContext& Context);

		/**
		 * @brief connect each abb and function which the called function by inserting a edge in the graph
		 * @param graph project data structure
		 */
		void set_called_functions(graph::Graph& graph);

		// TODO use templates
		/**
		 * function exists twice, one for invoke, one for call instructions->the call instruction parent class of both
		 * instructions could not use ?!
		 * @brief set all possbile argument std::any and llvm values of the abb call in a data structure. This
		 * data structure is then stored in each abb for each call.
		 * @param abb abb, which contains the call
		 * @param func llvm function, of the call instruction
		 * @param instruction call instruction, which is analyzed
		 * @param warning_list list to store warning
		 */
		void dump_instruction(OS::shared_abb abb, llvm::Function* func, llvm::CallInst* instruction,
		                      std::vector<shared_warning>* warning_list);
		/**
		 * @brief set all possbile argument std::any and llvm values of the abb call in a data structure. This
		 * data structure is then stored in each abb for each call.
		 * @param abb abb, which contains the call
		 * @param func llvm function, of the call instruction
		 * @param instruction call instruction, which is analyzed
		 * @param warning_list list to store warning
		 */
		void dump_instruction(OS::shared_abb abb, llvm::Function* func, llvm::InvokeInst* instruction,
		                      std::vector<shared_warning>* warning_list);

		/**
		 * @brief set the arguments std::any and llvm values of the abb
		 * @param abb abb, which should be analyzed
		 * @param warning_list list to store warning
		 */
		void set_arguments(OS::shared_abb abb, std::vector<shared_warning>* warning_list);

		/**
		 * @brief detects and set for each function in the graph an exit abb
		 * @param graph project data structure
		 * @param split_counter counter of all yet splitted bbs
		 */
		void set_exit_abb(graph::Graph& graph, unsigned int& split_counter);

		ara::option::TOption<ara::option::List<ara::option::String>> input_files{"input_files", "Get input files."};

		virtual void fill_options(std::vector<option_ref>& opts) override { opts.emplace_back(input_files); }

	  public:
		virtual std::string get_name() const override { return "LLVMStep"; }
		virtual std::string get_description() const override;
		virtual std::vector<std::string> get_dependencies() override { return {}; }

		virtual void run(graph::Graph& graph) override;
	};
} // namespace step

#endif // LLVM_STEP_H
