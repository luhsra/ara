// vim: set noet ts=4 sw=4:

#include "test.h"
#include "llvm_common.h"

#include "llvm/IR/Instructions.h"
#include "llvm/Support/Casting.h"

#include <iostream>
#include <string>
#include <stdexcept>

#include "graph.h"

namespace step {
	std::string BBSplitTest::get_name() const { return "BBSplitTest"; }

	std::string BBSplitTest::get_description() const { return "Step for testing the BBSplit step"; }

	void BBSplitTest::run(graph::Graph& graph) {
		llvm::Module& module = graph.new_graph.get_module();
		for (auto &F : module) {
			for (auto &B : F) {
				for (auto &I : B) {
					if (!(FakeCallBase::isa(I))) continue;
					if ((std::distance(B.begin(), B.end()) == 2) &&
					   (&B.front() == &I)) {
						if (llvm::BranchInst* b = llvm::dyn_cast<llvm::BranchInst>(&B.back())) {
							if (b->isUnconditional()) {
								continue;
							}
						}
					}
					if ((std::distance(B.begin(), B.end()) == 1) &&
					   (&B.front() == &I) && (&B.back() == &I)) {
						continue;
					}
					std::string call;
					llvm::raw_string_ostream rso(call);
					I.print(rso);
					std::string front;
					llvm::raw_string_ostream rso2(front);
					I.getParent()->front().print(rso2);
					std::string back;
					llvm::raw_string_ostream rso3(back);
					I.getParent()->back().print(rso3);
					logger.err() << "Found call that is not in extra basic block: " << call << std::endl;
					logger.err() << "Front: " << front << std::endl;
					logger.err() << "Back:  " << back << std::endl;
					throw std::runtime_error("Found call that is not in extra basic block.");
				}
			}
		}
	}

	std::vector<std::string> BBSplitTest::get_dependencies() { return {"BBSplit"}; }
} // namespace step
