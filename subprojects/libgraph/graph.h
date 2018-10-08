#ifndef GRAPH_H
#define GRAPH_H

#include <any>
#include <functional>
#include <list>
#include <string>
#include <typeinfo>
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Function.h"

//typedef enum function_definition_type { Task, ISR, Timer, normal };
//
//typedef enum syscall_definition_type { syscall1, funccall, nocall };
//
//typedef enum ISR_type { ISR1, ISR2, basic };
//
//typedef enum timer_type { oneshot, autoreload };
//
//typedef enum semaphore_type { binary, counting, mutex, recursive_mutex };
//
//typedef enum argument_type { integer, floating, pointer, array, structure, string, additional };
//
//typedef enum buffer_type { stream, message };

namespace graph {

	//class Graph;
	//class Vertex;
	//class Edge;

	// Basis Klasse des Graphen
	class Graph {
	};
//
//
//	  private:
//		//std::list<Vertex> vertexes; // std::liste aller Vertexes des Graphen
//		//std::list<Edge> edges;      // std::liste aller Edges des Graphen
//
//	  public:
//		bool set_vertex(
//		    Vertex vertex); // vertex.clone(); innerhalb der set Methode um Objekt für die Klasse Graph zu speichern
//		bool set_edge(Edge edge); // edge.clone(); innerhalb der set Methode um Objekt für die Klasse Graph zu speichern
//
//		std::list<Vertex *>
//		get_type_vertexes(size_t type_info); // gebe alle Vertexes eines Types (Task, ISR, etc.) zurück
//		Vertex *get_vertex(size_t seed);     // gebe Vertex mit dem entsprechenden hashValue zurück
//		std::list<Vertex *> get_vertexes();  // gebe alle Vertexes des Graphen zurück
//
//		bool remove_vertex(Vertex *vertex); // löschen den Vertex mit dem Namen und automatisch alle Knoten des Vertexes
//		                                    // aus dem Graphen
//		bool remove_edge(
//		    Edge *edge); // löschen den Vertex mit dem Namen und automatisch alle Knoten des Vertexes aus dem Graphen
//	};
//
//	/*//TODO
//	<Es wird verschiedene Sichten auf Knoten und Kanten geben. Man könnte das implementieren, indem man mehrere Graph
//	Objekte hat, die auf die gleichen Vertices und Kanten verweisen. Das klappt das aber nicht mehr, dass die Graphen
//	die Vertices und Kanten besitzen. Eine Lösung wäre zb mit Smart-Pointern.>
//	*///TODO
//
//	// Basis Klasse für alle Vertexes
//	class Vertex {
//
//	  private:
//		Graph *graph; // Referenz zum Graphen, in der der Vertex gespeichert ist
//
//		std::string name; // spezifischer Name des Vertexes
//		std::size_t seed; // für jedes Element spezifischer hashValue
//
//		std::list<Edge *> outgoing_edges; // std::liste mit allen ausgehenden Kanten zu anderen Vertexes
//		std::list<Edge *> ingoing_edges;  // std::liste mit allen eingehenden Kanten von anderen Vertexes
//
//		std::list<Vertex *> outgoing_vertexes; // std::liste mit allen ausgehenden Vertexes zu anderen Vertexes
//		std::list<Vertex *> ingoing_vertexes;  // std::liste mit allen eingehenden Vertexes von anderen Vertexes
//
//	  public:
//		// Discriminator for LLVM-style RTTI (dyn_cast<> et al.)
//		enum VertexKind {
//			Function,
//			ISR,
//			Timer,
//			Task,
//			Queue,
//			EventGroups,
//			Semaphore,
//			Buffer,
//			QueueSet
//
//		};
//		const VertexKind Kind;
//		//
//
//		Vertex(Graph *graph); // Construktor
//
//		std::string get_name(); // gebe Namen des Vertexes zurück
//		std::size_t get_seed(); // gebe den Hash des Vertexes zurück
//
//		VertexKind getKind(); // LLVM-style RTTI const {return Kind}
//
//		bool set_outgoing_edge(Edge *edge);
//		bool set_ingoing_edge(Edge *edge);
//
//		bool set_outgoing_vertex(Edge *edge);
//		bool set_ingoing_vertex(Vertex *vertex);
//
//		bool remove_edge(Edge *);
//		bool remove_vertex(Vertex *);
//
//		std::list<Vertex *>
//		get_specific_connected_vertexes(size_t type_info); // get elements from graph with specific type
//
//		std::list<Vertex *> get_vertex_chain(
//		    Vertex *vertex); // Methode, die die Kette der Elemente vom Start bis zum Ziel Vertex zurück gibt,
//		                     // interagieren die Betriebssystemabstrakionen nicht miteinader gebe nullptr zurück
//		std::list<Vertex *>
//		get_connected_vertexes();                // Methode, die die mit diesem Knoten verbundenen Vertexes zurückgibt
//		std::list<Edge *> get_connected_edges(); // Methode, die die mit diesem Knoten verbundenen Edges zurückgibt
//		std::list<Vertex *> get_ingoing_vertexes(); // Methode, die die mit diesem Knoten eingehenden Vertexes
//		                                            // zurückgibt
//		std::list<Edge *> get_ingoing_edges(); // Methode, die die mit diesem Knoten eingehenden Edges zurückgibt
//		std::list<Vertex *>
//		get_outgoing_vertexes();                // Methode, die die mit diesem Knoten ausgehenden Vertexes zurückgibt
//		std::list<Edge *> get_outgoing_edges(); // Methode, die die mit diesem Knoten ausgehenden Edges zurückgibt
//		Edge *get_direct_edge(Edge *edge); // Methode, die direkte Kante zwischen Start und Ziel Vertex zurückgibt,
//		                                   // falls keine vorhanden nullptr
//	};
//
//	class ABB;
//
//	// Klasse Edge verbindet zwei Betriebssystemabstraktionen über einen Syscall/Call mit entsprechenden Argumenten
//	// Da jeder Edge der Start und Ziel Vertex zugeordnet ist, kann der Graph durchlaufen werden
//	class Edge {
//
//	  private:
//		std::string name;
//		Graph *graph;          // Referenz zum Graphen, in der der Vertex gespeichert ist
//		std::size_t seed;      // für jedes Element spezifischer hashValue
//		Vertex *start_vertex;  // Entsprechende Set- und Get-Methoden
//		Vertex *target_vertex; // Entsprechende Set- und Get-Methoden
//		bool is_syscall;       // Flag, ob Edge ein Syscall ist
//		std::string call;      // Entsprechende Set- und Get-Methoden
//		std::list<std::tuple<argument_type, std::any>> arguments;
//		ABB *atomic_basic_block_reference;
//
//	  public:
//		Edge(Graph *graph, std::string name, Vertex *start, Vertex *target);
//
//		std::string get_name(); // gebe Namen des Vertexes zurück
//		std::size_t get_seed(); // gebe den Hash des Vertexes zurück
//
//		bool set_start_vertext(Vertex *vertex);
//		bool set_start_edge(Edge *edge);
//		Vertex *get_start_vertex();
//		Edge *get_start_edge();
//
//		void set_syscall(bool syscall);
//		bool is_sycall();
//
//		std::list<std::tuple<argument_type, std::any>> get_arguments();
//		bool set_arguments(std::list<std::tuple<argument_type, std::any>> arguments);
//	};
//} // namespace graph
//
//namespace OS {
//
//	class ABB;
//	class Task;
//	class QueueSet;
//
//	// Einfache Funktion innerhalb der Applikation
//	class Function : graph::Vertex {
//
//	  private:
//		std::string function_name;       // name der Funktion
//		std::list<llvm::Type> arguments; // Argumente des Functionsaufrufes
//
//		std::list<ABB *> atomic_basic_blocks;       // Liste der AtomicBasicBlocks, die die Funktion definieren
//		std::list<OS::Task *> referenced_tasks;     // Liste aller Task, die diese Function aufrufen
//		std::list<Function *> referenced_functions; // Liste aller Funktionen, die diese Funktion aufrufen
//
//		function_definition_type defintion; // information, ob task ,isr, timer durch die Funktion definiert wird
//
//		bool contains_critical_section;
//
//		llvm::BasicBlock *start_critical_section_block; //  LLVM BasicBlock reference
//		llvm::BasicBlock *end_critical_section_block;   //  LLVM BasicBlock reference
//
//		llvm::Function *LLVM_function_reference; //*Referenz zum LLVM Function Object LLVM:Function -> Dadurch sind die
//		                                         //sind auch die LLVM:BasicBlocks erreichbar und iterierbar*/
//
//		std::list<Function *>
//		get_used_functions(); // Gebe std::liste aller Funktionen zurück, die diese Funktion benutzen
//		bool set_used_functions(
//		    Function *function); // Setze Funktion in std::liste aller Funktionen, die diese Funktion benutzen
//
//	  public:
//		static bool classof(const Vertex *v); // LLVM RTTI class of Methode
//
//		bool set_defintion(function_definition_type type);
//		function_definition_type get_definition();
//
//		bool set_start_critical_section_block(llvm::BasicBlock *basic_block);
//		bool set_end_critical_section_block(llvm::BasicBlock *basic_block);
//
//		llvm::BasicBlock *get_start_critical_section_block(llvm::BasicBlock *basic_block);
//		llvm::BasicBlock *get_end_critical_section_block(llvm::BasicBlock *basic_block);
//
//		bool set_LLVM_reference(llvm::Function function);
//		llvm::Function *get_LLVM_reference();
//
//		bool set_atomic_basic_block(ABB *atomic_basic_block);
//		std::list<ABB *> get_atomic_basic_block();
//
//		std::list<OS::Task *> get_referenced_tasks();
//
//		bool set_referenced_task(OS::Task *task);
//
//		std::list<OS::Task *> get_referenced_functions();
//
//		bool set_referenced_function(Function *function);
//
//		std::list<llvm::Type> get_arguments();
//		bool set_arguments(std::list<llvm::Type> arguments); // Setze Argument des SystemCalls in Argumentenliste
//	};
//
//	// Klasse AtomicBasicBlock
//	class ABB {
//
//	  private:
//		syscall_definition_type
//		    type; // Information, welcher Syscall Typ, bzw. ob Computation Typ vorliegt (Computation, generate Task,
//		          // generate Queue, ....; jeder Typ hat einen anderen integer Wert)
//		std::list<ABB *> successors;   // AtomicBasicBlocks die dem BasicBlock folgen
//		std::list<ABB *> predecessor;  // AtomicBasicBlocks die dem BasicBlock vorhergehen
//		OS::Function *parent_function; // Zeiger auf Function, die den BasicBlock enthält
//
//		std::list<llvm::BasicBlock *> basic_blocks;
//
//		std::string callname = ""; // Name des Sycalls
//		std::list<std::any> arguments;
//
//		bool critical_section; // flag, ob AtomicBasicBlock in einer ḱritischen Sektion liegt
//
//	  public:
//		syscall_definition_type get_calltype();
//		bool set_calltype(syscall_definition_type type);
//
//		bool set_successor(ABB *atomic_basic_block);
//		bool set_predecessor(ABB *atomic_basic_block);
//
//		std::list<ABB *> get_successor();
//		std::list<ABB *> get_predecessor();
//
//		bool set_parent_function(OS::Function *function);
//		bool is_critical();
//		void set_critical(bool critical);
//
//		std::list<std::any> get_arguments();
//		bool set_arguments(std::list<std::any> new_arguments); // Setze Argument des SystemCalls in Argumentenliste
//
//		bool set_ABB_successor(ABB *basicblock);   // Speicher Referenz auf Nachfolger des BasicBlocks
//		bool set_ABB_predecessor(ABB *basicblock); // Speicher Referenz auf Vorgänger des BasicBlocks
//		std::list<ABB *> get_ABB_successor();      // Gebe Referenz auf Nachfolger zurück
//		std::list<ABB *> get_ABB_predecessor();    // Gebe Referenz auf Vorgänger zurück
//
//		bool set_BasicBlock(llvm::BasicBlock);
//		std::list<llvm::BasicBlock> get_BasicBlocks();
//
//		bool set_referenced_function(OS::Function *function);
//		OS::Function *get_referenced_function();
//	};
//
//	// Bei Betriebssystem Abstraktionen wurden für die Attribute, die get- und set-Methoden ausgelassen und ein direkter
//	// Zugriff erlaubt. Vielmehr wird der Zugriff auf interne Listen durch Methoden ermöglicht.
//
//	class TaskGroup : graph::Vertex {
//
//	  private:
//		std::string group_name;
//		std::list<OS::Task *> task_group;
//
//	  public:
//		std::string get_name();
//		void set_name(std::string name);
//		bool set_task_in_group(OS::Task *task);
//		bool remove_task_in_group(OS::Task *task);
//		std::list<OS::Task *> get_tasks_in_group();
//	};
//
//	class Task : graph::Vertex {
//
//	  public:
//		OS::Function *definition_function;
//		TaskGroup *task_group;
//
//		// FreeRTOS attributes
//		std::string handler_name;
//
//		llvm::Type parameter;
//
//		int stacksize;
//		int priority;
//
//		bool gatekeeper;
//
//		// OSEK attributes
//		std::string AUTOSTART;
//		std::string autostart_appmodes;
//		std::string ACTIVATION;
//		std::string SCHEDULE;
//		std::string TASKGROUP;
//
//		static bool classof(const Vertex *S);
//	};
//
//	class Timer : graph::Vertex {
//
//	  public:
//		OS::Function *definition_function;
//
//		int periode;     // Periode in Ticks
//		timer_type type; // enum timer_type {One_shot_timer, Auto_reload_timer}
//		int timer_id; // ID is a void pointer and can be used by the application writer for any purpose. useful when the
//		              // same callback function is used by more software timers because it can be used to provide
//		              // timer-specific storage.
//
//		static bool classof(const Vertex *S);
//	};
//
//	class ISR : graph::Vertex {
//
//	  public:
//		OS::Function *definition_function;
//
//		std::string interrupt_source;
//		std::string handler_name;
//		int stacksize;
//		int priority;
//
//		static bool classof(const Vertex *S);
//	};
//
//	class QueueSet : graph::Vertex {
//
//	  private:
//		std::list<Vertex *> queueset_elements; //  Queues, Semaphores
//
//	  public:
//		std::string queueset_handle_name;
//
//		int length_queueset;
//		bool set_queue(Vertex *element);
//		bool member_of_queueset(Vertex *element);
//		bool remove_from_queueset(Vertex *element);
//
//		std::list<Vertex *> get_queueset_elements(); // gebe alle Elemente der Queueset zurück
//		std::string get_queueset_handle_name();
//
//		void set_queueset_handle_name(std::string name);
//
//		static bool classof(const Vertex *S);
//	};
//
//	class Queue : graph::Vertex {
//
//	  public:
//		OS::QueueSet *queueset_reference; // Referenz zur Queueset
//
//		std::string handle_name; // Namen des Queue handle
//		int length;              // Länger der Queue
//		int item_size;
//
//		std::list<Vertex *> get_accessed_elements(); // gebe ISR/Task zurück, die mit der Queue interagieren
//
//		static bool classof(const Vertex *S);
//	};
//
//	class Semaphore : graph::Vertex {
//
//	  public:
//		semaphore_type type; // enum semaphore_type {binary, counting, mutex, recursive_mutex}
//		std::string handle_name;
//		int max_count;
//		int initial_count;
//
//		std::list<Vertex *> get_accessed_elements(); // gebe alle Elemente zurück, die auf die Sempahore zugreifen
//
//		static bool classof(const Vertex *S);
//	};
//
//	class EventGroups : graph::Vertex {
//
//	  private:
//		std::list<Vertex *> writing_vertexes;
//		std::list<Vertex *> reading_vertexes;
//
//		std::list<int> set_bits;     // Auflisten aller gesetzen Bits des Event durch Funktionen
//		std::list<int> cleared_bits; // Auflisten aller gelöschten Bits des Event durch Funktionen, gelöschte Bits
//		                             // müssen auch wieder gesetzt werden
//		std::list<Vertex *>
//		    synchronized_vertexes; // Alle Vertexes die durch den EventGroupSynchronized Aufruf synchronisiert werden
//
//	  public:
//		std::string event_group_handle_name;
//		bool wait_for_all_bits;
//		bool wait_for_any_bit;
//
//		bool set_writing_vertex(Vertex *);
//		bool is_writing_vertex(Vertex *);
//
//		bool set_reading_vertex(Vertex *);
//		bool is_reading_vertex(Vertex *);
//
//		bool set_synchronized_vertex(Vertex *);
//		bool is_synchronized_vertex(Vertex *);
//
//		bool set_bit(int bit);
//		bool set_cleared_bit(int bit);
//
//		bool remove_bit(int bit);
//		bool remove_cleared_bit(int bit);
//
//		bool is_set_bit(int bit);
//		bool is_cleared_bit(int bit);
//
//		static bool classof(const Vertex *S);
//	};
//
//	class Buffer : graph::Vertex {
//	  public:
//		buffer_type type; // enum buffer_type {stream, message}
//		Vertex *reader;   // Buffer sind als single reader und single writer objekte gedacht
//		Vertex *writer;
//		int buffer_size;
//		int trigger_level; // Anzahl an Bytesm, die in buffer liegen müssen, bevor der Task den block status verlassen
//		                   // kann
//		bool static_buffer;
//
//		static bool classof(const Vertex *S);
//	};
//

} // namespace OS


#endif // GRAPH_H
