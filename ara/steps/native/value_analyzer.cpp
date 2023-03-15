// SPDX-FileCopyrightText: 2019 Benedikt Steinmeier
// SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
// SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2021 Christoph Möller
// SPDX-FileCopyrightText: 2021 Lukas Berg
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "value_analyzer.h"

#include "common/llvm_common.h"
#include "common/util.h"

#include <boost/range/adaptor/indexed.hpp>
#include <boost/range/adaptor/map.hpp>
#include <pyllco.h>

extern PyObject* py_valueerror;
extern PyObject* py_connectionerror;

namespace ara::cython {

	void raise_py_valueerror() {
		try {
			throw;
		} catch (ValuesUnknown& e) {
			PyErr_SetString(py_valueerror, e.what());
		} catch (ConnectionStatusUnknown& e) {
			PyErr_SetString(py_connectionerror, e.what());
		} catch (const std::exception& e) {
			PyErr_SetString(PyExc_RuntimeError, e.what());
		}
	}
} // namespace ara::cython

namespace ara::step {
	// helper functions
	namespace {
		using Manip = std::function<Logger::LogStream&(Logger::LogStream&)>;
		Manip pretty_print(const llvm::Value& val) {
			return [&](Logger::LogStream& ls) -> Logger::LogStream& {
				if (const llvm::Function* f = llvm::dyn_cast<llvm::Function>(&val)) {
					return ls << f->getName().str();
				} else {
					return ls << val;
				}
			};
		}

		Manip offset_print(const std::vector<const llvm::GetElementPtrInst*>& vec) {
			return [&](Logger::LogStream& ls) -> Logger::LogStream& {
				ls << "[";
				for (const auto& gep : vec) {
					ls << *gep << ", ";
				}
				ls << "]";
				return ls;
			};
		}

		/**
		 * Calculate the static offset of a GetElementPtrInst.
		 *
		 * Return an offset, std::nullopt otherwise.
		 */
		std::optional<int64_t> get_offset(const llvm::GetElementPtrInst* gep, const llvm::Module& llvm_module) {
			assert(gep != nullptr && "GEP is null");
			const auto layout = llvm_module.getDataLayout();
			llvm::APInt ap_offset(layout.getIndexSizeInBits(gep->getPointerAddressSpace()), 0, true);
			bool success = gep->accumulateConstantOffset(layout, ap_offset);
			if (!success) {
				return std::nullopt;
			}
			return ap_offset.getSExtValue();
		}

		std::optional<std::vector<int64_t>>
		convert_to_number_offsets(const std::vector<const llvm::GetElementPtrInst*>& offsets,
		                          const llvm::Module& llvm_module) {
			std::vector<int64_t> number_offsets;
			for (const auto& gep : offsets) {
				auto number = get_offset(gep, llvm_module);
				if (!number) {
					return std::nullopt;
				}
				number_offsets.push_back(*number);
			}
			return number_offsets;
		}

		std::optional<SVF::CallSiteID> get_callsite_id(const SVF::VFGEdge* edge) {
			if (const auto* node = llvm::dyn_cast<SVF::CallDirSVFGEdge>(edge)) {
				return node->getCallSiteId();
			}
			if (const auto* node = llvm::dyn_cast<SVF::CallIndSVFGEdge>(edge)) {
				return node->getCallSiteId();
			}
			if (const auto* node = llvm::dyn_cast<SVF::RetDirSVFGEdge>(edge)) {
				return node->getCallSiteId();
			}
			if (const auto* node = llvm::dyn_cast<SVF::RetIndSVFGEdge>(edge)) {
				return node->getCallSiteId();
			}
			return std::nullopt;
		}

		const SVF::PTACallGraphEdge* get_callsite(const SVF::VFGEdge* edge, const SVF::PTACallGraph* callgraph) {
			auto id = get_callsite_id(edge);
			if (!id) {
				return nullptr;
			}
			const SVF::CallICFGNode* cbn = callgraph->getCallSite(*id);
			if (cbn == nullptr) {
				return nullptr;
			}

			// get call site
			assert(callgraph->hasCallGraphEdge(cbn) && "no valid call graph edge found");
			SVF::PTACallGraphEdge* call_site = nullptr;
			for (auto bi = callgraph->getCallEdgeBegin(cbn); bi != callgraph->getCallEdgeEnd(cbn); ++bi) {
				if (id == (*bi)->getCallSiteID()) {
					call_site = *bi;
					break;
				}
			}
			assert(call_site != nullptr && "no matching PTACallGraphEdge for CallDirSVFGEdge.");

			return call_site;
		}

	} // namespace

	std::ostream& operator<<(std::ostream& os, const WaitingReason& w) {
		switch (w) {
		case WaitingReason::not_set:
			return os << "WaitingReason::not_set";
		case WaitingReason::in_phi:
			return os << "WaitingReason::in_phi";
		case WaitingReason::i_am_manager:
			return os << "WaitingReason::i_am_manager";
		}
		return os;
	}

	std::ostream& operator<<(std::ostream& os, const Status& s) {
		switch (s) {
		case Status::active:
			return os << "Status::active";
		case Status::sleeping:
			return os << "Status::sleeping";
		case Status::dead:
			return os << "Status::dead";
		}
		return os;
	}

	template <typename SVFG>
	std::ostream& operator<<(std::ostream& os, const Node<SVFG> node) {
		// TODO: make print tidy
		os << "Node(";
		os << node;
		os << ')' << std::endl;
		return os;
	}

	template <typename SVFG>
	std::ostream& operator<<(std::ostream& os, const PrintableEdge<SVFG>& edge) {
		os << "Edge(";
		os << source(edge.edge, edge.g);
		os << "->";
		os << target(edge.edge, edge.g);
		os << ')' << std::endl;
		return os;
	}

	template <class SVFG>
	void Traverser<SVFG>::remove(size_t traverser_id) {
		workers.erase(traverser_id);
		// keep going
		act_if_necessary();
	}

	template <class SVFG>
	void Traverser<SVFG>::die() {
		this->dbg() << "change status: dead" << std::endl;
		status = Status::dead;
	}

	template <class SVFG>
	void Traverser<SVFG>::die_and_notify() {
		die();
		boss->remove(get_id());
	}

	template <class SVFG>
	void Traverser<SVFG>::sleep() {
		this->dbg() << "change status: sleeping" << std::endl;
		status = Status::sleeping;
	}

	template <class SVFG>
	void Traverser<SVFG>::wakeup() {
		this->dbg() << "change status: active" << std::endl;
		status = Status::active;
	}

	template <class SVFG>
	void Traverser<SVFG>::do_step() {
		assert(!trace.empty());
		Edge<SVFG> current_edge = trace.back();
		if (!skip_first_edge) {
			this->dbg() << "Analyzing edge " << PrintableEdge(current_edge, caretaker.get_g()) << std::endl;
			if (eval_result(handle_edge(current_edge))) {
				return;
			}
			skip_first_edge = false;
		}

		const Node<SVFG> current_node = source(current_edge, caretaker.get_g());
		this->dbg() << "Analyzing node " << current_node << std::endl;
		if (die_at_visited && caretaker.is_visited(current_node)) {
			this->die_and_notify();
			return;
		}
		caretaker.mark_visited(current_node);

		if (eval_result(handle_node(current_node))) {
			return;
		}

		eval_result(advance(current_node));
	}

	template <class SVFG>
	const SVF::PTACallGraphEdge* Traverser<SVFG>::t_get_callsite(const SVF::VFGEdge* edge) const {
		return get_callsite(edge, caretaker.get_svf_call_graph());
	}

	template <class SVFG>
	std::pair<CPA, const SVF::PTACallGraphEdge*>
	Traverser<SVFG>::evaluate_callpath(const Edge<SVFG>& edge, const graph::CallPath& cpath) const {
		SVF::VFGEdge* vfg_edge = caretaker.get_svfg()->template get_edge_obj<SVFG>(edge);
		bool is_call = vfg_edge != nullptr &&
		               (llvm::isa<SVF::CallDirSVFGEdge>(vfg_edge) || llvm::isa<SVF::CallIndSVFGEdge>(vfg_edge));
		bool is_ret = vfg_edge != nullptr &&
		              (llvm::isa<SVF::RetDirSVFGEdge>(vfg_edge) || llvm::isa<SVF::RetIndSVFGEdge>(vfg_edge));

		const SVF::PTACallGraphEdge* cg_edge = t_get_callsite(vfg_edge);
		if (cg_edge == nullptr) {
			return std::make_pair(CPA::keep, cg_edge);
		}
		if (cpath.size() == 0) {
			if (is_ret) {
				return std::make_pair(CPA::add, cg_edge);
			} else {
				// actually, this cannot not happen, if the call path begins at a root node such as main()
				// if this happens anyway, it is wanted by the user of the ValueAnlyzer
				// in this case we just ignore the call path
				return std::make_pair(CPA::keep, cg_edge);
			}
		}

		const SVF::PTACallGraphEdge* current = cpath.svf_at(cpath.size() - 1);
		if (is_call && *cg_edge == current) {
			return std::make_pair(CPA::drop, cg_edge);
		}

		if (is_ret) {
			const auto* node = current->getDstNode();
			for (const SVF::PTACallGraphEdge* out_edge :
			     boost::make_iterator_range(node->OutEdgeBegin(), node->OutEdgeEnd())) {
				if (*cg_edge == out_edge) {
					this->dbg() << "Found valid return edge. Go a level further down..." << std::endl;
					return std::make_pair(CPA::add, cg_edge);
				}
			}
		}
		return std::make_pair(CPA::false_path, cg_edge);
	}

	template <class SVFG>
	void Traverser<SVFG>::update_call_path(const CPA action, const SVF::PTACallGraphEdge* edge) {
		switch (action) {
		case CPA::drop:
			call_path.pop_back();
			return;
		case CPA::add:
			call_path.add_call_site(caretaker.get_call_graph(), safe_deref(edge));
			return;
		case CPA::keep:
			// do nothing
			return;
		case CPA::false_path:
			assert(false && "cannot handle false_path");
			return;
		}
	}

	template <class SVFG>
	void Traverser<SVFG>::add_edge_to_trace(const Edge<SVFG>& edge) {
		this->trace.emplace_back(edge);
		this->path.template add_edge<SVFG>(caretaker.get_tracer(), edge, caretaker.get_g());
		caretaker.get_tracer().go_to_node(this->entity, this->path, false);
	}

	template <class SVFG>
	TraversalResult<SVFG> Traverser<SVFG>::advance(const Node<SVFG> node, bool only_delegate) {
		// go into the direction of the first edge yourself or delegate
		bool first = !only_delegate;

		auto new_boss = (only_delegate) ? this : this->boss;

		// make a copy since we can change this->call_path in the first iteration
		graph::CallPath cp = call_path;
		unsigned spawned_traversers = 0;
		for (auto edge : graph_tool::in_edges_range(node, caretaker.get_g())) {
			this->dbg() << "Eval Callpath: " << cp << " | " << PrintableEdge(edge, caretaker.get_g()) << std::endl;

			tracer::GraphPath eval_path = this->path.clone();
			eval_path.template add_edge<SVFG>(caretaker.get_tracer(), edge, caretaker.get_g());
			caretaker.get_tracer().entity_is_looking_at(this->entity, eval_path);

			auto [action, cg_edge] = evaluate_callpath(edge, cp);
			if (action == CPA::false_path) {
				this->dbg() << "False path: " << PrintableEdge(edge, caretaker.get_g()) << std::endl;
				continue;
			}

			++spawned_traversers;
			if (first) {
				this->dbg() << "Advance: self, go to " << PrintableEdge(edge, caretaker.get_g()) << std::endl;
				this->trace.emplace_back(edge);
				caretaker.get_tracer().go_to_node(this->entity, eval_path, false);
				this->path = eval_path;
				update_call_path(action, cg_edge);
				first = false;
				continue;
			}
			auto worker = std::make_shared<Traverser<SVFG>>(new_boss, edge, cp, caretaker);
			this->dbg() << "COPY: Src: " << offset_print(offset) << " Dst: " << offset_print(worker->offset)
			            << std::endl;
			worker->offset = offset;
			this->dbg() << "COPY: Src: " << offset_print(offset) << " Dst: " << offset_print(worker->offset)
			            << std::endl;
			worker->level = level;
			worker->update_call_path(action, cg_edge);
			new_boss->hire(worker);
			this->dbg() << "Advance: new " << *worker << std::endl;
			this->caretaker.add_traverser(worker);
		}
		if (spawned_traversers == 0) {
			this->dbg() << "Advance: No further path. Die." << std::endl;
			return Die();
		}
		return KeepGoing();
	}

	template <class SVFG>
	void Traverser<SVFG>::sleep_and_send(Report<SVFG>&& report) {
		this->sleep();
		boss->send_report(std::move(report));
	}

	template <class SVFG>
	bool Traverser<SVFG>::eval_result(TraversalResult<SVFG>&& result) {
		bool ret = false;
		std::visit(overloaded{[&](Finished<SVFG> f) {
			                      this->dbg() << "Finished: Send report" << std::endl;
			                      sleep_and_send(std::move(f.report));
			                      ret = true;
		                      },
		                      [&](Wait w) {
			                      this->dbg() << "Waiting for reason " << w.reason << std::endl;
			                      reason = w.reason;
			                      this->sleep();
			                      ret = true;
		                      },
		                      [&](KeepGoing) { ret = false; },
		                      [&](Die) {
			                      this->die_and_notify();
			                      ret = true;
		                      }},
		           result);
		return ret;
	}

	template <class SVFG>
	TraversalResult<SVFG> Traverser<SVFG>::handle_edge(const Edge<SVFG>& edge) {
		SVF::VFGEdge* vfg_edge = caretaker.get_svfg()->template get_edge_obj<SVFG>(edge);
		auto hint = caretaker.get_hint();
		auto good_edge = [&]() {
			if (hint == graph::SigType::symbol) {
				return llvm::isa<SVF::CallDirSVFGEdge>(vfg_edge);
			}
			return llvm::isa<SVF::CallDirSVFGEdge>(vfg_edge) || llvm::isa<SVF::CallIndSVFGEdge>(vfg_edge);
		};
		if (good_edge()) {
			const SVF::PTACallGraphEdge* cg_edge = t_get_callsite(vfg_edge);
			if (cg_edge && call_path.size() > 0 && *cg_edge == call_path.svf_at(call_path.size() - 1)) {
				this->dbg() << "Found call edge further down. This could not be. Die: " << *vfg_edge << std::endl;
				return Die();
			} else {
				this->dbg() << "Found call edge up, waiting for other nodes: " << *vfg_edge << std::endl;
				level++;
				if (level > MAX_TRAVERSER_LEVEL) {
					this->caretaker.get_logger().warn() << "reached max traverser level" << std::endl;
					return Die();
				}
				return Finished<SVFG>{EndOfFunction()};
			}
		}
		if (hint == graph::SigType::symbol && llvm::isa<SVF::CallIndSVFGEdge>(vfg_edge)) {
			this->dbg() << "Found indirect call edge up, while searching for symbols, die: " << *vfg_edge << std::endl;
			return Die();
		}

		return KeepGoing();
	}

	template <class SVFG>
	TraversalResult<SVFG> Traverser<SVFG>::handle_node(const Node<SVFG> node) {
		this->dbg() << "Handle node: " << node << std::endl;
		SVF::VFGNode* svf_node = caretaker.get_svfg()->template get_node_obj<SVFG>(node);
		auto id = caretaker.get_obj_id(node, offset, call_path);
		if (id) {
			this->dbg() << "Found a previous assigned object." << std::endl;
			this->dbg() << "CallPath: " << call_path << std::endl;
			this->dbg() << "Asked for: " << node << " " << offset_print(offset) << std::endl;
			return Finished<SVFG>{FoundValue<SVFG>{*id, node, {}, call_path}};
		}
		if (llvm::isa<SVF::NullPtrVFGNode>(svf_node)) {
			// Sigtype is not important here, a nullptr serves as value and symbol.
			this->dbg() << "Found a nullptr." << std::endl;
			auto nullval = llvm::ConstantPointerNull::get(
			    llvm::PointerType::get(llvm::IntegerType::get(caretaker.get_module().getContext(), 8), 0));
			return Finished<SVFG>{FoundValue<SVFG>{nullval, node, offset, std::nullopt}};
		}

		if (auto stmt = llvm::dyn_cast<SVF::StmtVFGNode>(svf_node)) {
			const llvm::Value* val = stmt->getPAGEdge()->getValue();
			auto hint = caretaker.get_hint();

			if (llvm::isa<llvm::GlobalValue>(val)) {
				// GlobalValues are call path independent so check for object assignment again
				auto id = caretaker.get_obj_id(node, offset, graph::CallPath());
				if (id) {
					this->dbg() << "Found a previous assigned object." << std::endl;
					this->dbg() << "CallPath: " << call_path << std::endl;
					this->dbg() << "Asked for: " << node << " " << offset_print(offset) << std::endl;
					return Finished<SVFG>{FoundValue<SVFG>{*id, node, {}, graph::CallPath()}};
				}
			}

			if (const llvm::GetElementPtrInst* i = llvm::dyn_cast<llvm::GetElementPtrInst>(val)) {
				this->dbg() << "Found GetElementPtrInst: " << pretty_print(*i) << std::endl;
				offset.emplace_back(i);
				this->dbg() << "New offset: " << offset_print(offset) << std::endl;
			}

			if (hint == graph::SigType::value || hint == graph::SigType::undefined) {
				if (const llvm::ConstantData* c = llvm::dyn_cast<llvm::ConstantData>(val)) {
					this->dbg() << "Found constant data: " << pretty_print(*c) << std::endl;
					return Finished<SVFG>{FoundValue<SVFG>{c, node, offset, std::nullopt}};
				}

				if (const llvm::Function* func = llvm::dyn_cast<llvm::Function>(val)) {
					this->dbg() << "Found function: " << pretty_print(*func) << std::endl;
					return Finished<SVFG>{FoundValue<SVFG>{func, node, offset, std::nullopt}};
				}

				if (const llvm::GlobalVariable* gv = llvm::dyn_cast<llvm::GlobalVariable>(val)) {
					if (gv->hasExternalLinkage()) {
						this->dbg() << "Found global external constant: " << pretty_print(*gv) << std::endl;
						return Finished<SVFG>{FoundValue<SVFG>{gv, node, offset, std::nullopt}};
					} else if (gv->getNumOperands() > 0) { // TODO consider using offset
						// special handling for strings, they are pointer to constant data
						const llvm::Value* gvv = gv->getOperand(0);
						if (gvv != nullptr) {
							if (const llvm::ConstantData* gvvc = llvm::dyn_cast<llvm::ConstantData>(gvv)) {
								this->dbg() << "Found global constant data: " << pretty_print(*gvvc) << std::endl;
								return Finished<SVFG>{FoundValue<SVFG>{gvvc, node, {}, std::nullopt}};
							}
						}
					}
				}
			}

			if (hint == graph::SigType::symbol) {
				if (const llvm::GlobalValue* gv = llvm::dyn_cast<llvm::GlobalValue>(val)) {
					this->dbg() << "Found global value: " << pretty_print(*gv) << std::endl;
					return Finished<SVFG>{FoundValue<SVFG>{gv, node, offset, std::nullopt}};
				}

				if (const llvm::AllocaInst* ai = llvm::dyn_cast<llvm::AllocaInst>(val)) {
					this->dbg() << "Found alloca instruction (local variable): " << pretty_print(*ai) << std::endl;
					return Finished<SVFG>{FoundValue<SVFG>{ai, node, offset, call_path}};
				}
			}
		}
		if (llvm::isa<SVF::PHIVFGNode>(svf_node)) {
			this->dbg() << "Found PHIVFGNode, spawn subtraversers: " << node << std::endl;
			auto result = advance(node, /* only_delegate= */ true);
			if (std::holds_alternative<Die>(result)) {
				return result;
			}
			return Wait{WaitingReason::in_phi};
		}
		return KeepGoing();
	}

	template <class SVFG>
	void Traverser<SVFG>::act_if_necessary() {
		// output
		this->dbg() << "Worker has changed something, check if action is required." << std::endl;
		this->dbg() << "Current workers:" << std::endl;
		for (auto worker : workers | boost::adaptors::map_values) {
			this->dbg() << "Worker: " << *worker << std::endl;
		}
		// check
		if (workers.size() == 0) {
			this->die_and_notify();
			return;
		}
		if (std::all_of(workers.begin(), workers.end(), [](auto w) {
			    return w.second->get_status() == Status::sleeping && w.second->reason != WaitingReason::in_phi;
		    })) {
			this->dbg() << "Got all reports. Acting..." << std::endl;
			handle_reports();
		} else {
			this->dbg() << "No action required." << std::endl;
		}
	}

	template <class SVFG>
	void Traverser<SVFG>::send_report(Report<SVFG>&& report) {
		reports.emplace_back(report);
		act_if_necessary();
	}

	template <class SVFG>
	void Traverser<SVFG>::handle_found_value(FoundValue<SVFG>&& report) {
		sleep_and_send(report);
	}

	template <class SVFG>
	void Traverser<SVFG>::cleanup_workers() {
		// TODO use std::erase_if in C++20
		auto it = workers.begin();
		while (it != workers.end()) {
			if (it->second->get_status() == Status::dead) {
				it = workers.erase(it);
			} else {
				++it;
			}
		}
	}

	template <class SVFG>
	void Traverser<SVFG>::hire(std::shared_ptr<Traverser> worker) {
		workers[worker->get_id()] = worker;
		worker->boss = this;
	}

	template <class SVFG>
	FoundValue<SVFG> Traverser<SVFG>::get_best_find(std::vector<Report<SVFG>>&& finds) const {
		// current heuristic: if a previous assigned instance is found, take that, otherwise the first one
		auto found_instance = [](Report<SVFG>& r) {
			return std::holds_alternative<OSObject>(std::get<FoundValue<SVFG>>(r).value);
		};
		auto it = std::find_if(finds.begin(), finds.end(), found_instance);
		if (it != finds.end()) {
			return std::get<FoundValue<SVFG>>(std::move(*it));
		}
		return std::get<FoundValue<SVFG>>(std::move(finds[0]));
	}

	template <class SVFG>
	void Traverser<SVFG>::handle_reports() {
		auto found_value = [](Report<SVFG>& r) { return std::holds_alternative<FoundValue<SVFG>>(r); };

		auto it = std::find_if(reports.begin(), reports.end(), found_value);
		if (it != reports.end()) {
			std::vector<Report<SVFG>> finds;
			std::copy_if(reports.begin(), reports.end(), std::back_inserter(finds), found_value);
			if (finds.size() > 1 && reason == WaitingReason::in_phi) {
				// TODO we must not have two Found Values otherwise we are not able to handle it
				this->dbg() << "PHINode with multiple value nodes is not supported." << std::endl;
				throw ValuesUnknown("PHINode with multiple value nodes is not supported.");
			}
			this->dbg() << "Worker found a value, forwarding..." << std::endl;
			auto report = get_best_find(std::move(finds));

			std::for_each(workers.begin(), workers.end(), [](auto w) { w.second->die(); });
			workers.clear();
			reports.clear();
			reason = WaitingReason::not_set;
			handle_found_value(std::move(report));
			return;
		}
		if (std::all_of(reports.begin(), reports.end(),
		                [](Report<SVFG>& r) { return std::holds_alternative<EndOfFunction>(r); })) {
			if (workers.size() == 1 && reason == WaitingReason::in_phi && boss != this) {
				// currently waiting in phi node and we have only one subtraverser
				// We can savely ignore the phi in this case. Pass the traverser to our boss.
				auto worker = workers.begin()->second;
				boss->hire(worker);
				workers.clear();
				assert(reports.size() == 1 && "workers and reports size must match here");
				// we have no job anymore, just die()
				this->dbg() << "Found PHI with one possible continuation. Continue with T" << worker->get_id()
				            << " (boss=T" << boss->get_id() << "). Removing ourself." << std::endl;
				auto report = std::move(*reports.begin());
				reports.clear();
				boss->send_report(std::move(report));
				this->die_and_notify();
			} else {
				auto travs = choose_best_next_traversers();
				this->dbg() << "All subordinates reached end of current call level." << std::endl;
				reports.clear();
				for (auto t : travs) {
					this->dbg() << "Continue with: " << t->get_id() << std::endl;
					t->wakeup();
					t->skip_first_edge = true;
				}
			}
		}
	}

	template <class SVFG>
	std::vector<std::shared_ptr<Traverser<SVFG>>> Traverser<SVFG>::choose_best_next_traversers() {
		std::vector<std::shared_ptr<Traverser<SVFG>>> indirects;
		std::vector<std::shared_ptr<Traverser<SVFG>>> directs;
		for (auto worker : workers | boost::adaptors::map_values) {
			assert(!worker->trace.empty());
			if (llvm::isa<SVF::CallIndSVFGEdge>(
			        caretaker.get_svfg()->template get_edge_obj<SVFG>(worker->trace.back()))) {
				indirects.emplace_back(worker);
			} else {
				directs.emplace_back(worker);
			}
		}
		if (indirects.size() >= 1) {
			return indirects;
		}
		return directs;
	}

	template <class SVFG>
	Logger::LogStream& Traverser<SVFG>::dbg() const {
		auto& ls = caretaker.get_logger().debug();
		ls << std::string(level, ' ');
		ls << 'T' << id << " (" << call_path.size() << "): ";
		return ls;
	}

	template <typename SVFG>
	std::ostream& operator<<(std::ostream& os, const Traverser<SVFG>& t) {
		os << "Traverser(";
		os << "id=" << t.get_id();
		os << ", boss=" << t.boss->get_id();
		if (!t.trace.empty()) {
			Edge<SVFG> edge = t.trace.back();
			os << ", edge=" << source(edge, t.caretaker.get_g()) << "->" << target(edge, t.caretaker.get_g());
		} else {
			os << ", edge=nullptr";
		}
		os << ", status=" << t.status;
		if (t.reason != WaitingReason::not_set) {
			os << ", reason=" << t.reason;
		}
		os << ")";
		return os;
	}

	template <class SVFG>
	void Manager<SVFG>::act_if_necessary() {
		if (this->workers.size() == 0) {
			this->caretaker.get_logger().warn() << "Manager:: Did not found a valid value." << std::endl;
			throw ValuesUnknown("Manager: Did not found a valid value.");
		}
		Traverser<SVFG>::act_if_necessary();
	}

	template <class SVFG>
	bool Manager<SVFG>::eval_node_result(TraversalResult<SVFG>&& result) {
		bool ret = false;
		std::visit(overloaded{[&](Finished<SVFG> f) {
			                      this->value = std::move(std::get<FoundValue<SVFG>>(f.report));
			                      this->caretaker.stop();
			                      ret = true;
		                      },
		                      [&](Wait w) {
			                      this->reason = w.reason;
			                      this->sleep();
			                      ret = true;
		                      },
		                      [&](KeepGoing) { ret = false; },
		                      [&](Die) {
			                      this->die_and_notify();
			                      ret = true;
		                      }},
		           result);
		return ret;
	}

	template <class SVFG>
	void Manager<SVFG>::do_step() {
		this->dbg() << "Manager: search current node" << std::endl;
		if (eval_node_result(this->handle_node(node))) {
			return;
		}
		this->caretaker.mark_visited(node);

		this->dbg() << "Manager: delegate" << std::endl;
		TraversalResult<SVFG> result = this->advance(node, /* only_delegate= */ true);
		if (std::holds_alternative<Die>(result)) {
			throw ValuesUnknown("Start node has no incoming flows.");
		}
		this->sleep();
	}

	template <class SVFG>
	void Manager<SVFG>::handle_found_value(FoundValue<SVFG>&& report) {
		value = report;
		this->sleep();
		this->caretaker.stop();
	}

	template <class SVFG>
	const FoundValue<SVFG> Manager<SVFG>::get_value() {
		assert(value && "no value");
		return *value;
	}

	template <class SVFG>
	void Bookkeeping<SVFG>::run() {
		// while(true) {
		for (int i = 0; i < 100; ++i) {
			for (auto it = traversers.begin(); it != traversers.end();) {
				auto traverser = *it;
				if (should_stop) {
					va.logger.debug() << "Stopping..." << std::endl;
					return;
				}
				switch (traverser->get_status()) {
				case Status::dead:
					it = traversers.erase(it);
					continue;
				case Status::sleeping:
					++it;
					continue;
				case Status::active:
					traverser->do_step();
					++it;
				}
			}
		}
		va.logger.debug() << "Stopping after 100 iterations." << std::endl;
	}

	template <class SVFG>
	llvm::Module& Bookkeeping<SVFG>::get_module() const {
		return va.graph.get_module();
	}

	template <class SVFG>
	Logger& Bookkeeping<SVFG>::get_logger() const {
		return va.logger;
	}

	template <class SVFG>
	std::optional<OSObject> Bookkeeping<SVFG>::get_obj_id(const Node<SVFG> node,
	                                                      const std::vector<const llvm::GetElementPtrInst*>& offset,
	                                                      const graph::CallPath& callpath) const {
		auto num_offsets = convert_to_number_offsets(offset, this->get_module());
		if (!num_offsets) {
			return std::nullopt;
		}
		auto it = va.obj_map.left.find(std::make_tuple(node, *num_offsets, callpath.hash()));
		if (it != va.obj_map.left.end()) {
			return it->second;
		}
		return std::nullopt;
	}

	template <class SVFG>
	void ValueAnalyzerImpl<SVFG>::fail(const char* msg) {
		logger.error() << "ERROR: " << msg << std::endl;
		throw ValuesUnknown(msg);
	}

	template <class SVFG>
	const Node<SVFG> ValueAnalyzerImpl<SVFG>::get_vfg_node(const llvm::Value& start, int argument_nr) {
		auto nodes = this->svfg->template from_llvm_value<SVFG>(start);
		if (nodes.size() == 0) {
			logger.error() << "Call get_vfg_node with: " << start << " and argument_nr: " << argument_nr << std::endl;
			throw ValuesUnknown("Cannot go back from llvm::Value to an SVF node");
		}
		if (nodes.size() == 1) {
			// we have an 1 to 1 mapping, so just return
			return *nodes.begin();
		}
		// more than one node, we need to do a back mapping with a heuristic

		// helper variables for addr_pattern
		uint64_t addr = 0; // a graphtool vertex
		bool addr_set = false;
		bool addr_pattern_valid = true;
		auto fail_with_msg = [&](const char* msg) {
			logger.debug() << msg << std::endl;
			addr_pattern_valid = false;
		};
		auto assign_addr = [&](const Node<SVFG> n) {
			if (addr_set && static_cast<uint64_t>(n) == addr) {
				return;
			} else if (addr_set) {
				fail_with_msg("Addr pattern failed. Found a second addr node.");
			} else {
				addr = n;
				addr_set = true;
			}
		};

		// iterate all nodes to check for specific pattern
		for (auto node : nodes) {
			// Pattern 1: We have only one AddrVFGNode and multiple pointer (GepVFGNodes) to this node
			if (addr_pattern_valid) {
				SVF::VFGNode* vfg_node = this->svfg->template get_node_obj<SVFG>(node);
				if (llvm::dyn_cast<SVF::AddrVFGNode>(vfg_node)) {
					assign_addr(node);
				} else if (llvm::isa<SVF::GepVFGNode>(vfg_node)) {
					bool first_node = true;
					for (auto edge : graph_tool::in_edges_range(node, g)) {
						if (!first_node) {
							fail_with_msg("Addr pattern failed. Found a pointer to more than one node.");
							break;
						}
						auto cand = source(edge, g);
						if (llvm::dyn_cast<SVF::AddrVFGNode>(this->svfg->template get_node_obj<SVFG>(cand))) {
							assign_addr(cand);
						} else {
							fail_with_msg("Addr pattern failed. Found a pointer to a non AddrVFGNode");
						}
						first_node = false;
					}
				}
			}

			// Pattern 2: Any element in the list is a nullptr
			if (llvm::isa<SVF::NullPtrVFGNode>(this->svfg->template get_node_obj<SVFG>(node))) {
				logger.debug() << "Pattern 2, found nullptr: " << node << std::endl;
				return node;
			}
		}

		if (addr_pattern_valid && addr_set) {
			logger.debug() << "Pattern 1, found one address with multiple pointers: " << addr << std::endl;
			return addr;
		}

		// ATTENTION: Pattern 3 is under development
		if (argument_nr >= 0) {
			logger.warning() << "get_vfg_node(): try to check for Pattern 3 which is under development" << std::endl;
			for (auto node : nodes) {
				// Pattern 3: We are searching an argument, the next node has to be a FormalParmPHI
				for (auto edge : graph_tool::out_edges_range(node, g)) {
					auto cand = target(edge, g);
					logger.debug() << "cand: " << cand << std::endl;
					if (auto phi =
					        llvm::dyn_cast<SVF::InterPHIVFGNode>(this->svfg->template get_node_obj<SVFG>(cand))) {
						logger.debug() << "PHINode: " << *phi << std::endl;
						if (phi->isFormalParmPHI()) {
							if (auto arg = llvm::dyn_cast<llvm::Argument>(phi->getValue())) {
								logger.debug()
								    << "arg: " << *arg << " " << arg->getArgNo() << " " << argument_nr << std::endl;
								if (arg->getArgNo() == static_cast<unsigned>(argument_nr)) {
									logger.error() << "Found correct node" << std::endl;
									assert(false && "Pattern 3 (under development) found correct node.");
								}
							}
						}
					}
				}
			}
		}

		assert(false && "get_vfg_node(): No pattern is matching!");
	}

	template <class SVFG>
	FoundValue<SVFG> ValueAnalyzerImpl<SVFG>::do_backward_value_search(const Node<SVFG> start, graph::CallPath callpath,
	                                                                   graph::SigType hint) {
		Bookkeeping caretaker(*this, this->callgraph, this->svfg, g, tracer, svf_objects.s_callgraph, hint);
		std::shared_ptr<Manager<SVFG>> root = std::make_shared<Manager<SVFG>>(start, callpath, caretaker);
		caretaker.add_traverser(root);

		tracer.entity_on_node(root->get_entity(),
		                      tracer::GraphNode(static_cast<uint64_t>(start), graph::GraphType::SVFG));

		caretaker.run();
		auto& result = root->get_value();
		logger.debug() << "FoundValue with offset " << offset_print(result.offset) << std::endl;
		return result;
	}

	template <class SVFG>
	const llvm::Value& ValueAnalyzerImpl<SVFG>::get_nth_arg(const llvm::CallBase& callsite,
	                                                        const unsigned argument_nr) const {
		const auto& use = callsite.getArgOperandUse(argument_nr);
		return safe_deref(use.get());
	}

	template <class SVFG>
	Result ValueAnalyzerImpl<SVFG>::get_argument_value(llvm::CallBase& callsite, graph::CallPath callpath,
	                                                   unsigned argument_nr, graph::SigType hint, PyObject*) {
		if (is_call_to_intrinsic(callsite)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}
		if (callsite.isIndirectCall()) {
			throw ValuesUnknown("Called function is indirect.");
		}

		if (argument_nr >= callsite.arg_size()) {
			throw ValuesUnknown("Argument number is too big.");
		}

		/* retrieve value of arguments */
		llvm::AttributeList attrl = callsite.getAttributes();
		llvm::AttributeSet attrs = attrl.getAttributes(argument_nr + 1);
		const llvm::Value& val = get_nth_arg(callsite, argument_nr);

		logger.debug() << "Analyzing argument " << argument_nr << ": " << pretty_print(val) << std::endl;

		// fast lane, if val is a constant, take it
		FoundValue<SVFG> value;
		if (const llvm::ConstantData* c = llvm::dyn_cast<llvm::ConstantData>(&val)) {
			logger.debug() << "Found constant data: " << pretty_print(*c) << std::endl;
			value = FoundValue<SVFG>{c, std::nullopt, {}, std::nullopt};
		} else {
			const Node<SVFG> v_node = get_vfg_node(val, argument_nr);
			value = do_backward_value_search(v_node, callpath, hint);
		}

		// printing
		if (std::holds_alternative<OSObject>(value.value)) {
			logger.debug() << "Found previous object. ID: " << std::get<OSObject>(value.value) << std::endl;
		} else {
			logger.debug() << "Found value: " << pretty_print(*std::get<const llvm::Value*>(value.value)) << std::endl;
		}

		return Result{std::move(value.value), std::move(value.offset), std::move(attrs), std::move(value.callpath)};
	}

	template <class SVFG>
	const SVF::StoreVFGNode* ValueAnalyzerImpl<SVFG>::find_next_store(const Node<SVFG> start) {
		// we assume that the found value node is a PHINode or similar but flows directly or with some copies into a
		// statement node (the respective store) maybe this needs to be improved some time
		Node<SVFG> current = start;
		// random constant, prevent endless loops, this amount of copies is unlikely
		for (unsigned i = 0; i < 20; ++i) {
			logger.debug() << "Downward search: " << current << std::endl;
			for (auto edge : graph_tool::out_edges_range(current, g)) {
				Node<SVFG> cand = target(edge, g);
				SVF::VFGNode* svf_cand = this->svfg->template get_node_obj<SVFG>(cand);
				if (llvm::isa<SVF::CopyVFGNode>(svf_cand)) {
					current = cand;
					break; // only inner for loop
				}
				if (auto store = llvm::dyn_cast<SVF::StoreVFGNode>(svf_cand)) {
					logger.debug() << "Found store node: " << *store << std::endl;
					return store;
				}
			}
		}
		return nullptr;
	}

	template <class SVFG>
	void ValueAnalyzerImpl<SVFG>::assign_system_object(const llvm::Value* value, OSObject obj_index,
	                                                   const std::vector<const llvm::GetElementPtrInst*>& offsets,
	                                                   const graph::CallPath& callpath) {
		const Node<SVFG> v_node = get_vfg_node(safe_deref(value));

		logger.debug() << "Assign object ID " << obj_index << " to SVFG node: " << v_node;
		if (offsets.size() != 0) {
			logger.debug() << " with offset " << offset_print(offsets);
		}
		logger.debug() << " and callpath " << callpath << "." << std::endl;
		auto num_offsets = convert_to_number_offsets(offsets, graph.get_module());
		if (num_offsets) {
			obj_map.insert(graph::GraphData::ObjMap::value_type(std::make_tuple(v_node, *num_offsets, callpath.hash()),
			                                                    obj_index));
		} else {
			logger.error() << "Cannot calculate get_element_ptr offsets. Do not assign anything." << std::endl;
		}
	}

	template <class SVFG>
	bool ValueAnalyzerImpl<SVFG>::has_connection(llvm::CallBase& callsite, graph::CallPath, unsigned argument_nr,
	                                             OSObject obj_index) {
		if (is_call_to_intrinsic(callsite)) {
			throw ConnectionStatusUnknown("Called function is an intrinsic.");
		}
		if (callsite.isIndirectCall()) {
			throw ConnectionStatusUnknown("Called function is indirect.");
		}

		if (argument_nr >= callsite.arg_size()) {
			throw ConnectionStatusUnknown("Argument number is too big.");
		}

		/* check whether we have a node stored for the system object */
		auto it = obj_map.right.find(obj_index);
		if (it == obj_map.right.end()) {
			/* we cannot rule out a connection */
			throw ConnectionStatusUnknown("Object has no corresponding node in SVFG.");
		}
		auto id = it->second;
		// TODO handle offset and callpath

		/* retrieve SVFG node for system object */
		const Node<SVFG> obj_node = static_cast<Node<SVFG>>(std::get<0>(id));

		/* retrieve SVFG node for input triple */
		const llvm::Value& val = get_nth_arg(callsite, argument_nr);
		const Node<SVFG> input_node = get_vfg_node(val);

		logger.debug() << "Find connection between " << input_node << " and " << obj_node << std::endl;

		std::set<Node<SVFG>> visited;
		std::stack<Node<SVFG>> node_stack;

		/* starting the search from the object node makes the search terminate quickly in many cases */
		auto starting_node = obj_node;
		auto target_node = input_node;
		visited.emplace(starting_node);
		node_stack.push(starting_node);
		if (starting_node == target_node) {
			// This should not happen?!
			logger.warn() << "Asked for connection between identical nodes." << std::endl;
			return true;
		}

		/* do a DFS, storing the path in 'node_stack' and marking nodes by adding them to the 'visited' set */
		while (!node_stack.empty()) {
			auto current_node = node_stack.top();
			node_stack.pop();

			for (auto edge : graph_tool::out_edges_range(current_node, g)) {
				auto node = target(edge, g);
				SVF::VFGNode* svf_node = this->svfg->template get_node_obj<SVFG>(node);
				if (visited.find(node) == visited.end()) {
					if (llvm::isa<SVF::MRSVFGNode>(svf_node))
						continue; // helps constructed example
					if (llvm::isa<SVF::NullPtrVFGNode>(svf_node))
						continue; // helps gpslogger
					if (node == target_node) {
						logger.debug() << "Found connection after visiting " << visited.size() << " nodes."
						               << std::endl;
						return true;
					}
					visited.emplace(node);
					node_stack.push(node);
				}
			}
			for (auto edge : graph_tool::in_edges_range(current_node, g)) {
				auto node = source(edge, g);
				SVF::VFGNode* svf_node = this->svfg->template get_node_obj<SVFG>(node);
				if (visited.find(node) == visited.end()) {
					if (llvm::isa<SVF::MRSVFGNode>(svf_node))
						continue;
					if (llvm::isa<SVF::NullPtrVFGNode>(svf_node))
						continue;
					if (node == target_node) {
						logger.debug() << "Found connection after visiting " << visited.size() << " nodes."
						               << std::endl;
						return true;
					}
					visited.emplace(node);
					node_stack.push(node);
				}
			}
		}
		logger.debug() << "No connection after visiting " << visited.size() << " nodes." << std::endl;

		return false;
	}

	PyObject* ValueAnalyzer::py_repack_raw_value(const RawValue& value) const {
		if (std::holds_alternative<OSObject>(value)) {
			static_assert(std::is_same<uint64_t, OSObject>::value);
			uint64_t raw_index = std::get<OSObject>(value);
			PyObject* obj_index = PyLong_FromUnsignedLongLong(raw_index);
			assert(PyLong_AsUnsignedLongLong(obj_index) == raw_index && "Python long conversion failed");
			return obj_index;
		} else {
			// it would be nice to return a const value here, however const correctness and Python are not compatible
			return get_obj_from_value(safe_deref(const_cast<llvm::Value*>(std::get<const llvm::Value*>(value))));
		}
	}

	PyObject* ValueAnalyzer::py_repack_offsets(const std::vector<const llvm::GetElementPtrInst*>& offsets) const {
		PyObject* py_offsets = PyTuple_New(offsets.size());
		for (const auto& indexed_gep : offsets | boost::adaptors::indexed()) {
			// it would be nice to return a const gep here, however const correctness and Python are not compatible
			PyObject* py_gep =
			    get_obj_from_value(safe_deref(const_cast<llvm::GetElementPtrInst*>(indexed_gep.value())));
			PyTuple_SET_ITEM(py_offsets, indexed_gep.index(), py_gep);
		}
		return py_offsets;
	}

	template <class SVFG>
	const llvm::Value* ValueAnalyzerImpl<SVFG>::get_llvm_return(const llvm::CallBase& callsite) const {
		for (const auto user : callsite.users()) {
			if (const auto store = llvm::dyn_cast<llvm::StoreInst>(user)) {
				return store->getPointerOperand();
			}
		}
		// fallback, if no store is found
		return &callsite;
	}

	template <class SVFG>
	const llvm::Value* ValueAnalyzerImpl<SVFG>::get_return_value(const llvm::CallBase& callsite, graph::CallPath) {
		if (callsite.getFunctionType()->getReturnType()->isVoidTy()) {
			fail("Cannot get return value of void function.");
		}
		logger.debug() << "Get return value of " << callsite << std::endl;
		const Node<SVFG> node = get_vfg_node(callsite);

		auto store = find_next_store(node);
		if (store != nullptr) {
			logger.debug() << "GRV " << *store->getPAGEdge() << std::endl;
			return store->getInst()->getLLVMInstruction();
		}
		// fallback
		logger.warn() << "Did not find a storage node in the SVFG. Falling back to plain LLVM search." << std::endl;
		return get_llvm_return(callsite);
	}

	template <class SVFG>
	Result ValueAnalyzerImpl<SVFG>::get_memory_value(const llvm::Value* intermediate_value, graph::CallPath callpath) {
		const Node<SVFG> v_node = get_vfg_node(safe_deref(intermediate_value));
		FoundValue<SVFG> result = do_backward_value_search(v_node, callpath, graph::SigType::symbol);
		return Result{result.value, result.offset, std::nullopt, result.callpath};
	}

	PyObject* ValueAnalyzer::py_get_memory_value(const llvm::Value* intermediate_value, graph::CallPath callgraph) {
		PyObject* res;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    ValueAnalyzerImpl impl{g, graph, tracer, logger, svfg, svf_objects};
			    res = py_repack(impl.get_memory_value(intermediate_value, callgraph));
		    },
		    graph_tool::always_directed())(svfg->graph.get_graph_view());
		tracer.clear();
		return res;
	}

	template <class SVFG>
	std::vector<std::pair<const llvm::Value*, graph::CallPath>> ValueAnalyzerImpl<SVFG>::get_assignments(
	    const llvm::Value* value, const std::vector<const llvm::GetElementPtrInst*>& gep, graph::CallPath callpath) {
		const Node<SVFG> start_node = get_vfg_node(safe_deref(value));
		std::stack<std::pair<const Node<SVFG>, graph::CallPath>> nodes;
		nodes.emplace(std::make_pair(start_node, callpath));
		std::vector<std::pair<const llvm::Value*, graph::CallPath>> stores;
		auto gep_iter = gep.rbegin();
		while (nodes.size() != 0) {
			auto [node, path] = nodes.top();
			nodes.pop();

			SVF::VFGNode* svf_node = this->svfg->template get_node_obj<SVFG>(node);

			// termination condition
			if (auto gep_node = llvm::dyn_cast<SVF::GepVFGNode>(svf_node)) {
				const llvm::GetElementPtrInst* gep_inst =
				    llvm::cast<llvm::GetElementPtrInst>(gep_node->getPAGEdge()->getValue());
				if (get_offset(gep_inst, graph.get_module()) != get_offset(*(gep_iter++), graph.get_module())) {
					// not fitting, quit this path
					continue;
				}
			}
			if (auto gep_node = llvm::dyn_cast<SVF::StoreVFGNode>(svf_node)) {
				const llvm::Value* val = gep_node->getPAGEdge()->getValue();
				stores.emplace_back(std::make_pair(val, path));
			}

			// next step
			for (auto edge : graph_tool::out_edges_range(node, g)) {
				SVF::VFGEdge* svf_edge = this->svfg->template get_edge_obj<SVFG>(edge);
				if (llvm::isa<SVF::CallDirSVFGEdge>(svf_edge) || llvm::isa<SVF::CallIndSVFGEdge>(svf_edge)) {
					path.add_call_site(callgraph, safe_deref(get_callsite(svf_edge, svf_objects.s_callgraph)));
				}
				nodes.emplace(std::make_pair(target(edge, g), path));
			}
		}

		return stores;
	}

	PyObject* ValueAnalyzer::py_get_assignments(const llvm::Value* value,
	                                            const std::vector<const llvm::GetElementPtrInst*>& gep,
	                                            graph::CallPath callpath) {
		std::vector<std::pair<const llvm::Value*, graph::CallPath>> values;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    ValueAnalyzerImpl impl{g, graph, tracer, logger, svfg, svf_objects};
			    values = impl.get_assignments(value, gep, callpath);
		    },
		    graph_tool::always_directed())(svfg->graph.get_graph_view());

		PyObject* py_values = PyTuple_New(values.size());
		for (const auto& indexed_val : values | boost::adaptors::indexed()) {
			const auto& [val, callpath] = indexed_val.value();
			PyObject* py_val = get_obj_from_value(safe_deref(const_cast<llvm::Value*>(val)));
			PyObject* py_callpath = callpath.get_python_obj();
			PyObject* py_context_val = PyTuple_Pack(2, py_val, py_callpath);
			PyTuple_SET_ITEM(py_values, indexed_val.index(), py_context_val);
		}
		tracer.clear();
		return py_values;
	}

	PyObject* ValueAnalyzer::py_repack(Result&& result) const {
		PyObject* py_callpath = (result.callpath) ? result.callpath->get_python_obj() : Py_None;
		PyObject* py_attrs = (result.attrs) ? get_obj_from_attr_set(*result.attrs) : Py_None;
		return PyTuple_Pack(4, py_repack_raw_value(result.value), py_repack_offsets(result.offset), py_attrs,
		                    py_callpath);
	}

	PyObject* ValueAnalyzer::py_get_argument_value(PyObject* callsite, graph::CallPath callpath, unsigned argument_nr,
	                                               int hint, PyObject* type) {

		llvm::CallBase* ll_callsite;
		graph_tool::gt_dispatch<>()([&](auto& g) { get_llvm_callsite(g, &ll_callsite, callsite); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		PyObject* res;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    ValueAnalyzerImpl impl{g, graph, tracer, logger, svfg, svf_objects};
			    res = py_repack(impl.get_argument_value(safe_deref(ll_callsite), callpath, argument_nr,
			                                            static_cast<graph::SigType>(hint), type));
		    },
		    graph_tool::always_directed())(svfg->graph.get_graph_view());

		tracer.clear();
		return res;
	}

	PyObject* ValueAnalyzer::py_get_return_value(PyObject* callsite, graph::CallPath callpath) {
		llvm::CallBase* ll_callsite;
		graph_tool::gt_dispatch<>()([&](auto& g) { get_llvm_callsite(g, &ll_callsite, callsite); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		PyObject* res;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    ValueAnalyzerImpl impl{g, graph, tracer, logger, svfg, svf_objects};
			    res = get_obj_from_value(
			        safe_deref(const_cast<llvm::Value*>(impl.get_return_value(safe_deref(ll_callsite), callpath))));
		    },
		    graph_tool::always_directed())(svfg->graph.get_graph_view());
		tracer.clear();
		return res;
	}

	void ValueAnalyzer::py_assign_system_object(const llvm::Value* value, OSObject obj_index,
	                                            const std::vector<const llvm::GetElementPtrInst*>& offsets,
	                                            const graph::CallPath& callpath) {
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    ValueAnalyzerImpl impl{g, graph, tracer, logger, svfg, svf_objects};
			    impl.assign_system_object(value, obj_index, offsets, callpath);
		    },
		    graph_tool::always_directed())(svfg->graph.get_graph_view());
		tracer.clear();
	}

	bool ValueAnalyzer::py_has_connection(PyObject* callsite, graph::CallPath callpath, unsigned argument_nr,
	                                      OSObject obj_index) {
		llvm::CallBase* ll_callsite;
		graph_tool::gt_dispatch<>()([&](auto& g) { get_llvm_callsite(g, &ll_callsite, callsite); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		bool ret;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    ValueAnalyzerImpl impl{g, graph, tracer, logger, svfg, svf_objects};
			    ret = impl.has_connection(safe_deref(ll_callsite), callpath, argument_nr, obj_index);
		    },
		    graph_tool::always_directed())(svfg->graph.get_graph_view());
		tracer.clear();
		return ret;
	}

	llvm::GlobalValue* ValueAnalyzer::find_global(const std::string& name) {
		llvm::Module& mod = graph.get_module();
		return mod.getNamedValue(name);
	}

	PyObject* ValueAnalyzer::py_find_global(const std::string& name) {
		auto global = find_global(name);
		if (global == nullptr) {
			return Py_None;
		}
		return get_obj_from_value(*global);
	}

} // namespace ara::step
