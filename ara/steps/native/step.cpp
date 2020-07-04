#include "step.h"

namespace ara::step {
	bool Step::is_in_history(const std::string& dependency, const llvm::json::Array& step_history) {
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

	void Step::apply_config(PyObject* config) {
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

	llvm::json::Array Step::get_dependencies(const llvm::json::Array& step_history) {
		llvm::json::Array remaining_deps;
		for (const std::string& dependency : get_single_dependencies()) {
			if (is_in_history(dependency, step_history)) {
				continue;
			}
			remaining_deps.emplace_back(llvm::json::Object{{"name", dependency}});
		}
		return remaining_deps;
	}
} // namespace ara::step
