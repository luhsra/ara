// vim: set noet ts=4 sw=4:

#include "llvm_basic_optimization.h"

#include "llvm_common.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/InstCombine/InstCombine.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Scalar/GVN.h"

#include <iostream>
#include <list>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/Casting.h>
#include <llvm/Support/raw_os_ostream.h>

namespace step {
	using namespace llvm;

	std::string LLVMBasicOptimization::get_description() {
		return "Perform some basic optimizations passes from llvm."
		  "\n";
	}

	std::vector<std::string> LLVMBasicOptimization::get_dependencies() {
		return {"IRReader"};
	}

	void LLVMBasicOptimization::run(graph::Graph& graph) {
		setCurrentDebugType("gvn");
		DebugFlag = true;
		logger.debug() << "hello llvm" << std::endl;
		auto module = graph.get_llvm_module();
		auto& theContext = module->getContext();
		logger.err() << module << std::endl;
		std::unique_ptr<legacy::FunctionPassManager> fpm = make_unique<legacy::FunctionPassManager>(module.get());
		// Do simple "peephole" optimizations and bit-twiddling optzns.
		fpm->add(createInstructionCombiningPass());
		// Reassociate expressions.
		fpm->add(createReassociatePass());
		// Eliminate Common SubExpressions.
		fpm->add(createGVNPass());
		// Simplify the control flow graph (deleting unreachable blocks, etc).
		fpm->add(createCFGSimplificationPass());

		fpm->doInitialization();

		for (auto& function : *module) {
			function.viewCFG();
			fpm->run(function);
			function.viewCFG();
		}
		fpm->doFinalization();
	}
} // namespace step
