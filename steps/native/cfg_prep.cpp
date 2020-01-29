// vim: set noet ts=4 sw=4:

#include "cfg_prep.h"
#include <cassert>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Utils.h>

namespace ara::step {
    using namespace llvm;
	std::string CFGPreparation::get_description() const {
		return "Modifies the CFG to prepare it for further usage."
		       "\n"
		       "Performs various LLVM Passes on the IR to simplify the CFG.";
	}

    std::vector<std::string> CFGPreparation::get_dependencies() { return {"IRReader"}; }

	void CFGPreparation::fill_options() { opts.emplace_back(pass_list); }

	void CFGPreparation::run(graph::Graph& graph) {
        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);

        // Get pass list from command line options
        // TODO fix assert
        //assert(pass_list.get().second);
        std::vector<std::string> passes = pass_list.get().first;

        // Add the specified passes to the Function Pass Manager
        for (std::string pass_name : passes) {
            switch(resolveOption(pass_name)) {
                case Invalid: { 
                    std::cerr << "Specified pass name '" << pass_name << "' could not be resolved." << std::endl;
                    abort();
                }
                case ConstantPropagation: {
                    fpm.add(createConstantPropagationPass());
                    break;
                }
                case DeadCodeElimination: {
                    fpm.add(createDeadCodeEliminationPass());
                    break;
                }
                case MemoryToRegister: {
                    fpm.add(createPromoteMemoryToRegisterPass());
                    break;
                }
                default: break;
            }
        }

        // TODO Print Debug Information about Pass Chain to be run

        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn't given
            if (function.hasOptNone()) {
                function.removeFnAttr(Attribute::OptimizeNone);
            }

            fpm.run(function);
            // TODO Enable LLVM's "per-Pass-dump" and redirect LLVM ostream to ara's if necessary
            function.dump();
        }
		logger.debug() << this->get_name() << " step finished successfully. " << std::endl;
	}

    CFGPreparation::Option CFGPreparation::resolveOption(std::string arg) {
        static const std::map<std::string, Option> passOptions {
            { "dce",       DeadCodeElimination },
            { "constprop", ConstantPropagation },
            { "sccp",      SparseConditionalConstantPropagation },
            { "mem2reg",   MemoryToRegister }
        };

        auto iterator = passOptions.find(arg);
        if ( iterator != passOptions.end() ) {
            return iterator->second;
        }
        return Invalid;
    }
} // namespace ara::step
