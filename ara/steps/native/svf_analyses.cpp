// vim: set noet ts=4 sw=4:

#include "svf_analyses.h"

#include "common/util.h"

#include <Graphs/VFGNode.h>
#include <SVF-FE/SVFIRBuilder.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>

using namespace SVF;

namespace ara::step {
	std::string SVFAnalyses::get_description() { return "Run SVF analyses."; }

	void SVFAnalyses::run() {
		// Disable SVF ThreadCallGraph because this option will not work with POSIX os model.
		const char* command_line[] = {"ara", "-enable-tcg=false"};
		llvm::cl::ParseCommandLineOptions(2, command_line);

		logger.info() << "Building SVF graphs." << std::endl;
		SVFModule* svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(graph.get_module());
		assert(svfModule != nullptr && "SVF Module is null");
		svfModule->buildSymbolTableInfo();

		SVFIRBuilder builder(svfModule);
		SVFIR* svfir = builder.build();
		assert(svfir != nullptr && "SVFIR is null");

		Andersen* ander = AndersenWaveDiff::createAndersenWaveDiff(svfir);

		SVFGBuilder svfBuilder(true);
		std::unique_ptr<SVFG> svfg(svfBuilder.buildFullSVFG(ander));

		graph.get_graph_data().initialize_svfg(std::move(svfg));

		ICFG* icfg = svfir->getICFG();
		PTACallGraph* callgraph = ander->getPTACallGraph();

		// resolve indirect pointer in the icfg
		icfg->updateCallGraph(callgraph);

		// we don't need to store anything here, since all SVF datastructures are stored in singletons

		if (*dump.get()) {
			icfg->dump(*dump_prefix.get() + "svf-icfg");
			callgraph->dump(*dump_prefix.get() + "svf-callgraph");
			graph.get_svfg().dump(*dump_prefix.get() + "svfg");
		}
	}
} // namespace ara::step
