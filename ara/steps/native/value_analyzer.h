#pragma once

#include "arguments.h"
#include "graph.h"
#include "logging.h"

#include <WPA/Andersen.h>
#include <boost/bimap.hpp>
#include <graph_tool.hh>
#include <memory>

namespace ara::cython {
	void raise_py_valueerror();
}

namespace ara::step {
	struct EndOfFunction {};

	using OSObject = uint64_t;
	using RawValue = std::variant<const llvm::Value*, OSObject>;
	struct FoundValue {
		RawValue value;                                     /* found LLVM value or previously assigned object */
		const SVF::VFGNode* source;                         /* SVF node of the found value */
		std::vector<const llvm::GetElementPtrInst*> offset; /* offset within a struct */
		std::optional<graph::CallPath> callpath;            /* call context of this value */
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
	using TraversalResult = std::variant<Finished, Wait, KeepGoing, Die>;

	enum class Status { active, sleeping, dead };
	std::ostream& operator<<(std::ostream&, const Status&);

	class Bookkeeping;

	/**
	 * Entity to traverse the VFG backwards.
	 *
	 * The idea of the search is object based: A swarm of traversers traverse the VFG until they find the wanted
	 * information. Therefore, each traverser therefore analyzes a single path in the graph. To allow a pseudoparallel
	 * search (similar to a breath-first search), every traverser that gain control analyzes a single edge + node and
	 * then hands the control back to the main loop of the scheduling instance (Bookkeeping::run).
	 *
	 * Traverses can follow a path, hire other traversers and wait for their response or divide itself at crosses.
	 * Traverser therefore maintain a hierarchy. Every traverser has a "boss" which can give commands.
	 *
	 * The process is roughly so:
	 * A Manager (a special kind of Traverser) starts the search. It analyzes the current node. If a search on other
	 * nodes is necessary, it delegates all work to newly spawned subtraverses.
	 *
	 * These traversers follow the edges of the VFG backwards, until they found something interesting:
	 * 1. A PHINode: The traverser cannot decide the correct outcome of the PHINode and spawns subtraverses on its own
	 *    and wait for their reports.
	 * 2. A CallEdge up: The traverser examines if the edge is within its own Callpath and waits. If all traversers on
	 *    the same call level reach also a CallEdge (or die), the common boss decides which edge should be followed
	 *    (normally the IndCallEdge).
	 * 3. A CallEdge down: The traverser follows the edge if it is reachable from the current context and extends the
	 *    callpath accordingly.
	 * 4. A dead end: The traversers dies.
	 *
	 * Once a result is found or a all subtraversers are dead, the currect traverser reports this to its boss and dies,
	 * too. At the end, the Manager reports the result back to the ValueAnalysis.
	 */
	class Traverser {
	  protected:
		/** Communication message for call paths
		 *
		 * drop:       drop an entry from the callpath
		 * add:        add an entry to the callpath
		 * keep:       let the callpath as is
		 * false_path: don't go this way
		 */
		enum class CallPathAction { drop, add, keep, false_path };
		using CPA = CallPathAction;

		/**
		 * The traverser's boss.
		 */
		Traverser* boss;
		/**
		 * The traverser's employees.
		 */
		std::map<size_t, std::shared_ptr<Traverser>> workers;

		graph::CallPath call_path;

		/**
		 * The path of all gone VFGEdges
		 */
		std::vector<const SVF::VFGEdge*> trace;

		/**
		 * Reports from employes.
		 */
		std::vector<Report> reports;

		/**
		 * Instance for bookkeeping (scheduling, global information)
		 */
		Bookkeeping& caretaker;

		bool die_at_visited = true;
		bool skip_first_edge = false;

		/**
		 * Traverser status (active, sleep or dead)
		 */
		Status status = Status::active;
		/**
		 * If the traverser sleeps it waits for something. Store this here.
		 */
		WaitingReason reason = WaitingReason::not_set;
		size_t id;
		unsigned level = 0;
		/**
		 * Store the one elementptr that is found on the traversers way
		 */
		std::vector<const llvm::GetElementPtrInst*> offset;

		virtual void handle_found_value(FoundValue&& report);
		FoundValue get_best_find(std::vector<Report>&& finds) const;

		/**
		 * Take care of all received reports.
		 */
		void handle_reports();

		bool eval_result(TraversalResult&& result);
		void hire(std::shared_ptr<Traverser> worker);

		/**
		 * Handle a single Edge.
		 */
		TraversalResult handle_edge(const SVF::VFGEdge*);
		/**
		 * Handle a single Node.
		 */
		TraversalResult handle_node(const SVF::VFGNode*);

		/**
		 * Advance one edge further. May spawn other traversers (colleagues).
		 */
		TraversalResult advance(const SVF::VFGNode* node, bool only_delegate = false);

		void sleep_and_send(Report&& report);
		void die_and_notify();
		void cleanup_workers();
		virtual void act_if_necessary();

		const SVF::PTACallGraphEdge* t_get_callsite(const SVF::VFGEdge* edge) const;

		/**
		 * Check if an CallEdge fits to the current context (denoted by the call_path).
		 */
		std::pair<CallPathAction, const SVF::PTACallGraphEdge*>
		evaluate_callpath(const SVF::VFGEdge* edge, const graph::CallPath& call_path) const;

		void update_call_path(const CallPathAction action, const SVF::PTACallGraphEdge* edge);

		/**
		 * Decide, which traverser should be traversing the graph further.
		 *
		 * The function assumes that all subtraverses sleeping at CallEdges.
		 */
		std::vector<std::shared_ptr<Traverser>> choose_best_next_traversers();
		Logger::LogStream& dbg() const;
		void remove(size_t traverser_id);

	  public:
		Traverser(Traverser* boss, const SVF::VFGEdge* edge, graph::CallPath call_path, Bookkeeping& caretaker);

		virtual ~Traverser(){};

		/**
		 * Send a report to the boss.
		 */
		void send_report(Report&& report);

		/**
		 * Do a single step.
		 *
		 * 1. Analyze current edge and node
		 * 2. Advance
		 */
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

	/**
	 * Provide global information for all traversers and act as scheduler.
	 */
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

		/**
		 * Run the main scheduling loop.
		 */
		void run();

		// proxy functions
		llvm::Module& get_module() const;
		Logger& get_logger() const;
		std::optional<OSObject> get_obj_id(const SVF::NodeID id,
		                                   const std::vector<const llvm::GetElementPtrInst*>& offset,
		                                   const graph::CallPath& callpath) const;
	};

	/**
	 * A special traverser that mainly acts a single instance that manages a bunch a subtraversers.
	 * The value analysis only communicates with the manager that spawn subtraversers if needed.
	 *
	 * The manager is its own boss.
	 */
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

		bool eval_node_result(TraversalResult&& result);
		void do_step() override;
		const FoundValue get_value();
	};

	/**
	 * Get constant values for function call arguments.
	 *
	 * The value analysis traverses the SVFG that is provided by the SVF and tries to extract constant values for
	 * argument at a specific call site. Furthermore, it can assign an (artifical) object to the return target of a
	 * specific call.
	 *
	 * The ValueAnalyzer is not meant to be used directly but from Python, see value_analyzer.pxi for the Python entry
	 * class.
	 *
	 * The main functions are py_get_argument_value (retrieve a value for an argument) and py_assign_system_object
	 * (assign a system object to a return target or pointer).
	 */
	class ValueAnalyzer {
	  public:
		struct Result {
			RawValue value;                                     /* found LLVM value or previously assigned object */
			std::vector<const llvm::GetElementPtrInst*> offset; /* offset within a struct */
			std::optional<llvm::AttributeSet> attrs;            /* attributes specific to this callsite */
			std::optional<graph::CallPath> callpath;            /* call context of this value */
		};

	  private:
		friend class Bookkeeping;
		graph::Graph graph;
		graph::CFG cfg;
		Logger logger;
		/* Map between: Key = VFGNode, Value = Python system object */
		graph::GraphData::ObjMap& obj_map;

		/* SVF datastructures */
		SVF::PAG* pag = SVF::PAG::getPAG();
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* s_callgraph = ander->getPTACallGraph();

		std::shared_ptr<graph::CallGraph> callgraph;

		/**
		 * Output an error to the log and raise an ValuesUnknown exception.
		 *
		 * \param the message that should be printed
		 */
		[[noreturn]] inline void fail(const char* msg);

		/**
		 * Get the SVF::VFGNode to a specific llvm::Value.
		 */
		template <typename SVFGGraphtool>
		const SVF::VFGNode* get_vfg_node(SVFGGraphtool& g, const graph::SVFG svfg, const llvm::Value& start,
		                                 int argument_nr = -1);

		/**
		 * Perform an actual search. It traverses backwards in the Value Flow Graph to retrieve the origin of a specific
		 * value.
		 *
		 * Internally, it sets up a Bookkeeping object and delegates the work to a Manager (a special kind of
		 * Traverser). See the documention for Traverser for the algorithmic description.
		 *
		 * \param start Start the search at this Node
		 * \param callpath    the callpath (currect context) which applies in this search
		 * \param hint        specifies, which object the search should retrieve
		 *
		 * \return a pair of the found llvm::Value and the corresponding SVF::VFGNode
		 */
		FoundValue do_backward_value_search(const SVF::VFGNode* start, graph::CallPath callpath, graph::SigType hint);

		/**
		 * Retrieve the argument value of the nth argument of a call.
		 *
		 * Uses do_backward_value_search internally for the actual analysis.
		 *
		 * \param callsite    the callsite which should be analyzed
		 * \param callpath    the callpath (currect context) which applies for this call
		 * \param argument_nr the argument which should be analyzed
		 * \param hint        what type of analysis should be done
		 * \param type        the expected object type, currently unused
		 */
		template <typename SVFGGraphtool>
		ValueAnalyzer::Result get_argument_value(SVFGGraphtool& g, llvm::CallBase& callsite, graph::CallPath callpath,
		                                         unsigned argument_nr, graph::SigType hint, PyObject* type);

		/**
		 * Check if there is a connection within the SVFG between the SVFG node specified by (callsite, callpath,
		 * argument_nr) and the given obj_index.
		 *
		 * \param callsite    the callsite whose argument should be checked
		 * \param callpath    the callpath (currect context) which applies for this call. TODO: not used
		 * \param argument_nr the argument which should be checked
		 * \param obj_index   the unique ID of the object (the actual object is stored in Python)
		 *
		 * \return whether a connection is found
		 */
		template <typename SVFGGraphtool>
		bool has_connection(SVFGGraphtool& g, llvm::CallBase& callsite, graph::CallPath callpath, unsigned argument_nr,
		                    OSObject obj_index);

		/**
		 * Find the global llvm::Value with the given name.
		 *
		 * \param name the name of the global value
		 *
		 * \return the found value or nullptr
		 */
		llvm::GlobalValue* find_global(const std::string& name);

		/**
		 * Converts a ARA (Python) callsite to an LLVM callsite.
		 */
		template <class Graph>
		inline void get_llvm_callsite(Graph, llvm::CallBase** ll_callsite, PyObject* callsite) {
			const typename graph_tool::PythonVertex<Graph>& gt_cs =
			    boost::python::extract<typename graph_tool::PythonVertex<Graph>>(callsite);
			typename boost::graph_traits<Graph>::vertex_descriptor v_cs = gt_cs.get_descriptor();
			auto bb = cfg.get_llvm_bb<Graph>(v_cs);
			*ll_callsite = llvm::cast<llvm::CallBase>(&safe_deref(bb).front());
		}

		PyObject* py_repack_raw_value(const RawValue& value) const;
		PyObject* py_repack_offsets(const std::vector<const llvm::GetElementPtrInst*>& offsets) const;

		/**
		 * Get the nth argument (llvm::Value) for a specific callsite.
		 */
		const llvm::Value& get_nth_arg(const llvm::CallBase& callsite, const unsigned argument_nr) const;

		/**
		 * Get the next store VFGNode (the node in which a register value flows) for a specific start node.
		 *
		 * Uses do_backward_value_search internally to perform the actual analysis.
		 */
		const SVF::StoreVFGNode* find_next_store(const SVF::VFGNode* start);

		/**
		 * Get the llvm::Value to which a call (at a specific callsite) stores its result.
		 */
		const llvm::Value* get_llvm_return(const llvm::CallBase& callsite) const;

		/**
		 * Try to find the callpath specific return value for a specific callsite.
		 *
		 * Uses do_backward_value_search internally to perform the actual analysis.
		 */
		template <typename SVFGGraphtool>
		const llvm::Value* get_return_value(SVFGGraphtool& g, const llvm::CallBase& callsite, graph::CallPath callpath);

		template <typename SVFGGraphtool>
		ValueAnalyzer::Result get_memory_value(SVFGGraphtool& g, const llvm::Value* intermediate_value,
		                                       graph::CallPath callpath);

		template <typename SVFGGraphtool>
		std::vector<std::pair<const llvm::Value*, graph::CallPath>>
		get_assignments(SVFGGraphtool& g, const llvm::Value* value,
		                const std::vector<const llvm::GetElementPtrInst*>& gep, graph::CallPath callpath);

		PyObject* py_repack(ValueAnalyzer::Result&& result) const;

		/**
		 * Assign an (artificial) system object to an callsite return value or the nth argument pointer origin.
		 *
		 * Internally, the function also performs a value analysis since it tries to follow back the requested location
		 * (return value or argument) to which the object should be stored on the current callpath to a unique location.
		 * It then assign the object at this location where it can be found again by subsequent calls of
		 * get_argument_value.
		 *
		 * \param callsite    the callsite to which the system object should be assigned
		 * \param obj_index   the unique ID of the object (the actual object is stored in Python)
		 * \param callpath    the callpath (currect context) which applies for this call
		 * \param argument_nr the argument to which the object should be assigned. If argument_nr is -1 the object is
		 * assigned to the return value of this call, otherwise to nth argument which is assumed to be a pointer or
		 * reference.
		 */
		template <typename SVFGGraphtool>
		void assign_system_object(SVFGGraphtool& g, const llvm::Value* value, OSObject obj_index,
		                          const std::vector<const llvm::GetElementPtrInst*>&, const graph::CallPath& callpath);

	  public:
		// WARNING: do not use this class alone, always use the Python ValueAnalyzer.
		// If Cython would support this, this constructor would be private.
		ValueAnalyzer(graph::Graph&& graph, PyObject* logger)
		    : graph(std::move(graph)), cfg(graph.get_cfg()), logger(Logger(logger)),
		      obj_map(graph.get_graph_data().obj_map), callgraph(graph.get_callgraph_ptr()) {}

		static std::unique_ptr<ValueAnalyzer> get(graph::Graph&& graph, PyObject* logger) {
			return std::make_unique<ValueAnalyzer>(std::move(graph), logger);
		}

		/**
		 * Wrapper call for get_argument_value. See its documentation for details.
		 */
		PyObject* py_get_argument_value(PyObject* callsite, graph::CallPath callpath, unsigned argument_nr, int hint,
		                                PyObject* type);

		/**
		 * Wrapper call for get_return_value. See its documentation for details.
		 */
		PyObject* py_get_return_value(PyObject* callsite, graph::CallPath callpath);

		PyObject* py_get_memory_value(const llvm::Value* intermediate_value, graph::CallPath callgraph);

		/**
		 * Wrapper call for has_connection. See its documentation for details.
		 */
		PyObject* py_get_assignments(const llvm::Value* value, const std::vector<const llvm::GetElementPtrInst*>& gep,
		                             graph::CallPath callpath);

		/**
		 * Wrapper call for assign_system_object. See its documentation for details.
		 */
		void py_assign_system_object(const llvm::Value* value, OSObject obj_index,
		                             const std::vector<const llvm::GetElementPtrInst*>&,
		                             const graph::CallPath& callpath);

		// /**
		//  * Wrapper call for assign_system_object. See its documentation for details.
		//  */
		// void py_assign_system_object(PyObject* callsite, OSObject obj_index, graph::CallPath callpath,
		//                              int argument_nr) {
		// 	llvm::CallBase* ll_callsite;
		// 	graph_tool::gt_dispatch<>()([&](auto& g) { get_callsite(g, &ll_callsite, callsite); },
		// 	                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		// 	assign_system_object(safe_deref(ll_callsite), obj_index, callpath, argument_nr);
		// }

		/**
		 * Wrapper call for has_connection. See its documentation for details.
		 */
		bool py_has_connection(PyObject* callsite, graph::CallPath callpath, unsigned argument_nr, OSObject obj_index);

		/**
		 * Wrapper call for py_find_global. See its documention for details.
		 */
		PyObject* py_find_global(const std::string& name);
	};
} // namespace ara::step
