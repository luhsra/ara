// vim: set noet ts=4 sw=4:

#include "ir_writer.h"

#include <boost/algorithm/string.hpp>
#include <filesystem>
#include <llvm/Support/FileSystem.h>
#include <unordered_set>

namespace ara::step {
	std::string IRWriter::get_description() { return "Print current IR code."; }

	void IRWriter::init_options() {
		ir_file_option = ir_file_option_template.instantiate(get_name());
		opts.emplace_back(ir_file_option);
		functions_opt = functions_opt_template.instantiate(get_name());
		opts.emplace_back(functions_opt);
	}

	void IRWriter::run() {
		const auto& filename = ir_file_option.get();
		std::string fn = *filename;
		boost::replace_all(fn, "{dump_prefix}", *dump_prefix.get());

		logger.info() << "Writing IR to " << fn << '.' << std::endl;
		llvm::raw_ostream* output = nullptr;
		std::unique_ptr<llvm::raw_fd_ostream> out_file = nullptr;
		if (fn == "log") {
			output = &logger.info().llvm_ostream();
		} else {
			std::error_code error;
			std::filesystem::path parent_path = std::filesystem::path(fn).parent_path();
			// check for directory first to circumvent bug in C++17 create_directories()
			// issue LWG 2935 (https://cplusplus.github.io/LWG/issue2935)
			if (std::filesystem::is_directory(parent_path)) {
				std::filesystem::create_directories(parent_path);
			}
			out_file = std::make_unique<llvm::raw_fd_ostream>(fn, error, llvm::sys::fs::OpenFlags::OF_Text);
			if (out_file->has_error()) {
				logger.err() << out_file->error() << std::endl;
				out_file->close();
				fail("Error opening file");
			}
			output = out_file.get();
		}

		const auto& mod = graph.get_module();

		const auto& functions = functions_opt.get();
		if (functions) {
			std::unordered_set<std::string> functs(functions->begin(), functions->end());
			for (const auto& func : mod) {
				if (functs.find(func.getName().str()) != functs.end()) {
					func.print(*output, nullptr);
				}
			}
		} else {
			mod.print(*output, nullptr);
		}

		if (out_file) {
			out_file->close();
		} else {
			logger.info().flush();
		}
	}
} // namespace ara::step
