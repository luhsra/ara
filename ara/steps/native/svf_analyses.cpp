// vim: set noet ts=4 sw=4:

#include "svf_analyses.h"

#define VERSION_BKP VERSION
#undef VERSION
#include <Graphs/PTACallGraph.h>
#include <Graphs/VFGNode.h>
#include <SVF-FE/PAGBuilder.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

using namespace SVF;

namespace ara::step {
	std::string SVFAnalyses::get_description() { return "Run SVF analyses."; }

	void SVFAnalyses::run() {
		logger.info() << "Execute SVFAnalyses step." << std::endl;

		SVFModule* svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(graph.get_module());
		assert(svfModule != nullptr && "SVF Module is null");

		PAGBuilder builder;
		PAG* pag = builder.build(svfModule);
		assert(pag != nullptr && "SVF Module is null");

		Andersen* ander = AndersenWaveDiff::createAndersenWaveDiff(pag);

		SVFGBuilder svfBuilder;
		svfBuilder.buildFullSVFG(ander);

		// resolve indirect pointer
		pag->getICFG()->updateCallGraph(ander->getPTACallGraph());

		// we don't need to store anything here, since all SVF datastructures are stored in singletons
	}
} // namespace ara::step
