// vim: set noet ts=4 sw=4:

#include "value_analysis_core.h"

#include "common/llvm_common.h"
#include "value_analyzer.h"

#include <boost/property_tree/json_parser.hpp>
#include <boost/python.hpp>

#define VERSION_BKP VERSION
#undef VERSION
#include <Util/BasicTypes.h>
#include <Util/VFGNode.h>
#include <WPA/Andersen.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

using namespace boost::property_tree;

namespace ara::step {
	void ValueAnalysisCore::retrieve_value(const SVFG& vfg, const llvm::Value& value) {
		logger.debug() << "Trying to get value of " << value << std::endl;
		PAG* pag = PAG::getPAG();

		PAGNode* pNode = pag->getPAGNode(pag->getValueNode(&value));
		assert(pNode != nullptr);
		const VFGNode* vNode = vfg.getDefSVFGNode(pNode);
		assert(vNode != nullptr);
		FIFOWorkList<const VFGNode*> worklist;
		std::set<const VFGNode*> visited;
		worklist.push(vNode);

		/// Traverse along VFG
		while (!worklist.empty()) {
			const VFGNode* vNode = worklist.pop();
			logger.debug() << "Handle VFGNode " << *vNode << std::endl;
	        visited.insert(vNode);
			for(VFGNode::const_iterator it = vNode->InEdgeBegin(); it != vNode->InEdgeEnd(); ++it) {
				if(visited.find((*it)->getSrcNode())==visited.end()){
					logger.debug() << "Insert vNode " << *(*it)->getSrcNode() << std::endl;
					worklist.push((*it)->getSrcNode());
				}
			}
		}

	    /// Collect all LLVM Values
	    for(std::set<const VFGNode*>::const_iterator it = visited.begin(), eit = visited.end(); it!=eit; ++it){
	    	const VFGNode* node = *it;
	    	/// can only query VFGNode involving top-level pointers (starting with % or @ in LLVM IR)
	    	const PAGNode* pNode = vfg.getLHSTopLevPtr(node);
	    	const Value* val = pNode->getValue();
			if (const Instruction* inst = llvm::dyn_cast<Instruction>(val)) {
				if (const Constant* c = llvm::dyn_cast<Constant>(inst->getOperand(0))) {
					logger.debug() << "Found Value: " << *c << std::endl;
				}
			}
	    }
	}

	void ValueAnalysisCore::collectUsesOnVFG(const SVFG& vfg, const llvm::CallBase& call) {
		if (isCallToLLVMIntrinsic(&call)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}

		for (const llvm::Use& use : call.args()) {
			const Value* val = use.get();
			if (const llvm::Constant* c = llvm::dyn_cast<llvm::Constant>(val)) {
				// we have found a direct constant, no need for further analysis
				this->logger.debug() << "Found direct constant: " << *c << std::endl;
			} else {
				assert(val != nullptr);
				retrieve_value(vfg, *val);
			}
		}
	}

	llvm::json::Array ValueAnalysisCore::get_configured_dependencies() {
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");
		return llvm::json::Array{llvm::json::Object{{{"name", "Syscall"}, {"entry_point", *entry_point_name}}}};
	}

	std::string ValueAnalysisCore::get_description() {
		return "Perform a value analysis for all system calls (core step).";
	}

	void ValueAnalysisCore::init_options() {
		EntryPointStep<ValueAnalysisCore>::init_options();
		dump_stats = dump_stats_template.instantiate(get_name());
		opts.emplace_back(dump_stats);
	}

	void ValueAnalysisCore::run() {
		graph::CFG cfg = graph.get_cfg();
		const auto& dopt = dump_stats.get();
		const auto& prefix = dump_prefix.get();
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		SVFG* svfg = SVFGBuilder::globalSvfg;
		assert(svfg != nullptr && "svfg is null")

		    graph_tool::gt_dispatch<>()([&](auto& g) { this->get_values(g, *svfg); },
		                                graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
