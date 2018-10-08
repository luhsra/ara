#ifndef PASSAGE_H
#define PASSAGE_H

#include "graph.h"
#include "Python.h"

#include <string>
#include <stdexcept>
#include <vector>

namespace passage {

	// some comment
	class Passage {
	private:
		const PyObject* config;

	public:

		Passage(const PyObject* config) : config(config) {
			if (!PyDict_Check(config)) {
				throw std::invalid_argument("Pass: Need a dict as config.");
			}
		}
		virtual ~Passage() {}

		virtual std::string get_name() = 0;

		virtual std::string get_description() = 0;

		virtual std::vector<std::string> get_dependencies() = 0;

		/**
		 * This method is called, when the pass is invoked.
		 */
		virtual void run(graph::Graph graph) = 0;

	};
}

#endif //PASSAGE_H
