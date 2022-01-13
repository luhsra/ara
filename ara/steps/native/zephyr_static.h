// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class ZephyrStatic : public ConfStep<ZephyrStatic> {
	  private:
		using ConfStep<ZephyrStatic>::ConfStep;

	  public:
		static std::string get_name() { return "ZephyrStatic"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"IRReader"}; }

		virtual void run() override;
	};
} // namespace ara::step
