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
	void map_svfg(SVFGGraphtool& g, graph::SVFG svfg_graphtool, SVF::SVFG& svfg_svf, Logger& logger,
	              graph::GraphData& graph_data) {
		using GraphtoolVertex = typename boost::graph_traits<SVFGGraphtool>::vertex_descriptor;
		std::map<const SVF::VFGNode*, GraphtoolVertex> svf_to_ara_nodes;
		logger.info() << "Converting SVF graph to graphtool" << endl;

		// retrieve nullptr_node and blkptr_node via PAG
		PAG* pag = SVF::PAG::getPAG();
		auto get_vfg_node_by_pag_id = [&](SVF::NodeID id) -> const SVF::VFGNode* {
			PAGNode* pag_node = pag->getPAGNode(id);
			return svfg_svf.getDefSVFGNode(pag_node);
		};
		const SVF::VFGNode* nullptr_node = get_vfg_node_by_pag_id(pag->getNullPtr());
		const SVF::VFGNode* blackhole_node = get_vfg_node_by_pag_id(pag->getBlkPtr());
		bool found_nullptr = false;
		bool found_blackhole = false;

		// function to register vertex and its llvm value in value_to_svfg_node
		auto add_llvm_value = [&](const SVF::VFGNode* svf_vertex, GraphtoolVertex vertex) {
			const llvm::Value* llvm_value = reinterpret_cast<const llvm::Value*>(svf_vertex->getValue());
			if (llvm_value == nullptr) {
				return;
			}
			uint64_t vertex_as_int = static_cast<uint64_t>(vertex);
			auto vertex_container = graph_data.value_to_svfg_node.find(llvm_value);
			if (vertex_container == graph_data.value_to_svfg_node.end()) {
				graph_data.value_to_svfg_node.insert({llvm_value, {vertex_as_int}});
			} else {
				std::get<1>(*vertex_container).push_back(vertex_as_int);
			}
		};

		// convert nodes
		for (const auto& [_, svf_vertex] : svfg_svf) {
			auto graphtool_vertex = boost::add_vertex(g);
			std::stringstream ss;
			ss << type_to_str[svf_vertex->getNodeKind()] << " ID: " << svf_vertex->getId();
			svfg_graphtool.label[graphtool_vertex] = ss.str();
			svfg_graphtool.obj[graphtool_vertex] = reinterpret_cast<uintptr_t>(svf_vertex);
			svf_to_ara_nodes[svf_vertex] = graphtool_vertex;

			// register node in value_to_svfg_node map
			add_llvm_value(svf_vertex, graphtool_vertex);

			// check if node is nullptr or blkptr node
			// register in graph_data if found
			if (svf_vertex == nullptr_node) {
				graph_data.nullptr_node = static_cast<uint64_t>(graphtool_vertex);
				assert(!found_nullptr && "nullptr already found!");
				found_nullptr = true;
			} else if (svf_vertex == blackhole_node) {
				graph_data.blackhole_node = static_cast<uint64_t>(graphtool_vertex);
				assert(!found_blackhole && "blackhole already found!");
				found_blackhole = true;
			}
		}

		assert(found_nullptr && "No nullptr node found!");
		assert(found_blackhole && "No blackhole node found!");

		// convert edges
		for (const auto& [svf_vertex, graphtool_vertex] : svf_to_ara_nodes) {
			// convert all incoming edges of all vertices (We can not iterate over all edges directly)
			for (const SVF::VFGEdge* svf_edge :
			     boost::make_iterator_range(svf_vertex->InEdgeBegin(), svf_vertex->InEdgeEnd())) {
				auto graphtool_edge = boost::add_edge(svf_to_ara_nodes[svf_edge->getSrcNode()], graphtool_vertex, g);
				svfg_graphtool.eobj[graphtool_edge.first] = reinterpret_cast<uintptr_t>(svf_edge);
			}
		}
		logger.info() << "Conversion finished" << endl;
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
