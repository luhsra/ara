// vim: set noet ts=4 sw=4:

#ifndef STEP_H
#define STEP_H

#include "Python.h"
#include "graph.h"
#include "logging.h"

#include <stdexcept>
#include <string>
#include <vector>

namespace step {

	/**
	 * Superclass for constructing arbitrary steps in C++.
	 */
	class Step {
	  protected:
		PyObject* config;
		Logger logger;

	  public:
		/**
		 * Contruct a native step.
		 *
		 * @Args
		 * config -- a Python dictionary, that holds the configuration of the whole program.
		 */
		Step(PyObject* config) : config(config) {
			if (!PyDict_Check(config)) {
				throw std::invalid_argument("Step: Need a dict as config.");
			}
		}

		/**
		 * Set the python logger object, this must be called directly after the constructor.
		 */
		void set_logger(PyObject* py_logger) { logger = Logger(py_logger); }

		virtual ~Step() {}

		/**
		 * Return a unique name of this step. This acts as ID for the step.
		 */
		virtual std::string get_name() = 0;

		/**
		 * Get a descriptive string of the step that says what the step is doing.
		 */
		virtual std::string get_description() = 0;

		/**
		 * Get all depencies of this step.
		 *
		 * @Return: A list of step names (the ones that are returned with get_name().
		 */
		virtual std::vector<std::string> get_dependencies() = 0;

		/**
		 * This method is called, when the pass is invoked.
		 */
		virtual void run(graph::Graph& graph) = 0;
	};

	template<class S>
	Step* step_fac(PyObject* config)
	{
	    return new S(config);
	}
} // namespace step

#endif // STEP_H
