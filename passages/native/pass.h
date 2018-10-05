#ifndef PASS_H
#define PASS_H

#include "graph.h"

#include <string>

namespace pass {

	// some comment
	class Pass {
	public:

		Pass() = default;
		virtual ~Pass() {}

		virtual std::string get_name() = 0;

		virtual std::string get_description() = 0;

		/**
		 * This method is called, when the pass is invoked.
		 */
		virtual void run(graph::Graph graph) = 0;

	};
}

#endif //PASS_H
