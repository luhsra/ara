// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class ICFG : public EntryPointStep<ICFG> {
	  private:
		using EntryPointStep<ICFG>::EntryPointStep;

	  public:
		static std::string get_name() { return "ICFG"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override { return {"LLVMMap"}; }

		virtual void run() override;
	};
} // namespace ara::step
