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
		void test_map(Graph& g, graph::CFG& cfg, Module& mod, Logger& logger) {
			std::set<BasicBlock*> l_bbs;
			std::set<llvm::Function*> lfuncs;
			for (auto& f : mod) {
				lfuncs.insert(&f);
				for (auto& b : f) {
					l_bbs.insert(&b);
				}
			}

			size_t bb_count = 0;
			for (auto v : boost::make_iterator_range(vertices(g))) {
				if (cfg.get_level<Graph>(v) == graph::NodeLevel::function) {
					llvm::Function* lfunc = cfg.get_llvm_function<Graph>(v);

					if (lfuncs.find(lfunc) == lfuncs.end()) {
						logger.err() << "LLVM function (" << lfunc << ") not found in ABBGraph." << std::endl;
						throw std::runtime_error("LLVM function not found.");
					}
				} else if (cfg.get_level<Graph>(v) == graph::NodeLevel::bb) {
					BasicBlock* l_bb = cfg.get_llvm_bb<Graph>(v);
					if (cfg.name[v] == "empty") {
						if (l_bb != nullptr) {
							throw std::runtime_error("Found empty BB with linked LLVM BB.");
						}
						continue;
					}

					// all basicblocks can be found with LLVM
					if (l_bbs.find(l_bb) == l_bbs.end()) {
						logger.err() << "Found linked BasicBlock that is not in the LLVM model, in BB: " << cfg.name[v]
						             << std::endl;
						throw std::runtime_error("Found linked BasicBlock that is not in the LLVM model");
					}

					// successors match
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> succs1;
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> succs2;
					for (const BasicBlock* succ_b : successors(l_bb)) {
						succs1.insert(cfg.back_map(g, safe_deref(succ_b)));
					}
					for (auto succ : boost::make_iterator_range(boost::out_edges(v, g))) {
						if (cfg.etype[succ] == graph::CFType::lcf) {
							succs2.insert(boost::target(succ, g));
						}
					}
					if (succs1 != succs2) {
						logger.err() << "Successor sets of BB " << cfg.name[v] << " are not equivalent." << std::endl;
						throw std::runtime_error("Successor sets are not equivalent.");
					}

					// predecessors match
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> preds1;
					std::set<typename boost::graph_traits<Graph>::vertex_descriptor> preds2;
					for (const BasicBlock* pred_b : predecessors(l_bb)) {
						preds1.insert(cfg.back_map(g, safe_deref(pred_b)));
					}
					for (auto pred : boost::make_iterator_range(boost::in_edges(v, g))) {
						if (cfg.etype[pred] == graph::CFType::lcf) {
							preds2.insert(boost::source(pred, g));
						}
					}
					if (preds1 != preds2) {
						logger.err() << "Predecessor sets of BB " << cfg.name[v] << " are not equivalent." << std::endl;
						throw std::runtime_error("Predecessor sets are not equivalent.");
					}

					// functions match
					auto func = cfg.get_function(g, v);
					llvm::Function* lfunc = cfg.get_llvm_function<Graph>(func);
					if (lfunc != l_bb->getParent()) {
						logger.err() << "LLVM Function of LLVM BB" << l_bb << " and ARA BB " << cfg.name[v]
						             << " do not match." << std::endl;
						throw std::runtime_error("Functions do not match.");
					}

					bb_count++;
				} else {
					throw std::runtime_error("Type ABB should not be present here.");
				}
			}

			if (bb_count != l_bbs.size()) {
				logger.err() << "Amount of ARA BBs (" << bb_count << ") does not match count of LLVM BBs ("
				             << l_bbs.size() << ")." << std::endl;
				throw std::runtime_error("Size mismatch of ARA BBs and LLVM BBs");
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
