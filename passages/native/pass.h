#ifndef PASS_H
#define PASS_H

#include "graph.h"
#include "Python.h"

#include <string>
#include <stdexcept>
#include <vector>

namespace pass {

	// some comment
	class Pass {
	private:
		const PyObject* config;

	public:

		Pass(const PyObject* config) : config(config) {
			if (!PyDict_Check(config)) {
				throw std::invalid_argument("Pass: Need a dict as config.");
			}
		}
		virtual ~Pass() {}

		virtual std::string get_name() = 0;

		virtual std::string get_description() = 0;

		virtual std::vector<std::string> get_dependencies() = 0;

		/**
		 * This method is called, when the pass is invoked.
		 */
		virtual void run(graph::Graph graph) = 0;

	};
}

#endif //PASS_H
