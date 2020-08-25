// vim: set noet ts=4 sw=4:

#include "value_analysis_core.h"

#include "common/llvm_common.h"
#include "value_analyzer.h"

#include <boost/property_tree/json_parser.hpp>
#include <boost/python.hpp>

#define VERSION_BKP VERSION
#undef VERSION
#include <Util/BasicTypes.h>
#include <Graphs/VFGNode.h>
#include <WPA/Andersen.h>
#include <SVF-FE/PAGBuilder.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

using namespace boost::property_tree;

namespace ara::step {

	const llvm::Value* ValueAnalysisCore::temp_traverse(const SVFGNode* node, const SVFG& vfg, std::vector<const SVFGNode*>& visited) {
		// TODO investigate: svfg node ids/(structure?) changes for each ara run
#if 0
		if (const PHISVFGNode* tphi = SVFUtil::dyn_cast<PHISVFGNode>(node)) {
			//logger.debug() << "tphi: " << *tphi->getRes()->getValue() << std::endl;
			if (const llvm::Argument* arg = SVFUtil::dyn_cast<llvm::Argument>(tphi->getRes()->getValue())) {
				/**
				 * hacky method to find out whether our function is a constructor/destructor
				 *
				 * if the function name contains "~" it's a destructor
				 *
				 * otherwise, split off the part after the opening parenthesis containing the argument(s)
				 * if the before our delimiter "::" is the same as the substring after, it's a constructor
				 */
				std::string funName = demangle(arg->getParent()->getName().str());
				if (funName.find("~") != std::string::npos) {
					logger.debug() << "\033[31mDESTRUCTOR\033[0m ";
				}
				std::string fNB = funName.substr(0, funName.find("("));
				std::string delim = "::";
				if (fNB.substr(0, fNB.find(delim)) == fNB.substr(fNB.find(delim) + delim.length())) {
					logger.debug() << "\033[31mCONSTRUCTOR\033[0m ";
				}
				logger.debug() << funName  << " [" << arg->getParent()->arg_size() << " args] has ";
				for (auto it = arg->getParent()->arg_begin(); it != arg->getParent()->arg_end(); ++it) {
					logger.debug() << "arg" << it->getArgNo() << ": " << *it << " ";
				}
				logger.debug() << std::endl;
			}
		}
#endif
		std::vector<int> filterVFG = {SVFGNode::MPhi, SVFGNode::MIntraPhi, SVFGNode::MInterPhi,
									  SVFGNode::FunRet, SVFGNode::APIN, SVFGNode::APOUT,
									  SVFGNode::FPIN, SVFGNode::FPOUT};
		if (std::find(filterVFG.begin(), filterVFG.end(), node->getNodeKind()) != filterVFG.end()) {
			logger.debug() << *node << " has no pag nodes" << std::endl;
		}
		else {
			const PAGNode* pNode = vfg.getLHSTopLevPtr(node);
			if (pNode->getNodeKind() < 7) {
				const Value* val = pNode->getValue();
				logger.debug() << "pagnode value: " << *val << "(" << *node << ")" << std::endl;
				if (const Instruction* inst = llvm::dyn_cast<Instruction>(val)) {
					if (const AllocaInst* allocainst = llvm::dyn_cast<AllocaInst>(inst)) {
						//logger.debug() << "alloca: " << *allocainst << "||| opz: " << *allocainst->getOperand(0) << std::endl;
						//return allocainst;
					}
				}
				if (const GlobalVariable* globvar = llvm::dyn_cast<GlobalVariable>(val)) {
					// this contains stuff like xTestMutex (which is what we're looking for I think)
					// TODO return this somewhere
					logger.debug() << "value: " << *val << std::endl;
					return val;
					/*
					if (1 || globvar->hasInitializer()) {
						//
					}
					*/
				}
			}
		}
		for (auto it = node->InEdgeBegin(); it != node->InEdgeEnd(); ++it) {
			const SVFGNode* par = (*it)->getSrcNode();
			if (std::find(visited.begin(), visited.end(), par) == visited.end()) {
				vstd.push_back(par);
				temp_traverse(par, vfg, visited);
			}
		}
		return NULL;
	}

	const llvm::Constant* ValueAnalysisCore::handle_value(const llvm::Value* value, const SVFG& vfg, const VFGNode* node) {
		if (const Instruction* inst = llvm::dyn_cast<Instruction>(value)) {
			/* handle different constant types */
			llvm::Value* opz = inst->getOperand(0);
			if (const llvm::ConstantInt* cint = llvm::dyn_cast<ConstantInt>(opz)) {
				//logger.debug() << "---constant int " << *cint << std::endl;
				return cint;
			}
			else if (const llvm::ConstantFP* cfp = llvm::dyn_cast<llvm::ConstantFP>(opz)) {
				//logger.debug() << "---constant fp " << *cfp << std::endl;
				return cfp;
			}
			else if (const llvm::ConstantData* cdata = llvm::dyn_cast<ConstantData>(opz)) {
				//logger.debug() << "---constant data " << *cdata << std::endl;
				return cdata;
			}
			// TODO: refine
			else if (const llvm::ConstantExpr* cexpr = llvm::dyn_cast<ConstantExpr>(opz)) {
				//logger.debug() << "---constant expr " << *cexpr << std::endl;
				if (const llvm::GlobalVariable* gvar = llvm::dyn_cast<GlobalVariable>(cexpr->getOperand(0))) {
					//logger.debug() << "---constant globvar " << *gvar << std::endl;
					return handle_value(gvar, vfg, node);
				}
			}
			// TODO: refine
			else if (const ConstantAggregate* caggr = llvm::dyn_cast<ConstantAggregate>(opz)) {
				//logger.debug() << "---constant aggregate " << *caggr << std::endl;
			}
			else if (const GlobalVariable* globvar = llvm::dyn_cast<GlobalVariable>(opz)) {
				if (globvar->hasInitializer()) {
					//logger.debug() << "---globvar initializer: " << *globvar->getInitializer() << std::endl;
					return globvar->getInitializer();
				}
			}

			/* handle different instruction types */
			if (const GetElementPtrInst* gepinst = llvm::dyn_cast<GetElementPtrInst>(inst)) {
				if (gepinst->getOperand(0)->getValueName()->getKey().str() == "this") {
					//logger.debug() << "---skipping \"this\" value (" << *(gepinst->getOperand(0)) << ")" << std::endl;
					//std::cout << std::endl;
					//logger.debug() << "\"this\" found in vfgnode " << *node << std::endl;
					const llvm::Value* traverseResult = temp_traverse(node, vfg, vstd);
					if (traverseResult) {
						return handle_value(traverseResult, vfg, node);
					}
				}
				else {
					logger.debug() << "--gep operand 0: " << *(gepinst->getOperand(0))
								   << " -||- Instruction: " << *gepinst << std::endl;
					return handle_value(gepinst->getOperand(0), vfg, node);
				}
			}
			else if (const LoadInst* loadinst = llvm::dyn_cast<LoadInst>(inst)) {
				/*
				logger.debug() << "--load operand 0: " << *(loadinst->getOperand(0))
							   << " -||- Instruction: " << *loadinst << std::endl;
			   */
				if (const Constant* c = llvm::dyn_cast<Constant>(loadinst->getOperand(0))) {
					return c;
				}
			}
			else if (const AllocaInst* allocainst = llvm::dyn_cast<AllocaInst>(inst)) {
				logger.debug() << "--alloca operand 0: " << *(allocainst->getOperand(0))
							   << " -||- Instruction: " << *allocainst << std::endl;
			}
			else if (const CastInst* castinst = llvm::dyn_cast<CastInst>(inst)) {
				logger.debug() << "--cast operand 0: " << *(castinst->getOperand(0))
							   << " -||- Instruction: " << *castinst << std::endl;
			}
			else if (const StoreInst* storeinst = llvm::dyn_cast<StoreInst>(inst)) {
				logger.debug() << "--store operand 0: " << *(storeinst->getOperand(0))
							   << " -||- Instruction: " << *storeinst << std::endl;
			}
			else if (const CallInst* callinst = llvm::dyn_cast<CallInst>(inst)) {
				return handle_value(callinst->getOperand(0), vfg, node);
				/*
				if (const GetElementPtrInst* gepinst = llvm::dyn_cast<GetElementPtrInst>(callinst->getOperand(0))) {
					logger.debug() << "---call gep: " << *(gepinst->getOperand(0)) << std::endl;
					if (const Constant* c = llvm::dyn_cast<Constant>(gepinst->getOperand(0))) {
						return c;
					}
				}
				*/
				/* interesting stuff not always in operand 0 for a CallInst */
				for (int o = 0; o < inst->getNumOperands(); o++) {
					logger.debug() << "--call operand " << o
								   << ": " << *(inst->getOperand(o))
								   << " -||- Instruction: " << *inst << std::endl;
				}
			}
			// TODO binary ops?
			else {
				logger.debug() << "UNHANDLED INST !(gep | load | alloca | cast | store | call) "  << *inst << std::endl;
			}
		}
		return NULL;
	}


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
#if 1
			/* handle parent nodes */
			for(VFGNode::const_iterator it = vNode->InEdgeBegin(); it != vNode->InEdgeEnd(); ++it) {
				if(visited.find((*it)->getSrcNode())==visited.end()){
					//logger.debug() << "Insert src vNode " << *(*it)->getSrcNode() << std::endl;
					worklist.push((*it)->getSrcNode());
				}
			}
#endif
#if 1
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
			if (const MRSVFGNode* mrnode = SVFUtil::dyn_cast<MRSVFGNode>(node)) {
				const PointsTo pt = mrnode->getPointsTo();
				// something something PAGNode ids
				//logger.debug() << "pointsto: " << pt.count() << std::endl;
				for (auto info : pt) {
					//logger.debug() << info << std::endl;
				}
			}
#endif
			/* -- vfg node kind --
			 * 0 		1 			2 			3 		4 		5 		6 		 7 		8 		  9
			 * Addr 	Copy		Gep 		Store 	Load 	Cmp 	BinaryOp TPhi 	TIntraPhi TInterPhi
			 * MPhi 	MIntraPhi 	MInterPhi 	FRet 	ARet 	AParm 	FParm 	FunRet 	APIN 	  APOUT
			 * FPIN 	FPOUT 		NPtr
			 */
			/* vfg node types for which getLHSTopLevPtr is unsupported */
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
			/* pag node types which have no value */
			if (pNode->getNodeKind() > 6)
				continue;
	    	const Value* val = pNode->getValue();
			//logger.debug() << "[[[value: " << *val << std::endl;
			if (const Function* f = pNode->getFunction()) {
				//logger.debug() << "[[[PAGNode function: " << f->getName().str() << std::endl;
				/**
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
			/* evaluate the value we found */
			const Constant* c = handle_value(val, vfg, node);
			if (c) {
				ret.push_back(c);
				//logger.debug() << "icfg node: " << *node->getICFGNode() << std::endl;
			}
	    }
		return {ret, (paths.empty() ? altPaths : paths)};
	}

	std::vector<ValueAnalysisCore::ValPath> ValueAnalysisCore::collectUsesOnVFG(const SVFG& vfg, const llvm::CallBase& call){
		if (isCallToLLVMIntrinsic(&call)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}

		std::vector<ValueAnalysisCore::ValPath> vps;


		for (const llvm::Use& use : call.args()) {
			//logger.debug() << "function is: " << call.getCalledFunction()->getName().str() << std::endl;
			const Value* val = use.get();
			if (const llvm::Constant* c = llvm::dyn_cast<llvm::Constant>(val)) {
				/**
				 * constants are saved as just one value with a single call
				 * which is needed to determine the entry function later
				 */
				ValueAnalysisCore::ValPath vp = {{c}, {{(Instruction*)&call}}};
				vps.push_back(vp);
			} else {
				assert(val != nullptr);
				logger.debug() << "retrieving value: \033[35m" << *val << "\033[0m" << std::endl;
				ValueAnalysisCore::ValPath vp = retrieve_value(vfg, *val);
				/**
				 * insert the syscall itself at the front of the callpath
				 * this is needed to distinguish these values from constants
				 * which are later detected by having a callpath of size=1
				 *
				 * this way the values always have a callpath of size >=2
				 */
				for (auto& p : std::get<1>(vp)) {
					p.insert(p.begin(), (Instruction*)&call);
				}
				vps.push_back(vp);
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
		const auto& prefix = dump_prefix.get();
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		SVFG* svfg = SVFGBuilder::globalSvfg;
		assert(svfg != nullptr && "svfg is null");
		svfg->dump("svfgdump");
		assert(svfg != nullptr);

		    graph_tool::gt_dispatch<>()([&](auto& g) { this->get_values(g, *svfg); },
		                                graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
