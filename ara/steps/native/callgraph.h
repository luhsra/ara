// SPDX-FileCopyrightText: 2020 Yannick Loeck
// SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
// SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "option.h"
#include "step.h"

#define VERSION_BKP VERSION
#undef VERSION
#include <Graphs/ICFG.h>
#include <Graphs/PTACallGraph.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

#include <graph.h>

namespace ara::step {
	class CallGraph : public EntryPointStep<CallGraph> {
	  private:
		using EntryPointStep<CallGraph>::EntryPointStep;
		static SVF::PTACallGraph& get_svf_callgraph();

	  public:
		static std::string get_name() { return "CallGraph"; }
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override {
			return {"LLVMMap", "ResolveFunctionPointer"};
		}
		virtual llvm::json::Array get_configured_dependencies() override;

		virtual void run() override;
	};
} // namespace ara::step
