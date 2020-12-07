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
		 * Options cannot be requested within this function, only a list of step names is valid.
		 * Use get_configured_dependencies() for this.
		 *
		 * This function is called from the default implementation of get_dependencies().
		 */
		virtual std::vector<std::string> get_single_dependencies() { return {}; }
		virtual llvm::json::Array get_configured_dependencies() { return {}; }

		/**
		 * Check, if a step is already in the history.
		 */
		bool is_in_history(const llvm::json::Object& dependency, const llvm::json::Array& step_history);

	  public:
		/**
		 * Retrieve all global options. Used by StepTraits.
		 */
		static OptionVec get_global_options() { return {log_level_template, dump_template, dump_prefix_template}; }

		/**
		 * Apply a configuration to the step.
		 * Can be run multiple times.
		 */
		void apply_config(PyObject* config);

		virtual ~Step() {}

		/**
		 * Get all dependencies of this step.
		 *
		 * @Return: A list of steps. The steps need to be in an LLVM JSON opbject with the following format:
		 * [ { "name": "MyStep", "specific_option": true }, { "name": "MyOtherStep" } ]
		 */
		virtual llvm::json::Array get_dependencies(const llvm::json::Array& step_history);

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

	/**
	 * An EntryPointStep is a step that has the entry_point option.
	 */
	template <class SubStep>
	class EntryPointStep : public ConfStep<SubStep> {
	  protected:
		const static inline option::TOption<option::String> entry_point_template{"entry_point", "system entry point"};
		option::TOptEntity<option::String> entry_point;

		using ConfStep<SubStep>::ConfStep;

		/**
		 * Instantiate the entry point option.
		 *
		 * Attention: This function must be called from its override version, i.e.:
		 * virtual void init_options() override {
		 *     EntryPointStep<MyStep>::init_options();
		 *     ...
		 * }
		 */
		virtual void init_options() override {
			entry_point = entry_point_template.instantiate(SubStep::get_name());
			this->opts.emplace_back(entry_point);
		}

	  public:
		static Step::OptionVec get_entrypoint_options() { return {entry_point_template}; }
	};

	/**
	 * Common type for calling the static parts of all steps.
	 * Actual implementation is in StepTrait.
	 */
	class StepFactory {
	  public:
		virtual ~StepFactory() {}
		/**
		 * Return a unique name of this step. This acts as ID for the step.
		 */
		virtual std::string get_name() const = 0;

		/**
		 * Get a descriptive string of the step that says what the step is doing.
		 */
		virtual std::string get_description() const = 0;

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

	/**
	 * Enables calling of a certain function only if is present in the step.
	 *
	 * The class enables this functionality for all functions decleared with CHECK_FOR.
	 * So i.e. CHECK_FOR(get_foo) enables calling the function get_foo() in all steps where it is defined.
	 * The usage is then: OptionChecker::get_foo<MyStep>();
	 */
	class OptionChecker {
#define CHECK_FOR(FunctionName)                                                                                        \
  private:                                                                                                             \
	template <typename T, typename = void>                                                                             \
	struct Has##FunctionName : std::false_type {};                                                                     \
                                                                                                                       \
	template <typename T>                                                                                              \
	struct Has##FunctionName<T, std::void_t<decltype(std::declval<T>().FunctionName())>> : std::true_type {};          \
                                                                                                                       \
  public:                                                                                                              \
	template <typename T>                                                                                              \
	static const Step::OptionVec FunctionName() {                                                                      \
		if constexpr (Has##FunctionName<T>::value) {                                                                   \
			return T::FunctionName();                                                                                  \
		} else {                                                                                                       \
			return {};                                                                                                 \
		}                                                                                                              \
	}
		CHECK_FOR(get_local_options)
		CHECK_FOR(get_entrypoint_options)
	};

	/**
	 * Wrapper around the static methods of step. This allows to create an object again.
	 */
	template <class TStep>
	class StepTrait : public StepFactory {
	  private:
	  public:
		virtual inline std::string get_name() const override { return TStep::get_name(); }
		virtual inline std::string get_description() const override { return TStep::get_description(); }

		virtual const Step::OptionVec get_options() const override {
			const auto& global_opts = TStep::get_global_options();
			Step::OptionVec opts(global_opts.begin(), global_opts.end());

			const auto& local_opts = OptionChecker::get_local_options<TStep>();
			opts.insert(opts.end(), local_opts.begin(), local_opts.end());

			const auto& entrypoint_opts = OptionChecker::get_entrypoint_options<TStep>();
			opts.insert(opts.end(), entrypoint_opts.begin(), entrypoint_opts.end());
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
