// vim: set noet ts=4 sw=4:

#include "svf_analyses.h"

#include "common/util.h"

#include <Graphs/VFGNode.h>
#include <SVF-FE/SVFIRBuilder.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>
#include <sstream>

using namespace SVF;

namespace ara::step {
	// clang-format off
	// clang-format is failing to recognize the lambda function here
	namespace {
		// manual mapping of svf/include/Graphs/VFGNode.h
		#define vfg_type_to_str(name) result[VFGNode::VFGNodeK::name] = #name "VFGNode";
		constexpr auto type_to_str{[]() constexpr {
			std::array<const char*, 26> result{};
			vfg_type_to_str(Addr)
			vfg_type_to_str(Copy)
			vfg_type_to_str(Gep)
			vfg_type_to_str(Store)
			vfg_type_to_str(Load)
			vfg_type_to_str(Cmp)
			vfg_type_to_str(BinaryOp)
			vfg_type_to_str(UnaryOp)
			vfg_type_to_str(Branch)
			vfg_type_to_str(TPhi)
			vfg_type_to_str(TIntraPhi)
			vfg_type_to_str(TInterPhi)
			vfg_type_to_str(MPhi)
			vfg_type_to_str(MIntraPhi)
			vfg_type_to_str(MInterPhi)
			vfg_type_to_str(FRet)
			vfg_type_to_str(ARet)
			vfg_type_to_str(AParm)
			vfg_type_to_str(FParm)
			vfg_type_to_str(FunRet)
			vfg_type_to_str(APIN)
			vfg_type_to_str(APOUT)
			vfg_type_to_str(FPIN)
			vfg_type_to_str(FPOUT)
			vfg_type_to_str(NPtr)
			vfg_type_to_str(DummyVProp)
			return result;
		}()};
	} // namespace
}
// clang-format on

namespace ara::step {
	std::string SVFAnalyses::get_description() { return "Run SVF analyses."; }

	// map SVF SVFG to graph_tool SVFG
	template <typename SVFGGraphtool>
	void map_svfg(SVFGGraphtool& g, graph::SVFG svfg_graphtool, SVF::SVFG& svfg_svf, Logger& logger,
	              graph::GraphData& graph_data) {
		using GraphtoolVertex = typename boost::graph_traits<SVFGGraphtool>::vertex_descriptor;
		logger.info() << "Converting SVF graph to graphtool" << std::endl;

		// function to register node in svfg_to_graphtool_node map
		auto add_node_in_map = [&](const SVF::VFGNode* svf_vertex, GraphtoolVertex vertex) {
			uint64_t vertex_as_int = static_cast<uint64_t>(vertex);
			auto status = graph_data.svfg_to_graphtool_node.insert({svf_vertex, vertex_as_int});
			assert(std::get<1>(status) && "vertex already exists in map!");
		};

		// convert nodes
		for (const auto& [_, svf_vertex] : svfg_svf) {
			auto graphtool_vertex = boost::add_vertex(g);
			std::stringstream ss;
			ss << type_to_str.at(svf_vertex->getNodeKind()) << " ID: " << static_cast<uint64_t>(graphtool_vertex);
			svfg_graphtool.label[graphtool_vertex] = ss.str();
			svfg_graphtool.obj[graphtool_vertex] = reinterpret_cast<uintptr_t>(svf_vertex);

			// register node in value_to_svfg_node map
			add_node_in_map(svf_vertex, graphtool_vertex);
		}

		// convert edges
		for (const auto& [svf_vertex, graphtool_vertex] : graph_data.svfg_to_graphtool_node) {
			// convert all incoming edges of all vertices (We can not iterate over all edges directly)
			for (const SVF::VFGEdge* svf_edge :
			     boost::make_iterator_range(svf_vertex->InEdgeBegin(), svf_vertex->InEdgeEnd())) {
				auto graphtool_edge =
				    boost::add_edge(graph_data.svfg_to_graphtool_node[svf_edge->getSrcNode()], graphtool_vertex, g);
				svfg_graphtool.eobj[graphtool_edge.first] = reinterpret_cast<uintptr_t>(svf_edge);
			}
		}
		logger.info() << "Conversion finished" << std::endl;
	}

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

		graph::SVFG svfg_graphtool = graph.get_svfg_graphtool();
		graph::GraphData& graph_data = graph.get_graph_data();
		graph_tool::gt_dispatch<>()([&](auto& g) { map_svfg(g, svfg_graphtool, graph.get_svfg(), logger, graph_data); },
		                            graph_tool::always_directed())(svfg_graphtool.graph.get_graph_view());

		if (*dump.get()) {
			icfg->dump(*dump_prefix.get() + "svf-icfg");
			callgraph->dump(*dump_prefix.get() + "svf-callgraph");
			graph.get_svfg().dump(*dump_prefix.get() + "svfg");
		}
	}
} // namespace ara::step
