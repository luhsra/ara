// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "svf_reset.h"

using namespace SVF;
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "lib/Graphs/IRGraph.cpp"	// bug that IRGraph::~IRGraph() is not found, fixed with this import

namespace ara::step {


	namespace SVFReset_detail {} // namespace svf_reset_detail

	std::string SVFReset::get_description() {
		return "Deletes exisisting singeltons from svf."
		       "\n"
		       "Must be called before running HyperSSE, but after completing every other step that needs the svf datastructures.";
	}

	void SVFReset::init_options() {
	}

	Step::OptionVec SVFReset::get_local_options() { return {}; }

	void SVFReset::run() {

		logger.info() << "Start cleanup of svf singeltons" << std::endl;

		AndersenWaveDiff::releaseAndersenWaveDiff();
		logger.debug() << "Released AndersenWaveDiff" << std::endl;
		SVFIR::releaseSVFIR();
		logger.debug() << "Released SVFIR" << std::endl;
		SVF::LLVMModuleSet::releaseLLVMModuleSet();
		logger.debug() << "Released LLVMModuleSet" << std::endl;

	}
} // namespace ara::step
