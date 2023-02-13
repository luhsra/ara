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

      public:
        virtual ~AutosarGeneratorIR(){};
        static std::string get_name() { return "AutosarGeneratorIR"; }
        static std::string get_description();

        virtual std::vector<std::string> get_single_dependencies() override { return {"IPIAvoidance", "LockElision"}; }

        virtual void run() override;
    };
} // namespace ara::step
