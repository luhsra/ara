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
#include <llvm/IRReader/IRReader.h>
#include <llvm/IR/DiagnosticInfo.h>
#include <iostream>
#include <sstream>
#include <queue>


typedef enum { Task, ISR, Timer, normal }function_definition_type;

typedef enum { sys_call, func_call, no_call , has_call }call_definition_type;

typedef enum {	computate ,create, destroy ,receive, approach ,release ,schedule} syscall_definition_type;

typedef enum { ISR1, ISR2, basic }ISR_type;

typedef enum { oneshot, autoreload }timer_type;

typedef enum { binary = 3, counting = 2, mutex = 1 , recursive_mutex = 4 }semaphore_type;

typedef enum { stream, message }buffer_type;

typedef enum {activate_task, set_event, alarm_callback} alarm_action_type;

typedef enum {standard, linked, internal} resource_type;

typedef enum {full, none} schedule_type;

typedef enum {automatic, mask} event_type;


namespace graph {



	class Graph;
	class Vertex;
	class Edge;
	
	
	typedef std::shared_ptr<Vertex> shared_vertex;
	typedef std::shared_ptr<Edge>  shared_edge;


	// Basis Klasse des Graphen
	class Graph {

		private:
			std::list<std::shared_ptr<Vertex>> vertices; // std::liste aller Vertexes des Graphen
			std::list<std::shared_ptr<Edge>> edges;      // std::liste aller Edges des Graphen
			
			std::shared_ptr<llvm::Module> llvm_module;
			


                
		public:
                
			//Graph(std::shared_ptr<llvm::Module>module);
	
			Graph();
	
			void load_llvm_module(std::string file);
			void set_llvm_module(std::shared_ptr<llvm::Module> module);
                
			llvm::Module* get_llvm_module();
                
			void set_vertex(shared_vertex vertex); // vertex.clone(); innerhalb der set Methode um Objekt für die Klasse Graph zu speichern
			void set_edge(shared_edge edge); // edge.clone(); innerhalb der set Methode um Objekt für die Klasse Graph zu speichern
			
			shared_vertex create_vertex();
			shared_edge create_edge();
					
			std::list<shared_vertex>get_type_vertices(size_t type_info); // gebe alle Vertexes eines Types (Task, ISR, etc.) zurück
			shared_vertex get_vertex(size_t seed);     // gebe Vertex mit dem entsprechenden hashValue zurück
			shared_edge get_edge(size_t seed);     // gebe Edge mit dem entsprechenden hashValue zurück
			
			shared_vertex get_vertex(std::string name);     // gebe Edge mit dem
			
			std::list<shared_vertex> get_vertices();  // gebe alle Vertexes des Graphen zurück
                
			std::list<shared_edge> get_edges();  // gebe alle Edges des Graphen zurück

			bool remove_vertex(shared_vertex *vertex); // löschen den Vertex mit dem Namen und automatisch alle Knoten des Vertexes
												// aus dem Graphen
			bool remove_edge(shared_edge *edge); // löschen den Vertex mit dem Namen und automatisch alle Knoten des Vertexes aus dem Graphen
                
			bool contain_vertex(shared_vertex vertex);
			
			bool contain_edge(shared_edge edge);
			
			std::string print_information();
			
			~Graph();
                
	};


	// Basis Klasse für alle Vertexes
	class Vertex {

	  protected:
		Graph *graph; // Referenz zum Graphen, in der der Vertex gespeichert ist

		std::size_t vertex_type;
		std::string name; // spezifischer Name des Vertexes
		std::size_t seed; // für jedes Element spezifischer hashValue

		std::list<shared_edge> outgoing_edges; // std::liste mit allen ausgehenden Kanten zu anderen Vertexes
		std::list<shared_edge> ingoing_edges;  // std::liste mit allen eingehenden Kanten von anderen Vertexes

		std::list<shared_vertex> outgoing_vertices; // std::liste mit allen ausgehenden Vertexes zu anderen Vertexes
		std::list<shared_vertex> ingoing_vertices;  // std::liste mit allen eingehenden Vertexes von anderen Vertexes

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
		
		virtual std::string print_information(){
			return "";
		};
		virtual Vertex *clone() const{return new Vertex(*this);};
                
		Vertex(Graph *graph,std::string name); // Constructor
    
                
		void set_type(std::size_t type);
		std::size_t get_type();
                
		std::string get_name(); // gebe Namen des Vertexes zurück
		std::size_t get_seed(); // gebe den Hash des Vertexes zurück

		//VertexKind getKind(); // LLVM-style RTTI const {return Kind}

		bool set_outgoing_edge(shared_edge edge);
		bool set_ingoing_edge(shared_edge edge);

		bool set_outgoing_vertex(shared_vertex vertex);
		bool set_ingoing_vertex(shared_vertex vertex);

		bool remove_edge(shared_edge edge);
		bool remove_vertex(shared_vertex vertex);
                
		Graph* get_graph();

		std::list<shared_vertex> get_specific_connected_vertices(size_t type_info); // get elements from graph with specific type

		std::list<shared_vertex> get_vertex_chain(shared_vertex target_vertex); // Methode, die die Kette der Elemente vom Start bis zum Ziel Vertex zurück gibt,
		                     // interagieren die Betriebssystemabstrakionen nicht miteinader gebe nullptr zurück
		std::list<shared_vertex>
		get_connected_vertices();                // Methode, die die mit diesem Knoten verbundenen Vertexes zurückgibt
		std::list<shared_edge> get_connected_edges(); // Methode, die die mit diesem Knoten verbundenen Edges zurückgibt
		std::list<shared_vertex> get_ingoing_vertices(); // Methode, die die mit diesem Knoten eingehenden Vertexes
		                                            // zurückgibt
		std::list<shared_edge> get_ingoing_edges(); // Methode, die die mit diesem Knoten eingehenden Edges zurückgibt
		std::list<shared_vertex>
		get_outgoing_vertices();                // Methode, die die mit diesem Knoten ausgehenden Vertexes zurückgibt
		std::list<shared_edge> get_outgoing_edges(); // Methode, die die mit diesem Knoten ausgehenden Edges zurückgibt
		std::list<shared_edge>get_direct_edge(shared_vertex vertex); // Methode, die direkte Kante zwischen Start und Ziel Vertex zurückgibt,
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
		shared_vertex start_vertex;  // Entsprechende Set- und Get-Methoden
		shared_vertex target_vertex; // Entsprechende Set- und Get-Methoden
		bool is_syscall;       // Flag, ob Edge ein Syscall ist
		std::string call;      // Entsprechende Set- und Get-Methoden
		std::list<std::tuple<std::any,llvm::Type*>> arguments;
		ABB *atomic_basic_block_reference;

	  public:
		
		virtual Edge *clone() const{return new Edge(*this);};
		
		
		Edge();
		Edge(Graph *graph, std::string name, shared_vertex start, shared_vertex target);

		std::string get_name(); // gebe Namen des Vertexes zurück
		std::size_t get_seed(); // gebe den Hash des Vertexes zurück

		bool set_start_vertex(shared_vertex vertex);
		bool set_target_vertex(shared_vertex vertex);
		shared_vertex get_start_vertex();
		shared_vertex get_target_vertex();

		void set_syscall(bool syscall);
		bool is_sycall();

		std::list<std::tuple<std::any,llvm::Type*>>* get_arguments();
		void set_arguments(std::list<std::tuple<std::any,llvm::Type*>> arguments);
		void set_argument(std::tuple<std::any,llvm::Type*> argument);
	};
} // namespace graph




namespace OS {

	class ABB;
	class Task;
	class ISR;
	class QueueSet;
	class Function;
	class Resource;
	class Message;
	class Event;
	class Counter;
	
	typedef std::shared_ptr<ABB> shared_abb;
	typedef std::shared_ptr<Function> shared_function;
	typedef std::shared_ptr<Task> shared_task;
	typedef std::shared_ptr<ISR> shared_isr;
	typedef std::shared_ptr<QueueSet> shared_queueset;
	typedef std::shared_ptr<Resource> shared_resource;
	typedef std::shared_ptr<Message> shared_message;
	typedef std::shared_ptr<Event> shared_event;
	typedef std::shared_ptr<Counter> shared_counter;

	// Einfache Funktion innerhalb der Applikation
	class Function : public graph::Vertex {

	  private:
		std::string function_name;       // name der Funktion
		std::list<llvm::Type*> argument_types; // Argumente des Functionsaufrufes
		llvm::Type* return_type;

		std::list<OS::shared_abb> atomic_basic_blocks;       // Liste der AtomicBasicBlocks, die die Funktion definieren
		std::list<OS::shared_task> referenced_tasks;     // Liste aller Task, die diese Function aufrufen
		std::list<OS::shared_function> referenced_functions; // Liste aller Funktionen, die diese Funktion aufrufen

		std::list<OS::ISR *> referenced_ISRs;
		function_definition_type definition; // information, ob task ,isr, timer durch die Funktion definiert wird

		bool contains_critical_section;

		llvm::BasicBlock *start_critical_section_block; //  LLVM BasicBlock reference
		llvm::BasicBlock *end_critical_section_block;   //  LLVM BasicBlock reference

		llvm::Function *LLVM_function_reference; //*Referenz zum LLVM Function Object LLVM:Function -> Dadurch sind die
		                                         //sind auch die LLVM:BasicBlocks erreichbar und iterierbar*/
		
		shared_abb front_abb;

                                                            
	  public:
                              
              
		Function *clone() const{return new Function(*this);};
		
		
		std::string print_information();
		
		static bool classof(const Vertex *v); // LLVM RTTI class of Methode
                
                
		Function(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
			this->function_name = name;
			std::hash<std::string> hash_fn;
			this->seed = hash_fn(name +  typeid(Function).name());
			this->vertex_type =  typeid(Function).hash_code();
			//std::cerr << "FunctionID: " << typeid(Function).hash_code() << std::endl;
		}
		
		void set_front_abb(shared_abb abb);

		shared_abb get_front_abb();

		void set_definition(function_definition_type type);
		function_definition_type get_definition();
                
                
		//Funktionen zurück, die diese Funktion benutzen
		bool set_used_function(OS::Function *function); // Setze Funktion in std::liste aller Funktionen, die diese Funktion benutzen


		bool set_start_critical_section_block(llvm::BasicBlock *basic_block);
		bool set_end_critical_section_block(llvm::BasicBlock *basic_block);

		llvm::BasicBlock *get_start_critical_section_block();
		llvm::BasicBlock *get_end_critical_section_block();

		bool has_critical_section();
		void set_critical_section(bool flag);
                
		bool set_llvm_reference(llvm::Function *function);
		llvm::Function *get_llvm_reference();

		void set_atomic_basic_block(OS::shared_abb atomic_basic_block);
		//std::list<graph::shared_vertex> get_atomic_basic_blocks();
		
		std::list<OS::shared_abb> get_atomic_basic_blocks();
		
		std::list<shared_task> get_referenced_tasks();

		bool set_referenced_task(shared_task task);

		bool set_referenced_function(shared_function function);
		
		
		void set_function_name(std::string name);
		std::string get_function_name();
                
		std::list<OS::shared_function> get_referenced_functions();

		std::list<llvm::Type*> get_argument_types();
		void set_argument_type(llvm::Type* argument); // Setze Argument des SystemCalls in Argumentenliste
                
		void set_return_type(llvm::Type* argument); 
		llvm::Type * get_return_type();
	};

	// Klasse AtomicBasicBlock
	class ABB: public graph::Vertex  {

	  private:
              
		call_definition_type    abb_type; // Information, welcher Syscall Typ, bzw. ob Computation Typ vorliegt (Computation, generate Task,
		          // generate Queue, ....; jeder Typ hat einen anderen integer Wert)
		
		syscall_definition_type abb_syscall_type;
		std::list<shared_abb> successors;   // AtomicBasicBlocks die dem BasicBlock folgen
		std::list<shared_abb> predecessors;  // AtomicBasicBlocks die dem BasicBlock vorhergehen
		shared_function parent_function; // Zeiger auf Function, die den BasicBlock enthält
		
		
		std::list<llvm::BasicBlock *> basic_blocks;

		std::string call_name = ""; // Name des Sycalls
		
		std::list<std::tuple<std::any,llvm::Type*>> arguments;
		
		std::size_t call_target_instance;
		
		llvm::Instruction* call_instruction_reference;
		bool critical_section; // flag, ob AtomicBasicBlock in einer ḱritischen Sektion liegt

	  public:
              
		virtual ABB *clone() const{
			return new ABB(*this);};
		
		
		std::string print_information();
		
		ABB(graph::Graph *graph,shared_function function, std::string name) : graph::Vertex(graph,name){
			parent_function = function;
			std::hash<std::string> hash_fn;
			this->seed = hash_fn(name +  typeid(ABB).name());
			this->abb_type = no_call;
			this->vertex_type = typeid(ABB).hash_code();
		}
		
		void set_call_instruction_reference(llvm::Instruction * call_instruction);
		llvm::Instruction* get_call_instruction_reference();
		
		syscall_definition_type get_syscall_type();
		void set_syscall_type(syscall_definition_type type);
		
		call_definition_type get_call_type();
		void set_call_type(call_definition_type type);

		size_t get_call_target_instance();
		void set_call_target_instance(size_t target_instance);
		
		void set_call_name(std::string call_name);
		std::string get_call_name();
		
		std::list<shared_abb> get_ABB_successor();
		std::list<shared_abb> get_ABB_predecessor();

		bool set_parent_function(shared_function function);
		shared_function get_parent_function();
				
		bool is_critical();
		void set_critical(bool critical);

		std::list<std::tuple<std::any,llvm::Type*>> get_arguments_tmp();
		std::list<std::tuple<std::any,llvm::Type*>>* get_arguments();
		void set_arguments(std::list<std::tuple<std::any,llvm::Type*>> new_arguments); // Setze Argument des SystemCalls in Argumentenliste

		void set_argument(std::any,llvm::Type* type);
		bool set_ABB_successor(shared_abb basicblock);   // Speicher Referenz auf Nachfolger des BasicBlocks
		bool set_ABB_predecessor(shared_abb basicblock); // Speicher Referenz auf Vorgänger des BasicBlocks
		std::list<shared_abb> get_ABB_successors();      // Gebe Referenz auf Nachfolger zurück
		std::list<shared_abb> get_ABB_predecessors();    // Gebe Referenz auf Vorgänger zurück

		bool set_BasicBlock(llvm::BasicBlock* basic_block);
		std::list<llvm::BasicBlock*> get_BasicBlocks();


                
	};

	// Bei Betriebssystem Abstraktionen wurden für die Attribute, die get- und set-Methoden ausgelassen und ein direkter
	// Zugriff erlaubt. Vielmehr wird der Zugriff auf interne Listen durch Methoden ermöglicht.

	class TaskGroup : public graph::Vertex {

	  private:
		std::list<OS::shared_task> task_group;

	  public:
		
		TaskGroup(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
			this->vertex_type = typeid(TaskGroup).hash_code();
		} 
		
		virtual TaskGroup *clone() const{return new TaskGroup(*this);};
		
		std::string print_information(){
			return "";	
		};
		
		std::string group_name;
		
		bool set_task_in_group(OS::shared_task task);
		bool remove_task_in_group(OS::shared_task task);
		std::list<OS::shared_task> get_tasks_in_group();
	};

	class Task : public graph::Vertex {
	
	private:
		
		OS::shared_function definition_function;
		TaskGroup *task_group;
		
		std::list<shared_resource> resources;
		std::list<shared_event> events;
		std::list<shared_message> messages;
		std::list<std::string> app_modes;
	
		int stacksize;
		int priority;
		
		// FreeRTOS attributes
		std::string handler_name;
		llvm::Type* parameter;
		bool gatekeeper;

		// OSEK attributes
		bool autostart;	// Information if Task is activated during system start or or application mode
		unsigned int activation;
		schedule_type scheduler; //NON/FULL defines preemptability of task
		
	public:
		
		Task(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
			this->vertex_type = typeid(Task).hash_code();
			//std::cerr << "name subclass: " << name << std::endl;
		}
		
		
		std::string print_information(){
			return "";	
		};
		//virtual Task *clone() const{return new Task(*this);};

		
		
		bool set_task_group(std::string taskgroup); //name of TaskGroup
		bool set_definition_function(std::string function_name);
		bool set_handler_name(std::string handler_name);
		void set_priority(unsigned long priority);
		void set_stacksize(unsigned long priority);
		bool set_scheduler(std::string scheduler);
		void set_activation(unsigned long activation);
		void set_autostart(bool autostart);
		void set_appmode(std::string app_mode);
		bool set_resource_reference(std::string resource);
		bool set_event_reference(std::string event);
		bool set_message_reference(std::string message);
		
		
		static bool classof(const Vertex *S);
	};

	class Timer : public graph::Vertex {

		OS::shared_function definition_function;
		
		
		int periode;     // Periode in Ticks
		timer_type type; // enum timer_type {One_shot_timer, Auto_reload_timer}
		int timer_id; // ID is a void pointer and can be used by the application writer for any purpose. useful when the
		              // same callback function is used by more software timers because it can be used to provide
		              // timer-specific storage.
		
	  public:

		Timer(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
			this->vertex_type = typeid(Timer).hash_code();
		}

		virtual Timer *clone() const{return new Timer(*this);};
	
		std::string print_information(){
			return "";	
		};
		
		void set_timer_type(timer_type type);
		timer_type get_timer_type();
		void set_timer_id(unsigned long timer_id);
		void set_periode(unsigned long period);
		
		unsigned long get_timer_id();
		unsigned long get_periode();
		
		bool set_definition_function(std::string definition_function_name);


		static bool classof(const Vertex *S);
	};

	class ISR : public graph::Vertex {

		OS::shared_function definition_function;
		
		
		//OSEK attributes
		int category;			// OSEK just values 0 and 1 are allowed
		int stacksize;
		
		std::list<shared_resource> resources;
		std::list<shared_message> messages;
		
		//FreeRTOS attributes
		std::string interrupt_source;
		std::string handler_name;
		int priority;
		
	  public:

		ISR(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
			this->vertex_type = typeid(ISR).hash_code();
			//std::cerr  << "name: " << name << "\n";
		}
		
		std::string print_information(){
			return "";	
		};

		bool set_category(int category);
		bool set_message_reference(std::string);
		bool set_resource_reference(std::string);
		
		static bool classof(const Vertex *S);
	};

	class QueueSet : public graph::Vertex {

	  private:
		  
			std::string handler_name;

			unsigned long length;
		
			std::list<graph::shared_vertex> queueset_elements; //  Queues, Semaphores

	  public:
	  
			QueueSet(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(QueueSet).hash_code();
			}

			virtual QueueSet *clone() const{return new QueueSet(*this);};

			
			bool set_queue_element(graph::shared_vertex element);
			bool member_of_queueset(graph::shared_vertex element);
			bool remove_from_queueset(graph::shared_vertex element);

			std::list<graph::shared_vertex> get_queueset_elements(); // gebe alle Elemente der Queueset zurück
			std::string get_queueset_handler_name();

			void set_handler_name(std::string name);
			void set_length (unsigned long length);

			static bool classof(const Vertex *S);
	};

	class Queue : public graph::Vertex {
		
		private:
			
			OS::shared_queueset queueset_reference; // Referenz zur Queueset

			std::string handler_name; // Namen des Queue handle
			int length;              // Länger der Queue
			int item_size;
				
		public:
			
			Queue(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(Queue).hash_code();
			}
			std::string print_information(){
				return "";	
			};
			
			void set_handler_name(std::string handler_name);
			
			unsigned long get_item_size();
			void set_item_size(unsigned long size);
			
			unsigned long get_length();
			void set_length(unsigned long size);
			
			bool set_queueset_reference(shared_queueset);
			shared_queueset get_queueset_reference();
			std::list<graph::shared_vertex> get_accessed_elements(); // gebe ISR/Task zurück, die mit der Queue interagieren

			static bool classof(const Vertex *S);
	};

	class Semaphore : public graph::Vertex {

		private:
		
			semaphore_type type; // enum semaphore_type {binary, counting, mutex, recursive_mutex}
			std::string handler_name;
			unsigned long max_count;
			unsigned long initial_count;

			std::list<graph::shared_vertex> get_accessed_elements(); 
			
		public:
		
			Semaphore(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(Semaphore).hash_code();
			}
		
			void set_semaphore_type(semaphore_type type);
			semaphore_type get_semaphore_type();
			
			void set_max_count(unsigned long count);
			unsigned long get_max_count();
			
			void set_initial_count(unsigned long count);
			unsigned long get_initial_count();
			
			void set_handler_name(std::string name);
			std::string get_handler_name();
			
			
			std::string print_information(){
				return "";	
			};

			virtual Semaphore *clone() const{return new Semaphore(*this);};
			// gebe alle Elemente zurück, die auf die Sempahore zugreifen

			static bool classof(const Vertex *S);
	};

	class EventGroup : public graph::Vertex {

	  private:
		std::list<graph::shared_vertex> writing_vertices;
		std::list<graph::shared_vertex> reading_vertices;

		std::list<int> set_bits;     // Auflisten aller gesetzen Bits des Event durch Funktionen
		std::list<int> cleared_bits; // Auflisten aller gelöschten Bits des Event durch Funktionen, gelöschte Bits
		                             // müssen auch wieder gesetzt werden
		std::list<graph::shared_vertex >
		    synchronized_vertices; // Alle Vertexes die durch den EventGroupSynchronized Aufruf synchronisiert werden
		std::string handler_name;
	  public:
		
		EventGroup(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(EventGroup).hash_code();
		}
		
		std::string print_information(){
			return "";	
		};
			
		virtual EventGroup *clone() const{return new EventGroup(*this);};
		
		void set_handler_name(std::string handler_name);
		bool wait_for_all_bits;
		bool wait_for_any_bit;

		bool set_writing_vertex(graph::shared_vertex vertex);
		bool is_writing_vertex(graph::shared_vertex vertex);

		bool set_reading_vertex(graph::shared_vertex vertex);
		bool is_reading_vertex(graph::shared_vertex vertex);

		bool set_synchronized_vertex(graph::shared_vertex vertex);
		bool is_synchronized_vertex(graph::shared_vertex vertex);

		bool set_bit(int bit);
		bool set_cleared_bit(int bit);

		bool remove_bit(int bit);
		bool remove_cleared_bit(int bit);

		bool is_set_bit(int bit);
		bool is_cleared_bit(int bit);

		static bool classof(const Vertex *S);
	};

	class Buffer : public graph::Vertex {
	  
		private:
			
			buffer_type type; // enum buffer_type {stream, message}
			graph::shared_vertex reader;   // Buffer sind als single reader und single writer objekte gedacht
			graph::shared_vertex writer;
			int buffer_size;
			int trigger_level; // Anzahl an Bytesm, die in buffer liegen müssen, bevor der Task den block status verlassen
							// kann
			bool static_buffer;
	
		public:
			
			
			std::string print_information(){
				return "";	
			};

			static bool classof(const Vertex *S);
			
			~Buffer(){};
	};
	
	class Event: public graph::Vertex{
		
		private:
			std::list<OS::shared_task> task_reference;
			unsigned long  event_mask;
			unsigned int id;
			event_type mask_type;
			
		public:
			
			Event(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(Event).hash_code();
				//std::cerr << "name subclass: " << name << std::endl;
			};
			
			
			std::string print_information(){
				return "";	
			};
			
			bool set_task_reference(OS::shared_task task);
			std::list<OS::shared_task> get_task_references();
			void set_event_mask(unsigned long  mask);
			void set_event_mask_auto();
			void set_id(unsigned int id);
			
	};
	
	class Resource :public graph::Vertex{
		
		private:
			std::list<OS::shared_task> tasks;
			std::list<OS::shared_isr> irs;
			std::list<OS::shared_resource> resources;
			
			resource_type type;
			
		public:
			Resource(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(Resource).hash_code();
				//std::cerr << "name subclass: " << name << std::endl;
			};
			bool set_task_reference(OS::shared_task task);
			std::list<OS::shared_task> get_task_references();
			
			bool set_isr_reference(OS::shared_isr isr);
			std::list<OS::shared_isr> get_isr_references();
			
			bool set_linked_resource(OS::shared_resource resource);
			std::list<OS::shared_resource> get_linked_resources();
			
			bool set_resource_property(std::string type, std::string linked_resource);
			
			resource_type get_resource_type();
			
	};
	
	class Counter :public graph::Vertex{
		
			unsigned long max_allowed_value;
			unsigned long ticks_per_base;
			unsigned long min_cycle;
			
		public:
			
			Counter(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(Counter).hash_code();
				//std::cerr << "name subclass: " << name << std::endl;
			};
			
			
			std::string print_information(){
				return "";	
			};
			
			void set_max_allowed_value(unsigned long max_allowedvalue);
			void set_ticks_per_base(unsigned long ticks);
			void set_min_cycle(unsigned long min_cycle); 
	};
	
	
	//OSEK class
	class Alarm :public graph::Vertex{
		
		private:
		
			OS::shared_task referenced_task;
			OS::shared_event referenced_event;
			OS::shared_counter referenced_counter;
						
			alarm_action_type action;
			
			std::string alarm_callback;
			
			std::list<std::string> appmodes;
			
			bool autostart;
			unsigned int alarm_time;
			unsigned int cycle_time;
			
		public:
			
			Alarm(graph::Graph *graph,std::string name) : graph::Vertex(graph,name){
				this->vertex_type = typeid(Alarm).hash_code();
				//std::cerr << "name subclass: " << name << std::endl;
			};
			
			std::string print_information(){
				return "";	
			};

			bool set_task_reference(std::string task);
			OS::shared_task get_task_reference();
			
			bool set_counter_reference(std::string counter);
			OS::shared_counter get_counter_reference();
			
			
			bool set_event_reference(std::string event);
			void set_alarm_callback_reference(std::string callback_name);
			
			void set_autostart(bool flag);
			void set_alarm_time(unsigned int alarm_time);
			void set_cycle_time(unsigned int cycle_time);
			
			void set_appmode(std::string appmode);

	};
	

	
	
	

} // namespace OS

#endif // GRAPH_H
