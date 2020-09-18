// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <Graphs/ICFG.h>
#include <Graphs/PTACallGraph.h>
#include <graph.h>

namespace ara::step {
	class SVFAnalyses : public ConfStep<SVFAnalyses> {
	  private:
		using ConfStep<SVFAnalyses>::ConfStep;

	  public:
		static std::string get_name() { return "SVFAnalyses"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"LLVMMap"}; }

		virtual void run() override;
	};
} // namespace ara::step
