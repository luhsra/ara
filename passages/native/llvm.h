#ifndef LLVM_PASS_H
#define LLVM_PASS_H

#include "graph.h"
#include "pass.h"

#include <string>

namespace pass {

	// some comment
	class LLVMPass : public Pass {
	public:

		LLVMPass() = default;

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual void run(graph::Graph graph) override;
	};
}

#endif //LLVM_PASS_H
