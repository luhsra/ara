// vim: set noet ts=4 sw=4:

#include "ir_reader.h"

#include <llvm/Linker/Linker.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/raw_os_ostream.h>

static llvm::LLVMContext context;

namespace step {
	std::string IRReader::get_description() { return "Parser IR files and link together to an LLVM module"; }

	std::unique_ptr<llvm::Module> IRReader::load_file(const std::string& filepath, llvm::LLVMContext& Context) {
		llvm::SMDiagnostic err;
		logger.debug() << "Loading '" << filepath << "'\n";

		std::unique_ptr<llvm::Module> Result = 0;
		Result = parseIRFile(filepath, err, Context);
		if (Result)
			return Result;

		Logger::LogStream debug_logger = logger.debug();
		err.print("IRReader", debug_logger.llvm_ostream());
		debug_logger.flush();
		return NULL;
	}

	void IRReader::run(graph::Graph& graph) {
		// get file arguments from config
		std::vector<std::string> files;
		PyObject* input_files = PyDict_GetItemString(config, "input_files");
		assert(input_files != nullptr && PyList_Check(input_files));
		for (Py_ssize_t i = 0; i < PyList_Size(input_files); ++i) {
			PyObject* elem = PyList_GetItem(input_files, i);
			assert(PyUnicode_Check(elem));
			files.push_back(std::string(PyUnicode_AsUTF8(elem)));
		}

		// link the modules
		// use first module a main module
		logger.debug() << "Startfile: '" << files.at(0) << "'" << std::endl;
		auto composite = load_file(files.at(0), context);
		if (composite.get() == 0) {
			logger.err() << "Error loading file '" << files.at(0) << "'" << std::endl;
			abort();
		}

		llvm::Linker linker(*composite);

		// resolve link errors
		for (unsigned i = 1; i < files.size(); ++i) {
			auto M = load_file(files.at(i), context);
			if (M.get() == 0) {
				logger.err() << "Error loading file '" << files.at(i) << "'" << std::endl;
				abort();
			}

			logger.debug() << "Linking in '" << files.at(i) << "'" << std::endl;

			for (auto it = M->global_begin(); it != M->global_end(); ++it) {
				llvm::GlobalVariable& gv = *it;
				if (!gv.isDeclaration() && !gv.hasPrivateLinkage())
					gv.setLinkage(llvm::GlobalValue::AvailableExternallyLinkage);
			}

			if (linker.linkInModule(std::move(M))) {
				logger.err() << "Link error in '" << files.at(i) << "'" << std::endl;
				abort();
			}
		}

		// convert unique_ptr to shared_ptr
		graph.new_graph.set_module(std::move(composite));
	}
} // namespace step
