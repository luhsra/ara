// vim: set noet ts=4 sw=4:

#include "value_analysis.h"

#include "common/llvm_common.h"

#include <Graphs/GenericGraph.h>
#include <Graphs/VFGNode.h>
#include <SVF-FE/PAGBuilder.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>
#include <boost/property_tree/json_parser.hpp>
#include <boost/python.hpp>
#include <llvm/ADT/GraphTraits.h>

using namespace boost::property_tree;
using namespace SVF;

namespace ara::step {
	void ValueAnalysis::pretty_print(const llvm::Value& val, Logger::LogStream& ls) const {
		if (const llvm::Function* f = llvm::dyn_cast<llvm::Function>(&val)) {
			ls << f->getName().str();
		} else {
			ls << val;
		}
	}

	void ValueAnalysis::do_backward_value_search(const SVFG& vfg, const llvm::Value& start, graph::Argument& arg) {
		PAG* pag = PAG::getPAG();
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* s_callgraph = ander->getPTACallGraph();

		PAGNode* pNode = pag->getPAGNode(pag->getValueNode(&start));
		assert(pNode != nullptr);
		const VFGNode* vNode = vfg.getDefSVFGNode(pNode);
		assert(vNode != nullptr);

		shared_ptr<graph::CallGraph> callgraph = std::move(graph.get_callgraph_ptr());

		std::stack<VFGContainer> nodes;

		nodes.emplace(VFGContainer(vNode, graph::CallPath(), 1));

		while (!nodes.empty()) {
			VFGContainer current = std::move(nodes.top());
			nodes.pop();
			const VFGNode* current_node = current.node;
			graph::CallPath& current_path = current.call_path;
			unsigned depth = current.depth;
			logger.debug() << std::string(depth, ' ') << "Current Node: " << *current_node << std::endl;
			logger.debug() << std::string(depth, ' ') << "Current CallPath: " << current_path << std::endl;

			if (auto stmt = llvm::dyn_cast<StmtVFGNode>(current_node)) {
				const PAGEdge* edge = stmt->getPAGEdge();
				if (const Constant* c = llvm::dyn_cast<Constant>(edge->getValue())) {
					auto& ls = logger.debug() << std::string(depth, ' ') << "Found constant: ";
					pretty_print(*c, ls);
					ls << std::endl;
					// We have a problem here. SVF gives us a constant Value what is meaningful from their site.
					// However, we want to fill this into our Argument structure which is exposed in Python. In
					// Python there exists no thing like const correctness because is semantically useless. That
					// means that we are forced to limit the Python types to only support methods that don't violate
					// const correctness or do a const_cast here and hope that everything will work.
					//
					// GlobalVariables needs an extra unpacking
					if (const GlobalVariable* gv = llvm::dyn_cast<GlobalVariable>(c)) {
						const llvm::Value* gvv = gv->getOperand(0);
						if (gvv != nullptr) {
							if (const Constant* gvvc = llvm::dyn_cast<Constant>(gvv)) {
								arg.add_variant(current_path, const_cast<Constant&>(*gvvc));
								continue;
							}
						}
					}
					arg.add_variant(current_path, const_cast<Constant&>(*c));
					continue;
				}
			}
			if (llvm::isa<NullPtrVFGNode>(current_node)) {
				logger.debug() << std::string(depth, ' ') << "Found a nullptr." << std::endl;
				arg.add_variant(current_path, *llvm::ConstantPointerNull::get(llvm::PointerType::get(
				                                  llvm::IntegerType::get(graph.get_module().getContext(), 8), 0)));
				continue;
			}

			for (VFGNode::const_iterator it = current_node->InEdgeBegin(); it != current_node->InEdgeEnd(); ++it) {
				VFGEdge* edge = *it;
				graph::CallPath next_path = current_path;
				bool go_further = true;
				if (auto cde = llvm::dyn_cast<CallDirSVFGEdge>(edge)) {
					const CallBlockNode* cbn = s_callgraph->getCallSite(cde->getCallSiteId());
					assert(s_callgraph->hasCallGraphEdge(cbn) && "no call graph edge found");
					auto bi = s_callgraph->getCallEdgeBegin(cbn);
					const SVF::PTACallGraphEdge* call_site = *bi;
					bi++;
					assert(bi == s_callgraph->getCallEdgeEnd(cbn) && "more than one edge found");
					assert(call_site->getCallSiteID() == cde->getCallSiteId() && "call side IDs does not match.");
					try {
						next_path.add_call_site(callgraph, safe_deref(call_site));
					} catch (const ara::EdgeNotFound& _) {
						// this is not reachable from the current entry point
						go_further = false;
					}
					logger.debug() << std::string(depth, ' ') << "Going on call up. Callsite: " << *call_site
					               << std::endl;
				}

				if (go_further) {
					const VFGNode* next_node = (*it)->getSrcNode();
					if (next_node != nullptr) {
						nodes.emplace(VFGContainer(next_node, next_path, depth + 1));
					}
				}
			}
		}
	}

	std::shared_ptr<graph::Arguments> ValueAnalysis::get_values_for_call(const llvm::CallBase& called_func,
	                                                                     const SVFG& vfg) {
		if (is_call_to_intrinsic(called_func)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}

		std::shared_ptr<graph::Arguments> args = graph::Arguments::get();
		llvm::AttributeSet attrs;
		this->logger.debug() << "Number of args: " << called_func.getNumArgOperands() << std::endl;

		llvm::AttributeList attrl = called_func.getAttributes();

		/* retrieve value of arguments */
		int t = 0;
		for (const llvm::Use& use : called_func.args()) {
			const Value& val = safe_deref(use.get());
			llvm::AttributeSet attrs = attrl.getAttributes(t + 1);

			auto& ls = logger.debug() << "Analyzing argument " << t << ": ";
			pretty_print(val, ls);
			ls << std::endl;

			std::shared_ptr<graph::Argument> arg = graph::Argument::get(attrs);
			do_backward_value_search(vfg, val, *arg);
			args->emplace_back(arg);
			++t;
		}

		/* return value */
		if (called_func.hasOneUse()) {
			const llvm::User* ur = called_func.user_back();
			llvm::Value* retval = ur->getOperand(1);
			logger.debug() << "Return value: " << *retval << std::endl;
			args->set_return_value(graph::Argument::get(llvm::AttributeSet(), *retval));
		}

		this->logger.info() << "Retrieved " << args->size() << " arguments for call " << called_func << std::endl;
		return args;
	}

	llvm::json::Array ValueAnalysis::get_configured_dependencies() {
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");
		return llvm::json::Array{llvm::json::Object{{{"name", "Syscall"}, {"entry_point", *entry_point_name}}}};
	}

	std::string ValueAnalysis::get_description() {
		return "Perform a value analysis for all system calls reachable from the given entry point.\n\nThe analysis "
		       "ist based on the SVFG from SVF.";
	}

	void ValueAnalysis::run() {
		graph::CFG cfg = graph.get_cfg();
		const auto& prefix = dump_prefix.get();
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		SVFG& svfg = graph.get_svfg();

		graph_tool::gt_dispatch<>()([&](auto& g) { this->get_all_values(g, svfg, *entry_point_name); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			std::string uuid = step_manager.get_execution_id();
			std::string dot_file = *dump_prefix.get() + uuid + ".svfg";
			logger.warn()
			    << "There are known cases where the SVFG dumping causes a segfault. Deactivate dumping in this cases."
			    << std::endl;
			svfg.dump(dot_file);
		}
	}
} // namespace ara::step
