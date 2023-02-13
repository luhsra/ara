// vim: set noet ts=4 sw=4:

#include "autosar_generator_ir.h"

namespace ara::step {
    using namespace llvm;

    std::string AutosarGeneratorIR::get_description() {
        return "Add kickoff function"
               "\n"
               "Add AUTOSAR_kickoff() function to each TASK";
    }

    void AutosarGeneratorIR::run() {
        logger.info() << "Execute AutosarGeneratorIR step." << std::endl;

        Module& module = graph.get_module();
        LLVMContext& context = module.getContext();


        std::vector<Type *> args;
        FunctionType *kickoff_type = FunctionType::get(Type::getVoidTy(context), args, false);
        Function *kickoff = Function::Create(kickoff_type, Function::ExternalLinkage,
            "AUTOSAR_kickoff", &module);

        for (auto &function : module) {
            BasicBlock &bb = *function.begin();
            IRBuilder<> builder(context);

            // all TASK(foo) functions start with this string, see os/os.h
            if (function.getName().startswith("AUTOSAR_TASK_FUNC")) {
                Instruction *inst = &*bb.begin();
                builder.SetInsertPoint(inst);

                std::vector<Value*> ArgsV;
                CallInst *CS = builder.CreateCall(kickoff, ArgsV);

                logger.debug() << "add " << kickoff->getName().str() <<
                    " to " << function.getName().str() << std::endl;
            }
        }
    }
} // namespace ara::step
