#pragma once

#include "option.h"
#include "step.h"

#define VERSION_BKP VERSION
#undef VERSION
#include <Graphs/ICFG.h>
#include <Graphs/PTACallGraph.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

#include <graph.h>

namespace ara::step {
	class Callgraph : public ConfStep<Callgraph> {
	  private:
		using ConfStep<Callgraph>::ConfStep;
		static SVF::PTACallGraph& get_callgraph();

	  public:
		static std::string get_name() { return "Callgraph"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override { return {"LLVMMap", "SVFAnalyses"}; }

		virtual void run() override;
	};
} // namespace ara::step
