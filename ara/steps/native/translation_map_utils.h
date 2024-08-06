// SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <filesystem>
#include <fstream>
#include <llvm/Support/raw_ostream.h>

namespace ara::step::helper {

	template <class TMStep>
	class TranslationMapParser {
	  private:
		TMStep& outer;

		template <class String>
		void fail_if(bool condition, const char* opt_name, String additional_message) {
			outer.option_fail_if(condition, opt_name, additional_message);
		}

		void parse_json(const char* opt_name, const std::string& option,
		                std::function<void(const llvm::json::Array&)> do_with_array) {
			std::string source;
			// check if list is a file or directy a json list
			// TODO replace this with startswith, once we have C++20
			if (option.find("[") != 0) {
				std::ifstream ifs(option);
				source = std::string((std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
			} else {
				source = option;
			}

			// actual JSON parsing
			auto val = llvm::json::parse(source);
			fail_if(!val, opt_name, "LLVM JSON parsing failed");
			llvm::json::Array* arr = val->getAsArray();
			fail_if(!arr, opt_name, "Invalid JSON. Expecting a list.");

			do_with_array(*arr);
		}

	  public:
		TranslationMapParser(TMStep& outer) : outer(outer) {}

		void parse_list(const char* opt_name, option::TOptEntity<option::String>& option,
		                std::set<std::string>& target) {
			target.clear();

			std::function<void(const llvm::json::Array&)> do_with_array = [&](const llvm::json::Array& arr) {
				for (const llvm::json::Value& func_val : arr) {
					auto func = func_val.getAsString();
					fail_if(!func, opt_name, "Invalid JSON. Expecting a list of strings.");
					target.insert(func->str());
				}
			};
			const auto& opt = option.get();
			if (opt) {
				parse_json(opt_name, *opt, do_with_array);
			}
		}

		void parse_translation_map(
		    const char* opt_name, option::TOptEntity<option::List<option::String>>& option,
		    std::map<std::pair<std::filesystem::path, unsigned>, std::set<std::string>>& pointer_targets) {
			pointer_targets.clear();
			const auto& opt = option.get();
			if (opt) {
				for (const auto& mapping_file : *opt) {
					std::function<void(const llvm::json::Array&)> do_with_array = [&](const llvm::json::Array& arr) {
						for (const llvm::json::Value& entry : arr) {
							auto entry_d = entry.getAsObject();
							fail_if(!entry_d, opt_name, "Invalid JSON. Expecting a list of dicts.");
							auto source_file = entry_d->getString("source_file");
							fail_if(!source_file, opt_name, "Invalid JSON. Expecting a source_file entry.");
							std::filesystem::path source_path =
							    std::filesystem::canonical(std::filesystem::path(mapping_file).parent_path() /
							                               std::filesystem::path(source_file->str()));
							auto line_number = entry_d->getInteger("line_number");
							fail_if(!line_number, opt_name, "Invalid JSON. Expecting a line_number entry.");
							auto call_targets = entry_d->getArray("call_targets");
							fail_if(!call_targets, opt_name, "Invalid JSON. Expecting a call_targets entry.");

							std::set<std::string> call_t;
							for (const llvm::json::Value& func_val : *call_targets) {
								auto func = func_val.getAsString();
								fail_if(!func, opt_name, "Invalid JSON. Expecting a list of strings as call_targets.");
								call_t.insert(func->str());
							}
							pointer_targets[std::make_pair<std::filesystem::path, unsigned>(
							    std::move(source_path), *line_number)] = std::move(call_t);
						}
					};
					parse_json(opt_name, mapping_file, do_with_array);
				}
			}
		}
	};
} // namespace ara::step::helper
