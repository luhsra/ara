// SPDX-FileCopyrightText: 2019 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "ir_reader.h"

#include <cassert>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Linker/Linker.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Transforms/Utils.h>

namespace ara::step {
	std::string IRReader::get_description() {
		return "Parse IR file into an LLVM module and prepare it for ARA.\n"
		       "Currently this means: Execute the mem2reg pass.";
	}

	void IRReader::init_options() {
		input_file = input_file_template.instantiate(get_name());
		opts.emplace_back(input_file);
	}

	void IRReader::run() {
		// get file arguments from config
		assert(input_file.get());
		std::string file = *input_file.get();

		// link the modules
		// use first module a main module
		llvm::LLVMContext& context = graph.get_graph_data().get_context();

		logger.debug() << "Loading '" << file << "'" << std::endl;

		llvm::SMDiagnostic err;
		std::unique_ptr<llvm::Module> module = llvm::parseIRFile(file, err, context);

		if (module == nullptr) {
			logger.err() << "Error loading file '" << file << "'" << std::endl;
			Logger::LogStream& debug_logger = logger.debug();
			err.print("IRReader", debug_logger.llvm_ostream());
			debug_logger.flush();
			abort();
		}

		for (llvm::Function& func : *module) {
			// Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn't given
			if (func.hasOptNone()) {
				func.removeFnAttr(llvm::Attribute::OptimizeNone);
			}
		}

		// convert unique_ptr to shared_ptr
		graph.get_graph_data().initialize_module(std::move(module));
	}
} // namespace ara::step
