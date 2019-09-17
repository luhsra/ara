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
}
