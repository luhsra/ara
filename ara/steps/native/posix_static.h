// SPDX-FileCopyrightText: 2021 Kenny Albes
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class POSIXStatic : public ConfStep<POSIXStatic> {
	  private:
		using ConfStep<POSIXStatic>::ConfStep;

	  public:
		static std::string get_name() { return "POSIXStatic"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"RemoveSysfuncBody"}; }

		virtual void run() override;
	};
} // namespace ara::step
