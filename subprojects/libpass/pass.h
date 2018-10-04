#ifndef PASS_H
#define PASS_H

#include <string>
#include <tuple>
#include <vector>
#include <iostream>
#include "graph.h"

namespace pass {

	// some comment
	class Pass {
	public:

		Pass() = default;

		/**
		 * This method is called, when the pass is invoked.
		 */
		void run(graph::Graph graph, std::vector<std::string> files) {
		}

		/**
		 * Get a unique ID for the pass.
		 */
		//virtual std::string getID();
	};

}

#endif //PASS_H
