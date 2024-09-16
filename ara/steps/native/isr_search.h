// SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "option.h"
#include "step.h"
#include "translation_map_utils.h"

#define VERSION_BKP VERSION
#undef VERSION
#include <Graphs/ICFG.h>
#include <Graphs/PTACallGraph.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

#include <graph.h>

namespace ara::step {
	class ISRSearch : public ConfStep<ISRSearch> {
	  private:
		friend class helper::TranslationMapParser<ISRSearch>;
		using ConfStep<ISRSearch>::ConfStep;

		const static inline option::TOption<option::String> block_list_template{
		    "block_list", "Filepath or JSON list with invalid call targets for function pointer."};
		option::TOptEntity<option::String> block_list;
		const static inline option::TOption<option::Bool> mixed_method_fail_template{
		    "mixed_method_fail", "Fail, when normal syscalls are called in ISR functions.", /* ty = */ option::Bool(),
		    /* default_value = */ true};
		option::TOptEntity<option::Bool> mixed_method_fail;
		virtual void init_options() override;

		static SVF::PTACallGraph& get_svf_callgraph();
		void find_entry_points(const SVF::PTACallGraphNode* syscall);

		std::set<std::string> block_names;

	  public:
		static std::string get_name() { return "ISRSearch"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();
		virtual std::vector<std::string> get_single_dependencies() override {
			return {"LLVMMap", "ResolveFunctionPointer"};
		}

		virtual void run() override;
	};
} // namespace ara::step
