// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class SVFReset : public ConfStep<SVFReset> {
	  private:
		using ConfStep<SVFReset>::ConfStep;

		virtual void init_options() override;

	  public:
		virtual ~SVFReset(){};
		static std::string get_name() { return "SVFReset"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		virtual std::vector<std::string> get_single_dependencies() override { return {"SVFAnalyses"}; }

		virtual void run() override;
	};
} // namespace ara::step
