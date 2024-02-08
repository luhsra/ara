// SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "detect_exceptions.h"

namespace ara::step {
	using namespace llvm;

	std::string DetectExceptions::get_description() {
		return "Detect and mark all BasicBlocks that belong to exceptions.";
	}

	std::vector<std::string> DetectExceptions::get_single_dependencies() { return {"CompInsert"}; }

	void DetectExceptions::mark_region_as_exception(const BasicBlock* bb) {
		graph::GraphData& graph_data = graph.get_graph_data();
		std::queue<const BasicBlock*> bbs;
		bbs.push(bb);

		auto func = bb->getParent();

		while (!bbs.empty()) {
			auto cur = bbs.front();
			assert(cur->getParent() == func && "BB do not have the same function as parent.");
			bbs.pop();
			if (graph_data.basic_blocks[cur].is_part_of_exception) {
				continue;
			}
			logger.debug() << "Mark BB as exception: " << *cur << std::endl;
			graph_data.basic_blocks[cur].is_part_of_exception = true;
			for (auto succ : successors(cur)) {
				bbs.push(succ);
			}
		}
	}

	void DetectExceptions::run() {
		graph::GraphData& graph_data = graph.get_graph_data();
		for (auto& function : graph_data.get_module()) {
			if (function.empty() || function.isIntrinsic()) {
				continue;
			}
			for (BasicBlock& bb : function) {
				for (Instruction& i : bb) {
					if (auto* invoke = dyn_cast<InvokeInst>(&i)) {
						mark_region_as_exception(invoke->getUnwindDest());
					}
				}
			}
		}
	}
} // namespace ara::step
