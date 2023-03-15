// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "test.h"

#include <string>

namespace ara::step {
	std::string PosixClangGlobalTest::get_name() { return "PosixClangGlobalTest"; }

	std::string PosixClangGlobalTest::get_description() {
		return "Checks if Clang/LLVM is working as expected for static instance detection in POSIX model";
	}

	void PosixClangGlobalTest::fail(std::string msg) {
		logger.err() << msg << std::endl;
		throw std::runtime_error(msg);
	}

	void PosixClangGlobalTest::run() {
		assert(input_file.get());
		std::string file = *input_file.get();
		bool static_case = (file == "appl/POSIX/objs/clang_global_var_static.ll");
		if (!static_case && file != "appl/POSIX/objs/clang_global_var_dynamic.ll") {
			this->fail("unknown input file \"" + file +
			           "\" (arbitrary input files are not allowed for this test case)");
		}

		llvm::Module& module = graph.get_module();
		auto gb = module.global_begin();
		llvm::GlobalVariable* global = const_cast<llvm::GlobalVariable*>(&*gb);
		assert(++gb == module.global_end() && "Multiple globals in test file");

		if (!global->hasInitializer()) {
			this->fail("global does not have a initializer");
		}
		const llvm::Constant* initializer = global->getInitializer();
		const llvm::StructType* init_type = llvm::dyn_cast_or_null<llvm::StructType>(initializer->getType());
		// No type in initializer:
		if (init_type == nullptr || init_type->getStructName().str().length() == 0) {
			if (!static_case) {
				this->fail("dynamic global does not have a typed initializer! Clang/LLVM is working differently");
			}
		} else {
			if (static_case) {
				this->fail("static global have a typed initializer! Strange behaviour of Clang/LLVM is gone. We can "
				           "now no more rely on it.");
			}
		}
	}

	void PosixClangGlobalTest::init_options() {
		input_file = input_file_template.instantiate(get_name());
		opts.emplace_back(input_file);
	}

	std::vector<std::string> PosixClangGlobalTest::get_single_dependencies() { return {"IRReader"}; }
} // namespace ara::step
