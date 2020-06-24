// vim: set noet ts=4 sw=4:

#include "value_analysis_core.h"

#include "common/llvm_common.h"
#include "value_analyzer.h"

#include <boost/property_tree/json_parser.hpp>
#include <boost/python.hpp>

//#include <tuple>

#define VERSION_BKP VERSION
#undef VERSION
#include <Util/BasicTypes.h>
//#include <Util/VFGNode.h>
#include <Graphs/VFGNode.h>
#include <WPA/Andersen.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

using namespace boost::property_tree;

namespace ara::step {


	ValueAnalysisCore::ValPath ValueAnalysisCore::retrieve_value(const SVFG& vfg, const llvm::Value& value) {
		//logger.debug() << "Trying to get value of " << value << std::endl;
		PAG* pag = PAG::getPAG();

		PAGNode* pNode = pag->getPAGNode(pag->getValueNode(&value));
		assert(pNode != nullptr);
		const VFGNode* vNode = vfg.getDefSVFGNode(pNode);
		assert(vNode != nullptr);
		FIFOWorkList<const VFGNode*> worklist;
		std::set<const VFGNode*> visited;
		worklist.push(vNode);

	    /// Traverse along VFG
	    while(!worklist.empty()){
	    	const VFGNode* vNode = worklist.pop();
			//logger.debug() << "Handle VFGNode " << *vNode << std::endl;
	        visited.insert(vNode);
			/* handle parent nodes */
			for(VFGNode::const_iterator it = vNode->InEdgeBegin(); it != vNode->InEdgeEnd(); ++it) {
				if(visited.find((*it)->getSrcNode())==visited.end()){
					//logger.debug() << "Insert src vNode " << *(*it)->getSrcNode() << std::endl;
					worklist.push((*it)->getSrcNode());
				}
			}
#if 0
			/* handle child nodes */
			for(VFGNode::const_iterator it = vNode->OutEdgeBegin(); it != vNode->OutEdgeEnd(); ++it) {
				if(visited.find((*it)->getDstNode())==visited.end()){
					//logger.debug() << "Insert dst vNode " << *(*it)->getDstNode() << std::endl;
					worklist.push((*it)->getDstNode());
				}
			}
#endif
		}

		std::vector<std::vector<const Instruction*>> paths, altPaths;
		std::vector<const Instruction*> curPath;
		std::vector<const Constant*> ret;

	    /// Collect all LLVM Values
	    for(std::set<const VFGNode*>::const_iterator it = visited.begin(), eit = visited.end(); it!=eit; ++it){
	    	const VFGNode* node = *it;
#if 0
			// contains calling function
			//if (const llvm::Function* fun = vfg.isFunEntryVFGNode(node)) {
			if (const SVFFunction* fun = vfg.isFunEntryVFGNode(node)) {
				logger.debug() << "\033[31mcalling function:\033[0m " << fun->getName().str() << std::endl;
				//logger.debug() << *fun << std::endl;
			}
			else {
				//logger.debug() << "\033[33mno calling function for node type \033[0m" << node->getNodeKind() << std::endl;
			}
#endif
			/* -- vfg node kind --
			 * 0 		1 			2 			3 		4 		5 		6 		 7 		8 		  9
			 * Addr 	Copy		Gep 		Store 	Load 	Cmp 	BinaryOp TPhi 	TIntraPhi TInterPhi
			 * MPhi 	MIntraPhi 	MInterPhi 	FRet 	ARet 	AParm 	FParm 	FunRet 	APIN 	  APOUT
			 * FPIN 	FPOUT 		NPtr
			 */
			// vfg node types for which getLHSTopLevPtr is unsupported
			std::vector<int> filterVFG = {SVFGNode::MPhi, SVFGNode::MIntraPhi, SVFGNode::MInterPhi,
										  SVFGNode::FunRet, SVFGNode::APIN, SVFGNode::APOUT,
										  SVFGNode::FPIN, SVFGNode::FPOUT};
			if (std::find(filterVFG.begin(), filterVFG.end(), node->getNodeKind()) != filterVFG.end()) {
				continue;
			}
	    	/// can only query VFGNode involving top-level pointers (starting with % or @ in LLVM IR)
	    	const PAGNode* pNode = vfg.getLHSTopLevPtr(node);
			/* -- pag node kind --
			 * 0 	   1       2 	   3 		  4 		 5  		6 		  7 		   8
			 * ValNode ObjNode RetNode VarargNode GepValNode GepObjNode FIObjNode DummyValNode DummyObjNode
			 */
			// pag node types which have no value
			if (pNode->getNodeKind() > 6)
				continue;
	    	const Value* val = pNode->getValue();
			if (const Function* f = pNode->getFunction()) {
				logger.debug() << "[[[PAGNode function: " << f->getName().str() << std::endl;
				/*
				 * filter node with isFunEntryNode, additionally save all unfiltered results.
				 * at the end (after all nodes have been iterated over), check if the
				 * filtered <paths> are empty, if they are, use the unfiltered <altPaths>
				 */
				curPath.clear();
				if (vfg.isFunEntryVFGNode(node)) {
					getCallPaths(f, paths, curPath);
				}
				else {
					getCallPaths(f, altPaths, curPath);
				}
			}
			if (const Instruction* inst = llvm::dyn_cast<Instruction>(val)) {
				logger.debug() << "[[[Found Instruction: " << *inst << std::endl;
				if (const Constant* c = llvm::dyn_cast<Constant>(inst->getOperand(0))) {
					logger.debug() << "[[[Found Value: " << *c << std::endl;
					ret.push_back(c);
#if 0
					//logger.debug() << "instruction: " << inst->getFunction()->getName().str() << std::endl;
					if (const llvm::BasicBlock* nbb = reinterpret_cast<const llvm::BasicBlock*>(node->getBB())) {
						logger.debug() << "in bb: " << nbb->getName().str() << std::endl;
						logger.debug() << "first user: " << **inst->user_begin() << std::endl;
						// if the parent call is top level, it will contain the syscall, otherwise the parent call
						if (nbb->getUniqueSuccessor()) {
							if (nbb->getUniqueSuccessor()/* != *inst->user_begin()*/) {
								//logger.debug() << *nbb << std::endl;
								logger.debug() << "Call resides in: " << nbb->getUniqueSuccessor()->getName().str() << std::endl;
								logger.debug() << "call is: " << nbb->getUniqueSuccessor()->front() << std::endl;
							}
						}
					}

					// if unique successor call == call.getCalledFunction
					// 		origin function (vNode fun()) is top-level
					// else
					// 		origin function was called from some other function
					// 		get that other function
#endif
				}
			}
	    }
		return {ret, (paths.empty() ? altPaths : paths)};
	}

	std::vector<ValueAnalysisCore::ValPath> ValueAnalysisCore::collectUsesOnVFG(const SVFG& vfg, const llvm::CallBase& call){
		if (isCallToLLVMIntrinsic(&call)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}

		std::vector<ValueAnalysisCore::ValPath> vps;


		int i = 0;
		for (const llvm::Use& use : call.args()) {
			//logger.debug() << "HANDLING USE " << i++ << std::endl;
			//logger.debug() << "function is: " << call.getCalledFunction()->getName().str() << std::endl;
			const Value* val = use.get();
			if (const llvm::Constant* c = llvm::dyn_cast<llvm::Constant>(val)) {
				// is our constant a function?
				if (const Function* func = llvm::dyn_cast<llvm::Function>(val)) {
					//logger.debug() << "Found Value (constant function): " << /* *c*/ func->getName().str() << std::endl;
				}
				else {
					// we have found a direct constant, no need for further analysis
					//this->logger.debug() << "Found Value (direct  constant): " << *c << std::endl;
				}
				// constants are saved as just one value with a single call
				//ValueAnalysisCore::ValPath vp = {{c}, {{&call}}};
				ValueAnalysisCore::ValPath vp = {{c}, {}};
				vps.push_back(vp);
			} else {
				assert(val != nullptr);
				logger.debug() << "retrieving value: \033[35m" << *val << "\033[0m" << std::endl;
				ValueAnalysisCore::ValPath vp = retrieve_value(vfg, *val);
				for (auto& p : std::get<1>(vp)) {
					p.insert(p.begin(), (Instruction*)&call);
				}
				vps.push_back(vp);
				//assert(std::get<0>(vp).size() == std::get<1>(vp).size() && "Number of Values and Paths must be the same");
			}
		}
		return vps;
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
