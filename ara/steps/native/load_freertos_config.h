// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class LoadFreeRTOSConfig : public ConfStep<LoadFreeRTOSConfig> {
	  private:
		using ConfStep<LoadFreeRTOSConfig>::ConfStep;

	  public:
		static std::string get_name() { return "LoadFreeRTOSConfig"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"SysFuncts"}; }

		virtual void run() override;
	};
} // namespace ara::step
