// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <graph.h>
#include <string>

namespace ara::step {

	class BBTimings : public ConfStep<BBTimings> {
	  private:
		using ConfStep<BBTimings>::ConfStep;

	  public:
		static std::string get_name() { return "BBTimings"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;

		virtual void run() override;
	};
} // namespace ara::step
