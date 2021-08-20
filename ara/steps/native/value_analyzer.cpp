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
		std::optional<int64_t> get_offset(const llvm::GetElementPtrInst* gep) {
			assert(gep != nullptr && "GEP is null");
			const auto layout = gep->getModule()->getDataLayout();
			llvm::APInt ap_offset(layout.getIndexSizeInBits(gep->getPointerAddressSpace()), 0, true);
			bool success = gep->accumulateConstantOffset(layout, ap_offset);
			if (!success) {
				return std::nullopt;
			}
			return ap_offset.getSExtValue();
		}

		std::optional<std::vector<int64_t>>
		convert_to_number_offsets(const std::vector<const llvm::GetElementPtrInst*>& offsets) {
			std::vector<int64_t> number_offsets;
			for (const auto& gep : offsets) {
				auto number = get_offset(gep);
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
			const SVF::CallBlockNode* cbn = callgraph->getCallSite(*id);
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

	Traverser::Traverser(Traverser* boss, const SVF::VFGEdge* edge, graph::CallPath call_path, Bookkeeping& caretaker)
	    : boss(boss), call_path(call_path), caretaker(caretaker), id(caretaker.get_new_id()) {
		trace.emplace_back(edge);
	}

	void Traverser::remove(size_t traverser_id) {
		workers.erase(traverser_id);
		// keep going
		act_if_necessary();
	}

	void Traverser::die() {
		dbg() << "change status: dead" << std::endl;
		status = Status::dead;
	}

	void Traverser::die_and_notify() {
		die();
		boss->remove(get_id());
	}

	void Traverser::sleep() {
		dbg() << "change status: sleeping" << std::endl;
		status = Status::sleeping;
	}

	void Traverser::wakeup() {
		dbg() << "change status: active" << std::endl;
		status = Status::active;
	}

	void Traverser::do_step() {
		const auto current_edge = trace.back();
		if (!skip_first_edge) {
			dbg() << "Analyzing edge " << *current_edge << std::endl;
			if (eval_result(handle_edge(current_edge))) {
				return;
			}
			skip_first_edge = false;
		}

		const SVF::VFGNode* current_node = current_edge->getSrcNode();
		dbg() << "Analyzing node " << *current_node << std::endl;
		if (die_at_visited && caretaker.is_visited(current_node)) {
			die_and_notify();
			return;
		}
		caretaker.mark_visited(current_node);

		if (eval_result(handle_node(current_node))) {
			return;
		}

		eval_result(advance(current_node));
	}

	const SVF::PTACallGraphEdge* Traverser::t_get_callsite(const SVF::VFGEdge* edge) const {
		return get_callsite(edge, caretaker.get_svf_call_graph());
	}

	std::pair<Traverser::CPA, const SVF::PTACallGraphEdge*>
	Traverser::evaluate_callpath(const SVF::VFGEdge* edge, const graph::CallPath& cpath) const {
		bool is_call =
		    edge != nullptr && (llvm::isa<SVF::CallDirSVFGEdge>(edge) || llvm::isa<SVF::CallIndSVFGEdge>(edge));
		bool is_ret = edge != nullptr && (llvm::isa<SVF::RetDirSVFGEdge>(edge) || llvm::isa<SVF::RetIndSVFGEdge>(edge));

		const SVF::PTACallGraphEdge* cg_edge = t_get_callsite(edge);
		if (cg_edge == nullptr) {
			return std::make_pair(Traverser::CPA::keep, cg_edge);
		}
		if (cpath.size() == 0) {
			if (is_ret) {
				return std::make_pair(Traverser::CPA::add, cg_edge);
			} else {
				// actually, this cannot not happen, if the call path begins at a root node such as main()
				// if this happens anyway, it is wanted by the user of the ValueAnlyzer
				// in this case we just ignore the call path
				return std::make_pair(Traverser::CPA::keep, cg_edge);
			}
		}

		const SVF::PTACallGraphEdge* current = cpath.svf_at(cpath.size() - 1);
		if (is_call && *cg_edge == current) {
			return std::make_pair(Traverser::CPA::drop, cg_edge);
		}

		if (is_ret) {
			const auto* node = current->getDstNode();
			for (const SVF::PTACallGraphEdge* out_edge :
			     boost::make_iterator_range(node->OutEdgeBegin(), node->OutEdgeEnd())) {
				if (*cg_edge == out_edge) {
					dbg() << "Found valid return edge. Go a level further down..." << std::endl;
					return std::make_pair(Traverser::CPA::add, cg_edge);
				}
			}
		}
		return std::make_pair(Traverser::CPA::false_path, cg_edge);
	}

	void Traverser::update_call_path(const Traverser::CPA action, const SVF::PTACallGraphEdge* edge) {
		switch (action) {
		case Traverser::CPA::drop:
			call_path.pop_back();
			return;
		case Traverser::CPA::add:
			call_path.add_call_site(caretaker.get_call_graph(), safe_deref(edge));
			return;
		case Traverser::CPA::keep:
			// do nothing
			return;
		case Traverser::CPA::false_path:
			assert(false && "cannot handle false_path");
			return;
		}
	}

	Result Traverser::advance(const SVF::VFGNode* node, bool only_delegate) {
		// go into the direction of the first edge yourself or delegate
		bool first = !only_delegate;

		auto new_boss = (only_delegate) ? this : this->boss;

		// make a copy since we can change this->call_path in the first iteration
		graph::CallPath cp = call_path;
		unsigned spawned_traversers = 0;
		for (const SVF::VFGEdge* edge : boost::make_iterator_range(node->InEdgeBegin(), node->InEdgeEnd())) {
			dbg() << "Eval Callpath: " << cp << " | " << *edge << std::endl;
			auto [action, cg_edge] = evaluate_callpath(edge, cp);
			if (action == Traverser::CPA::false_path) {
				dbg() << "False path: " << *edge << std::endl;
				continue;
			}

			++spawned_traversers;
			if (first) {
				dbg() << "Advance: self, go to " << *edge << std::endl;
				this->trace.emplace_back(edge);
				update_call_path(action, cg_edge);
				first = false;
				continue;
			}
			auto worker = make_shared<Traverser>(new_boss, edge, cp, caretaker);
			dbg() << "COPY: Src: " << offset_print(offset) << " Dst: " << offset_print(worker->offset) << std::endl;
			worker->offset = offset;
			dbg() << "COPY: Src: " << offset_print(offset) << " Dst: " << offset_print(worker->offset) << std::endl;
			worker->level = level;
			worker->update_call_path(action, cg_edge);
			new_boss->hire(worker);
			dbg() << "Advance: new " << *worker << std::endl;
			this->caretaker.add_traverser(worker);
		}
		if (spawned_traversers == 0) {
			dbg() << "Advance: No further path. Die." << std::endl;
			return Die();
		}
		return KeepGoing();
	}

	void Traverser::sleep_and_send(Report&& report) {
		sleep();
		boss->send_report(std::move(report));
	}

	bool Traverser::eval_result(Result&& result) {
		bool ret = false;
		std::visit(overloaded{[&](Finished f) {
			                      dbg() << "Finished: Send report" << std::endl;
			                      sleep_and_send(std::move(f.report));
			                      ret = true;
		                      },
		                      [&](Wait w) {
			                      dbg() << "Waiting for reason " << w.reason << std::endl;
			                      reason = w.reason;
			                      sleep();
			                      ret = true;
		                      },
		                      [&](KeepGoing) { ret = false; },
		                      [&](Die) {
			                      die_and_notify();
			                      ret = true;
		                      }},
		           result);
		return ret;
	}

	Result Traverser::handle_edge(const SVF::VFGEdge* edge) {
		auto hint = caretaker.get_hint();
		auto good_edge = [&]() {
			if (hint == graph::SigType::symbol) {
				return llvm::isa<SVF::CallDirSVFGEdge>(edge);
			} else {
				return llvm::isa<SVF::CallDirSVFGEdge>(edge) || llvm::isa<SVF::CallIndSVFGEdge>(edge);
			}
		};
		if (good_edge()) {
			const SVF::PTACallGraphEdge* cg_edge = t_get_callsite(edge);
			if (cg_edge && call_path.size() > 0 && *cg_edge == call_path.svf_at(call_path.size() - 1)) {
				dbg() << "Found call edge further down. This could not be. Die: " << *edge << std::endl;
				return Die();
			} else {
				dbg() << "Found call edge up, waiting for other nodes: " << *edge << std::endl;
				level++;
				return Finished{EndOfFunction()};
			}
		}
		if (hint == graph::SigType::symbol && llvm::isa<SVF::CallIndSVFGEdge>(edge)) {
			dbg() << "Found indirect call edge up, while searching for symbols, die: " << *edge << std::endl;
			return Die();
		}

		return KeepGoing();
	}

	Result Traverser::handle_node(const SVF::VFGNode* node) {
		dbg() << "Handle node: " << *node << std::endl;
		auto id = caretaker.get_obj_id(node->getId(), offset);
		if (id) {
			dbg() << "Found a previous assigned object." << std::endl;
			dbg() << "CallPath: " << call_path << std::endl;
			dbg() << "Asked for: " << node->getId() << " " << offset_print(offset) << std::endl;
			return Finished{FoundValue{*id, node, {}}};
		}
		if (llvm::isa<SVF::NullPtrVFGNode>(node)) {
			// Sigtype is not important here, a nullptr serves as value and symbol.
			dbg() << "Found a nullptr." << std::endl;
			auto nullval = llvm::ConstantPointerNull::get(
			    llvm::PointerType::get(llvm::IntegerType::get(caretaker.get_module().getContext(), 8), 0));
			return Finished{FoundValue{nullval, node, offset}};
		}

		if (auto stmt = llvm::dyn_cast<SVF::StmtVFGNode>(node)) {
			const llvm::Value* val = stmt->getPAGEdge()->getValue();
			auto hint = caretaker.get_hint();

			if (const llvm::GetElementPtrInst* i = llvm::dyn_cast<llvm::GetElementPtrInst>(val)) {
				dbg() << "Found GetElementPtrInst: " << pretty_print(*i) << std::endl;
				offset.emplace_back(i);
				dbg() << "New offset: " << offset_print(offset) << std::endl;
			}

			if (hint == graph::SigType::value || hint == graph::SigType::undefined) {
				if (const llvm::ConstantData* c = llvm::dyn_cast<llvm::ConstantData>(val)) {
					dbg() << "Found constant data: " << pretty_print(*c) << std::endl;
					return Finished{FoundValue{c, node, offset}};
				}

				if (const llvm::Function* func = llvm::dyn_cast<llvm::Function>(val)) {
					dbg() << "Found function: " << pretty_print(*func) << std::endl;
					return Finished{FoundValue{func, node, offset}};
				}

				if (const llvm::GlobalVariable* gv = llvm::dyn_cast<llvm::GlobalVariable>(val)) {
					if (gv->hasExternalLinkage()) {
						dbg() << "Found global external constant: " << pretty_print(*gv) << std::endl;
						return Finished{FoundValue{gv, node, offset}};
					} else if (gv->getNumOperands() > 0) { // TODO consider using offset
						// special handling for strings, they are pointer to constant data
						const llvm::Value* gvv = gv->getOperand(0);
						if (gvv != nullptr) {
							if (const llvm::ConstantData* gvvc = llvm::dyn_cast<llvm::ConstantData>(gvv)) {
								dbg() << "Found global constant data: " << pretty_print(*gvvc) << std::endl;
								return Finished{FoundValue{gvvc, node, {}}};
							}
						}
					}
				}
			}

			if (hint == graph::SigType::symbol) {
				if (const llvm::GlobalValue* gv = llvm::dyn_cast<llvm::GlobalValue>(val)) {
					dbg() << "Found global value: " << pretty_print(*gv) << std::endl;
					return Finished{FoundValue{gv, node, offset}};
				}

				if (const llvm::AllocaInst* ai = llvm::dyn_cast<llvm::AllocaInst>(val)) {
					dbg() << "Found alloca instruction (local variable): " << pretty_print(*ai) << std::endl;
					return Finished{FoundValue{ai, node, offset}};
				}
			}
		}
		if (llvm::isa<SVF::PHIVFGNode>(node)) {
			dbg() << "Found PHIVFGNode, spawn subtraversers: " << *node << std::endl;
			auto result = advance(node, /* only_delegate= */ true);
			if (std::holds_alternative<Die>(result)) {
				return result;
			}
			return Wait{WaitingReason::in_phi};
		}
		return KeepGoing();
	}

	void Traverser::act_if_necessary() {
		// output
		dbg() << "Worker has changed something, check if action is required." << std::endl;
		dbg() << "Current workers:" << std::endl;
		for (auto worker : workers | boost::adaptors::map_values) {
			dbg() << "Worker: " << *worker << std::endl;
		}
		// check
		if (workers.size() == 0) {
			die_and_notify();
			return;
		}
		if (std::all_of(workers.begin(), workers.end(), [](auto w) {
			    return w.second->get_status() == Status::sleeping && w.second->reason != WaitingReason::in_phi;
		    })) {
			dbg() << "Got all reports. Acting..." << std::endl;
			handle_reports();
		} else {
			dbg() << "No action required." << std::endl;
		}
	}

	void Traverser::send_report(Report&& report) {
		reports.emplace_back(report);
		act_if_necessary();
	}

	void Traverser::handle_found_value(FoundValue&& report) { sleep_and_send(report); }

	void Traverser::cleanup_workers() {
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

	void Traverser::hire(std::shared_ptr<Traverser> worker) {
		workers[worker->get_id()] = worker;
		worker->boss = this;
	}

	FoundValue Traverser::get_best_find(std::vector<Report>&& finds) const {
		// current heuristic: if a previous assigned instance is found, take that, otherwise the first one
		auto found_instance = [](Report& r) { return std::holds_alternative<OSObject>(std::get<FoundValue>(r).value); };
		auto it = std::find_if(finds.begin(), finds.end(), found_instance);
		if (it != finds.end()) {
			return std::get<FoundValue>(std::move(*it));
		}
		return std::get<FoundValue>(std::move(finds[0]));
	}

	void Traverser::handle_reports() {
		auto found_value = [](Report& r) { return std::holds_alternative<FoundValue>(r); };

		auto it = std::find_if(reports.begin(), reports.end(), found_value);
		if (it != reports.end()) {
			std::vector<Report> finds;
			std::copy_if(reports.begin(), reports.end(), std::back_inserter(finds), found_value);
			if (finds.size() > 1 && reason == WaitingReason::in_phi) {
				// TODO we must not have two Found Values otherwise we are not able to handle it
				dbg() << "PHINode with multiple value nodes is not supported." << std::endl;
				throw ValuesUnknown("PHINode with multiple value nodes is not supported.");
			}
			dbg() << "Worker found a value, forwarding..." << std::endl;
			auto report = get_best_find(std::move(finds));

			std::for_each(workers.begin(), workers.end(), [](auto w) { w.second->die(); });
			workers.clear();
			reports.clear();
			reason = WaitingReason::not_set;
			handle_found_value(std::move(report));
			return;
		}
		if (std::all_of(reports.begin(), reports.end(),
		                [](Report& r) { return std::holds_alternative<EndOfFunction>(r); })) {
			if (workers.size() == 1 && reason == WaitingReason::in_phi && boss != this) {
				// currently waiting in phi node and we have only one subtraverser
				// We can savely ignore the phi in this case. Pass the traverser to our boss.
				auto worker = workers.begin()->second;
				boss->hire(worker);
				workers.clear();
				assert(reports.size() == 1 && "workers and reports size must match here");
				// we have no job anymore, just die()
				dbg() << "Found PHI with one possible continuation. Continue with T" << worker->get_id() << " (boss=T"
				      << boss->get_id() << "). Removing ourself." << std::endl;
				auto report = std::move(*reports.begin());
				reports.clear();
				boss->send_report(std::move(report));
				die_and_notify();
			} else {
				auto travs = choose_best_next_traversers();
				dbg() << "All subordinates reached end of current call level." << std::endl;
				reports.clear();
				for (auto t : travs) {
					dbg() << "Continue with: " << t->get_id() << std::endl;
					t->wakeup();
					t->skip_first_edge = true;
				}
			}
		}
	}

	std::vector<shared_ptr<Traverser>> Traverser::choose_best_next_traversers() {
		std::vector<shared_ptr<Traverser>> indirects;
		std::vector<shared_ptr<Traverser>> directs;
		for (auto worker : workers | boost::adaptors::map_values) {
			if (llvm::isa<SVF::CallIndSVFGEdge>(worker->trace.back())) {
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

	Logger::LogStream& Traverser::dbg() const {
		auto& ls = caretaker.get_logger().debug();
		ls << std::string(level, ' ');
		ls << 'T' << id << " (" << call_path.size() << "): ";
		return ls;
	}

	std::ostream& operator<<(std::ostream& os, const Traverser& t) {
		os << "Traverser(";
		os << "id=" << t.get_id();
		os << ", boss=" << t.boss->get_id();
		auto& edge = t.trace.back();
		os << ", edge=" << edge->getSrcNode()->getId() << "->" << edge->getDstNode()->getId();
		os << ", status=" << t.status;
		if (t.reason != WaitingReason::not_set) {
			os << ", reason=" << t.reason;
		}
		os << ")";
		return os;
	}

	void Manager::act_if_necessary() {
		if (workers.size() == 0) {
			caretaker.get_logger().warn() << "Manager:: Did not found a valid value." << std::endl;
			throw ValuesUnknown("Manager: Did not found a valid value.");
		}
		Traverser::act_if_necessary();
	}

	bool Manager::eval_node_result(Result&& result) {
		bool ret = false;
		std::visit(overloaded{[&](Finished f) {
			                      this->value = std::move(std::get<FoundValue>(f.report));
			                      this->caretaker.stop();
			                      ret = true;
		                      },
		                      [&](Wait w) {
			                      reason = w.reason;
			                      sleep();
			                      ret = true;
		                      },
		                      [&](KeepGoing) { ret = false; },
		                      [&](Die) {
			                      die_and_notify();
			                      ret = true;
		                      }},
		           result);
		return ret;
	}

	void Manager::do_step() {
		dbg() << "Manager: search current node" << std::endl;
		if (eval_node_result(handle_node(node))) {
			return;
		}
		caretaker.mark_visited(node);

		dbg() << "Manager: delegate" << std::endl;
		Result result = advance(node, /* only_delegate= */ true);
		if (std::holds_alternative<Die>(result)) {
			throw ValuesUnknown("Start node has no incoming flows.");
		}
		sleep();
	}

	void Manager::handle_found_value(FoundValue&& report) {
		value = report;
		sleep();
		caretaker.stop();
	}

	const FoundValue Manager::get_value() {
		assert(value && "no value");
		return *value;
	}

	void Bookkeeping::run() {
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

	llvm::Module& Bookkeeping::get_module() const { return va.graph.get_module(); }

	Logger& Bookkeeping::get_logger() const { return va.logger; }

	std::optional<OSObject> Bookkeeping::get_obj_id(const SVF::NodeID id,
	                                                const std::vector<const llvm::GetElementPtrInst*>& offset) const {
		auto num_offsets = convert_to_number_offsets(offset);
		if (!num_offsets) {
			return std::nullopt;
		}
		auto it = va.obj_map.left.find(std::make_pair(id, *num_offsets));
		if (it != va.obj_map.left.end()) {
			return it->second;
		}
		return std::nullopt;
	}

	void ValueAnalyzer::fail(const char* msg) {
		logger.error() << "ERROR: " << msg << std::endl;
		throw ValuesUnknown(msg);
	}

	const SVF::VFGNode* ValueAnalyzer::get_vfg_node(const SVF::SVFG& vfg, const llvm::Value& start, int argument_nr) {
		logger.debug() << "get_vfg_node: " << start << std::endl;
		auto nodes = vfg.fromValue(&start);
		if (nodes.size() == 0) {
			throw ValuesUnknown("Cannot go back from llvm::Value to an SVF node");
		}
		if (nodes.size() == 1) {
			return *nodes.begin();
		}
		// more than one node, map back with a heuristic
		for (const SVF::SVFGNode* node : nodes) {
			if (argument_nr >= 0) {
				// we are searching an argument, the next node has to be a FormalParmPHI
				for (const SVF::VFGEdge* edge : boost::make_iterator_range(node->OutEdgeBegin(), node->OutEdgeEnd())) {
					SVF::VFGNode* cand = edge->getDstNode();
					logger.debug() << "cand: " << *cand << std::endl;
					if (auto phi = llvm::dyn_cast<SVF::InterPHIVFGNode>(cand)) {
						logger.debug() << "PHINode: " << *phi << std::endl;
						if (phi->isFormalParmPHI()) {
							if (auto arg = llvm::dyn_cast<llvm::Argument>(phi->getValue())) {
								logger.debug()
								    << "arg: " << *arg << " " << arg->getArgNo() << " " << argument_nr << std::endl;
								if (arg->getArgNo() == argument_nr) {
									logger.error() << "Found correct node" << std::endl;
									assert(false);
								}
							}
						}
					}
				}
			}

			if (llvm::isa<SVF::NullPtrVFGNode>(node)) {
				return node;
			}
			logger.debug() << "Got node: " << *node << std::endl;
		}
		assert(false && "This must not happen. Update the above for loop.");
	}

	FoundValue ValueAnalyzer::do_backward_value_search(const SVF::VFGNode* start, graph::CallPath callpath,
	                                                   graph::SigType hint) {
		Bookkeeping caretaker(*this, callgraph, s_callgraph, hint);
		shared_ptr<Manager> root = std::make_shared<Manager>(start, callpath, caretaker);
		caretaker.add_traverser(root);

		caretaker.run();
		auto& result = root->get_value();
		logger.debug() << "FoundValue with offset " << offset_print(result.offset) << std::endl;
		return result;
	}

	const llvm::Value& ValueAnalyzer::get_nth_arg(const llvm::CallBase& callsite, const unsigned argument_nr) const {
		const auto& use = callsite.getArgOperandUse(argument_nr);
		return safe_deref(use.get());
	}

	std::tuple<RawValue, llvm::AttributeSet, const std::vector<const llvm::GetElementPtrInst*>>
	ValueAnalyzer::get_argument_value(llvm::CallBase& callsite, graph::CallPath callpath, unsigned argument_nr,
	                                  graph::SigType hint, PyObject* type) {
		if (is_call_to_intrinsic(callsite)) {
			throw ValuesUnknown("Called function is an intrinsic.");
		}
		if (callsite.isIndirectCall()) {
			throw ValuesUnknown("Called function is indirect.");
		}

		if (argument_nr >= callsite.getNumArgOperands()) {
			throw ValuesUnknown("Argument number is too big.");
		}

		/* retrieve value of arguments */
		llvm::AttributeList attrl = callsite.getAttributes();
		llvm::AttributeSet attrs = attrl.getAttributes(argument_nr + 1);
		const llvm::Value& val = get_nth_arg(callsite, argument_nr);

		logger.debug() << "Analyzing argument " << argument_nr << ": " << pretty_print(val) << std::endl;

		// fast lane, if val is a constant, take it
		FoundValue value;
		if (const llvm::ConstantData* c = llvm::dyn_cast<llvm::ConstantData>(&val)) {
			logger.debug() << "Found constant data: " << pretty_print(*c) << std::endl;
			value = FoundValue{c, nullptr, {}};
		} else {
			const SVF::VFGNode* v_node = get_vfg_node(graph.get_svfg(), val, argument_nr);
			value = do_backward_value_search(v_node, callpath, hint);
		}

		// printing
		if (std::holds_alternative<OSObject>(value.value)) {
			logger.debug() << "Found previous object. ID: " << std::get<OSObject>(value.value) << std::endl;
		} else {
			logger.debug() << "Found value: " << pretty_print(*std::get<const llvm::Value*>(value.value)) << std::endl;
		}

		return std::make_tuple(value.value, std::move(attrs), value.offset);
	}

	const SVF::StoreVFGNode* ValueAnalyzer::find_next_store(const SVF::VFGNode* start) {
		// we assume that the found value node is a PHINode or similar but flows directly or with some copies into a
		// statement node (the respective store) maybe this needs to be improved some time
		const SVF::VFGNode* current = start;
		// random constant, prevent endless loops, this amount of copies is unlikely
		for (unsigned i = 0; i < 20; ++i) {
			logger.debug() << "Downward search: " << *current << std::endl;
			for (const SVF::VFGEdge* edge :
			     boost::make_iterator_range(current->OutEdgeBegin(), current->OutEdgeEnd())) {
				SVF::VFGNode* cand = edge->getDstNode();
				if (llvm::isa<SVF::CopyVFGNode>(cand)) {
					current = cand;
					break; // only inner for loop
				}
				if (auto store = llvm::dyn_cast<SVF::StoreVFGNode>(cand)) {
					logger.debug() << "Found store node: " << *store << std::endl;
					return store;
				}
			}
		}
		return nullptr;
	}

	void ValueAnalyzer::assign_system_object(const llvm::Value* value, OSObject obj_index,
	                                         const std::vector<const llvm::GetElementPtrInst*>& offsets) {
		const SVF::VFGNode* v_node = get_vfg_node(graph.get_svfg(), safe_deref(value));
		SVF::NodeID id = v_node->getId();

		logger.debug() << "Assign object ID " << obj_index << " to SVF node ID: " << id;
		if (offsets.size() != 0) {
			logger.debug() << " with offset " << offset_print(offsets);
		}
		logger.debug() << "." << std::endl;
		auto num_offsets = convert_to_number_offsets(offsets);
		if (num_offsets) {
			obj_map.insert(graph::GraphData::ObjMap::value_type(std::make_pair(id, *num_offsets), obj_index));
		} else {
			logger.error() << "Cannot calculate get_element_ptr offsets. Do not assign anything." << std::endl;
		}
	}

	bool ValueAnalyzer::has_connection(llvm::CallBase& callsite, graph::CallPath callpath, unsigned argument_nr,
	                                   OSObject obj_index) {
		if (is_call_to_intrinsic(callsite)) {
			throw ConnectionStatusUnknown("Called function is an intrinsic.");
		}
		if (callsite.isIndirectCall()) {
			throw ConnectionStatusUnknown("Called function is indirect.");
		}

		if (argument_nr >= callsite.getNumArgOperands()) {
			throw ConnectionStatusUnknown("Argument number is too big.");
		}

		/* check whether we have a node stored for the system object */
		auto it = obj_map.right.find(obj_index);
		if (it == obj_map.right.end()) {
			/* we cannot rule out a connection */
			throw ConnectionStatusUnknown("Object has no corresponding node in SVFG.");
		}
		auto id = it->second;

		/* retrieve SVFG node for system object */
		const SVF::VFGNode* obj_node = graph.get_svfg().getGNode(id);

		/* retrieve SVFG node for input triple */
		const llvm::Value& val = get_nth_arg(callsite, argument_nr);
		const SVF::VFGNode* input_node = get_vfg_node(graph.get_svfg(), val);

		logger.debug() << "Find connection between " << *input_node << " and " << *obj_node << std::endl;

		std::set<const SVF::VFGNode*> visited;
		std::stack<const SVF::VFGNode*> node_stack;

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

			for (const SVF::VFGEdge* edge :
			     boost::make_iterator_range(current_node->OutEdgeBegin(), current_node->OutEdgeEnd())) {
				auto node = edge->getDstNode();
				if (visited.find(node) == visited.end()) {
					if (llvm::isa<SVF::MRSVFGNode>(node))
						continue; // helps constructed example
					if (llvm::isa<SVF::NullPtrVFGNode>(node))
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
			for (const SVF::VFGEdge* edge :
			     boost::make_iterator_range(current_node->InEdgeBegin(), current_node->InEdgeEnd())) {
				auto node = edge->getSrcNode();
				if (visited.find(node) == visited.end()) {
					if (llvm::isa<SVF::MRSVFGNode>(node))
						continue;
					if (llvm::isa<SVF::NullPtrVFGNode>(node))
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

	const llvm::Value* ValueAnalyzer::get_llvm_return(const llvm::CallBase& callsite) const {
		for (const auto user : callsite.users()) {
			if (const auto store = llvm::dyn_cast<llvm::StoreInst>(user)) {
				return store->getPointerOperand();
			}
		}
		// fallback, if no store is found
		return &callsite;
	}

	const llvm::Value* ValueAnalyzer::get_return_value(const llvm::CallBase& callsite, graph::CallPath callpath) {
		if (callsite.getFunctionType()->getReturnType()->isVoidTy()) {
			fail("Cannot get return value of void function.");
		}
		logger.debug() << "Get return value of " << callsite << std::endl;
		const SVF::VFGNode* node = get_vfg_node(graph.get_svfg(), callsite);

		auto store = find_next_store(node);
		if (store != nullptr) {
			logger.debug() << "GRV " << *store->getPAGEdge() << std::endl;
			return store->getInst();
		}
		// fallback
		logger.warn() << "Did not find a storage node in the SVFG. Falling back to plain LLVM search." << std::endl;
		return get_llvm_return(callsite);
	}

	std::pair<RawValue, const std::vector<const llvm::GetElementPtrInst*>>
	ValueAnalyzer::get_memory_value(const llvm::Value* intermediate_value, graph::CallPath callpath) {
		const SVF::VFGNode* v_node = get_vfg_node(graph.get_svfg(), safe_deref(intermediate_value));
		FoundValue mem_val = do_backward_value_search(v_node, callpath, graph::SigType::symbol);
		return make_pair(mem_val.value, mem_val.offset);
	}

	PyObject* ValueAnalyzer::py_get_memory_value(const llvm::Value* intermediate_value, graph::CallPath callgraph) {
		auto [value, offset] = get_memory_value(intermediate_value, callgraph);
		return PyTuple_Pack(2, py_repack_raw_value(value), py_repack_offsets(offset));
	}

	std::vector<std::pair<const llvm::Value*, graph::CallPath>>
	ValueAnalyzer::get_assignments(const llvm::Value* value, const std::vector<const llvm::GetElementPtrInst*>& gep,
	                               graph::CallPath callpath) {
		const SVF::VFGNode* start_node = get_vfg_node(graph.get_svfg(), safe_deref(value));
		std::stack<std::pair<const SVF::VFGNode*, graph::CallPath>> nodes;
		nodes.emplace(std::make_pair(start_node, callpath));
		std::vector<std::pair<const llvm::Value*, graph::CallPath>> stores;
		auto gep_iter = gep.rbegin();
		while (nodes.size() != 0) {
			auto [node, path] = nodes.top();
			nodes.pop();

			// termination condition
			if (auto gep_node = llvm::dyn_cast<SVF::GepVFGNode>(node)) {
				const llvm::GetElementPtrInst* gep_inst =
				    llvm::cast<llvm::GetElementPtrInst>(gep_node->getPAGEdge()->getValue());
				if (get_offset(gep_inst) != get_offset(*(gep_iter++))) {
					// not fitting, quit this path
					continue;
				}
			}
			if (auto gep_node = llvm::dyn_cast<SVF::StoreVFGNode>(node)) {
				const llvm::Value* val = gep_node->getPAGEdge()->getValue();
				stores.emplace_back(std::make_pair(val, path));
			}

			// next step
			for (const SVF::VFGEdge* edge : boost::make_iterator_range(node->OutEdgeBegin(), node->OutEdgeEnd())) {
				if (llvm::isa<SVF::CallDirSVFGEdge>(edge) || llvm::isa<SVF::CallIndSVFGEdge>(edge)) {
					path.add_call_site(callgraph, safe_deref(get_callsite(edge, s_callgraph)));
				}
				nodes.emplace(std::make_pair(edge->getDstNode(), path));
			}
		}

		return stores;
	}

	PyObject* ValueAnalyzer::py_get_assignments(const llvm::Value* value,
	                                            const std::vector<const llvm::GetElementPtrInst*>& gep,
	                                            graph::CallPath callpath) {
		auto values = get_assignments(value, gep, callpath);
		PyObject* py_values = PyTuple_New(values.size());
		for (const auto& indexed_val : values | boost::adaptors::indexed()) {
			const auto& [val, callpath] = indexed_val.value();
			PyObject* py_val = get_obj_from_value(safe_deref(const_cast<llvm::Value*>(val)));
			PyObject* py_callpath = callpath.get_python_obj();
			PyObject* py_context_val = PyTuple_Pack(2, py_val, py_callpath);
			PyTuple_SET_ITEM(py_values, indexed_val.index(), py_context_val);
		}
		return py_values;
	}

	PyObject* ValueAnalyzer::py_get_argument_value(PyObject* callsite, graph::CallPath callpath, unsigned argument_nr,
	                                               int hint, PyObject* type) {
		llvm::CallBase* ll_callsite;
		graph_tool::gt_dispatch<>()([&](auto& g) { get_llvm_callsite(g, &ll_callsite, callsite); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		auto [value, attrs, offset] =
		    get_argument_value(safe_deref(ll_callsite), callpath, argument_nr, static_cast<graph::SigType>(hint), type);
		return PyTuple_Pack(3, py_repack_raw_value(value), get_obj_from_attr_set(attrs), py_repack_offsets(offset));
	}

	PyObject* ValueAnalyzer::py_get_return_value(PyObject* callsite, graph::CallPath callpath) {
		llvm::CallBase* ll_callsite;
		graph_tool::gt_dispatch<>()([&](auto& g) { get_llvm_callsite(g, &ll_callsite, callsite); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		return get_obj_from_value(
		    safe_deref(const_cast<llvm::Value*>(get_return_value(safe_deref(ll_callsite), callpath))));
	}

	bool ValueAnalyzer::py_has_connection(PyObject* callsite, graph::CallPath callpath, unsigned argument_nr,
	                                      OSObject obj_index) {
		llvm::CallBase* ll_callsite;
		graph_tool::gt_dispatch<>()([&](auto& g) { get_llvm_callsite(g, &ll_callsite, callsite); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		return has_connection(safe_deref(ll_callsite), callpath, argument_nr, obj_index);
	}

} // namespace ara::step
