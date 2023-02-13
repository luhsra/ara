// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"
#include <llvm/IR/Intrinsics.h>

#include <graph.h>

namespace ara::step {
    class AutosarGeneratorIR : public ConfStep<AutosarGeneratorIR> {
      private:
        using ConfStep<AutosarGeneratorIR>::ConfStep;

        const static inline option::TOption<option::Bool> rename_syscalls_template {
            "rename_syscalls", "Rename System Calls for specialization",
            /* ty = */ option::Bool(),
            /* default = */ false
        };
        option::TOptEntity<option::Bool> rename_syscalls;
		virtual void init_options() override;

      public:
        virtual ~AutosarGeneratorIR(){};
        static std::string get_name() { return "AutosarGeneratorIR"; }
        static std::string get_description();
        static Step::OptionVec get_local_options();

        virtual std::vector<std::string> get_single_dependencies() override { return {"IPIAvoidance", "LockElision"}; }

        virtual void run() override;
    };
} // namespace ara::step
