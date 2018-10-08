#ifndef LLVM_PASSAGE_H
#define LLVM_PASSAGE_H

#include "graph.h"
#include "passage.h"

#include <string>

namespace passage {
	class LLVMPassage : public Passage {
	public:
		LLVMPassage(const PyObject* config) : Passage(config) {}

		virtual std::string get_name() override;

		virtual std::string get_description() override;

		virtual std::vector<std::string> get_dependencies() override;

		virtual void run(graph::Graph graph) override;
	};
}

#endif //LLVM_PASSAGE_H
