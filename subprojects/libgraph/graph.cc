// vim: set noet ts=4 sw=4:

#include "graph.h"
#include <iostream>

using namespace graph;
using namespace llvm;

/*graph::Graph::Graph(std::shared_ptr<llvm::Module> module){
    llvm_module = module;
}
*/

//help function to use string in switch case statements
constexpr unsigned int str2int(const char* str, int h = 0)
{
    return !str[h] ? 5381 : (str2int(str, h+1) * 33) ^ str[h];
}

graph::Graph::~Graph(){
}



graph::Graph::Graph(){
}


void graph::Graph::set_llvm_module(std::shared_ptr<llvm::Module> module){

	llvm_module = module;
}

void load_llvm_module(std::string file){
	
	llvm::SMDiagnostic Err;
	//this->tmp_module = parseIRFile(file, Err, *(this->llvm_context)).get();
}


llvm::Module* graph::Graph::get_llvm_module(){
    return this->llvm_module.get();
}

void graph::Graph::set_vertex(shared_vertex vertex){
	
	//std::cerr << vertex->get_name();
	
	if(vertex == nullptr){
		std::cerr << " set nullptr in list";
	} 
	
	this->vertices.emplace_back(vertex);
}

void graph::Graph::set_edge(shared_edge edge){
    this->edges.emplace_back(edge);
}

shared_vertex graph::Graph::create_vertex(){
    shared_vertex vertex = std::make_shared<Vertex>(this,""); 	//create shared po
    this->vertices.emplace_back(vertex);                   		//store the shared pointer in the internal list
    return vertex;
}

shared_edge graph::Graph::create_edge(){
    shared_edge edge = std::make_shared<Edge>();    		//create shared pointer
    this->edges.emplace_back(edge);               				//store the shared pointer in the internal list
    return edge;
}

std::list<shared_vertex> graph::Graph::get_type_vertices(size_t type_info){
    std::list<shared_vertex> tmp_list;
    std::list<shared_vertex>::iterator it = this->vertices.begin();       //iterate about the list elements
	
    for(; it != this->vertices.end(); ++it){
		
		
		//std::cerr << "searched type: " << type_info << ";current type: " << (*it).get()->get_type() << std::endl;
        if(type_info==(*it).get()->get_type()){                                         //check if vertex is from wanted type
			//std::cerr << "succes\n";
            tmp_list.emplace_back((*it));
        }
    }
    return tmp_list;
}

shared_vertex graph::Graph::get_vertex(size_t seed){   
    //gebe Vertex mit dem entsprechenden hashValue zurück
    std::list<shared_vertex>::iterator it = this->vertices.begin();       //iterate about the list elements
	
    for(; it != this->vertices.end(); ++it){
		
        //gesuchter vertex gefunden
        if(seed==(*it)->get_seed()){//check if vertex is from wanted type
		
			return (*it); 
        }
    }
    return nullptr;
}


shared_vertex graph::Graph::get_vertex(std::string name){   
    //gebe Vertex mit dem entsprechenden hashValue zurück
    std::list<shared_vertex>::iterator it = this->vertices.begin();       //iterate about the list elements
	
	shared_vertex return_vertex;
	int counter = 0;
	
	for (auto& vertex : this->vertices) {
		if(name==vertex->get_name()){                                         //check if vertex is from wanted type
			counter++;
			return_vertex = vertex; 
        }
	}
	
    if(counter == 1){
		return return_vertex;
	}
	else{
		return nullptr;
	}
		
}


shared_edge graph::Graph::get_edge(size_t seed){   
    //gebe edge mit dem entsprechenden hashValue zurück
    std::list<shared_edge>::iterator it = this->edges.begin();       //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        //gesuchter vertex gefunden
        if(seed==(*it)->get_seed()){                                         //check if vertex is from wanted type
           return (*it); 
        }
    }
    return nullptr;
}

std::list<shared_vertex> graph::Graph::get_vertices(){
    std::list<shared_vertex> tmp_list;
    std::list<shared_vertex>::iterator it = this->vertices.begin();            //iterate about the list elements
    for(; it != this->vertices.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

std::list<shared_edge> graph::Graph::get_edges(){
    std::list<shared_edge> tmp_list;
    std::list<shared_edge>::iterator it = this->edges.begin();           //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

bool graph::Graph::remove_vertex(size_t seed){
    bool success = false;
    std::list<shared_vertex>::iterator it = this->vertices.begin();           //iterate about the list elements
    for(; it != this->vertices.end(); ++it){
        if(seed == (*it)->get_seed()){
            //TODO remove edges
            it = this->vertices.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}


bool graph::Graph::remove_vertex(graph::shared_vertex vertex){
    bool success = false;
    std::list<shared_vertex>::iterator it = this->vertices.begin();           //iterate about the list elements
    for(; it != this->vertices.end(); ++it){
        if(vertex->get_seed() == (*it)->get_seed()){
            //TODO remove edges
            it = this->vertices.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}

bool graph::Graph::remove_edge(shared_edge *edge){
    bool success = false;
    std::list<shared_edge>::iterator it = this->edges.begin();           //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        if(edge->get()->get_seed() == (*it)->get_seed()){
            //TODO remove edges
            it = this->edges.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}

bool graph::Graph::contain_vertex(shared_vertex vertex){
    bool success = false;
    std::list<shared_vertex>::iterator it = this->vertices.begin();           //iterate about the list elements
    for(; it != this->vertices.end(); ++it){
        if(vertex->get_seed() == ((*it)->get_seed())){
            success = true;
            break;
        }
    }
    return success;
}

bool graph::Graph::contain_edge(shared_edge edge){
    bool success = false;
    std::list<shared_edge>::iterator it = this->edges.begin();           //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        if(edge->get_seed() ==(*it)->get_seed()){
            success = true;
            break;
        }
    }
    return success;
}





graph::Vertex::Vertex(Graph *graph,std::string name){
	
    this->graph = graph;
	this->name = name;
	//std::cerr  << "name: " << this->name << "\n";
}

std::string graph::Vertex::get_name(){
        return this->name;
}

std::size_t graph::Vertex::get_seed(){
        return this->seed;
}

bool graph::Vertex::set_outgoing_edge(shared_edge edge){
	bool success = false;
    if(this->graph->contain_edge(edge)){
		success = true;
		this->outgoing_edges.emplace_back(edge);
	}
    return success;
}

bool graph::Vertex::set_ingoing_edge(shared_edge edge){
	bool success = false;
    if(this->graph->contain_edge(edge)){
		success = true;
		this->ingoing_edges.emplace_back(edge);
	}
    return success;
}

bool graph::Vertex::set_outgoing_vertex(shared_vertex vertex){
	bool success = false;
    if(this->graph->contain_vertex(vertex)){
		success = true;
		this->outgoing_vertices.emplace_back(vertex);
	}
    return success;
}

bool graph::Vertex::set_ingoing_vertex(shared_vertex vertex){
	bool success = false;
    if(this->graph->contain_vertex(vertex)){
		success = true;
		this->ingoing_vertices.emplace_back(vertex);
	}
    return success;
}

bool graph::Vertex::remove_edge(shared_edge edge){
    bool success = false;
    std::list<shared_edge>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
    for(; it != this->outgoing_edges.end(); ++it){
        if(edge == (*it)){
            it = this->outgoing_edges.erase(it--);
            success = true;
            break;
        }
    }
    for(it = this->ingoing_edges.begin();  it != this->ingoing_edges.end(); ++it){
        if(edge == (*it)){
            it = this->ingoing_edges.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}

bool graph::Vertex::remove_vertex(shared_vertex vertex){
    bool success = false;
    std::list<shared_vertex>::iterator it = this->outgoing_vertices.begin();           //iterate about the list elements
    //iterate about the outgoing vertices
    for(; it != this->outgoing_vertices.end(); ++it){
        if(vertex == (*it)){
            it = this->outgoing_vertices.erase(it--);
            success = true;
            break;
        }
    }
    //iterate about the ingoing vertices
    for(it = this->ingoing_vertices.begin();  it != this->ingoing_vertices.end(); ++it){
        if(vertex == (*it)){
            it = this->ingoing_vertices.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}

std::list<graph::shared_vertex > graph::Vertex::get_specific_connected_vertices(size_t type_info){
    std::list<shared_vertex> tmp_list;
    std::list<shared_vertex>::iterator it = this->outgoing_vertices.begin();           //iterate about the list elements
    //iterate about the outgoing vertices
    for(; it != this->outgoing_vertices.end(); ++it){
        if((*it)->get_type() == type_info){
            tmp_list.emplace_back(*it);
        }
    }
    //iterate about the ingoing vertices
    for(it = this->ingoing_vertices.begin();  it != this->ingoing_vertices.end(); ++it){
         if((*it)->get_type() == type_info){
            tmp_list.emplace_back(*it);
        }
    }
    return tmp_list;
}

//width search
std::list<graph::shared_vertex > wide_search (Vertex* start,graph::shared_vertex end){
    std::list<graph::shared_vertex> tmp_list;
    /*//TODO
	std::queue<graph::shared_vertex> queue;
    queue.push(*start);
    tmp_list.emplace_back(start);
    std::vector<size_t> visited;
    visited.emplace_back(start->get_seed());
    //iterate about the queue with open elements
    while(!queue.empty()){
        graph::shared_vertex tmp = queue.front();
        queue.pop();
        if(&tmp==&end) return tmp_list;
        std::list<graph::shared_vertex> neighbours = tmp->get_outgoing_vertices();
        std::list<graph::shared_vertex>::iterator it = neighbours.begin();

        for(; it != neighbours.end(); ++it){
            if(!(std::find(visited.begin(), visited.end(), (*it)->get_seed()) != visited.end())){
                queue.push(*it);
                tmp_list.emplace_back(*it);
            }
        }
    }
    */
    return tmp_list;
}

std::list<graph::shared_vertex> graph::Vertex::get_vertex_chain(graph::shared_vertex vertex){     // Methode, die die Kette der Elemente vom Start bis zum Ziel Vertex zurück gibt,
    return wide_search(this, vertex); // interagieren die Betriebssystemabstrakionen nicht miteinader gebe nullptr zurück
}

std::list<graph::shared_vertex >graph::Vertex::get_connected_vertices(){ // Methode, die die mit diesem Knoten verbundenen Vertexes zurückgibt
    std::list<graph::shared_vertex> tmp_list;
    std::list<graph::shared_vertex>::iterator it = this->outgoing_vertices.begin();           //iterate about the list elements
    //iterate about the outgoing vertices
    for(; it != this->outgoing_vertices.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    //iterate about the ingoing vertices
    for(it = this->ingoing_vertices.begin();  it != this->ingoing_vertices.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge> graph::Vertex::get_connected_edges(){ // Methode, die die mit diesem Knoten verbundenen Edges zurückgibt

    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
    //iterate about the outgoing edges
    for(; it != this->outgoing_edges.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    //iterate about the ingoing edges
    for(it = this->ingoing_edges.begin();  it != this->ingoing_edges.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_vertex > graph::Vertex::get_ingoing_vertices(){    // Methode, die die mit diesem Knoten eingehenden Vertexes
                                                                // zurückgibt
    std::list<graph::shared_vertex> tmp_list;
    std::list<graph::shared_vertex>::iterator it = this->ingoing_vertices.begin();
    for(; it != this->ingoing_vertices.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge> graph::Vertex::get_ingoing_edges(){ // Methode, die die mit diesem Knoten eingehenden Edges zurückgibt
    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->ingoing_edges.begin();
    for(; it != this->ingoing_edges.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_vertex > graph::Vertex::get_outgoing_vertices(){                // Methode, die die mit diesem Knoten ausgehenden Vertexes zurückgibt
    std::list<graph::shared_vertex> tmp_list;
    std::list<graph::shared_vertex>::iterator it = this->outgoing_vertices.begin();
    for(; it != this->outgoing_vertices.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge > graph::Vertex::get_outgoing_edges(){ // Methode, die die mit diesem Knoten ausgehenden Edges zurückgibt
    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->outgoing_edges.begin();
    for(; it != this->outgoing_edges.end(); ++it){
        tmp_list.emplace_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge> graph::Vertex::get_direct_edge(graph::shared_vertex vertex){ // Methode, die direkte Kante zwischen Start und Ziel Vertex zurückgibt,
    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
    //iterate about the outgoing vertices
    for(; it != this->outgoing_edges.end(); ++it){
        if(vertex->get_seed()==((*it)->get_target_vertex()->get_seed())){
            tmp_list.emplace_back(*it);
        }
    }
    //iterate about the ingoing verticesget
    for(it = this->ingoing_edges.begin();  it != this->ingoing_edges.end(); ++it){
        if(vertex->get_seed()==((*it)->get_start_vertex()->get_seed())){
            tmp_list.emplace_back(*it);
        }
    }
    return tmp_list;
}

void graph::Vertex::set_type(std::size_t type){
    this->vertex_type = type;
}


std::size_t graph::Vertex::get_type(){
    return this->vertex_type;
}

std::string graph::Vertex::get_handler_name(){
    return this->handler_name;
}


void graph::Vertex::set_handler_name(std::string handler_name){
     this->handler_name = handler_name;
}

void graph::Vertex::set_start_scheduler_creation_flag(bool flag){
     this->start_scheduler_creation_flag = flag;
}

bool graph::Vertex::get_start_scheduler_creation_flag(){
	return this->start_scheduler_creation_flag;
}





graph::Edge::Edge(){
    this->name = "";
    this->graph = nullptr;
}







graph::Edge::Edge(Graph *graph, std::string name, shared_vertex start, shared_vertex target,shared_vertex atomic_basic_block_reference){
    this->name = name;
    this->graph = graph;
    this->start_vertex = start;
    this->target_vertex = target;
	this->atomic_basic_block_reference = atomic_basic_block_reference;
}


std::string graph::Edge::get_name(){
    return this->name;
}
std::size_t graph::Edge::get_seed(){
    return this->seed;
}

bool graph::Edge::set_start_vertex(graph::shared_vertex vertex){
    bool success = false;
    if(this->graph->contain_vertex(vertex)){
        success = true;
        this->start_vertex =vertex;  
    }
    return success;
}

bool graph::Edge::set_target_vertex(graph::shared_vertex vertex){
    bool success = false;
    if(this->graph->contain_vertex(vertex)){
        success = true;
        this->target_vertex =vertex;
    }
    return success;
}


graph::shared_vertex graph::Edge::get_start_vertex(){return this->target_vertex;}
graph::shared_vertex graph::Edge::get_target_vertex(){return this->start_vertex;}

void graph::Edge::set_syscall(bool syscall){this->is_syscall = syscall;}
bool graph::Edge::is_sycall(){return this->is_syscall;}




std::list<std::tuple< std::any,llvm::Type*>>* graph::Edge::get_arguments(){
	std::cout << "TEST";
	return &this->arguments;
	
}



void graph::Edge::set_arguments(std::list<std::tuple<std::any,llvm::Type*>> arguments){
    this->arguments = arguments;
    return;
}

void graph::Edge::set_argument(std::tuple<std::any,llvm::Type*> argument){
    this->arguments.emplace_back(argument);
    return;
}


bool OS::Function::remove_abb(size_t seed){
	
	bool success = false;
	for (auto itr = this->atomic_basic_blocks.begin(); itr != this->atomic_basic_blocks.end(); ){
		if ((*itr)->get_seed() == seed){
			success = true;
			itr = this->atomic_basic_blocks.erase(itr);
		}
		else{
			++itr;
		}
	}
	if(this->front_abb->get_seed() == seed)this->front_abb =nullptr;
	if(this->exit_abb->get_seed() == seed)this->exit_abb =nullptr;
	
	return success;
	
}



bool OS::Function::set_definition_vertex(graph::shared_vertex vertex){
	bool success =false;
	if(this->graph->contain_vertex(vertex)){
		this->definition_element = vertex;
		success = true;
	}
	return success;
}

graph::shared_vertex OS::Function::get_definition_vertex(){
	return this->definition_element;
}

void OS::Function::has_syscall(bool flag){
    this->syscall_flag = flag;
}

bool OS::Function::has_syscall(){
    return this->syscall_flag ;
}


void OS::Function::set_function_name(std::string name){
    this->function_name = name;
}


std::string OS::Function::get_function_name(){
    return this->function_name;
}






void OS::Function::set_definition(function_definition_type type){
        this->definition = type;
}

function_definition_type OS::Function::get_definition(){return this->definition;}


std::list<OS::shared_function> OS::Function::get_referenced_functions(){return (this->referenced_functions);} // Gebe std::liste aller Funktionen zurück, die diese Funktion benutzen


bool OS::Function::set_referenced_function(OS::shared_function function){
    bool success = false;
    graph::Graph graph = (*this->graph);
    if(this->graph->contain_vertex(function)){
        this->referenced_functions.emplace_back(function);
        success = true;
    }
    return success;
} // Setze Funktion in std::liste aller Funktionen, die diese Funktion benutzen


bool OS::Function::set_start_critical_section_block(llvm::BasicBlock *basic_block){
        //TODO check if llvm function exists in module
        this->start_critical_section_block = basic_block;
        return true;
}
bool OS::Function::set_end_critical_section_block(llvm::BasicBlock *basic_block){
        //TODO check if llvm function exists in module
        this->end_critical_section_block = basic_block;
        return true;
}   

llvm::BasicBlock* OS::Function::get_start_critical_section_block(){return this->start_critical_section_block;}
llvm::BasicBlock* OS::Function::get_end_critical_section_block(){return this->end_critical_section_block;}


bool OS::Function::has_critical_section(){
    return this->contains_critical_section;
}

void OS::Function::set_critical_section(bool flag){
    this->contains_critical_section = flag;
    return;
}


bool OS::Function::set_llvm_reference(llvm::Function *function){
    
    //TODO check if llvm function exists in module
    this->LLVM_function_reference= function;   
    return true;
}


llvm::Function* OS::Function::get_llvm_reference(){return this->LLVM_function_reference;}



void OS::Function::set_atomic_basic_block(OS::shared_abb atomic_basic_block){
    this->atomic_basic_blocks.emplace_back(atomic_basic_block);
}

/*
std::list<graph::shared_vertex> OS::Function::get_atomic_basic_blocks(){
	std::list<graph::shared_vertex> tmp_list;
	for(auto &abb : this->atomic_basic_blocks){
			tmp_list.emplace_back(abb);
	}
	return tmp_list;
}*/


std::list<OS::shared_abb> OS::Function::get_atomic_basic_blocks(){
	//std::cerr << this->atomic_basic_blocks.size() << std::endl;
	return this->atomic_basic_blocks;
	
}


std::list<OS::shared_task> OS::Function::get_referenced_tasks(){
    return this->referenced_tasks;
}

bool OS::Function::set_referenced_task(OS::shared_task task){
    bool success = false;
	
    if(this->graph->contain_vertex(task)){
        this->referenced_tasks.emplace_back(task);
        success = true;
    }
    return success;
}






std::list<llvm::Type*>  OS::Function::get_argument_types(){
    return this->argument_types;
}

void  OS::Function::set_argument_type(llvm::Type* argument){ // Setze Argument des SystemCalls in Argumentenliste
    this->argument_types.emplace_back(argument);
}


void OS::Function::set_return_type(llvm::Type* type){
    return_type = type;
}

llvm::Type * OS::Function::get_return_type(){
    return return_type;
}


		
void OS::Function::set_front_abb(OS::shared_abb abb){
	this->front_abb = abb;
}

void OS::Function::set_exit_abb(OS::shared_abb abb){
	this->exit_abb = abb;
}


OS::shared_abb OS::Function::get_exit_abb(){
	return this->exit_abb;
}


OS::shared_abb OS::Function::get_front_abb(){
	return this->front_abb;
}




void OS::ABB::set_call_target_instance(size_t target_instance){
	this->call_target_instances.emplace_back(target_instance);
}


syscall_definition_type OS::ABB::get_syscall_type(){
    return this->abb_syscall_type;
}

void OS::ABB::set_syscall_type(syscall_definition_type type){
    this->abb_syscall_type = type;
}


std::list<std::size_t>* OS::ABB::get_call_target_instances(){
	return  &(this->call_target_instances);
}


call_definition_type OS::ABB::get_call_type(){
    return this->abb_type;
}

void OS::ABB::set_call_type(call_definition_type type){
    this->abb_type = type;
}




bool OS::ABB::is_critical(){return this->critical_section;}
void OS::ABB::set_critical(bool critical){this->critical_section = critical;}


std::list<std::list<std::tuple<std::any,llvm::Type*>>>* OS::ABB::get_arguments(){
	//std::cerr << "length: " << this->arguments.size() << std::endl;
	return &this->arguments;
}

std::list<std::tuple<std::any,llvm::Type*>>* OS::ABB::get_syscall_arguments(){
	//std::cerr << "length: " << this->arguments.size() << std::endl;
	return &this->syscall_arguments;
}

/*
std::list<std::tuple< std::any,llvm::Type*>> OS::ABB::get_arguments_tmp(){
	return this->arguments;
}*/



void OS::ABB::set_arguments(std::list<std::tuple<std::any,llvm::Type*>> new_arguments){
    this->arguments.push_back(new_arguments);
	
	
} // Setze Argument des SystemCalls in Argumentenliste




bool OS::ABB::set_ABB_successor(OS::shared_abb basicblock){
	this->successors.emplace_back(basicblock);
        //TODO check if basic_block exists in module
	return true;	
}   // Speicher Referenz auf Nachfolger des BasicBlocks
bool OS::ABB::set_ABB_predecessor(OS::shared_abb basicblock){
	this->predecessors.emplace_back(basicblock);
        //TODO check if basic_block exists in module
	return true;	
} // Speicher Referenz auf Vorgänger des BasicBlocks

std::list<OS::shared_abb> OS::ABB::get_ABB_successors(){
	return this->successors;	
}      // Gebe Referenz auf Nachfolger zurück

OS::shared_abb OS::ABB::get_single_ABB_successor(){
	if(this->successors.size() ==1)return this->successors.front();
	else return nullptr;
}      // Gebe Referenz auf Nachfolger zurück



std::list<OS::shared_abb> OS::ABB::get_ABB_predecessors(){
	return this->predecessors;	
}    // Gebe Referenz auf Vorgänger zurück

bool OS::ABB::set_BasicBlock(llvm::BasicBlock *basic_block){
	bool success = false;
	if(this->parent_function->get_llvm_reference() == basic_block->getParent()){
		this->basic_blocks.emplace_back(basic_block);	
		success = true;
	}
	return success;
}



std::list<llvm::BasicBlock*> OS::ABB::get_BasicBlocks(){
	return this->basic_blocks;	
}



bool  OS::ABB::set_parent_function( OS::shared_function function){

	bool success = false;
	if(this->graph->contain_vertex(function)){
		success = true;
		this->parent_function = function;
	}
	return success;
}



OS::shared_function OS::ABB::get_parent_function(){
	return this->parent_function;
}



void OS::ABB::set_call_name(std::string call_name){
	this->call_names.emplace_back(call_name);
}
std::list<std::string> OS::ABB::get_call_names(){
	return this->call_names;
}



void OS::ABB::set_call_instruction_reference(llvm::Instruction * call_instruction){
	this->call_instruction_references.emplace_back(call_instruction);
}

std::list<llvm::Instruction*> OS::ABB::get_call_instruction_references(){
	return this->call_instruction_references;
}

llvm::Instruction* OS::ABB::get_syscall_instruction_reference(){
	return this->syscall_instruction_reference;
}

void OS::ABB::set_expected_syscall_argument_type(size_t argument_type){
	this->expected_argument_types.emplace_back(argument_type);
}

// std::list<size_t> OS::ABB::get_expected_syscall_argument_types(){
// 	
// 	return this->expected_argument_types;
// }

bool OS::ABB::convert_call_to_syscall(std::string name){
	
	if(this->call_names.size() != this->arguments.size())return false;
	
	int index= 0;
	for(auto& call_name: this->call_names){
		if(call_name == name)break;
		index++;
	}
	int tmp_index = 0;
	for(auto& call_arguments: this->arguments){
		if(tmp_index == index){
			this->syscall_arguments =call_arguments;
			this->syscall_name = name;
		}
		tmp_index++;
	}
}

std::list<std::list<size_t>> OS::ABB::get_call_argument_types(){
	
	std::list<std::list<size_t>> argument_types;

	for(auto & tmp_list: this->arguments){
		
		std::list<size_t>  tmp_argument_types;
		for(auto & tuple: tmp_list){
			tmp_argument_types.emplace_back(std::get<std::any>(tuple).type().hash_code());
		}
		argument_types.emplace_back(tmp_argument_types);
	}
	
	return argument_types;
}


std::list<OS::shared_function> OS::ABB::get_called_functions(){
	std::cout << "test" << std::endl;
	std::list<OS::shared_function> function_list;
	for(auto *instr : this->call_instruction_references){
		if(CallInst* tmp = dyn_cast<CallInst>((instr))){
			llvm::Function* llvm_function = tmp->getCalledFunction();
			std::hash<std::string> hash_fn;
			std::cout<< "function name" << llvm_function->getName().str();
			shared_vertex vertex = this->graph->get_vertex(hash_fn(llvm_function->getName().str() +  typeid(OS::Function).name()));
			if(vertex != nullptr){
				vertex->get_type();
				auto function =  std::dynamic_pointer_cast<OS::Function>(vertex);
				function_list.emplace_back( function);
			}
		}
		if(InvokeInst* tmp = dyn_cast<InvokeInst>((instr))){
			llvm::Function* llvm_function = tmp->getCalledFunction();
			std::hash<std::string> hash_fn;
			std::cout<< "function name" << llvm_function->getName().str();
			shared_vertex vertex = this->graph->get_vertex(hash_fn(llvm_function->getName().str() +  typeid(OS::Function).name()));
			if(vertex != nullptr){
				vertex->get_type();
				auto function =  std::dynamic_pointer_cast<OS::Function>(vertex);
				function_list.emplace_back( function);
			}
		}
	}
	return function_list;
}

//append basic blocks to entry abb from abb
bool OS::ABB::append_basic_blocks(shared_abb  abb){
	
	if(!this->graph->contain_vertex(abb))return false;
	for(auto& basic_block : abb->get_BasicBlocks()){
		this->set_BasicBlock(basic_block);
	}
	
	return true;
}


bool OS::ABB::is_mergeable(){
	
	bool syscall_flag;
	for(auto& function : this->get_called_functions()){
		if(function->has_syscall()){
			syscall_flag = true;
			break;
		}
	}
	
	if(this->abb_type ==computate  && !syscall_flag)return true;
	else return false;
}

void OS::ABB::expend_call_sites(shared_abb abb){
	
	if(this->syscall_instruction_reference != nullptr && abb->get_syscall_instruction_reference() != nullptr){
		std::cout << "ERROR, both abbs, which shall be merged, contain a syscall"<< std::endl;
	}
	if(this->syscall_instruction_reference == nullptr && abb->get_syscall_instruction_reference() != nullptr){
		this->syscall_instruction_reference = abb->get_syscall_instruction_reference();
		this->syscall_arguments = *(abb->get_syscall_arguments());
		this->syscall_name = abb->get_syscall_name();
	}
	
	for(auto& call_name: abb->get_call_names()){
		
		this->call_names.emplace_back(call_name);
	}
	
	for(auto& call_instruction_reference: abb->get_call_instruction_references()){
		
		this->call_instruction_references.emplace_back(call_instruction_reference);
	}
	
	for(auto& tmp_argument: *(abb->get_arguments())){
		
		this->arguments.emplace_back(tmp_argument);
	}
	
	
	for(auto& call_target_instance: *(abb->get_call_target_instances())){
		
		this->call_target_instances.emplace_back(call_target_instance);
	}

}

std::string OS::ABB::get_syscall_name( ){
	return this->syscall_name;
}

void OS::ABB::set_syscall_name(std::string name ){
	this->syscall_name = name;
}



llvm::BasicBlock* OS::ABB::get_exit_bb(){
	return this->exit;
}

void OS::ABB::remove_successor(shared_abb abb){
	for (std::list<shared_abb>::iterator itr = this->successors.begin(); itr != this->successors.end();){
		if ((*itr)->get_seed() == abb->get_seed()){
			itr = this->successors.erase(itr);
		}
		else{
			++itr;
	
		}
	}
}

void OS::ABB::adapt_exit_bb(shared_abb abb){
	this->exit = abb->get_exit_bb();
}

bool  OS::ABB::has_single_successor(){
	if(this->successors.size() == 1)return true;
	else return false;
}

void OS::Counter::set_max_allowed_value(unsigned long max_allowed_value) { 
	this->max_allowed_value = max_allowed_value;
}


void OS::Counter::set_ticks_per_base(unsigned long ticks_per_base) { 
	this->min_cycle = min_cycle;
}

void OS::Counter::set_min_cycle(unsigned long min_cycle) { 
	this->ticks_per_base = ticks_per_base;
}

bool OS::Resource::set_linked_resource(OS::shared_resource resource) {
	
	bool result = false;
	if(this->graph->contain_vertex(resource)){
		result = true;
		this->resources.emplace_back(resource);
	}
	return result;
}


resource_type OS::Resource::get_resource_type(){
	return this->type;
}

bool OS::Resource::set_resource_property(std::string type, std::string linked_resource) {
	
	bool result = false;
	
	
	switch(str2int(type.c_str())){
		
		case str2int("INTERNAL"):
			this->type = internal;
			result = true;
			break;
		case str2int("STANDARD"):
			this->type = standard;
			result = true;
			break;
				
		case str2int("LINKED"):
			shared_vertex vertex = this->graph->get_vertex(linked_resource);
			
			shared_resource resource_reference = std::dynamic_pointer_cast<OS::Resource> (vertex);
			if(resource_reference){
				if(resource_reference->get_resource_type() == linked || resource_reference->get_resource_type() == standard){
					this->type = linked;
					result = true;
					this->set_linked_resource(resource_reference);
				}
			}
	}
	
	return result;

}


void OS::Task::set_priority(unsigned long priority) {
	this->priority = priority;
}

void OS::Task::set_stacksize(unsigned long stacksize) {
	this->stacksize = stacksize;
}


bool OS::Task::set_message_reference(std::string message) { 
	return false; 

}


bool OS::Task::set_scheduler(std::string scheduler){
	
	bool result = false;
	switch(str2int(scheduler.c_str())){
		
		case str2int("NONE"):
			this->scheduler = none;
			result = true;
			break;
		case str2int("FULL"):
			result = true;
			this->scheduler = full;
			break;
	}
	return result;
}

void OS::Task::set_activation(unsigned long activation){
	this->activation = activation;
}

void OS::Task::set_autostart(bool autostart){
	this->autostart = autostart;
}

void OS::Task::set_appmode(std::string app_mode){
	this->app_modes.emplace_back(app_mode);
}

bool OS::Task::set_resource_reference(std::string resource_name){
	bool result = false;
	auto resource = this->graph->get_vertex(resource_name);
	if(resource != nullptr){
		auto resource_cast = std::dynamic_pointer_cast<OS::Resource> (resource);
		if(resource_cast){
			this->resources.emplace_back(resource_cast);
			result = true;
		}
	}
	return result;
}

bool OS::Task::set_event_reference(std::string event_name){
	bool result = false;
	auto event = this->graph->get_vertex(event_name);
	if(event != nullptr){
		auto event_cast = std::dynamic_pointer_cast<OS::Event> (event);
		if(event_cast){
			this->events.emplace_back(event_cast);
			result = true;
		}
	}
	return result;
	
}



bool OS::Task::set_definition_function(std::string function_name){
	bool result = false;
	auto function = this->graph->get_vertex(function_name);
	if(function != nullptr){
		auto function_cast = std::dynamic_pointer_cast<OS::Function> (function);
		if(function_cast){
			this->definition_function = function_cast;
			result = true;
		}
	}
	return result;
	
}


bool OS::ISR::set_definition_function(std::string function_name){
	bool result = false;
	auto function = this->graph->get_vertex(function_name);
	if(function != nullptr){
		auto function_cast = std::dynamic_pointer_cast<OS::Function> (function);
		if(function_cast){
			this->definition_function = function_cast;
			result = true;
		}
	}
	return result;
	
}

void OS::Event::set_event_mask(unsigned long  mask){
	this->event_mask = mask;	
}

void OS::Event::set_event_mask_auto(){
	this->mask_type = automatic;	
}

bool OS::ISR::set_category(int category){
	bool result =false;
	
	if(category == 0 || category == 1){
		this->category = category;
		result = true;
	}
	return result;
}



bool OS::ISR::set_resource_reference(std::string resource_name){
	bool result = false;
	auto resource = this->graph->get_vertex(resource_name);
	if(resource != nullptr){
		auto resource_cast = std::dynamic_pointer_cast<OS::Resource> (resource);
		if(resource_cast){
			this->resources.emplace_back(resource_cast);
			result = true;
		}
	}
	return result;
}


bool OS::Alarm::set_task_reference(std::string task_name){
	bool result = false;
	auto task = this->graph->get_vertex(task_name);
	if(task != nullptr){
		auto task_cast = std::dynamic_pointer_cast<OS::Task>(task);
		if(task_cast){
			this->referenced_task = task_cast;
			result = true;
		}
	}
	return result;
}
	
	
bool OS::Alarm::set_counter_reference(std::string counter_name){
	bool result = false;
	auto counter = this->graph->get_vertex(counter_name);
	if(counter != nullptr){
		auto counter_cast = std::dynamic_pointer_cast<OS::Counter>(counter);
		if(counter_cast){
			referenced_counter = counter_cast;
			result = true;
		}
	}
	return result;
}

bool OS::Alarm::set_event_reference(std::string event_name){
	bool result = false;
	auto event = this->graph->get_vertex(event_name);
	if(event != nullptr){
		auto event_cast = std::dynamic_pointer_cast<OS::Event> (event);
		if(event_cast){
			this->referenced_event = event_cast;
			result = true;
		}
	}
	return result;
}

void OS::Alarm::set_alarm_callback_reference(std::string callback_name){
	alarm_callback = callback_name;
}

void OS::Alarm::set_autostart(bool flag){
	this->autostart = flag;
}
void OS::Alarm::set_alarm_time(unsigned int alarm_time){
	this->alarm_time = alarm_time;
}

void OS::Alarm::set_cycle_time(unsigned int cycle_time){
	this->cycle_time = cycle_time;
}

void OS::Alarm::set_appmode(std::string appmode){
	this->appmodes.emplace_back(appmode);
}

void OS::Queue::set_item_size(unsigned long item_size){
	this->item_size;
}

unsigned long OS::Queue::get_item_size(){
	return this->item_size = item_size;
}

unsigned long OS::Queue::get_length(){
	return this->length;
}

void OS::Queue::set_length(unsigned long length){
	this->length = length;
}


void OS::Timer::set_timer_id(unsigned long timer_id){
	this->timer_id = timer_id;
}

void OS::Timer::set_periode(unsigned long periode){
	this->periode = periode;
}



void OS::Timer::set_timer_type( timer_type type){
	this->type = type;
}




bool OS::Timer::set_definition_function(std::string function_name){
	bool result = false;
	auto function = this->graph->get_vertex(function_name);
	if(function != nullptr){
		auto function_cast = std::dynamic_pointer_cast<OS::Function> (function);
		if(function_cast){
			this->definition_function = function_cast;
			result = true;
		}
	}
	return result;
	
}



void OS::Semaphore::set_max_count(unsigned long max_count){
	this->max_count = max_count;
}

void OS::Semaphore::set_initial_count(unsigned long initial_count){
	this->initial_count = initial_count;
}


void OS::Semaphore::set_semaphore_type( semaphore_type type){
	this->type = type;
}


void OS::QueueSet::set_length(unsigned long length){
	this->length = length;
}


void OS::Buffer::set_buffer_type(buffer_type type){
	this->type = type;
}


void OS::Buffer::set_buffer_size(unsigned long size){
	this->buffer_size = size;
}

void OS::Buffer::set_trigger_level(unsigned long level){
	this->trigger_level = level;
}

template< typename T > bool contains( std::any& a ){
   try
   {
      // we do the comparison with 'name' because across shared library boundries we get
      // two different type_info objects
      return( std::strcmp( typeid( T ).name(), a.type().name() ) == 0 );
   }
   catch( ... )
   { }

   return false;
}

//print methods -------------------------------------------------------------------------------
std::string debug_argument(std::any value,llvm::Type *type){
	
	std::size_t const tmp = value.type().hash_code();
	const std::size_t  tmp_int = typeid(int).hash_code();
	const std::size_t  tmp_double = typeid(double).hash_code();
	const std::size_t  tmp_string = typeid(std::string).hash_code();
	const std::size_t tmp_long 	= typeid(long).hash_code();
	std::string information = "Argument: ";
	
	//std::cout << "reference: " << tmp_int << " " << tmp_double << " " << tmp_string << " " << tmp_long << std::endl;
	
	
	try{
		//std::cout << "test" << value.type().name() << "\n" << value.type().hash_code() << std::endl;
		if( contains< int >( value ) ){
			int tmp = (std::any_cast< int >( value ));
			information += std::to_string(tmp);
		}
		if( contains<double>( value ) ){
			double tmp = (std::any_cast< double >( value ));
			information += std::to_string(tmp);
		}
		if( contains<std::string>( value ) ){
			std::string tmp = std::any_cast< std::string >( value );
			information += tmp;
		}
		if( contains< long >( value ) ){
			long tmp = (std::any_cast< long >( value ));
			information += std::to_string(tmp);
		}
	}
	catch( ... )
	{ 
		information+=  "any cast not possible";
	}
	return information;
}


std::string graph::Graph::print_information(){
	std::string information = "\n------------------------\nGraph:\n";
	information += "Vertices:\n";
	for (auto & vertex:this->vertices){
		information+= vertex->print_information();
	}
	return information += "\n------------------------\n\n";
}	




std::string OS::Function::print_information(){
	std::string information = "\n------------------------\nFunction:\n";
	information += "name:" + this->name + "\n";
	information += "function name:" + this->function_name + "\n";
	information += "argument types: ";
	for (auto & argument:this->argument_types){
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		argument->print(rso);
		information += "\t" +  rso.str() ;
	}
	information += "\n";
	{
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		this->return_type->print(rso);
		information += "return type: " + rso.str() + "\n";
	}
	if(contains_critical_section)information += "contains critical section: True \n";
	//if(definition_element != nullptr)information += "OS definition instance name:" + this->definition_element->get_name() + "\n";
		
	if(this->front_abb != nullptr)information += "first abb: " + this->front_abb->get_name() + "\n";
	if(this->exit_abb != nullptr)information += "last abb: " + this->exit_abb->get_name() + "\n";
	information += "abbs: ";

	for (auto & abb: this->atomic_basic_blocks){
		information += abb->get_name() + ", ";
	}
	information += "\n";
	return information += "\n------------------------\n\n";
}	


std::string OS::ABB::print_information(){
	std::string information = "\n------------------------\nABB:\n";
	information += "abb name: " + this->name + "\n";
	information += "successors: ";
	for (auto & successor:this->successors){
		information += "\t" + successor->get_name();
	}

	information += "\npredecessors: ";
	for (auto & predecessor:this->predecessors){
		information += "\t" + predecessor->get_name() ;
	}
	information += "\n";
	if(this->abb_type != no_call){
		
		information += "syscall: ";
		information += (this->abb_type);
		information += "\n";
	
		if(this->call_names.size() != this->arguments.size()){
			std::cerr <<  "ERROR: call names and call arguments size are different!\n";
			std::cerr << "ERROR: call names size:" << std::to_string(this->call_names.size()) << ", call arguments size:" << std::to_string(this->arguments.size()) << "\n";
			abort();
		}
		else{
			
			int i = 0;
			for(auto& call_name : this->call_names){
				information += "call: " + call_name + "\n";
				information += "arguments: ";
				int j = 0;
				for (auto  argument_list: this->arguments){
					for(auto & tuple :argument_list){
						information +=  debug_argument(std::get<std::any>(tuple),std::get<llvm::Type*>(tuple))+ ", ";
					}
					if(i == j) break;
					++j;
				}
				information += "\n";
				++i;
			}
		}
	}
	if(this->abb_type == sys_call){
		int i = 0;
		for(auto& call_name : this->call_names){
			information += "syscall: " + call_name + "\n";
			information += "arguments: ";
			int j = 0;
			for (auto & argument: this->syscall_arguments){
				information +=  debug_argument(std::get<std::any>(argument),std::get<llvm::Type*>(argument))+ ", ";
				if(i == j) break;
				++j;
			}
			information += "\n";
			++i;
		}
	}
	
	

	return information += "------------------------\n\n";
}	


//print methods -------------------------------------------------------------------------------

