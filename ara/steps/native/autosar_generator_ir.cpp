// vim: set noet ts=4 sw=4:

#include "autosar_generator_ir.h"
#include <set>
#include <regex>

namespace ara::step {
    using namespace llvm;

    std::string AutosarGeneratorIR::get_description() {
        return "Add kickoff function"
               "\n"
               "Add AUTOSAR_kickoff() function to each TASK";
    }

    void AutosarGeneratorIR::init_options() {
		rename_syscalls = rename_syscalls_template.instantiate(get_name());
		opts.emplace_back(rename_syscalls);
	}

	Step::OptionVec AutosarGeneratorIR::get_local_options() { return {rename_syscalls_template}; }

    /*! Create a unique kickoff function call at the beginning of each task. */
    void AutosarGeneratorIR::AddKickoffFunctionCalls(Module &module, LLVMContext &context) {
        logger.info() << "Execute AddKickoffFunctionCalls" << std::endl;

        std::vector<Type *> args;
        FunctionType *kickoff_type = FunctionType::get(Type::getVoidTy(context), args, false);
        Function *kickoff = Function::Create(kickoff_type, Function::ExternalLinkage,
            "AUTOSAR_kickoff", &module);

        for (auto &function : module) {
            // all TASK(foo) functions start with this string, see os/os.h
            if (function.getName().startswith("AUTOSAR_TASK_FUNC")) {
				BasicBlock &bb = *function.begin();
				IRBuilder<> builder(context);
                Instruction *inst = &*bb.begin();
                builder.SetInsertPoint(inst);

                std::vector<Value*> ArgsV;
                builder.CreateCall(kickoff, ArgsV);

                logger.debug() << "add " << kickoff->getName().str() << " to " << function.getName().str() << std::endl;
            }
        }
    }

    /*! Rename each systemcall to a basic block specific pendant.
    *
    * Each systemcall is renamed to systemcallname_basicblockname.
    */
    void AutosarGeneratorIR::RenameSystemcall(Module &module, CallInst * call) {
        Function * func = call->getCalledFunction();
        FunctionType *func_ty = func->getFunctionType();

        std::stringstream name;
        name << func->getName().str() << "_" << call->getParent()->getName().str();

        Function *x = Function::Create(func_ty,
                                    Function::ExternalLinkage,
                                    name.str(), &module);
        call->setCalledFunction(x);

        logger.debug() << "Rename function " << name.str() << std::endl;
    }

    /*! Find all systemcalls and rename them via RenameSystemcall(). */
    void AutosarGeneratorIR::RenameSystemcalls(Module &module) {
        logger.info() << "Execute RenameSystemcalls" << std::endl;

        std::set<std::string> SystemCalls = this->graph.get_os().get_syscall_names();
        // only a subset of system calls are renamed
        std::regex re("Resource|Task|Event|Spinlock|Alarm");

        for (const std::string &call : SystemCalls) {
            if (std::regex_search(call, re))
                continue;

            SystemCalls.erase(call);
        }

        for (auto &function : module) {
            for (auto &bb : function) {
                for (auto &inst : bb) {
                    if (CallInst* callInst = dyn_cast<CallInst>(&inst)) {
                        Function * func = callInst->getCalledFunction();
                        if (!func) continue;
                        // Found a Call. Is it a systemcall?
                        for (auto syscall : SystemCalls) {
                            if (func->getName() == syscall) {
                                RenameSystemcall(module, callInst);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    void AutosarGeneratorIR::run() {
        logger.info() << "Execute AutosarGeneratorIR step." << std::endl;

        Module& module = graph.get_module();
        LLVMContext& context = module.getContext();
        AddKickoffFunctionCalls(module, context);

        const auto& rename = rename_syscalls.get();
        assert(rename);
        if (*rename) {
            RenameSystemcalls(module);
        }
    }
} // namespace ara::step
