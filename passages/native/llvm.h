#ifndef LLVM_PASS_H
#define LLVM_PASS_H

#include "graph.h"
#include "pass.h"

#include <string>

namespace pass {
	class LLVMPass : public Pass {
	public:
		LLVMPass(const PyObject* config) : Pass(config) {}

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph graph) override;
	};
}

#endif //LLVM_PASS_H
