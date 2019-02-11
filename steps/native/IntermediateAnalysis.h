// vim: set noet ts=4 sw=4:

#ifndef IntermediateAnalysis_STEP_H
#define IntermediateAnalysis_STEP_H

#include "graph.h"
#include "step.h"


#include <string>
#include <tuple>
#include <vector>
#include <iostream>
#include <queue>
#include <llvm/Analysis/LoopInfo.h>
#include "llvm/IR/Dominators.h"
#include <llvm/Config/llvm-config.h>
#include <llvm/Linker/Linker.h>
#include <llvm/IR/Verifier.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/DebugInfoMetadata.h>
#include <llvm/IR/DiagnosticInfo.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/IRBuilder.h>
#include "llvm/IR/Constants.h"
#include "llvm/IR/User.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/Use.h"
#include "llvm/IR/Function.h"
#include <llvm/IRReader/IRReader.h>
#include <llvm/Support/CommandLine.h>
#include <llvm/Support/ManagedStatic.h>
#include <llvm/Support/Path.h>
#include <llvm/Support/PrettyStackTrace.h>
#include <llvm/Support/Signals.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/SystemUtils.h>
#include <llvm/Support/ToolOutputFile.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Analysis/Interval.h>
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/OrderedBasicBlock.h"
#include "llvm/IR/Operator.h"
#include "warning.h"



namespace step {
	class IntermediateAnalysisStep : public Step {
        
        
    private:
        std::vector<shared_warning> warnings;
        
	public:
		IntermediateAnalysisStep(PyObject* config) : Step(config) {}

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph& graph) override;
	};
}

#endif //IntermediateAnalysis_STEP_H
