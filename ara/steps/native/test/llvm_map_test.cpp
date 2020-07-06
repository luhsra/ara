// vim: set noet ts=4 sw=4:

#include "common/exceptions.h"
#include "common/llvm_common.h"
#include "test.h"

#include <graph.h>
#include <iostream>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Instructions.h>
#include <llvm/Support/Casting.h>
#include <stdexcept>
#include <string>

using namespace llvm;

namespace ara::step {
	std::string LLVMMapTest::get_name() { return "LLVMMapTest"; }

	std::string LLVMMapTest::get_description() { return "Step for testing the LLVMMap step"; }

	namespace {
		template <typename Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor back_map(Graph& g, graph::CFG& cfg,
		                                                                const BasicBlock* block) {
			for (auto abb : boost::make_iterator_range(vertices(g))) {
				if (cfg.entry_bb[abb] == reinterpret_cast<intptr_t>(block) ||
				    cfg.exit_bb[abb] == reinterpret_cast<intptr_t>(block)) {
					return abb;
				}
			}
			throw VertexNotFound();
		}

		template <typename Graph>
		void test_map(Graph& g, graph::CFG& cfg, Module& mod, Logger& logger) {
			std::set<BasicBlock*> bbs;
			std::set<llvm::Function*> lfuncs;
			for (auto& f : mod) {
				lfuncs.insert(&f);
				for (auto& b : f) {
					bbs.insert(&b);
				}
			}

			size_t abb_count = 0;
			for (auto abb : boost::make_iterator_range(vertices(g))) {
				if (cfg.is_function[abb]) {
					llvm::Function* lfunc = reinterpret_cast<llvm::Function*>(cfg.function[abb]);

					if (lfuncs.find(lfunc) == lfuncs.end()) {
						logger.err() << "LLVM function (" << lfunc << ") not found in ABBGraph." << std::endl;
						throw std::runtime_error("LLVM function not found.");
					}
				} else {
					if (cfg.name[abb] == "empty") {
						if (cfg.entry_bb[abb] != 0 || cfg.exit_bb[abb] != 0) {
							throw std::runtime_error("Found empty ABB with linked LLVM BB.");
						}
						continue;
					}
					BasicBlock* entry = reinterpret_cast<BasicBlock*>(cfg.entry_bb[abb]);
					BasicBlock* exit = reinterpret_cast<BasicBlock*>(cfg.exit_bb[abb]);

					// entry and exit node are the same
					if (entry != exit) {
						logger.err() << "BasicBlocks does not match, in ABB: " << cfg.name[abb] << std::endl;
						throw std::runtime_error("BasicBlocks does not match");
					}

					// all basicblocks can be find with LLVM
					if (bbs.find(entry) == bbs.end()) {
						logger.err() << "Found linked BasicBlock that is not in the LLVM model, in ABB: "
						             << cfg.name[abb] << std::endl;
						throw std::runtime_error("Found linked BasicBlock that is not in the LLVM model");
					}

					// successors match
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> succs1;
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> succs2;
					for (const BasicBlock* succ_b : successors(entry)) {
						succs1.insert(back_map(g, cfg, succ_b));
					}
					for (auto succ : boost::make_iterator_range(boost::out_edges(abb, g))) {
						if (cfg.etype[succ] == graph::CFType::lcf) {
							succs2.insert(boost::target(succ, g));
						}
					}
					if (succs1 != succs2) {
						logger.err() << "Successor sets of ABB " << cfg.name[abb] << " are not equivalent."
						             << std::endl;
						throw std::runtime_error("Successor sets are not equivalent.");
					}

					// predecessors match
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> preds1;
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> preds2;
					for (const BasicBlock* pred_b : predecessors(entry)) {
						preds1.insert(back_map(g, cfg, pred_b));
					}
					for (auto pred : boost::make_iterator_range(boost::in_edges(abb, g))) {
						if (cfg.etype[pred] == graph::CFType::lcf) {
							preds2.insert(boost::source(pred, g));
						}
					}
					if (preds1 != preds2) {
						logger.err() << "Predecessor sets of ABB " << cfg.name[abb] << " are not equivalent."
						             << std::endl;
						throw std::runtime_error("Predecessor sets are not equivalent.");
					}

					// functions match
					typename boost::graph_traits<Graph>::vertex_descriptor func;
					auto its = boost::out_edges(abb, g);
					auto it = std::find_if(its.first, its.second,
					                       [&](auto e) -> bool { return cfg.etype[e] == graph::CFType::a2f; });
					assert(it != its.second);
					func = boost::target(*it, g);

					llvm::Function* lfunc = reinterpret_cast<llvm::Function*>(cfg.function[func]);
					if (lfunc != entry->getParent()) {
						logger.err() << "LLVM Function of BB" << entry << " and ABB " << cfg.name[abb]
						             << " do not match." << std::endl;
						throw std::runtime_error("Functions do not match.");
					}

					abb_count++;
				}
			}

			if (abb_count != bbs.size()) {
				logger.err() << "Amount of ABBs (" << abb_count << ") does not match count of BBs (" << bbs.size()
				             << ")." << std::endl;
				throw std::runtime_error("Size mismatch of ABBs and BBs");
			}
		}
	} // namespace

	void LLVMMapTest::run() {
		Module& mod = graph.get_module();
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { test_map(g, cfg, mod, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}

	std::vector<std::string> LLVMMapTest::get_single_dependencies() { return {"LLVMMap"}; }
} // namespace ara::step
