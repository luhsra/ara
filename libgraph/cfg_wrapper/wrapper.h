#pragma once

#include "bgl/bgl_bridge.h"
#include "graph.h"

namespace ara::cfg_wrapper {
	class ABBGraph : ara::bgl_wrapper::SubGraphImpl<ara::cfg::ABBGraph, ara::cfg::FunctionDescriptor> {
	  public:
		using ara::bgl_wrapper::SubGraphImpl<ara::cfg::ABBGraph, ara::cfg::FunctionDescriptor>::SubGraphImpl;
	};
} // namespace ara::cfg_wrapper
