// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "svf_reset.h"

using namespace SVF;
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "lib/Graphs/IRGraph.cpp"	// bug that IRGraph::~IRGraph() is not found, fixed with this import

#include "graph_data.h"

namespace ara::step {

	namespace SVFReset_detail {} // namespace svf_reset_detail

	std::string SVFReset::get_description() {
		return "Resets singeltons from svf back to nullptr, so a different system can be analysed.\n"
		       "Must be called before running HyperSSE, but after completing every other step that needs the svf datastructures.";
	}

	void SVFReset::init_options() {
	}

	Step::OptionVec SVFReset::get_local_options() { return {}; }

	void SVFReset::run() {

		logger.info() << "Start SVFReset" << std::endl;

		// Get pointer of existing singeltons
		SVFIR* old_pag = SVFIR::getPAG();
		LLVMModuleSet* old_llvm = LLVMModuleSet::getLLVMModuleSet();
		AndersenWaveDiff* old_anderson = AndersenWaveDiff::createAndersenWaveDiff(old_pag);
		SymbolTableInfo* sym = SymbolTableInfo::SymbolInfo();

		// Save memory adresses into graph_data, so the data from this system can be retrieved later
		graph.get_graph_data().pags_pointer = old_pag;
		graph.get_graph_data().llvm_module = old_llvm;
		graph.get_graph_data().anderson = old_anderson;
		graph.get_graph_data().syminfo = sym;

		// Forget (but not delete) singeltons in SVF
		LLVMModuleSet::forgetLLVMModuleSet();
		// logger.debug() << "Released LLVMModuleSet" << std::endl;

		SVFIR::forgetSVFIR();
		// logger.debug() << "Released SVFIR" << std::endl;

		AndersenWaveDiff::forgetAndersenWaveDiff();
		// logger.debug() << "Released AndersenWaveDiff" << std::endl;

		SVFGBuilder::releaseSVFG();
		// logger.debug() << "Released SVFG" << std::endl;

		SymbolTableInfo::forgetSymbolInfo();
		// logger.debug() << "Released SVFModule" << std::endl;

		// Other possible singeltons in svf, but (probaly) not used/set
		// SVFGBuilder::releaseMemory();
		
		// FSMPTA::releaseFSMPTA();
		// releaseVFSWPA();
		// releaseSteensgaard();

		// releaseAndersenSFR;
		// releaseAndersenSCD;

		// SVF::Z3Expr::sreleaseContext();
		// SVF::Z3Expr::releaseSolver();
	}
} // namespace ara::step
