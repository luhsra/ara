// vim: set noet ts=4 sw=4:

#include "svf_transformation.h"

#include <SVF-FE/BreakConstantExpr.h>

namespace ara::step {
	std::string SVFTransformation::get_description() {
		return "Do all necessary IR transformations needed by SVF analyses.";
	}

	void SVFTransformation::run() {
		SVF::BreakConstantGEPs break_geps;
		break_geps.runOnModule(graph.get_module());

		SVF::UnifyFunctionExitNodes unify;
		for (llvm::Function& func : graph.get_module()) {
			unify.runOnFunction(func);
		}
	}
} // namespace ara::step
