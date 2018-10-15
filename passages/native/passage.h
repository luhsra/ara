// vim: set noet ts=4 sw=4:

#ifndef PASSAGE_H
#define PASSAGE_H

#include "graph.h"
#include "Python.h"

#include <string>
#include <stdexcept>
#include <vector>

namespace passage {

	/**
	 * Superclass for constructing arbitrary passages in C++.
	 */
	class Passage {
	protected:
		PyObject* config;

	public:

		/**
		 * Contruct a native passage.
		 *
		 * @Args
		 * config -- a Python dictionary, that holds the configuration of the whole program.
		 */
		Passage(PyObject* config) : config(config) {
			if (!PyDict_Check(config)) {
				throw std::invalid_argument("Pass: Need a dict as config.");
			}
		}
		virtual ~Passage() {}

		/**
		 * Return a unique name of this passage. This acts as ID for the passage.
		 */
		virtual std::string get_name() = 0;

		/**
		 * Get a descriptive string of the passage that says what the passage is doing.
		 */
		virtual std::string get_description() = 0;

		/**
		 * Get all depencies of this passage.
		 *
		 * @Return: A list of passage names (the ones that are returned with get_name().
		 */
		virtual std::vector<std::string> get_dependencies() = 0;

		/**
		 * This method is called, when the pass is invoked.
		 */
		virtual void run(graph::Graph& graph) = 0;

	};
}

#endif //PASSAGE_H
