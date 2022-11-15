// vim: set noet ts=4 sw=4:

#include "bb_timings.h"

#include "common/llvm_common.h"

#include <iostream>
#include <list>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/Casting.h>
#include <llvm/Support/raw_os_ostream.h>

namespace ara::step {
	using namespace llvm;

	std::string BBTimings::get_description() {
		return "Annotate BBs with call to special timing funtion wit wcet/bcet times.";
	}

	std::vector<std::string> BBTimings::get_single_dependencies() { return {"BBSplit", "CreateABBs"}; }

	namespace {
		template <typename Graph>
		void do_stuff(Graph& g, graph::CFG& cfg, Logger& logger) {
			bool found_any = false;
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				if (cfg.level[v] != static_cast<int>(graph::NodeLevel::bb)) {
					continue;
				}
				// logger.debug() << "v: " << cfg.name[v] << std::endl;
				BasicBlock* bb = reinterpret_cast<BasicBlock*>(cfg.llvm_link[v]);
				if (bb == nullptr) {
					continue;
				}
				// logger.debug() << "bb: \n" << *bb << std::endl;
				for (auto it = bb->begin(); it != bb->end(); ++it) {
					// logger.debug() << "inst: " << *it << std::endl;
					if (isa<CallInst>(*it)) {
						CallInst* ci = dyn_cast<CallInst>(it);
						Function* func = ci->getCalledFunction();
						if (func != nullptr) {
							logger.debug() << "call: " << func->getName().str() << std::endl;
							if (func->getName().str().compare("ara_timing_info") == 0 ||
							    func->getName().str().compare("_Z15ara_timing_infoii") == 0) {
								// logger.error() << "Hey" << std::endl;
								ConstantInt* bcet_v = dyn_cast<ConstantInt>(ci->getArgOperand(0));
								ConstantInt* wcet_v = dyn_cast<ConstantInt>(ci->getArgOperand(1));
								uint64_t bcet = bcet_v ? bcet_v->getLimitedValue() : 0;
								uint64_t wcet = wcet_v ? wcet_v->getLimitedValue() : 0;
								logger.debug()
								    << cfg.name[v] << " found timing: " << bcet << " / " << wcet << std::endl;
								cfg.bcet[v] = bcet;
								cfg.wcet[v] = wcet; // <-- stirbt hier
								found_any = true;
							}
						}
					}
				}
			}
			if (!found_any) {
				logger.crit() << "BBTimings requested but did not find any timing info" << std::endl;
				;
			}
		}
	} // namespace

	void BBTimings::run() {
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { do_stuff(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
		logger.debug() << "finished" << std::endl;
	}

} // namespace ara::step
