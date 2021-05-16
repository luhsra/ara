#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	using syscall_map = std::map<const std::string, ara::os::SysCall>;
	class RemoveSysfuncBody : public ConfStep<RemoveSysfuncBody> {
	  private:
		using ConfStep<RemoveSysfuncBody>::ConfStep;
		void py_assert(bool cond, std::string msg, PyObject* error_with_obj);
		std::vector<ara::os::OS> py_get_oses();
		syscall_map get_os_syscalls();

	  public:
		static std::string get_name() { return "RemoveSysfuncBody"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"IRReader"}; }

		virtual void run() override;
	};
} // namespace ara::step