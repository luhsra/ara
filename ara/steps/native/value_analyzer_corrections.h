// SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class ValueAnalyzerCorrections : public ConfStep<ValueAnalyzerCorrections> {
	  private:
		using ConfStep<ValueAnalyzerCorrections>::ConfStep;

		template <class T, class String>
		void fail_if_empty(T& obj, const std::string opt_name, String additional_message) {
			if (!obj) {
				std::stringstream sts;
				sts << opt_name << ": " << additional_message;
				fail(sts.str());
			}
		}

		const static inline option::TOption<option::String> va_corrections_template{
		    "va_corrections", "Path to a JSON file with Correction info for the Value Analyzer."};
		option::TOptEntity<option::String> va_corrections;

		virtual void init_options() override;

		void parse_corrections(const std::string& json);

	  public:
		virtual ~ValueAnalyzerCorrections(){};
		static std::string get_name() { return "ValueAnalyzerCorrections"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		// virtual std::vector<std::string> get_single_dependencies() override { return {"Dummy"}; }

		virtual void run() override;
	};
} // namespace ara::step
