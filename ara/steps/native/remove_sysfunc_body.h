#pragma once

#include "option.h"
#include "step.h"

#include "llvm/ADT/StringRef.h"

#include <Python.h>
#include <graph.h>

namespace ara::step {
	using syscall_map = std::map<const std::string, ara::os::SysCall>;
	class RemoveSysfuncBody : public ConfStep<RemoveSysfuncBody> {
	  private:
		using ConfStep<RemoveSysfuncBody>::ConfStep;

		const static inline option::TOption<option::Bool> drop_llvm_suffix_option_template{
		    "drop_llvm_suffix",
		    "If true this step also removes system functions that have a llvm suffix. "
		    "An example for syscalls with a llvm suffix is: \"sleep.5\" or \"wait.3\". "
		    "If you do not need this feature, set this option to false to increase performance of this step.",
		    /* ty = */ option::Bool(),
		    /* default = */ true};
		option::TOptEntity<option::Bool> drop_llvm_suffix_option;
		virtual void init_options();

		void py_assert(bool cond, const std::string& msg, const PyObject* error_with_obj);
		std::vector<ara::os::OS> py_get_oses();
		syscall_map get_os_syscalls();
		PyObject* get_drop_llvm_suffix_func();
		PyObject* drop_llvm_suffix(PyObject* drop_llvm_suffix_func, const llvm::StringRef& func_name);

	  public:
		static std::string get_name() { return "RemoveSysfuncBody"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {drop_llvm_suffix_option_template}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"IRReader"}; }

		virtual void run() override;
	};
} // namespace ara::step