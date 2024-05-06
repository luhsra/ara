// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"
#include "translation_map_utils.h"

#include <Graphs/ICFG.h>
#include <Graphs/PTACallGraph.h>
#include <graph.h>

namespace ara::step {
	class SVFAnalyses : public ConfStep<SVFAnalyses> {
	  private:
	  friend class helper::TranslationMapParser<SVFAnalyses>;
		std::map<std::pair<std::filesystem::path, unsigned>, std::set<std::string>> pointer_targets;

		using ConfStep<SVFAnalyses>::ConfStep;

		const static inline option::TOption<option::String> translation_map_template{
		    "translation_map", "Filepath or JSON dictionary with a manual function pointer mapping.\n"
		                       "For the format see resolve_function_pointer.h"};
		option::TOptEntity<option::String> translation_map;
		virtual void init_options() override;

		void apply_translation_map(SVF::PTACallGraph& callgraph);

	  public:
		static std::string get_name() { return "SVFAnalyses"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		virtual std::vector<std::string> get_single_dependencies() override {
			return {"FnSingleExit", "FakeEntryPoint"};
		}

		virtual void run() override;
	};
} // namespace ara::step
