#pragma once

#include "bgl/bgl_bridge.h"
#include "graph.h"
#include "common/cy_helper.h"

namespace ara::cfg_wrapper {
	class ABBGraph : public ara::bgl_wrapper::SubGraphImpl<ara::cfg::ABBGraph, ara::cfg::FunctionDescriptor> {
	  public:
		using ara::bgl_wrapper::SubGraphImpl<ara::cfg::ABBGraph, ara::cfg::FunctionDescriptor>::SubGraphImpl;

		std::string to_string() {
			return ara::cy_helper::to_string(this->graph);
		}

	};
} // namespace ara::cfg_wrapper
