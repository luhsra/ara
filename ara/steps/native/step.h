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

	template <class U>
	class StepTrait;

	/**
	 * Superclass for constructing arbitrary steps in C++.
	 */
	class Step {
	  public:
		using OptionVec = std::vector<std::reference_wrapper<const option::Option>>;
		using OptEntityVec = std::vector<std::reference_wrapper<option::OptEntity>>;

		template <class U>
		friend class StepTrait;

	  protected:
		Logger logger;
		StepManager step_manager;
		graph::Graph graph;
		OptEntityVec opts;

		// ATTENTION: If you change this, also change the option list in step.pyx for class Step.
		// All of these options are also defined in ara.py and have their defaults from there.
		const static inline option::TOption<option::Choice<6>> log_level_template{
		    "log_level", "Adjust the log level of this step.",
		    /* ty = */ option::makeChoice("critical", "error", "warn", "warning", "info", "debug"),
		    /* default_value = */ std::nullopt,
		    /* global = */ true};
		option::TOptEntity<option::Choice<6>> log_level;

		const static inline option::TOption<option::Bool> dump_template{
		    "dump", "If possible, dump the changed graph into a dot file.",
		    /* ty = */ option::Bool(),
		    /* default_value = */ std::nullopt,
		    /* global = */ true};
		option::TOptEntity<option::Bool> dump;

		const static inline option::TOption<option::String> dump_prefix_template{
		    "dump_prefix", "If a file is dumped, set this as prefix for the files (default: dumps/{step_name}).",
		    /* ty = */ option::String(),
		    /* default_value = */ std::nullopt,
		    /* global = */ true};
		option::TOptEntity<option::String> dump_prefix;

		/**
		 * Contruct a native step.
		 */
		Step(PyObject* py_logger, graph::Graph graph, PyObject* py_step_manager)
		    : logger(Logger(py_logger)), step_manager(StepManager(py_step_manager)), graph(std::move(graph)) {}

		virtual void init_options() {}

		/**
		 * Retrieve all dependencies that needs to be executed at minimum one time before this step.
		 *
		 * Is called from the default implementation of get_dependencies()
		 */
		virtual std::vector<std::string> get_static_dependencies() { return {}; }

		bool is_in_history(const std::string& dependency, const llvm::json::Array& step_history) {
			for (const llvm::json::Value& step : step_history) {
				const llvm::json::Object* obj = step.getAsObject();
				assert(obj != nullptr && "step_history is wrong");
				auto step_name = obj->getString("name");
				if (step_name && *step_name == dependency) {
					return true;
				}
			}
			return false;
		}

	  public:
		static OptionVec get_global_options() { return {log_level_template, dump_template, dump_prefix_template}; }

		/**
		 * Apply a configuration to the step.
		 * Can be run multiple times.
		 */
		void apply_config(PyObject* config) {
			if (!PyDict_Check(config)) {
				throw std::invalid_argument("Step: Need a dict as config.");
			}

			for (option::OptEntity& option : opts) {
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
			// easier in Python so already done in the NativeStep wrapper in step.pyx.
		}

		virtual ~Step() {}

		/**
		 * Get all dependencies of this step.
		 *
		 * @Return: A list of step names (the ones that are returned with get_name().
		 */
		virtual llvm::json::Array get_dependencies(const llvm::json::Array& step_history) {
			llvm::json::Array remaining_deps;
			for (const std::string& dependency : get_static_dependencies()) {
				if (is_in_history(dependency, step_history)) {
					continue;
				}
				remaining_deps.emplace_back(llvm::json::Object{{"name", dependency}});
			}
			return remaining_deps;
		}

		/**
		 * This method is called, when the pass is invoked.
		 */
		virtual void run() = 0;
	};

	template <class SubStep>
	class ConfStep : public Step {
	  public:
		template <class U>
		friend class StepTrait;

	  protected:
		/**
		 * Fail with an error message.
		 */
		void fail(const std::string& message) {
			logger.err() << message << std::endl;
			std::string step_name = SubStep::get_name();
			throw StepError(step_name, message);
		}

		ConfStep(PyObject* py_logger, graph::Graph graph, PyObject* py_step_manager)
		    : Step(py_logger, std::move(graph), py_step_manager) {
			log_level = log_level_template.instantiate(SubStep::get_name());
			dump = dump_template.instantiate(SubStep::get_name());
			dump_prefix = dump_prefix_template.instantiate(SubStep::get_name());

			opts = {log_level, dump, dump_prefix};
		}
	};

	// we just need a common type
	class StepFactory {
	  public:
		virtual ~StepFactory() {}
		/**
		 * Return a unique name of this step. This acts as ID for the step.
		 */
		virtual inline std::string get_name() const = 0;

		/**
		 * Get a descriptive string of the step that says what the step is doing.
		 */
		virtual inline std::string get_description() const = 0;

		/**
		 * Return a vector with all options.
		 */
		virtual const Step::OptionVec get_options() const = 0;

		/**
		 * Instantiate the real step.
		 */
		virtual std::unique_ptr<Step> instantiate(PyObject* py_logger, graph::Graph graph,
		                                          PyObject* py_step_manager) const = 0;
	};

	template <class TStep>
	class StepTrait : public StepFactory {
	  public:
		virtual inline std::string get_name() const override { return TStep::get_name(); }
		virtual inline std::string get_description() const override { return TStep::get_description(); }

		virtual const Step::OptionVec get_options() const override {
			const auto& global_opts = TStep::get_global_options();
			const auto& local_opts = TStep::get_local_options();
			Step::OptionVec opts(global_opts.begin(), global_opts.end());
			opts.insert(opts.end(), local_opts.begin(), local_opts.end());
			return opts;
		}

		virtual std::unique_ptr<Step> instantiate(PyObject* py_logger, graph::Graph graph,
		                                          PyObject* py_step_manager) const override {
			std::unique_ptr<Step> step(new TStep(py_logger, std::move(graph), py_step_manager));
			step->init_options();
			return step;
		}
	};

} // namespace ara::step

#endif // STEP_H
