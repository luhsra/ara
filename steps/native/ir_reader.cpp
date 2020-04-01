// vim: set noet ts=4 sw=4:

#include "ir_reader.h"

#include <cassert>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Linker/Linker.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/raw_os_ostream.h>

namespace ara::step {
	std::string IRReader::get_description() const { return "Parse IR file into an LLVM module"; }

	void IRReader::run(graph::Graph& graph) {
		// get file arguments from config
		assert(input_file.get());
		std::string file = *input_file.get();

		// link the modules
		// use first module a main module
		llvm::LLVMContext& context = graph.get_llvm_data().get_context();

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

		// convert unique_ptr to shared_ptr
		graph.get_llvm_data().initialize_module(std::move(module));
	}
} // namespace ara::step
