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

		void run(graph::Graph graph, std::vector<std::string> files) {
			//graph.addVertex();
			for (const auto& file : files) {
				std::cout << "Get file: " << file << '\n';
			}
		}
	};

}

#endif //PASS_H
