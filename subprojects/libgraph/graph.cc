// vim: set noet ts=4 sw=4:

#include "graph.h"

using namespace graph;

graph::Graph::Graph(std::shared_ptr<llvm::Module>* module){
    llvm_module = *module;
}

graph::Graph::~Graph(){
}

graph::Graph::Graph(){
}

void graph::Graph::set_llvm_module(std::shared_ptr<llvm::Module> *module,std::shared_ptr<llvm::LLVMContext>*context){
	llvm_context = *context;
	llvm_module = *module;
}

llvm::Module* graph::Graph::get_llvm_module(){
    return this->llvm_module.get();
}

void graph::Graph::set_vertex(shared_vertex vertex){
	this->vertexes.push_back(vertex);
}

void graph::Graph::set_edge(shared_edge edge){
    this->edges.push_back(edge);
}

shared_vertex graph::Graph::create_vertex(){
    shared_vertex vertex = std::make_shared<Vertex>(this,""); 	//create shared po
    this->vertexes.push_back(vertex);                   		//store the shared pointer in the internal list
    return vertex;
}

shared_edge graph::Graph::create_edge(){
    shared_edge edge = std::make_shared<Edge>();    		//create shared pointer
    this->edges.push_back(edge);               				//store the shared pointer in the internal list
    return edge;
}

std::list<shared_vertex> graph::Graph::get_type_vertexes(size_t type_info){
    std::list<shared_vertex> tmp_list;
    std::list<shared_vertex>::iterator it = this->vertexes.begin();       //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        if(type_info==(*it).get()->get_type()){                                         //check if vertex is from wanted type
            tmp_list.push_back((*it));
        }
    }
    return tmp_list;
}

shared_vertex graph::Graph::get_vertex(size_t seed){   
    //gebe Vertex mit dem entsprechenden hashValue zurück
    std::list<shared_vertex>::iterator it = this->vertexes.begin();       //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        //gesuchter vertex gefunden
        if(seed==(*it)->get_seed()){                                         //check if vertex is from wanted type
           return (*it); 
        }
    }
    return nullptr;
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

std::list<shared_vertex> graph::Graph::get_vertexes(){
    std::list<shared_vertex> tmp_list;
    std::list<shared_vertex>::iterator it = this->vertexes.begin();            //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<shared_edge> graph::Graph::get_edges(){
    std::list<shared_edge> tmp_list;
    std::list<shared_edge>::iterator it = this->edges.begin();           //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

bool graph::Graph::remove_vertex(graph::shared_vertex *vertex){
    bool success = false;
    std::list<shared_vertex>::iterator it = this->vertexes.begin();           //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        if(vertex->get()->get_seed() == (*it)->get_seed()){
            //TODO remove edges
            it = this->vertexes.erase(it--);
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
    std::list<shared_vertex>::iterator it = this->vertexes.begin();           //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
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
	std::hash<std::string> hash_fn;
	this->seed = hash_fn(name +  typeid(this).name());
    this->type = typeid(this).hash_code();
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
		this->outgoing_edges.push_back(edge);
	}
    return success;
}

bool graph::Vertex::set_ingoing_edge(shared_edge edge){
	bool success = false;
    if(this->graph->contain_edge(edge)){
		success = true;
		this->ingoing_edges.push_back(edge);
	}
    return success;
}

bool graph::Vertex::set_outgoing_vertex(shared_vertex vertex){
	bool success = false;
    if(this->graph->contain_vertex(vertex)){
		success = true;
		this->outgoing_vertexes.push_back(vertex);
	}
    return success;
}

bool graph::Vertex::set_ingoing_vertex(shared_vertex vertex){
	bool success = false;
    if(this->graph->contain_vertex(vertex)){
		success = true;
		this->ingoing_vertexes.push_back(vertex);
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
    std::list<shared_vertex>::iterator it = this->outgoing_vertexes.begin();           //iterate about the list elements
    //iterate about the outgoing vertexes
    for(; it != this->outgoing_vertexes.end(); ++it){
        if(vertex == (*it)){
            it = this->outgoing_vertexes.erase(it--);
            success = true;
            break;
        }
    }
    //iterate about the ingoing vertexes
    for(it = this->ingoing_vertexes.begin();  it != this->ingoing_vertexes.end(); ++it){
        if(vertex == (*it)){
            it = this->ingoing_vertexes.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}

std::list<graph::shared_vertex > graph::Vertex::get_specific_connected_vertexes(size_t type_info){
    std::list<shared_vertex> tmp_list;
    std::list<shared_vertex>::iterator it = this->outgoing_vertexes.begin();           //iterate about the list elements
    //iterate about the outgoing vertexes
    for(; it != this->outgoing_vertexes.end(); ++it){
        if(typeid((*(*it))).hash_code() == type_info){
            tmp_list.push_back(*it);
        }
    }
    //iterate about the ingoing vertexes
    for(it = this->ingoing_vertexes.begin();  it != this->ingoing_vertexes.end(); ++it){
        if(typeid((*(*it))).hash_code()== type_info){
            tmp_list.push_back(*it);
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
    tmp_list.push_back(start);
    std::vector<size_t> visited;
    visited.push_back(start->get_seed());
    //iterate about the queue with open elements
    while(!queue.empty()){
        graph::shared_vertex tmp = queue.front();
        queue.pop();
        if(&tmp==&end) return tmp_list;
        std::list<graph::shared_vertex> neighbours = tmp->get_outgoing_vertexes();
        std::list<graph::shared_vertex>::iterator it = neighbours.begin();

        for(; it != neighbours.end(); ++it){
            if(!(std::find(visited.begin(), visited.end(), (*it)->get_seed()) != visited.end())){
                queue.push(*it);
                tmp_list.push_back(*it);
            }
        }
    }
    */
    return tmp_list;
}

std::list<graph::shared_vertex> graph::Vertex::get_vertex_chain(graph::shared_vertex vertex){     // Methode, die die Kette der Elemente vom Start bis zum Ziel Vertex zurück gibt,
    return wide_search(this, vertex); // interagieren die Betriebssystemabstrakionen nicht miteinader gebe nullptr zurück
}

std::list<graph::shared_vertex >graph::Vertex::get_connected_vertexes(){ // Methode, die die mit diesem Knoten verbundenen Vertexes zurückgibt
    std::list<graph::shared_vertex> tmp_list;
    std::list<graph::shared_vertex>::iterator it = this->outgoing_vertexes.begin();           //iterate about the list elements
    //iterate about the outgoing vertexes
    for(; it != this->outgoing_vertexes.end(); ++it){
        tmp_list.push_back(*it);
    }
    //iterate about the ingoing vertexes
    for(it = this->ingoing_vertexes.begin();  it != this->ingoing_vertexes.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge> graph::Vertex::get_connected_edges(){ // Methode, die die mit diesem Knoten verbundenen Edges zurückgibt

    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
    //iterate about the outgoing edges
    for(; it != this->outgoing_edges.end(); ++it){
        tmp_list.push_back(*it);
    }
    //iterate about the ingoing edges
    for(it = this->ingoing_edges.begin();  it != this->ingoing_edges.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_vertex > graph::Vertex::get_ingoing_vertexes(){    // Methode, die die mit diesem Knoten eingehenden Vertexes
                                                                // zurückgibt
    std::list<graph::shared_vertex> tmp_list;
    std::list<graph::shared_vertex>::iterator it = this->ingoing_vertexes.begin();
    for(; it != this->ingoing_vertexes.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge> graph::Vertex::get_ingoing_edges(){ // Methode, die die mit diesem Knoten eingehenden Edges zurückgibt
    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->ingoing_edges.begin();
    for(; it != this->ingoing_edges.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_vertex > graph::Vertex::get_outgoing_vertexes(){                // Methode, die die mit diesem Knoten ausgehenden Vertexes zurückgibt
    std::list<graph::shared_vertex> tmp_list;
    std::list<graph::shared_vertex>::iterator it = this->outgoing_vertexes.begin();
    for(; it != this->outgoing_vertexes.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge > graph::Vertex::get_outgoing_edges(){ // Methode, die die mit diesem Knoten ausgehenden Edges zurückgibt
    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->outgoing_edges.begin();
    for(; it != this->outgoing_edges.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::shared_edge> graph::Vertex::get_direct_edge(graph::shared_vertex vertex){ // Methode, die direkte Kante zwischen Start und Ziel Vertex zurückgibt,
    std::list<graph::shared_edge> tmp_list;
    std::list<graph::shared_edge>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
    //iterate about the outgoing vertexes
    for(; it != this->outgoing_edges.end(); ++it){
        if(vertex->get_seed()==((*it)->get_target_vertex()->get_seed())){
            tmp_list.push_back(*it);
        }
    }
    //iterate about the ingoing vertexesget
    for(it = this->ingoing_edges.begin();  it != this->ingoing_edges.end(); ++it){
        if(vertex->get_seed()==((*it)->get_start_vertex()->get_seed())){
            tmp_list.push_back(*it);
        }
    }
    return tmp_list;
}

void graph::Vertex::set_type(std::size_t type){
    this->type = type;
}


std::size_t graph::Vertex::get_type(){
    return this->type;
}









                
                







graph::Edge::Edge(){
    this->name = "";
    this->graph = nullptr;
}







graph::Edge::Edge(Graph *graph, std::string name, graph::shared_vertex start, graph::shared_vertex target){
    this->name = name;
    this->graph = graph;
    this->start_vertex = start;
    this->target_vertex = target;
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




std::list<std::tuple< std::any,llvm::Type*>> graph::Edge::get_arguments(){return this->arguments;}


void graph::Edge::set_arguments(std::list<std::tuple<std::any,llvm::Type*>> arguments){
    this->arguments = arguments;
    return;
}

void graph::Edge::set_argument(std::tuple<std::any,llvm::Type*> argument){
    this->arguments.push_back(argument);
    return;
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


std::list<OS::shared_function>* OS::Function::get_used_functions(){return &(this->referenced_functions);} // Gebe std::liste aller Funktionen zurück, die diese Funktion benutzen


bool OS::Function::set_referenced_function(OS::shared_function function){
    bool success = false;
    graph::Graph graph = (*this->graph);
    if(this->graph->contain_vertex(function)){
        this->referenced_functions.push_back(function);
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



void OS::Function::set_atomic_basic_block(OS::ABB *atomic_basic_block){
    this->atomic_basic_blocks.push_back(atomic_basic_block);
}

std::list<OS::ABB *> OS::Function::get_atomic_basic_blocks(){
    return this->atomic_basic_blocks;
}

std::list<OS::Task *> OS::Function::get_referenced_tasks(){
    return this->referenced_tasks;
}

bool OS::Function::set_referenced_task(OS::Task *task){
    bool success = false;
    if(this->graph->contain_vertex((shared_vertex)task)){
        this->referenced_tasks.push_back(task);
        success = true;
    }
    return success;
}






std::list<llvm::Type*>  OS::Function::get_argument_types(){
    return this->argument_types;
}

void  OS::Function::set_argument_type(llvm::Type* argument){ // Setze Argument des SystemCalls in Argumentenliste
    this->argument_types.push_back(argument);
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

OS::shared_abb OS::Function::get_front_abb(){
	return this->front_abb;
}













syscall_definition_type OS::ABB::get_calltype(){
    return this->abb_type;
}

void OS::ABB::set_calltype(syscall_definition_type type){
    this->abb_type = type;
}



bool OS::ABB::is_critical(){return this->critical_section;}
void OS::ABB::set_critical(bool critical){this->critical_section = critical;}


std::list<std::tuple<std::any,llvm::Type*>> OS::ABB::get_arguments(){
    return this->arguments;
}

void OS::ABB::set_arguments(std::list<std::tuple<std::any,llvm::Type*>> new_arguments){
    this->arguments = new_arguments;
} // Setze Argument des SystemCalls in Argumentenliste

void OS::ABB::set_argument(std::any argument,llvm::Type* type){
	
    this->arguments.push_back(std::make_tuple (argument,type));
} // Setze Argument des SystemCalls in Argumentenliste



bool OS::ABB::set_ABB_successor(OS::shared_abb basicblock){
	this->successors.push_back(basicblock);
        //TODO check if basic_block exists in module
	return true;	
}   // Speicher Referenz auf Nachfolger des BasicBlocks
bool OS::ABB::set_ABB_predecessor(OS::shared_abb basicblock){
	this->predecessors.push_back(basicblock);
        //TODO check if basic_block exists in module
	return true;	
} // Speicher Referenz auf Vorgänger des BasicBlocks

std::list<OS::shared_abb> OS::ABB::get_ABB_successors(){
	return this->successors;	
}      // Gebe Referenz auf Nachfolger zurück


std::list<OS::shared_abb> OS::ABB::get_ABB_predecessor(){
	return this->predecessors;	
}    // Gebe Referenz auf Vorgänger zurück

bool OS::ABB::set_BasicBlock(llvm::BasicBlock *basic_block){
	bool success = false;
	if(this->parent_function->get_llvm_reference() == basic_block->getParent()){
		this->basic_blocks.push_back(basic_block);	
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
	this->call_name = call_name;
}
std::string OS::ABB::get_call_name(){
	return this->call_name;
}






















