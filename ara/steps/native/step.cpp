// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "step.h"

namespace ara::step {
	bool Step::is_in_history(const llvm::json::Object& dependency, const llvm::json::Array& step_history) {
		for (const llvm::json::Value& step_v : step_history) {
			bool match = true;
			const llvm::json::Object* step = step_v.getAsObject();
			assert(step != nullptr && "step_history is wrong");
			for (const auto& kv : dependency) {
				if (kv.first == "name") {
					auto step_name = step->getString("name");
					if (!(step_name && *step_name == kv.second)) {
						match = false;
						break;
					}
				} else {
					const llvm::json::Object* step_config = step->getObject("config");
					assert(step_config && "step history object has no config.");
					auto it = step_config->find(kv.first);
					if (it == step_config->end() || it->second != kv.second) {
						match = false;
						break;
					}
				}
			}
			if (match) {
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
			const llvm::json::Object dep_obj{{"name", dependency}};
			if (is_in_history(dep_obj, step_history)) {
				continue;
			}
			remaining_deps.emplace_back(llvm::json::Object{{"name", dependency}});
		}
		for (llvm::json::Value& dependency : get_configured_dependencies()) {
			llvm::json::Object* obj = dependency.getAsObject();
			assert(obj && "Dependency is not a JSON object.");
			if (is_in_history(*obj, step_history)) {
				continue;
			}
			remaining_deps.emplace_back(std::move(*obj));
		}
		return remaining_deps;
	}

	// llvm::json::Array get_configured_dependencies() { return {}; }
	//
} // namespace ara::step
