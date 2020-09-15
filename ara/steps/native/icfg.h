// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#define VERSION_BKP VERSION
#undef VERSION
#include <Graphs/ICFG.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

#include <graph.h>

namespace ara::step {
	class ICFG : public EntryPointStep<ICFG> {
	  private:
		using EntryPointStep<ICFG>::EntryPointStep;
		static SVF::ICFG& get_icfg();

	  public:
		static std::string get_name() { return "ICFG"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override { return {"LLVMMap", "SVFAnalyses"}; }

		virtual void run() override;
	};
} // namespace ara::step
