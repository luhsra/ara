// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class ValueAnalysisCore : public EntryPointStep<ValueAnalysisCore> {
	  private:
		using EntryPointStep<ValueAnalysisCore>::EntryPointStep;

		const static inline option::TOption<option::Bool> dump_stats_template{
		    "dump_stats", "Export JSON statistics about the value-analysis depth."};
		option::TOptEntity<option::Bool> dump_stats;

		virtual void init_options() override;

	  public:
		static std::string get_name() { return "ValueAnalysisCore"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {dump_stats_template}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"Syscall"}; }

		virtual void run() override;
	};
} // namespace ara::step
