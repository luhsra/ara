// vim: set noet ts=4 sw=4:

#include "svf_analyses.h"

#include "common/util.h"

#include <Graphs/VFGNode.h>
#include <SVF-FE/PAGBuilder.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>
#include <sstream>

using namespace SVF;

namespace ara::step {
	// clang-format off
	// clang-format is failing to recognize the lambda function here
	namespace {
		// manual mapping of svf/include/Graphs/VFGNode.h
		constexpr auto type_to_str{[]() constexpr {
			std::array<const char*, 24> result{};
			result[VFGNode::VFGNodeK::Addr] = "AddrVFGNode";
			result[VFGNode::VFGNodeK::Copy] = "Copy";
			result[VFGNode::VFGNodeK::Gep] = "Gep";
			result[VFGNode::VFGNodeK::Store] = "Store";
			result[VFGNode::VFGNodeK::Load] = "Load";
			result[VFGNode::VFGNodeK::Cmp] = "Cmp";
			result[VFGNode::VFGNodeK::BinaryOp] = "BinaryOp";
			result[VFGNode::VFGNodeK::UnaryOp] = "UnaryOp";
			result[VFGNode::VFGNodeK::TPhi] = "TPhi";
			result[VFGNode::VFGNodeK::TIntraPhi] = "TIntraPhi";
			result[VFGNode::VFGNodeK::TInterPhi] = "TInterPhi";
			result[VFGNode::VFGNodeK::MPhi] = "MPhi";
			// TODO: here are some values missing, see svf/include/Graphs/VFGNode.h
			return result;
		}()};
	} // namespace
}
// clang-format on

namespace ara::step {
	std::string SVFAnalyses::get_description() { return "Run SVF analyses."; }

	// map SVF SVFG to graph_tool SVFG
	template <typename SVFGGraphtool>
	void map_svfg(SVFGGraphtool& g, graph::SVFG svfg_graphtool, SVF::SVFG& svfg_svf, Logger& logger) {
		using GraphtoolVertex = typename boost::graph_traits<SVFGGraphtool>::vertex_descriptor;
		std::map<const SVF::VFGNode*, GraphtoolVertex> svf_to_ara_nodes;
		logger.info() << "Converting SVF graph to graphtool" << endl;

		// convert nodes
		for (const auto& [_, svf_vertex] : svfg_svf) {
			auto graphtool_vertex = boost::add_vertex(g);
			std::stringstream ss;
			ss << type_to_str[svf_vertex->getNodeKind()] << " ID: " << svf_vertex->getId();
			svfg_graphtool.vLabel[graphtool_vertex] = ss.str();
			svfg_graphtool.vObj[graphtool_vertex] = reinterpret_cast<uintptr_t>(svf_vertex);
			svf_to_ara_nodes[svf_vertex] = graphtool_vertex;
		}

		// convert edges
		for (const auto& [svf_vertex, graphtool_vertex] : svf_to_ara_nodes) {
			// convert all incoming edges of all vertices (We can not iterate over all edges directly)
			for (const SVF::VFGEdge* svf_edge :
			     boost::make_iterator_range(svf_vertex->InEdgeBegin(), svf_vertex->InEdgeEnd())) {
				auto graphtool_edge = boost::add_edge(svf_to_ara_nodes[svf_edge->getSrcNode()], graphtool_vertex, g);
				svfg_graphtool.eObj[graphtool_edge.first] = reinterpret_cast<uintptr_t>(svf_edge);
			}
		}
	}

	void SVFAnalyses::run() {
		logger.info() << "Building SVF graphs." << std::endl;
		SVFModule* svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(graph.get_module());
		assert(svfModule != nullptr && "SVF Module is null");

		PAGBuilder builder;
		PAG* pag = builder.build(svfModule);
		assert(pag != nullptr && "PAG is null");

		Andersen* ander = AndersenWaveDiff::createAndersenWaveDiff(pag);

		SVFGBuilder svfBuilder(true);
		std::unique_ptr<SVFG> svfg(svfBuilder.buildFullSVFG(ander));

		graph.get_graph_data().initialize_svfg(std::move(svfg));

		ICFG* icfg = pag->getICFG();
		PTACallGraph* callgraph = ander->getPTACallGraph();

		// resolve indirect pointer in the icfg
		icfg->updateCallGraph(callgraph);

		// we don't need to store anything here, since all SVF datastructures are stored in singletons

		graph::SVFG svfg_graphtool = graph.get_svfg_graphtool();
		graph_tool::gt_dispatch<>()([&](auto& g) { map_svfg(g, svfg_graphtool, graph.get_svfg(), logger); },
		                            graph_tool::always_directed())(svfg_graphtool.graph.get_graph_view());

		if (*dump.get()) {
			icfg->dump(*dump_prefix.get() + "svf-icfg");
			callgraph->dump(*dump_prefix.get() + "svf-callgraph");
			graph.get_svfg().dump(*dump_prefix.get() + "svfg");
		}
	}
} // namespace ara::step
