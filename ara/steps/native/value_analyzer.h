#pragma once

#include "arguments.h"
#include "graph.h"
#include "logging.h"

#include <graph_tool.hh>

namespace ara::cython {
	void raise_py_valueerror();
}

namespace ara::step {
	struct EndOfFunction {};
	struct FoundValue {
		std::variant<const llvm::Value*, unsigned> value;
		const SVF::VFGNode* source;
	};
	using Report = std::variant<EndOfFunction, FoundValue>;

	enum class WaitingReason { not_set, in_phi, i_am_manager };
	std::ostream& operator<<(std::ostream&, const WaitingReason&);

	struct Finished {
		Report report;
	};
	struct Wait {
		WaitingReason reason;
	};
	struct KeepGoing {};
	struct Die {};
	using Result = std::variant<Finished, Wait, KeepGoing, Die>;

	enum class Status { active, sleeping, dead };
	std::ostream& operator<<(std::ostream&, const Status&);

	class Bookkeeping;

	class Traverser {
	  protected:
		enum class CallPathAction { drop, add, keep, false_path };
		using CPA = CallPathAction;

		Traverser* boss;
		std::map<size_t, std::shared_ptr<Traverser>> workers;

		graph::CallPath call_path;
		std::vector<const SVF::VFGEdge*> trace;

		std::vector<Report> reports;
		Bookkeeping& caretaker;
		bool die_at_visited = true;
		bool skip_first_edge = false;
		Status status = Status::active;
		WaitingReason reason = WaitingReason::not_set;
		size_t id;
		unsigned level = 0;

		virtual void handle_found_value(FoundValue&& report);
		FoundValue get_best_find(std::vector<Report>&& finds) const;
		void handle_reports();
		bool eval_result(Result&& result);
		void hire(std::shared_ptr<Traverser> worker);

		Result handle_edge(const SVF::VFGEdge*);
		Result handle_node(const SVF::VFGNode*);

		Result advance(const SVF::VFGNode* node, bool only_delegate = false);

		void sleep_and_send(Report&& report);
		void die_and_notify();
		void cleanup_workers();
		virtual void act_if_necessary();

		std::optional<SVF::CallSiteID> get_call_site_id(const SVF::VFGEdge* edge) const;
		const SVF::PTACallGraphEdge* get_call_site(const SVF::VFGEdge* edge) const;
		std::pair<CallPathAction, const SVF::PTACallGraphEdge*>
		evaluate_callpath(const SVF::VFGEdge* edge, const graph::CallPath& call_path) const;
		void update_call_path(const CallPathAction action, const SVF::PTACallGraphEdge* edge);
		std::vector<shared_ptr<Traverser>> choose_best_next_traversers();
		Logger::LogStream& dbg() const;
		void remove(size_t traverser_id);

	  public:
		Traverser(Traverser* boss, const SVF::VFGEdge* edge, graph::CallPath call_path, Bookkeeping& caretaker);

		virtual ~Traverser(){};

		void send_report(Report&& report);

		virtual void do_step();

		void die();
		void sleep();
		void wakeup();
		Status get_status() const { return status; }
		size_t get_id() const { return id; }
		friend std::ostream& operator<<(std::ostream& os, const Traverser& t);
	};
	std::ostream& operator<<(std::ostream& os, const Traverser& t);

	class ValueAnalyzer;

	class Bookkeeping {
		ValueAnalyzer& va;
		std::list<std::shared_ptr<Traverser>> traversers;
		std::set<const SVF::VFGNode*> visited;
		std::shared_ptr<graph::CallGraph> call_graph;
		const SVF::PTACallGraph* s_call_graph;
		graph::SigType hint;
		bool should_stop = false;
		size_t next_id = 0;

		Bookkeeping(ValueAnalyzer& va, std::shared_ptr<graph::CallGraph> call_graph,
		            const SVF::PTACallGraph* s_call_graph, graph::SigType hint)
		    : va(va), call_graph(call_graph), s_call_graph(s_call_graph), hint(hint) {}
		friend class ValueAnalyzer;

	  public:
		void add_traverser(std::shared_ptr<Traverser> traverser) { traversers.emplace_back(traverser); }
		bool is_visited(const SVF::VFGNode* node) const { return visited.find(node) != visited.end(); }
		void mark_visited(const SVF::VFGNode* node) { visited.emplace(node); }
		std::shared_ptr<graph::CallGraph> get_call_graph() const { return call_graph; }
		const SVF::PTACallGraph* get_svf_call_graph() const { return s_call_graph; }
		graph::SigType get_hint() { return hint; }
		size_t get_new_id() { return next_id++; }
		void stop() { should_stop = true; }
		void run();

		// proxy functions
		llvm::Module& get_module() const;
		Logger& get_logger() const;
		std::optional<unsigned> get_obj_id(const SVF::NodeID id) const;
	};

	class Manager : public Traverser {
		const SVF::VFGNode* node;
		std::optional<FoundValue> value = std::nullopt;

		void act_if_necessary() override;
		void handle_found_value(FoundValue&& report) override;

	  public:
		Manager(const SVF::VFGNode* node, graph::CallPath call_path, Bookkeeping& caretaker)
		    : Traverser(this, nullptr, call_path, caretaker), node(node) {
			reason = WaitingReason::i_am_manager;
		}

		bool eval_node_result(Result&& result);
		void do_step() override;
		const std::pair<std::variant<const llvm::Value*, unsigned>, const SVF::VFGNode*> get_value();
	};

	class ValueAnalyzer {
	  private:
		friend class Bookkeeping;
		graph::Graph graph;
		graph::CFG cfg;
		Logger logger;
		/* Map between: Key = VFGNode, Value = Python system object */
		std::map<SVF::NodeID, unsigned>& obj_map;

		/**
		 * Convenience datatype, since the Value Analysis does a depth first search about the nodes, but also needs the
		 * call_path.
		 */
		struct VFGContainer {
			const SVF::VFGNode* node;
			graph::CallPath call_path;
			unsigned global_depth;
			unsigned local_depth;
			unsigned call_depth;

			VFGContainer(const SVF::VFGNode* node, graph::CallPath call_path, unsigned global_depth,
			             unsigned local_depth, unsigned call_depth)
			    : node(node), call_path(call_path), global_depth(global_depth), local_depth(local_depth),
			      call_depth(call_depth) {}
			VFGContainer() {}
		};

		[[noreturn]] inline void fail(const char* msg);

		const SVF::VFGNode* get_vfg_node(const SVF::SVFG& vfg, const llvm::Value& start) const;

		std::pair<std::variant<const llvm::Value*, unsigned>, const SVF::VFGNode*>
		do_backward_value_search(const SVF::VFGNode* start, graph::CallPath callpath, graph::SigType hint);

		std::pair<std::variant<const llvm::Value*, unsigned>, llvm::AttributeSet>
		get_argument_value(llvm::CallBase& callsite, graph::CallPath callpath, unsigned argument_nr,
		                   graph::SigType hint, PyObject* type);

		void assign_system_object(llvm::CallBase& callsite, unsigned obj_index, graph::CallPath callpath,
		                          int argument_nr);

		template <class Graph>
		inline void get_callsite(Graph, llvm::CallBase** ll_callsite, PyObject* callsite) {
			const typename graph_tool::PythonVertex<Graph>& gt_cs =
			    boost::python::extract<typename graph_tool::PythonVertex<Graph>>(callsite);
			typename boost::graph_traits<Graph>::vertex_descriptor v_cs = gt_cs.get_descriptor();
			auto bb = cfg.get_llvm_bb<Graph>(v_cs);
			*ll_callsite = llvm::cast<llvm::CallBase>(&safe_deref(bb).front());
		}

		PyObject* py_repack(std::pair<std::variant<const llvm::Value*, unsigned>, llvm::AttributeSet> result) const;

		const llvm::Value& get_nth_arg(const llvm::CallBase& callsite, const unsigned argument_nr) const;

		const SVF::VFGNode* find_next_store(const SVF::VFGNode* start);
		const llvm::Value* get_llvm_return(const llvm::CallBase& callsite) const;
		const llvm::Value* get_return_value(const llvm::CallBase& callsite, graph::CallPath callpath);

	  public:
		// WARNING: do not use this class alone, always use the Python ValueAnalyzer.
		// If Cython would support this, this constructor would be private.
		ValueAnalyzer(graph::Graph&& graph, PyObject* logger)
		    : graph(std::move(graph)), cfg(graph.get_cfg()), logger(Logger(logger)),
		      obj_map(graph.get_graph_data().obj_map) {}

		static std::unique_ptr<ValueAnalyzer> get(graph::Graph&& graph, PyObject* logger) {
			return std::make_unique<ValueAnalyzer>(std::move(graph), logger);
		}

		PyObject* py_get_argument_value(PyObject* callsite, graph::CallPath callpath, unsigned argument_nr, int hint,
		                                PyObject* type) {
			llvm::CallBase* ll_callsite;
			graph_tool::gt_dispatch<>()([&](auto& g) { get_callsite(g, &ll_callsite, callsite); },
			                            graph_tool::always_directed())(cfg.graph.get_graph_view());

			auto ret_value = get_argument_value(safe_deref(ll_callsite), callpath, argument_nr,
			                                    static_cast<graph::SigType>(hint), type);
			return py_repack(ret_value);
		}

		void py_assign_system_object(PyObject* callsite, unsigned obj_index, graph::CallPath callpath,
		                             int argument_nr) {
			llvm::CallBase* ll_callsite;
			graph_tool::gt_dispatch<>()([&](auto& g) { get_callsite(g, &ll_callsite, callsite); },
			                            graph_tool::always_directed())(cfg.graph.get_graph_view());

			assign_system_object(safe_deref(ll_callsite), obj_index, callpath, argument_nr);
		}

		PyObject* py_get_return_value(PyObject* callsite, graph::CallPath callpath) {
			llvm::CallBase* ll_callsite;
			graph_tool::gt_dispatch<>()([&](auto& g) { get_callsite(g, &ll_callsite, callsite); },
			                            graph_tool::always_directed())(cfg.graph.get_graph_view());

			return get_obj_from_value(
			    safe_deref(const_cast<llvm::Value*>(get_return_value(safe_deref(ll_callsite), callpath))));
		}
	};
} // namespace ara::step
