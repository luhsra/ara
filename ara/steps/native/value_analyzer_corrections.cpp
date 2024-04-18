// SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "value_analyzer_corrections.h"

#include <fstream>
#include <llvm/Support/JSON.h>

namespace ara::step {
	std::string ValueAnalyzerCorrections::get_description() {
		return "Give the ValueAnalyzer manual hints for values.";
	}

	void ValueAnalyzerCorrections::init_options() {
		va_corrections = va_corrections_template.instantiate(get_name());
		opts.emplace_back(va_corrections);
	}

	Step::OptionVec ValueAnalyzerCorrections::get_local_options() { return {va_corrections_template}; }

	void ValueAnalyzerCorrections::parse_corrections(const std::string& json) {
		std::ifstream ifs(json);
		auto source = std::string((std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
		auto val = llvm::json::parse(source);
		if (auto e = val.takeError()) {
			std::stringstream sts;
			sts << "JSON parsing failed. Problem: " << toString(std::move(e));
			fail(sts.str());
		}
		const llvm::json::Array* arr = val->getAsArray();
		fail_if_empty(arr, json, "Expecting a list.");

		auto& corrections = this->graph.get_graph_data().va_state.corrections;
		for (const llvm::json::Value& correction : *arr) {
			const llvm::json::Object* corr_pair = correction.getAsObject();
			fail_if_empty(corr_pair, json, "Expecting a dict.");

			const llvm::json::Object* json_key = corr_pair->getObject("key");
			fail_if_empty(json_key, json, "Key malformatted");
			try {
				value_analyzer::ValueLocation key(*json_key);

				const llvm::json::Object* value = corr_pair->getObject("value");
				fail_if_empty(value, json, "value malformatted");

				const auto type = value->getString("type");
				fail_if_empty(type, json, "No value type found.");

				if (*type == "functionpointer") {
					const auto name = value->getString("name");
					fail_if_empty(name, json, "No name for functionpointer found.");
					logger.debug() << "Load correction for " << key.as_json() << std::endl;
					corrections.insert(std::pair(std::move(key), value_analyzer::FunctionPointerHint(name->str())));
				} else {
					fail("Value type not known.");
				}
			} catch (JSONError& j) {
				fail("Key malformed.");
			}
		}
	}

	void ValueAnalyzerCorrections::run() {
		const std::optional<std::string>& json = va_corrections.get();
		if (json) {
			logger.info() << "Reading correction from " << *json << '.' << std::endl;
			parse_corrections(*json);
		}
	}
} // namespace ara::step
