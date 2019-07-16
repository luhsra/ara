// vim: set noet ts=4 sw=4:

#include "test.h"
#include "llvm_common.h"

#include "llvm/IR/Instructions.h"
#include "llvm/Support/Casting.h"

#include <iostream>
#include <string>
#include <stdexcept>

#include "graph.h"

using namespace llvm;
using namespace ara::cfg;

namespace step {
	std::string LLVMMapTest::get_name() { return "LLVMMapTest"; }

	std::string LLVMMapTest::get_description() { return "Step for testing the LLVMMap step"; }

	void LLVMMapTest::run(graph::Graph& graph) {
		Module& module = graph.new_graph.get_module();
		std::set<BasicBlock*> bbs;
		for (auto &F : module) {
			for (auto &B : F) {
				bbs.insert(&B);
			}
		}

		ABBGraph& abbs = graph.new_graph.abbs();

		size_t abb_count = 0;
		for (auto abb : boost::make_iterator_range(vertices(abbs))) {
			BasicBlock* entry = abbs[abb].entry_bb;
			BasicBlock* exit = abbs[abb].exit_bb;

			// entry and exit node are the same
			if (entry != exit) {
				logger.err() << "BasicBlocks does not match, in ABB: " << abbs[abb].name << std::endl;
				throw std::runtime_error("BasicBlocks does not match");
			}

			// all basicblocks can be find with LLVM
			if (bbs.find(entry) == bbs.end()) {
				logger.err() << "Found linked BasicBlock that is not in the LLVM model, in ABB: " << abbs[abb].name << std::endl;
				throw std::runtime_error("Found linked BasicBlock that is not in the LLVM model");
			}

			// successors match
			std::set<ABBGraph::vertex_descriptor> succs1;
			std::set<ABBGraph::vertex_descriptor> succs2;
			for (const BasicBlock* succ_b : successors(entry)) {
				succs1.insert(abbs.back_map(succ_b));
			}
			for (auto succ : boost::make_iterator_range(boost::out_edges(abb, abbs))) {
				succs2.insert(boost::target(succ, abbs));
			}
			if (succs1 != succs2) {
				logger.err() << "Successor sets of ABB " << abbs[abb].name << " are not equivalent." << std::endl;
				throw std::runtime_error("Successor sets are not equivalent.");
			}

			// predecessors match
			std::set<ABBGraph::vertex_descriptor> preds1;
			std::set<ABBGraph::vertex_descriptor> preds2;
			for (const BasicBlock* pred_b : predecessors(entry)) {
				preds1.insert(abbs.back_map(pred_b));
			}
			for (auto pred : boost::make_iterator_range(boost::in_edges(abb, abbs))) {
				preds2.insert(boost::source(pred, abbs));
			}
			if (preds1 != preds2) {
				logger.err() << "Predecessor sets of ABB " << abbs[abb].name << " are not equivalent." << std::endl;
				throw std::runtime_error("Predecessor sets are not equivalent.");
			}

			abb_count++;
		}

		if (abb_count != bbs.size()) {
			logger.err() << "Amount of ABBs (" << abb_count << ") does not match count of BBs (" << bbs.size() << ")." << std::endl;
			throw std::runtime_error("Size mismatch of ABBs and BBs");
		}
	}

	std::vector<std::string> LLVMMapTest::get_dependencies() { return {"LLVMMap"}; }
} // namespace step
