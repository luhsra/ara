// vim: set noet ts=4 sw=4:

#include "value_analysis.h"

#include "common/llvm_common.h"
#include "os.h"

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

	const VFGNode* ValueAnalysis::get_vfg_node(const SVFG& vfg, const llvm::Value& start) const {
		PAG* pag = PAG::getPAG();

		PAGNode* pNode = pag->getPAGNode(pag->getValueNode(&start));
		assert(pNode != nullptr);
		const VFGNode* vNode = vfg.getDefSVFGNode(pNode);
		assert(vNode != nullptr);
		return vNode;
	}

	void ValueAnalysis::do_forward_value_search(const SVFG& vfg, const llvm::Value& start, graph::Argument& arg) {
		const VFGNode* v_node = get_vfg_node(vfg, start);

		std::stack<const VFGNode*> nodes;
		std::set<const VFGNode*> visited;

		nodes.emplace(v_node);

		while (!nodes.empty()) {
			const VFGNode* current = nodes.top();
			nodes.pop();

			if (visited.find(current) != visited.end()) {
				continue;
			}
			visited.insert(current);

			if (const StoreVFGNode* s_node = llvm::dyn_cast<StoreVFGNode>(current)) {
				const Value* val = s_node->getPAGEdge()->getValue();
				const StoreInst* si = llvm::cast<StoreInst>(val);
				const Value* target = si->getPointerOperand();
				do_backward_value_search(vfg, safe_deref(target), arg, graph::SigType::symbol);
				if (arg.size() == 0) {
					// if no good value is found, store the bad one
					// We have a problem here. SVF gives us a constant Value what is meaningful from their site.
					// However, we want to fill this into our Argument structure which is exposed in Python. In
					// Python there exists no thing like const correctness because is semantically useless. That
					// means that we are forced to limit the Python types to only support methods that don't violate
					// const correctness or do a const_cast here and hope that everything will work.
					arg.add_variant(graph::CallPath(), *const_cast<llvm::Value*>(target));
				}
			} else {
				for (VFGNode::const_iterator it = current->OutEdgeBegin(); it != current->OutEdgeEnd(); ++it) {
					const VFGNode* next_node = (*it)->getDstNode();

					nodes.emplace(next_node);
				}
			}
		}
	}

	void ValueAnalysis::do_backward_value_search(const SVFG& vfg, const llvm::Value& start, graph::Argument& arg,
	                                             graph::SigType hint) {
		PAG* pag = PAG::getPAG();
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* s_callgraph = ander->getPTACallGraph();

		const VFGNode* vNode = get_vfg_node(vfg, start);

		shared_ptr<graph::CallGraph> callgraph = std::move(graph.get_callgraph_ptr());

		std::queue<VFGContainer> nodes;

		nodes.emplace(VFGContainer(vNode, graph::CallPath(), 0, 0, 0));

		std::map<unsigned, bool> found_on_level;
		std::set<const SVF::VFGNode*> visited;

		while (!nodes.empty()) {
			VFGContainer current = std::move(nodes.front());
			nodes.pop();

			const VFGNode* current_node = current.node;

			if (visited.find(current_node) != visited.end()) {
				continue;
			}
			visited.insert(current_node);

			graph::CallPath& current_path = current.call_path;
			unsigned global_depth = current.global_depth;
			unsigned local_depth = current.local_depth;
			unsigned call_depth = current.call_depth;

			logger.debug() << std::string(global_depth, ' ') << "Current Node (" << local_depth << "/" << call_depth
			               << "): " << *current_node << std::endl;
			logger.debug() << std::string(global_depth, ' ') << "Current CallPath: " << current_path << std::endl;

			if (global_depth > 100 || local_depth > 100) {
				fail("The value analysis reached a backtrack level of 100. Aborting due to preventing a to long "
				     "runtime.");
			}

			if (auto stmt = llvm::dyn_cast<StmtVFGNode>(current_node)) {
				const Value* val = stmt->getPAGEdge()->getValue();
				if (hint == graph::SigType::value || hint == graph::SigType::undefined) {
					if (const ConstantData* c = llvm::dyn_cast<ConstantData>(val)) {
						auto& ls = logger.debug() << std::string(global_depth, ' ') << "Found constant data: ";
						pretty_print(*c, ls);
						ls << std::endl;
						// We have a problem here. SVF gives us a constant Value what is meaningful from their site.
						// However, we want to fill this into our Argument structure which is exposed in Python. In
						// Python there exists no thing like const correctness because is semantically useless. That
						// means that we are forced to limit the Python types to only support methods that don't violate
						// const correctness or do a const_cast here and hope that everything will work.
						arg.add_variant(current_path, const_cast<ConstantData&>(*c));
						found_on_level[call_depth] = true;
						continue;
					}

					if (const GlobalVariable* gv = llvm::dyn_cast<GlobalVariable>(val)) {
						logger.warn() << "GV: " << *gv << " " << gv->hasExternalLinkage() << std::endl;
						if (gv->hasExternalLinkage()) {
							auto& ls = logger.debug()
							           << std::string(global_depth, ' ') << "Found global external constant: ";
							pretty_print(*gv, ls);
							ls << std::endl;
							arg.add_variant(current_path, const_cast<GlobalVariable&>(*gv));
							found_on_level[call_depth] = true;
						} else {
							const llvm::Value* gvv = gv->getOperand(0);
							if (gvv != nullptr) {
								if (const ConstantData* gvvc = llvm::dyn_cast<ConstantData>(gvv)) {
									auto& ls = logger.debug()
									           << std::string(global_depth, ' ') << "Found global constant data: ";
									pretty_print(*gvvc, ls);
									ls << std::endl;
									arg.add_variant(current_path, const_cast<ConstantData&>(*gvvc));
									found_on_level[call_depth] = true;
									continue;
								}
							}
						}
					}
				}

				if (hint == graph::SigType::symbol) {
					if (const GlobalValue* gv = llvm::dyn_cast<GlobalValue>(val)) {
						auto& ls = logger.debug() << std::string(global_depth, ' ') << "Found global value: ";
						pretty_print(*gv, ls);
						ls << std::endl;
						arg.add_variant(current_path, const_cast<GlobalValue&>(*gv));
						found_on_level[call_depth] = true;
						continue;
					}

					if (const AllocaInst* ai = llvm::dyn_cast<AllocaInst>(val)) {
						auto& ls = logger.debug()
						           << std::string(global_depth, ' ') << "Found alloca instruction (local variable): ";
						pretty_print(*ai, ls);
						ls << std::endl;
						arg.add_variant(current_path, const_cast<AllocaInst&>(*ai));
						found_on_level[call_depth] = true;
						continue;
					}
				}
			}
			if (llvm::isa<NullPtrVFGNode>(current_node)) {
				// Sigtype is not important here, a nullptr serves as value and symbol.
				logger.debug() << std::string(global_depth, ' ') << "Found a nullptr." << std::endl;
				arg.add_variant(current_path, *llvm::ConstantPointerNull::get(llvm::PointerType::get(
				                                  llvm::IntegerType::get(graph.get_module().getContext(), 8), 0)));
				found_on_level[call_depth] = true;
				continue;
			}

			for (VFGNode::const_iterator it = current_node->InEdgeBegin(); it != current_node->InEdgeEnd(); ++it) {
				unsigned next_local_depth = local_depth + 1;
				VFGEdge* edge = *it;
				graph::CallPath next_path = current_path;
				bool go_further = true;
				if (auto cde = llvm::dyn_cast<CallDirSVFGEdge>(edge)) {
					const CallBlockNode* cbn = s_callgraph->getCallSite(cde->getCallSiteId());
					assert(s_callgraph->hasCallGraphEdge(cbn) && "no call graph edge found");
					SVF::PTACallGraphEdge* call_site = nullptr;
					for (auto bi = s_callgraph->getCallEdgeBegin(cbn); bi != s_callgraph->getCallEdgeEnd(cbn); ++bi) {
						if (cde->getCallSiteId() == (*bi)->getCallSiteID()) {
							call_site = *bi;
							break;
						}
					}
					assert(call_site != nullptr && "no matching PTACallGraphEdge for CallDirSVFGEdge.");
					try {
						next_path.add_call_site(callgraph, safe_deref(call_site));
					} catch (const ara::EdgeNotFound& _) {
						// this is not reachable from the current entry point
						go_further = false;
					}
					call_depth++;
					next_local_depth = 0;
					logger.debug() << std::string(global_depth, ' ') << "Going one call up. Callsite: " << *call_site
					               << std::endl;
				} else {
					go_further = !found_on_level[call_depth];
				}

				if (go_further) {
					const VFGNode* next_node = (*it)->getSrcNode();
					if (next_node != nullptr) {
						nodes.emplace(
						    VFGContainer(next_node, next_path, global_depth + 1, next_local_depth, call_depth));
					}
				}
			}
		}
	}

	std::shared_ptr<graph::Arguments> ValueAnalysis::get_values_for_call(llvm::CallBase& called_func, const SVFG& vfg) {
		if (is_call_to_intrinsic(called_func)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}
		if (called_func.isIndirectCall()) {
			throw ValuesUnknown("Called function is indirect.");
		}

		std::shared_ptr<graph::Arguments> args = graph::Arguments::get();
		llvm::AttributeSet attrs;
		this->logger.debug() << "Number of args: " << called_func.getNumArgOperands() << std::endl;

		llvm::AttributeList attrl = called_func.getAttributes();

		const auto& syscall = syscalls.at(called_func.getCalledFunction()->getName().str());
		const auto& arg_sigs = syscall.get_signature();

		/* retrieve value of arguments */
		int t = 0;
		for (const llvm::Use& use : called_func.args()) {
			const Value& val = safe_deref(use.get());
			llvm::AttributeSet attrs = attrl.getAttributes(t + 1);
			graph::SigType arg_sig;

			auto& ls = logger.debug() << "Analyzing argument " << t << ": ";
			pretty_print(val, ls);
			ls << std::endl;

			std::shared_ptr<graph::Argument> arg = graph::Argument::get(attrs);
			if (arg_sigs.size() == called_func.getNumArgOperands()) {
				arg_sig = arg_sigs[t];
			} else {
				arg_sig = graph::SigType::undefined;
			}
			do_backward_value_search(vfg, val, *arg, arg_sig);
			args->emplace_back(arg);
			++t;
		}

		/* return value */
		if (called_func.hasNUsesOrMore(1)) {
			std::shared_ptr<graph::Argument> return_arg = graph::Argument::get(llvm::AttributeSet());
			do_forward_value_search(vfg, called_func, *return_arg);
			logger.debug() << "Return value: " << *return_arg << std::endl;
			args->set_return_value(return_arg);
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
		return "Perform a value analysis for all system calls reachable from the given entry point.\n"
		       "\n"
		       "The analysis is based on the SVFG from SVF.";
	}

	void ValueAnalysis::run() {
		graph::CFG cfg = graph.get_cfg();

		const auto& prefix = dump_prefix.get();
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		for (const os::SysCall& syscall : graph.get_os().get_syscalls()) {
			syscalls.insert({syscall.get_name(), syscall});
		}

		SVFG& svfg = graph.get_svfg();

		graph_tool::gt_dispatch<>()([&](auto& g) { this->get_all_values(g, svfg, *entry_point_name); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			logger.warn()
			    << "There are known cases where the SVFG dumping causes a segfault. Deactivate dumping in this cases."
			    << std::endl;
			svfg.dump(*dump_prefix.get() + ".svfg");
		}
	}
} // namespace ara::step
