// vim: set noet ts=4 sw=4:

#ifndef STEP_H
#define STEP_H

#include "Python.h"
#include "graph.h"
#include "logging.h"
#include "option.h"

#include <stdexcept>
#include <string>
#include <vector>
#include <functional>

namespace step {

	/**
	 * Superclass for constructing arbitrary steps in C++.
	 */
	class Step {
		public:
		using option_ref = std::reference_wrapper<ara::option::Option>;
		private:
		  std::vector<option_ref> opts;

	  protected:
		Logger logger;

		ara::option::TOption<ara::option::Choice<5>> log_level{"log_level", "Adjust the log level of this step.",
				ara::option::makeChoice("critical", "error", "warn", "info", "debug"),
				/* global = */ true};
		ara::option::TOption<ara::option::Choice<2>> os{"os", "Select the operating system.",
				ara::option::makeChoice("FreeRTOS", "OSEK"),
				/* global = */ true};
		ara::option::TOption<ara::option::String> after{"after", "Queue step directly after the mentioned step.",
			ara::option::String(), /* global = */ true};

		/**
		 * Fill with all used options.
		 */
		virtual void fill_options(std::vector<option_ref>&) {}

	  public:
		/**
		 * Contruct a native step.
		 */
		Step() {
			opts.emplace_back(log_level);
			opts.emplace_back(os);
			opts.emplace_back(after);
		}

		/**
		 * Apply configuration to the step.
		 * Must be called after the constructor.
		 */
		void parse_options(PyObject* config) {
			fill_options(opts);

			if (!PyDict_Check(config)) {
				throw std::invalid_argument("Step: Need a dict as config.");
			}

			for (ara::option::Option& option : opts) {
				option.set_step_name(this->get_name());
				option.check(config);
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
		virtual std::string get_name() const = 0;

		/**
		 * Get a descriptive string of the step that says what the step is doing.
		 */
		virtual std::string get_description() const = 0;

		/**
		 * Get all dependencies of this step.
		 *
		 * @Return: A list of step names (the ones that are returned with get_name().
		 */
		virtual std::vector<std::string> get_dependencies() = 0;

		/**
		 * This method is called, when the pass is invoked.
		 */
		virtual void run(graph::Graph& graph) = 0;

		/**
		 * Return a vector with all options.
		 */
		const std::vector<option_ref>& options() const { return opts; }
	};

} // namespace step

#endif // STEP_H
