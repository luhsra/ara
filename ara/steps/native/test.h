// SPDX-FileCopyrightText: 2019 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#ifndef TEST_STEP_H
#define TEST_STEP_H

#include "step.h"

#include <graph.h>
#include <string>

namespace ara::step {
	class Test0Step : public ConfStep<Test0Step> {
	  private:
		using ConfStep<Test0Step>::ConfStep;

	  public:
		static std::string get_name();
		static std::string get_description();
		virtual void run() override;
	};

	class Test2Step : public ConfStep<Test2Step> {
	  private:
		using ConfStep<Test2Step>::ConfStep;

	  public:
		static std::string get_name();
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;
		virtual void run() override;
	};

	class BBSplitTest : public ConfStep<BBSplitTest> {
	  private:
		using ConfStep<BBSplitTest>::ConfStep;

	  public:
		static std::string get_name();
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;
		virtual void run() override;
	};

	class CFGOptimizeTest : public ConfStep<CFGOptimizeTest> {
	  private:
		using ConfStep<CFGOptimizeTest>::ConfStep;

	  private:
		const static inline option::TOption<option::String> input_file_template{"input_file", "Input file."};
		option::TOptEntity<option::String> input_file;
		virtual void init_options() override;

	  public:
		static std::string get_name();
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {input_file_template}; };

		virtual std::vector<std::string> get_single_dependencies() override;
		virtual void run() override;
	};

	class CompInsertTest : public ConfStep<CompInsertTest> {
	  private:
		using ConfStep<CompInsertTest>::ConfStep;

	  public:
		static std::string get_name();
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;
		virtual void run() override;
	};

	class FnSingleExitTest : public ConfStep<FnSingleExitTest> {
	  private:
		using ConfStep<FnSingleExitTest>::ConfStep;

	  public:
		static std::string get_name();
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;

		virtual void run() override;
	};

	class LLVMMapTest : public ConfStep<LLVMMapTest> {
	  private:
		using ConfStep<LLVMMapTest>::ConfStep;

	  public:
		static std::string get_name();
		static std::string get_description();
		virtual std::vector<std::string> get_single_dependencies() override;

		virtual void run() override;
	};

	class PosixClangGlobalTest : public ConfStep<PosixClangGlobalTest> {
	  private:
		using ConfStep<PosixClangGlobalTest>::ConfStep;

	  private:
		const static inline option::TOption<option::String> input_file_template{"input_file", "Input file."};
		option::TOptEntity<option::String> input_file;
		virtual void init_options() override;
		[[noreturn]] void fail(std::string msg);

	  public:
		static std::string get_name();
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {input_file_template}; };

		virtual std::vector<std::string> get_single_dependencies() override;
		virtual void run() override;
	};
} // namespace ara::step

#endif // TEST_STEP_H
