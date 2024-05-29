// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class ThreadWrapper : public ConfStep<ThreadWrapper> {
	  private:
		using ConfStep<ThreadWrapper>::ConfStep;
	  public:
		static std::string get_name() { return "ThreadWrapper"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override { return {"ZephyrStaticPost"}; }

		virtual void run() override;
	};
} // namespace ara::step
