// vim: set noet ts=4 sw=4:

#ifndef GRAPH_H
#define GRAPH_H

#include <any>
#include <functional>
#include <list>
#include <string>
#include <tuple>
#include <typeinfo>
#include <memory>
#include "llvm/IR/Module.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Function.h"
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <iostream>
#include <sstream>
#include <queue>


typedef enum  { Task, ISR, Timer, normal }function_definition_type;

typedef enum  { sys_call, func_call, no_call , has_call }syscall_definition_type;

typedef enum  { ISR1, ISR2, basic }ISR_type;

typedef enum  { oneshot, autoreload }timer_type;

typedef enum  { binary, counting, mutex, recursive_mutex }semaphore_type;

typedef enum  { integer, floating, pointer, array, structure, string, initial }argument_type;

typedef enum  { stream, message }buffer_type;




namespace graph {

	class Graph;
	class Vertex;
	class Edge;

	// Basis Klasse des Graphen
	class Graph {

		private:
			std::list<std::shared_ptr<Vertex>> vertexes; // std::liste aller Vertexes des Graphen
			std::list<std::shared_ptr<Edge>> edges;      // std::liste aller Edges des Graphen
			
			std::shared_ptr<llvm::Module> llvm_module;
                
		public:
                
			Graph(std::shared_ptr<llvm::Module>);

			Graph();
			void set_llvm_module(std::shared_ptr<llvm::Module> module);
                
			llvm::Module* get_llvm_module();
                
			Vertex* set_vertex(Vertex *vertex); // vertex.clone(); innerhalb der set Methode um Objekt für die Klasse Graph zu speichern
			Edge* set_edge(Edge *edge); // edge.clone(); innerhalb der set Methode um Objekt für die Klasse Graph zu speichern
			
			Vertex * create_vertex();
			Edge * create_edge();
					
			std::list<Vertex*>get_type_vertexes(size_t type_info); // gebe alle Vertexes eines Types (Task, ISR, etc.) zurück
			Vertex* get_vertex(size_t seed);     // gebe Vertex mit dem entsprechenden hashValue zurück
			Edge* get_edge(size_t seed);     // gebe Edge mit dem entsprechenden hashValue zurück
			std::list<Vertex*> get_vertexes();  // gebe alle Vertexes des Graphen zurück
                
			std::list<Edge*> get_edges();  // gebe alle Edges des Graphen zurück

			bool remove_vertex(Vertex * vertex); // löschen den Vertex mit dem Namen und automatisch alle Knoten des Vertexes
												// aus dem Graphen
			bool remove_edge(Edge * edge); // löschen den Vertex mit dem Namen und automatisch alle Knoten des Vertexes aus dem Graphen
                
			bool contain_vertex(Vertex *vertex);
			
			bool contain_edge(Edge *edge);
   
                
	};


	// Basis Klasse für alle Vertexes
	class Vertex {

	  protected:
		Graph *graph; // Referenz zum Graphen, in der der Vertex gespeichert ist

                std::size_t type;
		std::string name; // spezifischer Name des Vertexes
		std::size_t seed; // für jedes Element spezifischer hashValue

		std::list<std::shared_ptr<Edge> *> outgoing_edges; // std::liste mit allen ausgehenden Kanten zu anderen Vertexes
		std::list<std::shared_ptr<Edge> *> ingoing_edges;  // std::liste mit allen eingehenden Kanten von anderen Vertexes

		std::list<std::shared_ptr<Vertex> *> outgoing_vertexes; // std::liste mit allen ausgehenden Vertexes zu anderen Vertexes
		std::list<std::shared_ptr<Vertex> *> ingoing_vertexes;  // std::liste mit allen eingehenden Vertexes von anderen Vertexes

	  public:
              /*
		// Discriminator for LLVM-style RTTI (dyn_cast<> et al.)
		enum VertexKind {
			Function,
			ISR,
			Timer,
			Task,
			Queue,
			EventGroups,
			Semaphore,
			Buffer,
			QueueSet

		};
		const VertexKind Kind;
		*/
                
		virtual Vertex *clone() const{return new Vertex(*this);};
                
		Vertex(Graph *graph,std::size_t type); // Construktor
    
                
		void set_type(std::size_t type);
		std::size_t get_type();
                
		std::string get_name(); // gebe Namen des Vertexes zurück
		std::size_t get_seed(); // gebe den Hash des Vertexes zurück

		//VertexKind getKind(); // LLVM-style RTTI const {return Kind}

		bool set_outgoing_edge(std::shared_ptr<Edge> *edge);
		bool set_ingoing_edge(std::shared_ptr<Edge> *edge);

		bool set_outgoing_vertex(std::shared_ptr<Vertex> *vertex);
		bool set_ingoing_vertex(std::shared_ptr<Vertex> *vertex);

		bool remove_edge(std::shared_ptr<Edge> *);
		bool remove_vertex(std::shared_ptr<Vertex> *vertex);
                
		Graph* get_graph();

		std::list<std::shared_ptr<Vertex>*>
		get_specific_connected_vertexes(size_t type_info); // get elements from graph with specific type

		std::list<Vertex*> get_vertex_chain(std::shared_ptr<Vertex*> *vertex); // Methode, die die Kette der Elemente vom Start bis zum Ziel Vertex zurück gibt,
		                     // interagieren die Betriebssystemabstrakionen nicht miteinader gebe nullptr zurück
		std::list<std::shared_ptr<Vertex> *>
		get_connected_vertexes();                // Methode, die die mit diesem Knoten verbundenen Vertexes zurückgibt
		std::list<std::shared_ptr<Edge>*> get_connected_edges(); // Methode, die die mit diesem Knoten verbundenen Edges zurückgibt
		std::list<std::shared_ptr<Vertex> *> get_ingoing_vertexes(); // Methode, die die mit diesem Knoten eingehenden Vertexes
		                                            // zurückgibt
		std::list<std::shared_ptr<Edge>*> get_ingoing_edges(); // Methode, die die mit diesem Knoten eingehenden Edges zurückgibt
		std::list<std::shared_ptr<Vertex>*>
		get_outgoing_vertexes();                // Methode, die die mit diesem Knoten ausgehenden Vertexes zurückgibt
		std::list<std::shared_ptr<Edge>*> get_outgoing_edges(); // Methode, die die mit diesem Knoten ausgehenden Edges zurückgibt
		std::list<std::shared_ptr<Edge>*>get_direct_edge(std::shared_ptr<Vertex> *vertex); // Methode, die direkte Kante zwischen Start und Ziel Vertex zurückgibt,
		                                   // falls keine vorhanden nullptr
		                                   
		//virtual  ~Vertex();
	};

	class ABB;

	// Klasse Edge verbindet zwei Betriebssystemabstraktionen über einen Syscall/Call mit entsprechenden Argumenten
	// Da jeder Edge der Start und Ziel Vertex zugeordnet ist, kann der Graph durchlaufen werden
	class Edge {

	  private:
		std::string name;
		Graph *graph;          // Referenz zum Graphen, in der der Vertex gespeichert ist
		std::size_t seed;      // für jedes Element spezifischer hashValue
		std::shared_ptr<Vertex> *start_vertex;  // Entsprechende Set- und Get-Methoden
		std::shared_ptr<Vertex> *target_vertex; // Entsprechende Set- und Get-Methoden
		bool is_syscall;       // Flag, ob Edge ein Syscall ist
		std::string call;      // Entsprechende Set- und Get-Methoden
		std::list<std::tuple<argument_type, std::any>> arguments;
		ABB *atomic_basic_block_reference;

	  public:
		
		virtual Edge *clone() const{return new Edge(*this);};
		
		
		Edge();
		Edge(Graph *graph, std::string name, std::shared_ptr<Vertex> *start, std::shared_ptr<Vertex> *target);

		std::string get_name(); // gebe Namen des Vertexes zurück
		std::size_t get_seed(); // gebe den Hash des Vertexes zurück

		bool set_start_vertex(std::shared_ptr<Vertex> *vertex);
		bool set_target_vertex(std::shared_ptr<Vertex> *edge);
		std::shared_ptr<Vertex> *get_start_vertex();
		std::shared_ptr<Vertex> *get_target_vertex();

		void set_syscall(bool syscall);
		bool is_sycall();

		std::list<std::tuple<argument_type, std::any>> get_arguments();
		void set_arguments(std::list<std::tuple<argument_type, std::any>> arguments);
		void append_argument(std::tuple<argument_type, std::any> argument);
	};
} // namespace graph

namespace OS {

	class ABB;
	class Task;
        class ISR;
	class QueueSet;
        class Function;

	// Einfache Funktion innerhalb der Applikation
	class Function : public graph::Vertex {

	  private:
		std::string function_name;       // name der Funktion
		std::list<llvm::Type*> argument_types; // Argumente des Functionsaufrufes
		llvm::Type* return_type;

		std::list<ABB *> atomic_basic_blocks;       // Liste der AtomicBasicBlocks, die die Funktion definieren
		std::list<OS::Task *> referenced_tasks;     // Liste aller Task, die diese Function aufrufen
		std::list<Function *> referenced_functions; // Liste aller Funktionen, die diese Funktion aufrufen
                
                std::list<OS::ISR *> referenced_ISRs;
		function_definition_type definition; // information, ob task ,isr, timer durch die Funktion definiert wird

		bool contains_critical_section;

		llvm::BasicBlock *start_critical_section_block; //  LLVM BasicBlock reference
		llvm::BasicBlock *end_critical_section_block;   //  LLVM BasicBlock reference

		llvm::Function *LLVM_function_reference; //*Referenz zum LLVM Function Object LLVM:Function -> Dadurch sind die
		                                         //sind auch die LLVM:BasicBlocks erreichbar und iterierbar*/
		
		ABB * front_abb;

                                                            
	  public:
                              
              
		Function *clone() const{return new Function(*this);};
                
		static bool classof(const Vertex *v); // LLVM RTTI class of Methode
                
                
		Function(graph::Graph *graph, std::size_t type,std::string name) : graph::Vertex(graph,type){
			this->function_name = name;
			this->name = name;
			std::hash<std::string> hash_fn;
			this->seed = hash_fn(name +  typeid(this).name());
		}
		
		void set_front_abb(ABB * abb);

		ABB* get_front_abb();

		void set_definition(function_definition_type type);
		function_definition_type get_definition();
                
                
		std::list<Function*>get_used_functions(); // Gebe std::liste aller Funktionen zurück, die diese Funktion benutzen
		bool set_used_function(OS::Function *function); // Setze Funktion in std::liste aller Funktionen, die diese Funktion benutzen


		bool set_start_critical_section_block(llvm::BasicBlock *basic_block);
		bool set_end_critical_section_block(llvm::BasicBlock *basic_block);

		llvm::BasicBlock *get_start_critical_section_block();
		llvm::BasicBlock *get_end_critical_section_block();

		bool has_critical_section();
		void set_critical_section(bool flag);
                
		bool set_llvm_reference(llvm::Function *function);
		llvm::Function *get_llvm_reference();

		void set_atomic_basic_block(ABB *atomic_basic_block);
		std::list<ABB *> get_atomic_basic_blocks();

		std::list<OS::Task *> get_referenced_tasks();

		bool set_referenced_task(OS::Task *task);

		bool set_referenced_function(OS::Function *function);
		
		
		void set_function_name(std::string name);
		std::string get_function_name();
                
		std::list<OS::Function *> get_referenced_functions();

		std::list<llvm::Type*> get_argument_types();
		void set_argument_type(llvm::Type* argument); // Setze Argument des SystemCalls in Argumentenliste
                
		void set_return_type(llvm::Type* argument); 
		llvm::Type * get_return_type();
	};

	// Klasse AtomicBasicBlock
	class ABB: public graph::Vertex  {

	  private:
              
		syscall_definition_type
		    type; // Information, welcher Syscall Typ, bzw. ob Computation Typ vorliegt (Computation, generate Task,
		          // generate Queue, ....; jeder Typ hat einen anderen integer Wert)
		std::list<ABB *> successors;   // AtomicBasicBlocks die dem BasicBlock folgen
		std::list<ABB *> predecessors;  // AtomicBasicBlocks die dem BasicBlock vorhergehen
		OS::Function *parent_function; // Zeiger auf Function, die den BasicBlock enthält
		
		
		std::list<llvm::BasicBlock *> basic_blocks;

		std::string call_name = ""; // Name des Sycalls
		
		std::list<std::tuple<std::any,llvm::Type*>> arguments;

		bool critical_section; // flag, ob AtomicBasicBlock in einer ḱritischen Sektion liegt

	  public:
              
		virtual ABB *clone() const{
			return new ABB(*this);};
		
		ABB(graph::Graph *graph,  std::size_t type,Function *function, std::string name) : graph::Vertex(graph,type){
			parent_function = function;
			this->name = name;
			std::hash<std::string> hash_fn;
			this->seed = hash_fn(name +  typeid(this).name());       
			this->type = no_call;
		}
              
		syscall_definition_type get_calltype();
		void set_calltype(syscall_definition_type type);

		void set_call_name(std::string call_name);
		std::string get_call_name();
		
		std::list<ABB *> get_ABB_successor();
		std::list<ABB *> get_ABB_predecessor();

		bool set_parent_function(OS::Function *function);
		OS::Function *get_parent_function();
				
		bool is_critical();
		void set_critical(bool critical);

		std::list<std::tuple<std::any,llvm::Type*>> get_arguments();
		void set_arguments(std::list<std::tuple<std::any,llvm::Type*>> new_arguments); // Setze Argument des SystemCalls in Argumentenliste

		void set_argument(std::any,llvm::Type* type);
		bool set_ABB_successor(ABB *basicblock);   // Speicher Referenz auf Nachfolger des BasicBlocks
		bool set_ABB_predecessor(ABB *basicblock); // Speicher Referenz auf Vorgänger des BasicBlocks
		std::list<ABB *> get_ABB_successors();      // Gebe Referenz auf Nachfolger zurück
		std::list<ABB *> get_ABB_predecessors();    // Gebe Referenz auf Vorgänger zurück

		bool set_BasicBlock(llvm::BasicBlock* basic_block);
		std::list<llvm::BasicBlock*> get_BasicBlocks();


                
	};

	// Bei Betriebssystem Abstraktionen wurden für die Attribute, die get- und set-Methoden ausgelassen und ein direkter
	// Zugriff erlaubt. Vielmehr wird der Zugriff auf interne Listen durch Methoden ermöglicht.

	class TaskGroup : public graph::Vertex {

	  private:
		std::string group_name;
		std::list<OS::Task *> task_group;

	  public:
              
                virtual TaskGroup *clone() const{return new TaskGroup(*this);};
                
		std::string get_name();
		void set_name(std::string name);
		bool set_task_in_group(OS::Task *task);
		bool remove_task_in_group(OS::Task *task);
		std::list<OS::Task *> get_tasks_in_group();
	};

	class Task : public graph::Vertex {

	  public:
              
                //virtual Task *clone() const{return new Task(*this);};
                
		OS::Function *definition_function;
		TaskGroup *task_group;

		// FreeRTOS attributes
		std::string handler_name;

		llvm::Type* parameter;

		int stacksize;
		int priority;

		bool gatekeeper;

		// OSEK attributes
		std::string AUTOSTART;
		std::string autostart_appmodes;
		std::string ACTIVATION;
		std::string SCHEDULE;
		std::string TASKGROUP;

		static bool classof(const Vertex *S);
	};

	class Timer : public graph::Vertex {

	  public:
              
                virtual Timer *clone() const{return new Timer(*this);};
                
		OS::Function *definition_function;

		int periode;     // Periode in Ticks
		timer_type type; // enum timer_type {One_shot_timer, Auto_reload_timer}
		int timer_id; // ID is a void pointer and can be used by the application writer for any purpose. useful when the
		              // same callback function is used by more software timers because it can be used to provide
		              // timer-specific storage.

		static bool classof(const Vertex *S);
	};

	class ISR : public graph::Vertex {

	  public:
              
                virtual ISR *clone() const{return new ISR(*this);};
              
		OS::Function *definition_function;

		std::string interrupt_source;
		std::string handler_name;
		int stacksize;
		int priority;

		static bool classof(const Vertex *S);
	};

	class QueueSet : public graph::Vertex {

	  private:
		std::list<std::shared_ptr<Vertex> *> queueset_elements; //  Queues, Semaphores

	  public:
              
                virtual QueueSet *clone() const{return new QueueSet(*this);};
                
		std::string queueset_handle_name;

		int length_queueset;
		bool set_queue(std::shared_ptr<Vertex> *element);
		bool member_of_queueset(std::shared_ptr<Vertex> *element);
		bool remove_from_queueset(std::shared_ptr<Vertex> *element);

		std::list<std::shared_ptr<Vertex> *> get_queueset_elements(); // gebe alle Elemente der Queueset zurück
		std::string get_queueset_handle_name();

		void set_queueset_handle_name(std::string name);

		static bool classof(const Vertex *S);
	};

	class Queue : public graph::Vertex {

	  public:
              
                virtual Queue *clone() const{return new Queue(*this);};
		OS::QueueSet *queueset_reference; // Referenz zur Queueset

		std::string handle_name; // Namen des Queue handle
		int length;              // Länger der Queue
		int item_size;

		std::list<std::shared_ptr<Vertex> *> get_accessed_elements(); // gebe ISR/Task zurück, die mit der Queue interagieren

		static bool classof(const Vertex *S);
	};

	class Semaphore : public graph::Vertex {

	  public:
              
                virtual Semaphore *clone() const{return new Semaphore(*this);};
		semaphore_type type; // enum semaphore_type {binary, counting, mutex, recursive_mutex}
		std::string handle_name;
		int max_count;
		int initial_count;

		std::list<std::shared_ptr<Vertex> *> get_accessed_elements(); // gebe alle Elemente zurück, die auf die Sempahore zugreifen

		static bool classof(const Vertex *S);
	};

	class EventGroups : public graph::Vertex {

	  private:
		std::list<std::shared_ptr<Vertex> *> writing_vertexes;
		std::list<std::shared_ptr<Vertex> *> reading_vertexes;

		std::list<int> set_bits;     // Auflisten aller gesetzen Bits des Event durch Funktionen
		std::list<int> cleared_bits; // Auflisten aller gelöschten Bits des Event durch Funktionen, gelöschte Bits
		                             // müssen auch wieder gesetzt werden
		std::list<std::shared_ptr<Vertex> *>
		    synchronized_vertexes; // Alle std::shared_ptr<Vertex>es die durch den EventGroupSynchronized Aufruf synchronisiert werden

	  public:
                virtual EventGroups *clone() const{return new EventGroups(*this);};
              
		std::string event_group_handle_name;
		bool wait_for_all_bits;
		bool wait_for_any_bit;

		bool set_writing_vertex(std::shared_ptr<Vertex> *);
		bool is_writing_vertex(std::shared_ptr<Vertex> *);

		bool set_reading_vertex(std::shared_ptr<Vertex> *);
		bool is_reading_vertex(std::shared_ptr<Vertex> *);

		bool set_synchronized_vertex(std::shared_ptr<Vertex> *);
		bool is_synchronized_vertex(std::shared_ptr<Vertex> *);

		bool set_bit(int bit);
		bool set_cleared_bit(int bit);

		bool remove_bit(int bit);
		bool remove_cleared_bit(int bit);

		bool is_set_bit(int bit);
		bool is_cleared_bit(int bit);

		static bool classof(const Vertex *S);
	};

	class Buffer : public graph::Vertex {
	  public:
              
                virtual Buffer *clone() const{return new Buffer(*this);};
		buffer_type type; // enum buffer_type {stream, message}
		std::shared_ptr<Vertex> *reader;   // Buffer sind als single reader und single writer objekte gedacht
		std::shared_ptr<Vertex> *writer;
		int buffer_size;
		int trigger_level; // Anzahl an Bytesm, die in buffer liegen müssen, bevor der Task den block status verlassen
		                   // kann
		bool static_buffer;

		static bool classof(const Vertex *S);
		
		~Buffer(){};
	};

} // namespace OS

#endif // GRAPH_H
