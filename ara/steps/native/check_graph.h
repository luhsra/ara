// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>

namespace ara::step {
	class CheckGraph : public ConfStep<CheckGraph> {
	  private:
		using ConfStep<CheckGraph>::ConfStep;

	  public:
		static std::string get_name() { return "CheckGraph"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"LLVMMap"}; }

		virtual void run() override;
	};
} // namespace ara::step
