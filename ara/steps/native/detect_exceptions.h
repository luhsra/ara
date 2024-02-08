// SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
// SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class DetectExceptions : public ConfStep<DetectExceptions> {
	  private:
		using ConfStep<DetectExceptions>::ConfStep;
		void mark_region_as_exception(const llvm::BasicBlock* bb);

	  public:
		virtual ~DetectExceptions(){};
		static std::string get_name() { return "DetectExceptions"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;

		virtual void run() override;
	};
} // namespace ara::step
