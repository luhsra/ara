// SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "isr_search.h"

#include "common/exceptions.h"
#include "common/util.h"

#include <Graphs/PTACallGraph.h>
#include <WPA/Andersen.h>
#include <boost/graph/filtered_graph.hpp>
#include <llvm/ADT/GraphTraits.h>
#include <llvm/ADT/SCCIterator.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Function.h>
#include <os.h>
#include <queue>
#include <type_traits>
#include <typeinfo>

namespace ara::step {
	std::string ISRSearch::get_description() {
		return "Find entry points for potential ISRs based on ISR only syscalls in the SVF callgraph.";
	}

	void ISRSearch::init_options() {
		ConfStep<ISRSearch>::init_options();
		block_list = block_list_template.instantiate(get_name());
		opts.emplace_back(block_list);
	}

	Step::OptionVec ISRSearch::get_local_options() { return {block_list_template}; }

	namespace {
		const std::string get_func_name(const SVF::PTACallGraphNode& node) {
			return node.getFunction()->getLLVMFun()->getName().str();
		}
	} // namespace

	SVF::PTACallGraph& ISRSearch::get_svf_callgraph() {
		SVF::PAG* pag = SVF::PAG::getPAG();
		// this is actually a singleton, so the creation was done in SVFAnalyses
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* ptacallgraph = ander->getPTACallGraph();
		return *ptacallgraph;
	}

	void ISRSearch::find_entry_points(const SVF::PTACallGraphNode* syscall) {
		std::stack<const SVF::PTACallGraphNode*> node_stack;
		std::set<const SVF::PTACallGraphNode*> handled;
		std::vector<std::string> isrs;
		node_stack.emplace(syscall);
		// the syscall itself obviously it not an ISR so handle the first loop run differently
		bool syscall_itself = true;
		while (!node_stack.empty()) {
			auto current = node_stack.top();
			handled.insert(current);
			node_stack.pop();
			bool has_in_edges = false;
			for (SVF::PTACallGraphNode::iterator it = current->InEdgeBegin(); it != current->InEdgeEnd(); ++it) {
				auto next = (*it)->getSrcNode();
				if (handled.find(next) == handled.end()) {
					// TODO: also in a recursion situation a valid start point can be found. Currently the node is
					// simply ignored.
					node_stack.emplace((*it)->getSrcNode());
				}
				has_in_edges = true;
			}
			if (!has_in_edges && !syscall_itself) {
				// we found a root node
				auto func_name = get_func_name(*current);
				if (block_names.find(func_name) != block_names.end()) {
					logger.debug() << "ISR node ignored due to block list: " << func_name << std::endl;
				} else {
					logger.info() << "Found new ISR node: " << func_name << std::endl;
					isrs.emplace_back(func_name);
				}
			}
			syscall_itself = false;
		}
		// We need to register all ISRs. This is easier in Python
		for (auto& func_name : isrs) {
			llvm::json::Value create_isr_conf(llvm::json::Object{{"name", "CreateISR"}, {"entry_point", func_name}});
			step_manager.chain_step(create_isr_conf);
		}
	}

	void ISRSearch::run() {
		llvm::Module& mod = graph.get_module();
		SVF::PTACallGraph& svf_callgraph = get_svf_callgraph();
		os::OS os = this->graph.get_os();
		auto all_syscalls = os.get_syscall_names();

		helper::TranslationMapParser tmp(*this);
		tmp.parse_list("block_list", block_list, block_names);
		// this is inherently ignored
		block_names.insert(constants::ARA_ENTRY_POINT);

		for (const auto& [index, node] : svf_callgraph) {
			auto func_name = get_func_name(*node);
			if (all_syscalls.find(func_name) != all_syscalls.end()) {
				os::SysCall syscall = os.get_syscall(func_name);
				if (syscall.is_isr_call()) {
					logger.debug() << "ISR syscall found: " << syscall.get_name() << ". Search for entry points."
					               << std::endl;
					find_entry_points(node);
				}
			}
		}
	}
} // namespace ara::step
