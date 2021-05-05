#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class RemoveSyscallDef : public ConfStep<RemoveSyscallDef> {
	  private:
		using ConfStep<RemoveSyscallDef>::ConfStep;
        void py_assert(bool cond, std::string msg, PyObject* error_with_obj);

	  public:
		static std::string get_name() { return "RemoveSyscallDef"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {"IRReader"}; }

		virtual void run() override;
	};
} // namespace ara::step