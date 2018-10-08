#ifndef PASS_H
#define PASS_H


#include <iostream>
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include <llvm/IR/Instructions.h>
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/ErrorOr.h"

//#include "llvm/Bitcode/ReaderWriter.h"

#include <string>
#include <tuple>
#include <vector>
#include <iostream>
#include <llvm/IRReader/IRReader.h>
#include "graph.h"

using namespace llvm;

namespace pass {

	// some comment
	class Pass {
            
            public:

		Pass() = default;
                
		void run(graph::Graph graph, std::vector<std::string> files);
            
        };
}

#endif //PASS_H









