// vim: set noet ts=4 sw=4:

#include "autosar_generator_ir.h"

#include <regex>
#include <set>

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
	void AutosarGeneratorIR::AddSystemcalls(Module& module, LLVMContext& context) {
		logger.info() << "Execute AddSystemcalls" << std::endl;

		FunctionType* void_type_void = FunctionType::get(Type::getVoidTy(context), false);
		std::vector<Type*> arg_types;
		arg_types.emplace_back(Type::getInt32Ty(context));
		FunctionType* void_type_iii = FunctionType::get(Type::getVoidTy(context), arg_types, false);

		/* Kickoff function af beginning of each task */
		Function* kickoff = Function::Create(void_type_void, Function::ExternalLinkage, "AUTOSAR_kickoff", &module);

		/* arch startup at beginning of main */
		Function* arch_startup = Function::Create(void_type_void, Function::ExternalLinkage, "arch_startup", &module);

		/* error hook if using ret to return from Task */
		Function* error_hook = Function::Create(void_type_iii, Function::ExternalLinkage, "__OS_HOOK_ErrorHook", &module);

		for (auto& function : module) {
			// all TASK(foo) functions start with this string, see os/os.h
			if (function.getName().startswith("AUTOSAR_TASK_FUNC")) {
				IRBuilder<> builder(context);
				BasicBlock& bb = *function.begin();
				Instruction* inst = &*bb.begin();
				builder.SetInsertPoint(inst);
				std::vector<Value*> ArgsV;
				builder.CreateCall(kickoff, ArgsV);
				logger.debug() << "add " << kickoff->getName().str() << " to " << function.getName().str() << std::endl;

				BasicBlock& bb1 = function.back();
				Instruction* inst1 = &bb1.back();
				if (llvm::dyn_cast<llvm::ReturnInst>(inst1)) {
					builder.SetInsertPoint(inst1);
					ArgsV.emplace_back(builder.getInt32(14)); //E_OS_MISSINGEND
					builder.CreateCall(error_hook, ArgsV);
					logger.debug() << "add " << error_hook->getName().str() << " to " << function.getName().str() << std::endl;
				}
			} else if (function.getName().equals("main")) {
				IRBuilder<> builder(context);
				BasicBlock& bb = *function.begin();
				Instruction* inst = &*bb.begin();
				builder.SetInsertPoint(inst);
				std::vector<Value*> ArgsV;

				builder.CreateCall(arch_startup, ArgsV);
				logger.debug() << "add " << arch_startup->getName().str() << " to " << function.getName().str() << std::endl;
			}
		}
	}

	/*! Rename each systemcall to a basic block specific pendant.
	 *
	 * Each systemcall is renamed to systemcallname_basicblockname.
	 */
	void AutosarGeneratorIR::RenameSystemcall(Module& module, CallInst* call) {
		Function* func = call->getCalledFunction();
		FunctionType* func_ty = func->getFunctionType();

		std::stringstream name;
		name << func->getName().str() << "_" << call->getParent()->getName().str();

		Function* x = Function::Create(func_ty, Function::ExternalLinkage, name.str(), &module);
		call->setCalledFunction(x);

		logger.debug() << "Rename function " << name.str() << std::endl;
	}

	/*! Find all systemcalls and rename them via RenameSystemcall(). */
	void AutosarGeneratorIR::RenameSystemcalls(Module& module) {
		logger.info() << "Execute RenameSystemcalls" << std::endl;

		std::set<std::string> SystemCalls = this->graph.get_os().get_syscall_names();
		// only a subset of system calls are renamed
		std::regex re("Resource|Task|Event|Spinlock|Alarm|Counter");

		for (const std::string& call : SystemCalls) {
			if (std::regex_search(call, re))
				continue;

			SystemCalls.erase(call);
		}

		for (auto& function : module) {
			for (auto& bb : function) {
				for (auto& inst : bb) {
					if (CallInst* callInst = dyn_cast<CallInst>(&inst)) {
						Function* func = callInst->getCalledFunction();
						if (!func)
							continue;
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
		AddSystemcalls(module, context);

		const auto& rename = rename_syscalls.get();
		assert(rename);
		if (*rename) {
			RenameSystemcalls(module);
		}
	}
} // namespace ara::step
