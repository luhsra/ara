#include "value_analyzer.h"

#include "common/llvm_common.h"
#include "common/util.h"

#include <boost/range/adaptor/map.hpp>

extern PyObject* py_valueerror;

namespace ara::cython {

	void raise_py_valueerror() {
		try {
			throw;
		} catch (ValuesUnknown& e) {
			PyErr_SetString(py_valueerror, e.what());
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

	std::optional<SVF::CallSiteID> Traverser::get_call_site_id(const SVF::VFGEdge* edge) const {
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

	const SVF::PTACallGraphEdge* Traverser::get_call_site(const SVF::VFGEdge* edge) const {
		auto s_callgraph = caretaker.get_svf_call_graph();
		auto id = get_call_site_id(edge);
		if (!id) {
			return nullptr;
		}
		const SVF::CallBlockNode* cbn = s_callgraph->getCallSite(*id);
		if (cbn == nullptr) {
			return nullptr;
		}

		// get call site
		assert(s_callgraph->hasCallGraphEdge(cbn) && "no valid call graph edge found");
		SVF::PTACallGraphEdge* call_site = nullptr;
		for (auto bi = s_callgraph->getCallEdgeBegin(cbn); bi != s_callgraph->getCallEdgeEnd(cbn); ++bi) {
			if (id == (*bi)->getCallSiteID()) {
				call_site = *bi;
				break;
			}
		}
		assert(call_site != nullptr && "no matching PTACallGraphEdge for CallDirSVFGEdge.");

		return call_site;
	}

	std::pair<Traverser::CPA, const SVF::PTACallGraphEdge*>
	Traverser::evaluate_callpath(const SVF::VFGEdge* edge, const graph::CallPath& cpath) const {
		bool is_call =
		    edge != nullptr && (llvm::isa<SVF::CallDirSVFGEdge>(edge) || llvm::isa<SVF::CallIndSVFGEdge>(edge));
		bool is_ret = edge != nullptr && (llvm::isa<SVF::RetDirSVFGEdge>(edge) || llvm::isa<SVF::RetIndSVFGEdge>(edge));

		const SVF::PTACallGraphEdge* cg_edge = get_call_site(edge);
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
			const SVF::PTACallGraphEdge* cg_edge = get_call_site(edge);
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
		auto id = caretaker.get_obj_id(node->getId());
		if (id) {
			dbg() << "Found a previous assigned object." << std::endl;
			dbg() << "CallPath: " << call_path << std::endl;
			return Finished{FoundValue{*id, node}};
		}
		if (llvm::isa<SVF::NullPtrVFGNode>(node)) {
			// Sigtype is not important here, a nullptr serves as value and symbol.
			dbg() << "Found a nullptr." << std::endl;
			auto nullval = llvm::ConstantPointerNull::get(
			    llvm::PointerType::get(llvm::IntegerType::get(caretaker.get_module().getContext(), 8), 0));
			return Finished{FoundValue{nullval, node}};
		}

		if (auto stmt = llvm::dyn_cast<SVF::StmtVFGNode>(node)) {
			const llvm::Value* val = stmt->getPAGEdge()->getValue();
			auto hint = caretaker.get_hint();

			if (hint == graph::SigType::value || hint == graph::SigType::undefined) {
				if (const llvm::ConstantData* c = llvm::dyn_cast<llvm::ConstantData>(val)) {
					dbg() << "Found constant data: " << pretty_print(*c) << std::endl;
					return Finished{FoundValue{c, node}};
				}

				if (const llvm::Function* func = llvm::dyn_cast<llvm::Function>(val)) {
					dbg() << "Found function: " << pretty_print(*func) << std::endl;
					return Finished{FoundValue{func, node}};
				}

				if (const llvm::GlobalVariable* gv = llvm::dyn_cast<llvm::GlobalVariable>(val)) {
					// logger.warn() << "GV: " << *gv << " " << gv->hasExternalLinkage() << std::endl;
					if (gv->hasExternalLinkage()) {
						dbg() << "Found global external constant: " << pretty_print(*gv) << std::endl;
						return Finished{FoundValue{gv, node}};
					} else {
						const llvm::Value* gvv = gv->getOperand(0);
						if (gvv != nullptr) {
							if (const llvm::ConstantData* gvvc = llvm::dyn_cast<llvm::ConstantData>(gvv)) {
								dbg() << "Found global constant data: " << pretty_print(*gvvc) << std::endl;
								return Finished{FoundValue{gvvc, node}};
							}
						}
					}
				}
			}

			if (hint == graph::SigType::symbol) {
				if (const llvm::GlobalValue* gv = llvm::dyn_cast<llvm::GlobalValue>(val)) {
					dbg() << "Found global value: " << pretty_print(*gv) << std::endl;
					return Finished{FoundValue{gv, node}};
				}

				if (const llvm::AllocaInst* ai = llvm::dyn_cast<llvm::AllocaInst>(val)) {
					dbg() << "Found alloca instruction (local variable): " << pretty_print(*ai) << std::endl;
					return Finished{FoundValue{ai, node}};
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
		auto found_instance = [](Report& r) { return std::holds_alternative<unsigned>(std::get<FoundValue>(r).value); };
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
			                      this->value = std::get<FoundValue>(f.report);
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

	const std::pair<std::variant<const llvm::Value*, unsigned>, const SVF::VFGNode*> Manager::get_value() {
		assert(value && "no value");
		return std::make_pair(value->value, value->source);
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
	std::optional<unsigned> Bookkeeping::get_obj_id(const SVF::NodeID id) const {
		auto it = va.obj_map.find(id);
		if (it != va.obj_map.end()) {
			return it->second;
		}
		return std::nullopt;
	}

	void ValueAnalyzer::fail(const char* msg) {
		logger.error() << "ERROR: " << msg << std::endl;
		throw ValuesUnknown(msg);
	}

	const SVF::VFGNode* ValueAnalyzer::get_vfg_node(const SVF::SVFG& vfg, const llvm::Value& start) const {
		SVF::PAG* pag = SVF::PAG::getPAG();

		SVF::PAGNode* pNode = pag->getPAGNode(pag->getValueNode(&start));
		assert(pNode != nullptr);
		const SVF::VFGNode* vNode = vfg.getDefSVFGNode(pNode);
		assert(vNode != nullptr);
		return vNode;
	}

	std::pair<std::variant<const llvm::Value*, unsigned>, const SVF::VFGNode*>
	ValueAnalyzer::do_backward_value_search(const SVF::VFGNode* start, graph::CallPath callpath, graph::SigType hint) {
		SVF::PAG* pag = SVF::PAG::getPAG();
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* s_callgraph = ander->getPTACallGraph();

		Bookkeeping caretaker(*this, std::shared_ptr<graph::CallGraph>(graph.get_callgraph_ptr()), s_callgraph, hint);
		shared_ptr<Manager> root = std::make_shared<Manager>(start, callpath, caretaker);
		caretaker.add_traverser(root);

		caretaker.run();
		return root->get_value();
	}

	// const llvm::Value* ValueAnalyzer::do_backward_value_search(const SVF::SVFG& vfg, const llvm::Value& start,
	// graph::CallPath callpath, graph::SigType hint) { 	SVF::PAG* pag = SVF::PAG::getPAG(); 	SVF::Andersen* ander
	// =
	// SVF::AndersenWaveDiff::createAndersenWaveDiff(pag); 	SVF::PTACallGraph* s_callgraph = ander->getPTACallGraph();

	//	const SVF::VFGNode* vNode = get_vfg_node(vfg, start);

	//	std::deque<VFGContainer> nodes;

	//	nodes.emplace_front(VFGContainer(vNode, callpath, 0, 0, 0));

	//	std::map<unsigned, bool> found_on_level;
	//	std::set<const SVF::VFGNode*> visited;

	//	while (!nodes.empty()) {
	//		VFGContainer current = std::move(nodes.front());
	//		nodes.pop_front();

	//		const SVF::VFGNode* current_node = current.node;

	//		if (visited.find(current_node) != visited.end()) {
	//			continue;
	//		}
	//		visited.insert(current_node);

	//		graph::CallPath& current_path = current.call_path;
	//		unsigned global_depth = current.global_depth; // absolute amount of iterations
	//		unsigned local_depth = current.local_depth;   // amount of iterations within this function layer
	//		unsigned call_depth = current.call_depth;     // amount of function layers

	//		auto dbg = [&]() -> auto& {
	//			return logger.debug() << std::string(call_depth, ' ') << '|' << std::string(local_depth, ' ');
	//		};

	//		dbg() << "Current Node (" << local_depth << "/" << call_depth << "): " << *current_node << std::endl;
	//		dbg() << "Current CallPath: " << current_path << std::endl;

	//		if (global_depth > 300) {
	//			fail("The value analysis reached a backtrack level of 300. Aborting due to preventing a too long "
	//			     "runtime.");
	//		}
	//		if (local_depth > 200) {
	//			fail("The value analysis reached a local backtrack level of 200. Aborting due to preventing a too long "
	//			     "runtime.");
	//		}

	//		if (local_depth == 0) {
	//			// the are in a new layer of the call depth. In this layer a node was not found, so resetting the map.
	//			found_on_level[call_depth] = false;
	//		}

	//		if (auto stmt = llvm::dyn_cast<SVF::StmtVFGNode>(current_node)) {
	//			const llvm::Value* val = stmt->getPAGEdge()->getValue();
	//			if (hint == graph::SigType::value || hint == graph::SigType::undefined) {
	//				if (const llvm::ConstantData* c = llvm::dyn_cast<llvm::ConstantData>(val)) {
	//					auto& ls = dbg() << "Found constant data: ";
	//					pretty_print(*c, ls);
	//					ls << std::endl;
	//					return c;
	//				}

	//				if (const llvm::GlobalVariable* gv = llvm::dyn_cast<llvm::GlobalVariable>(val)) {
	//					logger.warn() << "GV: " << *gv << " " << gv->hasExternalLinkage() << std::endl;
	//					if (gv->hasExternalLinkage()) {
	//						auto& ls = dbg() << "Found global external constant: ";
	//						pretty_print(*gv, ls);
	//						ls << std::endl;
	//						return gv;
	//					} else {
	//						const llvm::Value* gvv = gv->getOperand(0);
	//						if (gvv != nullptr) {
	//							if (const llvm::ConstantData* gvvc = llvm::dyn_cast<llvm::ConstantData>(gvv)) {
	//								auto& ls = dbg() << "Found global constant data: ";
	//								pretty_print(*gvvc, ls);
	//								ls << std::endl;
	//								return gvvc;
	//							}
	//						}
	//					}
	//				}
	//			}

	//			if (hint == graph::SigType::symbol) {
	//				if (const llvm::GlobalValue* gv = llvm::dyn_cast<llvm::GlobalValue>(val)) {
	//					auto& ls = dbg() << "Found global value: ";
	//					pretty_print(*gv, ls);
	//					ls << std::endl;
	//					return gv;
	//				}

	//				if (const llvm::AllocaInst* ai = llvm::dyn_cast<llvm::AllocaInst>(val)) {
	//					auto& ls = dbg() << "Found alloca instruction (local variable): ";
	//					pretty_print(*ai, ls);
	//					ls << std::endl;
	//					return ai;
	//				}
	//			}
	//		}
	//		if (llvm::isa<SVF::NullPtrVFGNode>(current_node)) {
	//			// Sigtype is not important here, a nullptr serves as value and symbol.
	//			dbg() << "Found a nullptr." << std::endl;
	//			return llvm::ConstantPointerNull::get(
	//			    llvm::PointerType::get(llvm::IntegerType::get(graph.get_module().getContext(), 8), 0));
	//		}

	//		for (SVF::VFGNode::const_iterator it = current_node->InEdgeBegin(); it != current_node->InEdgeEnd(); ++it) {
	//			unsigned next_local_depth = local_depth + 1;
	//			unsigned next_call_depth = call_depth;
	//			SVF::VFGEdge* edge = *it;
	//			graph::CallPath next_path = current_path;
	//			bool go_further = false;
	//			bool is_call = false;
	//			if (auto cde = llvm::dyn_cast<SVF::CallDirSVFGEdge>(edge)) {
	//				is_call = true;
	//				const SVF::CallBlockNode* cbn = s_callgraph->getCallSite(cde->getCallSiteId());
	//				assert(s_callgraph->hasCallGraphEdge(cbn) && "no call graph edge found");
	//				SVF::PTACallGraphEdge* call_site = nullptr;
	//				for (auto bi = s_callgraph->getCallEdgeBegin(cbn); bi != s_callgraph->getCallEdgeEnd(cbn); ++bi) {
	//					if (cde->getCallSiteId() == (*bi)->getCallSiteID()) {
	//						call_site = *bi;
	//						break;
	//					}
	//				}
	//				assert(call_site != nullptr && "no matching PTACallGraphEdge for CallDirSVFGEdge.");
	//				if (*call_site == next_path.svf_at(next_path.size() - 1)) {
	//					go_further = true;
	//					next_path.pop_back();
	//				}
	//				if (go_further) {
	//					next_call_depth++;
	//					next_local_depth = 0;
	//					dbg() << "Going one call up. Callsite: " << *call_site << std::endl;
	//				}
	//			} else {
	//				go_further = !found_on_level[next_call_depth];
	//			}

	//			if (go_further) {
	//				const SVF::VFGNode* next_node = (*it)->getSrcNode();
	//				if (next_node != nullptr) {
	//					VFGContainer t(next_node, next_path, global_depth + 1, next_local_depth, next_call_depth);
	//					if (is_call) {
	//						nodes.emplace_back(std::move(t));
	//					} else {
	//						nodes.emplace_front(std::move(t));
	//					}
	//				}
	//			}
	//		}
	//	}
	//	fail("backward search did not find any values");
	//	return nullptr;
	//}

	const llvm::Value& ValueAnalyzer::get_nth_arg(const llvm::CallBase& callsite, const unsigned argument_nr) const {
		const auto& use = callsite.getArgOperandUse(argument_nr);
		return safe_deref(use.get());
	}

	std::pair<std::variant<const llvm::Value*, unsigned>, llvm::AttributeSet>
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

		const SVF::VFGNode* v_node = get_vfg_node(graph.get_svfg(), val);
		auto [value, _] = do_backward_value_search(v_node, callpath, hint);

		// printing
		if (std::holds_alternative<unsigned>(value)) {
			logger.debug() << "Found previous object. ID: " << std::get<unsigned>(value) << std::endl;
		} else {
			logger.debug() << "Found value: " << pretty_print(*std::get<const llvm::Value*>(value)) << std::endl;
		}

		return std::make_pair(value, std::move(attrs));
	}

	const SVF::VFGNode* ValueAnalyzer::find_next_store(const SVF::VFGNode* start) {
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
				if (llvm::isa<SVF::StoreVFGNode>(cand)) {
					logger.debug() << "Found store node: " << *cand << std::endl;
					return cand;
				}
			}
		}
		return nullptr;
	}

	void ValueAnalyzer::assign_system_object(llvm::CallBase& callsite, unsigned obj_index, graph::CallPath callpath,
	                                         int argument_nr) {
		assert(!callsite.getFunctionType()->getReturnType()->isVoidTy() && "Callsite has no return value");

		SVF::NodeID id;
		if (argument_nr == -1) {
			const SVF::VFGNode* node = get_vfg_node(graph.get_svfg(), callsite);
			logger.debug() << "Assign: Initial node " << *node << std::endl;

			auto store = find_next_store(node);
			if (store == nullptr) {
				logger.warn() << "Assignment to storage node not possible. Assign to call node itself." << std::endl;
				id = node->getId();
			} else {
				auto [_, target] = do_backward_value_search(store, callpath, graph::SigType::symbol);
				id = safe_deref(target).getId();
			}
		} else {
			assert(argument_nr >= 0);

			const llvm::Value& val = get_nth_arg(callsite, static_cast<unsigned>(argument_nr));
			logger.debug() << "Assign to argument " << argument_nr << " " << val << std::endl;
			const SVF::VFGNode* v_node = get_vfg_node(graph.get_svfg(), val);
			auto [_, target] = do_backward_value_search(v_node, callpath, graph::SigType::symbol);
			id = safe_deref(target).getId();
		}

		if (id != 0) {
			logger.debug() << "Assign object ID " << obj_index << " to SVF node ID: " << id << "." << std::endl;
			obj_map[id] = obj_index;
		} else {
			logger.debug() << "Assign object ID " << obj_index << " to nothing. A nullptr was given." << std::endl;
		}
	}

	PyObject*
	ValueAnalyzer::py_repack(std::pair<std::variant<const llvm::Value*, unsigned>, llvm::AttributeSet> result) const {
		PyObject* obj_index;
		PyObject* value;
		if (std::holds_alternative<unsigned>(result.first)) {
			obj_index = PyLong_FromLong(std::get<unsigned>(result.first));
			value = Py_None;
			Py_INCREF(value);
		} else {
			obj_index = Py_None;
			Py_INCREF(obj_index);
			// it would be nice to return a const value here, however const correctness and Python are not compatible
			value =
			    get_obj_from_value(safe_deref(const_cast<llvm::Value*>(std::get<const llvm::Value*>(result.first))));
		}
		return PyTuple_Pack(3, value, get_obj_from_attr_set(result.second), obj_index);
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
		if (store == nullptr) {
			logger.warn() << "Did not find a storage node in the SVFG. Falling back to plain LLVM search." << std::endl;
			return get_llvm_return(callsite);
		} else {
			try {
				auto [value, _] = do_backward_value_search(store, callpath, graph::SigType::symbol);
				if (std::holds_alternative<const llvm::Value*>(value)) {
					const llvm::Value* ret = std::get<const llvm::Value*>(value);
					logger.debug() << "Found return value: " << pretty_print(*ret) << std::endl;
					return ret;
				}
			} catch (ValuesUnknown&) {
				return get_llvm_return(callsite);
			}
			fail("Found an already assigned object.");
		}
	}
} // namespace ara::step
