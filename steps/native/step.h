// vim: set noet ts=4 sw=4:

#ifndef STEP_H
#define STEP_H

#include "logging.h"
#include "option.h"

#include <Python.h>
#include <functional>
#include <graph.h>
#include <llvm/Support/JSON.h>
#include <map>
#include <stdexcept>
#include <string>
#include <vector>

namespace ara::step {
	class Step;

	/**
	 * Lightweight wrapper class for the Python StepManager.
	 */
	class StepManager {
		friend class Step;

	  private:
		PyObject* step_manager = nullptr;

		StepManager() {}
		StepManager(PyObject* step_manager) : step_manager(step_manager) {}

	  public:
		/**
		 * See stepmanager.py for a description.
		 */
		void change_global_config(const llvm::json::Value& config);
		void chain_step(const llvm::json::Value& step_config);
		void chain_step(const std::string& step_name);
		void chain_step(const char* step_name);

		std::string get_execution_id();
	};

	/**
	 * Superclass for constructing arbitrary steps in C++.
	 */
	class Step {
	  public:
		using option_ref = std::reference_wrapper<option::Option>;

	  protected:
		std::vector<option_ref> opts;
		Logger logger;
		StepManager step_manager;

		// ATTENTION: If you change this, also change the option list in native_step.py for class Step.
		// All of these options are also defined in ara.py and have their defaults from there.
		option::TOption<option::Choice<6>> log_level{
		    "log_level", "Adjust the log level of this step.",
		    /* ty = */ option::makeChoice("critical", "error", "warn", "warning", "info", "debug"),
		    /* default_value = */ std::nullopt,
		    /* global = */ true};
		option::TOption<option::Bool> dump{"dump", "If possible, dump the changed graph into a dot file.",
		                                   /* ty = */ option::Bool(),
		                                   /* default_value = */ std::nullopt,
		                                   /* global = */ true};
		option::TOption<option::String> dump_prefix{
		    "dump_prefix", "If a file is dumped, set this as prefix for the files (default: dumps/{step_name}).",
		    /* ty = */ option::String(),
		    /* default_value = */ std::nullopt,
		    /* global = */ true};

		/**
		 * Fill with all used options.
		 */
		virtual void fill_options() {}

		/**
		 * Fail with an error message.
		 */
		void fail(const std::string& message) {
			logger.err() << message << std::endl;
			std::string step_name = get_name();
			throw StepError(step_name, message);
		}

	  public:
		/**
		 * Contruct a native step.
		 */
		Step() {
			opts.emplace_back(log_level);
			opts.emplace_back(dump);
			opts.emplace_back(dump_prefix);
		}

		/**
		 * Init options. Must be called after the constructor.
		 */
		void init_options() {
			fill_options();
			for (option::Option& option : opts) {
				option.set_step_name(get_name());
			}
		}

		/**
		 * Apply a configuration to the step.
		 * Can be run multiple times.
		 */
		void apply_config(PyObject* config) {
			if (!PyDict_Check(config)) {
				throw std::invalid_argument("Step: Need a dict as config.");
			}

			for (option::Option& option : opts) {
				option.check(config);
			}
			auto lvl = log_level.get();
			if (lvl) {
				logger.set_level(translate_level(*lvl));
			}
			// This option are set by default in ara.py. Check that additionally.
			assert(dump_prefix.get());
			assert(dump.get());
			// HINT: For Python steps also the dump_prefix string replacement happens in apply_config. However, this is
			// easier in Python so already done in the NativeStep wrapper in native_step.pyx.
		}

		/**
		 * Link the python objects, this must be called directly after the constructor and on every object update.
		 */
		void python_init(PyObject* py_logger, PyObject* py_step_manager) {
			logger = Logger(py_logger);
			step_manager = StepManager(py_step_manager);
		}

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

} // namespace ara::step

#endif // STEP_H
