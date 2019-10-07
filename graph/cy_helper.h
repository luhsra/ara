/* Helper functions for the Cython graph bridge. DO NOT USE IN C++-CODE! */

#pragma once

#include <memory>

#include "bgl/bgl_bridge.h"
#include "graph.h"

namespace ara::graph::cy_helper {
	struct BGLExtensions {
		static const std::shared_ptr<ara::bgl_wrapper::GraphWrapper> get_subgraph(ara::cfg::ABBGraph& self, const std::shared_ptr<ara::bgl_wrapper::VertexWrapper> vertex){
			auto v = std::static_pointer_cast<ara::bgl_wrapper::VertexImpl<ara::cfg::ABBGraph>>(vertex);
			return std::make_shared<ara::bgl_wrapper::SubGraphImpl<ara::cfg::FunctionDescriptor, ara::cfg::FunctionDescriptor, ara::cfg::ABBGraph>>(self.get_subgraph(v->v), self);
		}
	};

	std::shared_ptr<bgl_wrapper::GraphWrapper> create_graph(bool directed, bool with_subgraph) {
		typedef boost::subgraph<boost::adjacency_list<boost::vecS, boost::vecS, boost::bidirectionalS,
		                                              boost::no_property, boost::property<boost::edge_index_t, int>>>
		    DirectedSubGraph;
		typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::bidirectionalS> DirectedGraph;
		typedef boost::subgraph<boost::adjacency_list<boost::vecS, boost::vecS, boost::undirectedS, boost::no_property,
		                                              boost::property<boost::edge_index_t, int>>>
		    UnDirectedSubGraph;
		typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::undirectedS> UnDirectedGraph;

		if (directed) {
			if (with_subgraph) {
				return std::make_shared<ara::bgl_wrapper::SubGraphOwnerImpl<DirectedSubGraph>>();
			} else {
				return std::make_shared<ara::bgl_wrapper::GraphOwnerImpl<DirectedGraph>>();
			}
		} else {
			if (with_subgraph) {
				return std::make_shared<ara::bgl_wrapper::SubGraphOwnerImpl<UnDirectedSubGraph>>();
			} else {
				return std::make_shared<ara::bgl_wrapper::GraphOwnerImpl<UnDirectedGraph>>();
			}
		}
		return nullptr;
	}
}
