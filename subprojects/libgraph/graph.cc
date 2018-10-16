// vim: set noet ts=4 sw=4:

#include "graph.h"

graph::Graph::Graph(std::shared_ptr<llvm::Module>* module){
   
    llvm_module = *module;
	
}


graph::Graph::~Graph(){

}



graph::Graph::Graph(){
	/*
	llvm::LLVMContext ctx;
	std::unique_ptr<llvm::Module> uptr_module = llvm::make_unique<llvm::Module>( "tmp", ctx );
    std::shared_ptr<llvm::Module> shared_module = std::move(uptr_module);
    */
	//llvm_module = shared_module;
}


void graph::Graph::set_llvm_module(std::shared_ptr<llvm::Module> *module){
    
    /*
    std::cerr << "Adress" << &module << "\n" <<std::endl;
    std::cerr << "Adress" << &llvm_module << "\n" <<std::endl;
    std::cerr << "Type" << typeid(module.get()).name() << "\n" <<std::endl;
    std::cerr << "Type" << typeid(llvm_module.get()).name() << "\n" <<std::endl;
    */

    
    
    llvm_module = *module;
	std::cerr << "Count: " << llvm_module.use_count() << "\n";
}

llvm::Module* graph::Graph::get_llvm_module(){
    return this->llvm_module.get();
}



graph::Vertex* graph::Graph::set_vertex(Vertex *vertex){
    
    std::shared_ptr<graph::Vertex> graph_vertex(vertex->clone());       //create shared po
    this->vertexes.push_back(graph_vertex);                                                //store the shared pointer in the internal list
    
   // std::cout << "Referenz: " << graph_vertex.get() << std::endl;
    
   // std::cout << "Return Referenz: " << this->vertexes.back().get() << std::endl;
    //std::cout << "Name: " << this->vertexes.back().get()->get_name() << std::endl;
    
    return this->vertexes.back().get();
}

graph::Edge* graph::Graph::set_edge(Edge *edge){
    
    std::shared_ptr<graph::Edge> graph_edge(edge->clone());          //create shared pointer of copied and heap allocated edge
    this->edges.push_back(graph_edge);                                                   //store the shared pointer in the internal list
    return this->edges.back().get();
}


graph::Vertex* graph::Graph::create_vertex(){
    
    //std::shared_ptr<Vertex> shared_pointer = std::make_shared<Vertex>(vertex->clone());     //create shared pointer of copied and heap allocated vertex

    
    std::shared_ptr<Vertex> shared_pointer = std::make_shared<Vertex>(this,"");     //create shared po
    
    this->vertexes.push_back(shared_pointer);                                                //store the shared pointer in the internal list
    return shared_pointer.get();
}


graph::Edge* graph::Graph::create_edge(){
    
    
    std::shared_ptr<Edge> shared_pointer = std::make_shared<Edge>();           //create shared pointer of copied and heap allocated edge
    this->edges.push_back(shared_pointer);                                                   //store the shared pointer in the internal list
    return shared_pointer.get();
    
}


            
std::list<graph::Vertex*> graph::Graph::get_type_vertexes(size_t type_info){
    
    std::list<Vertex*> tmp_list;
    std::list<std::shared_ptr<Vertex>>::iterator it = this->vertexes.begin();       //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        if(type_info==(*it).get()->get_type()){                                         //check if vertex is from wanted type
            graph::Vertex* tmp_pointer = (*it).get();
            tmp_list.push_back(tmp_pointer);
        }
    }
    return tmp_list;
}


graph::Vertex* graph::Graph::get_vertex(size_t seed){   
    
    //gebe Vertex mit dem entsprechenden hashValue zurück
    std::list<std::shared_ptr<Vertex>>::iterator it = this->vertexes.begin();       //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        
        //gesuchter vertex gefunden
        if(seed==(*it)->get_seed()){                                         //check if vertex is from wanted type
           return (*it).get(); 
        }
    }
    return nullptr;        
}


graph::Edge* graph::Graph::get_edge(size_t seed){   
    
    //gebe edge mit dem entsprechenden hashValue zurück
    std::list<std::shared_ptr<Edge>>::iterator it = this->edges.begin();       //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        
        //gesuchter vertex gefunden
        if(seed==(*it)->get_seed()){                                         //check if vertex is from wanted type
           return ((*it).get()); 
        }
    }
    return nullptr;        
}

std::list<graph::Vertex *> graph::Graph::get_vertexes(){
    
    std::list<graph::Vertex*> tmp_list;
    std::list<std::shared_ptr<Vertex>>::iterator it = this->vertexes.begin();            //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        tmp_list.push_back((*it).get());
    }
    return tmp_list;
}

std::list<graph::Edge *> graph::Graph::get_edges(){
    
    std::list<graph::Edge*> tmp_list;
    std::list<std::shared_ptr<graph::Edge>>::iterator it = this->edges.begin();           //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        tmp_list.push_back((*it).get());
    }
    return tmp_list;
}

bool graph::Graph::remove_vertex(graph::Vertex * vertex){
    
    bool success = false;
     std::list<std::shared_ptr<Vertex>>::iterator it = this->vertexes.begin();           //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        if(vertex == (*it).get()){
            //TODO remove edges
            it = this->vertexes.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}


bool graph::Graph::remove_edge(Edge* edge){
    
    bool success = false;
    std::list<std::shared_ptr<Edge>>::iterator it = this->edges.begin();           //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        if(edge == (*it).get()){
            //TODO remove edges
            it = this->edges.erase(it--);
            success = true;
            break;
        }
    }
    return success;
}


bool graph::Graph::contain_vertex(Vertex *vertex){
    
    bool success = false;
    std::list<std::shared_ptr<Vertex>>::iterator it = this->vertexes.begin();           //iterate about the list elements
    for(; it != this->vertexes.end(); ++it){
        if(vertex == ((*it).get())){
            success = true;
            break;
        }
    }
    return success;
}




bool graph::Graph::contain_edge(Edge *edge){
    
    bool success = false;
    std::list<std::shared_ptr<Edge>>::iterator it = this->edges.begin();           //iterate about the list elements
    for(; it != this->edges.end(); ++it){
        if(edge ==((*it).get())){
            success = true;
            break;
        }
    }
    return success;
}




/*
graph::Vertex::Vertex(){
    this->graph = nullptr;;
    this->name = ""  ; // spezifischer Name des Vertexes
    this->seed = 0 ; // für jedes Element spezifischer hashValue 
    thi
}*/



















graph::Vertex::Vertex(Graph *graph,std::string name){
    this->graph = graph;
	this->name = name;
	std::hash<std::string> hash_fn;
	this->seed = hash_fn(name +  typeid(this).name());
    this->type = typeid(this).hash_code();
} // Constructor




std::string graph::Vertex::get_name(){
        return this->name;
}

std::size_t graph::Vertex::get_seed(){
        return this->seed;
}


bool graph::Vertex::set_outgoing_edge(Edge *edge){
    
    //TODO check if element is not in list yet
    
    bool success = true;
    this->outgoing_edges.push_back(edge);
    return success;
}

bool graph::Vertex::set_ingoing_edge(Edge *edge){
    //TODO check if element is not in list yet
    
    bool success = true;
    this->ingoing_edges.push_back(edge);
    return success;
}

bool graph::Vertex::set_outgoing_vertex(Vertex *vertex){
    bool success = true;
    this->outgoing_vertexes.push_back(vertex);
    return success;
}

bool graph::Vertex::set_ingoing_vertex(Vertex *vertex){
    bool success = true;
    this->ingoing_vertexes.push_back(vertex);
    return success;
}



bool graph::Vertex::remove_edge(Edge *edge){
    bool success = false;
    
    std::list<Edge*>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
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
    
    
    
bool graph::Vertex::remove_vertex(Vertex *vertex){
    bool success = false;
    
    std::list<Vertex*>::iterator it = this->outgoing_vertexes.begin();           //iterate about the list elements
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




std::list<graph::Vertex *> graph::Vertex::get_specific_connected_vertexes(size_t type_info){
    std::list<Vertex*> tmp_list;
    
    std::list<Vertex*>::iterator it = this->outgoing_vertexes.begin();           //iterate about the list elements
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
std::list<graph::Vertex *> wide_search (graph::Vertex* start,graph::Vertex* ende){
    
    std::list<graph::Vertex*> tmp_list;
    std::queue<graph::Vertex*> queue;
    queue.push(start);
    tmp_list.push_back(start);
    
    std::vector<size_t> visited;

    visited.push_back(start->get_seed());
    //iterate about the queue with open elements
    while(!queue.empty()){
        graph::Vertex *  tmp = queue.front();
        queue.pop();
        if(&tmp==&ende) return tmp_list;
        std::list<graph::Vertex*> neighbours = tmp->get_outgoing_vertexes();
        std::list<graph::Vertex*>::iterator it = neighbours.begin();

        for(; it != neighbours.end(); ++it){
            if(!(std::find(visited.begin(), visited.end(), (*it)->get_seed()) != visited.end())){
                queue.push(*it);
                tmp_list.push_back(*it);
            }
        }
    }
    return tmp_list;
}





std::list<graph::Vertex*> graph::Vertex::get_vertex_chain(graph::Vertex *vertex){     // Methode, die die Kette der Elemente vom Start bis zum Ziel Vertex zurück gibt,
                                                                                            // interagieren die Betriebssystemabstrakionen nicht miteinader gebe nullptr zurück
    return wide_search(this, vertex);                       
}

std::list<graph::Vertex *>graph::Vertex::get_connected_vertexes(){ // Methode, die die mit diesem Knoten verbundenen Vertexes zurückgibt
    
    std::list<graph::Vertex*> tmp_list;
    
    std::list<graph::Vertex*>::iterator it = this->outgoing_vertexes.begin();           //iterate about the list elements
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


std::list<graph::Edge*> graph::Vertex::get_connected_edges(){ // Methode, die die mit diesem Knoten verbundenen Edges zurückgibt
    
    std::list<graph::Edge*> tmp_list;
    std::list<graph::Edge*>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
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

std::list<graph::Vertex *> graph::Vertex::get_ingoing_vertexes(){    // Methode, die die mit diesem Knoten eingehenden Vertexes
                                                                // zurückgibt
    std::list<graph::Vertex*> tmp_list;
    std::list<graph::Vertex*>::iterator it = this->ingoing_vertexes.begin();
    for(; it != this->ingoing_vertexes.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}
    
std::list<graph::Edge*> graph::Vertex::get_ingoing_edges(){ // Methode, die die mit diesem Knoten eingehenden Edges zurückgibt
    std::list<graph::Edge*> tmp_list;
    std::list<graph::Edge*>::iterator it = this->ingoing_edges.begin();
    for(; it != this->ingoing_edges.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::Vertex *> graph::Vertex::get_outgoing_vertexes(){                // Methode, die die mit diesem Knoten ausgehenden Vertexes zurückgibt
    std::list<graph::Vertex*> tmp_list;
    std::list<graph::Vertex*>::iterator it = this->outgoing_vertexes.begin();
    for(; it != this->outgoing_vertexes.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::Edge *> graph::Vertex::get_outgoing_edges(){ // Methode, die die mit diesem Knoten ausgehenden Edges zurückgibt
    std::list<graph::Edge*> tmp_list;
    std::list<graph::Edge*>::iterator it = this->outgoing_edges.begin();
    for(; it != this->outgoing_edges.end(); ++it){
        tmp_list.push_back(*it);
    }
    return tmp_list;
}

std::list<graph::Edge*> graph::Vertex::get_direct_edge(graph::Vertex *vertex){ // Methode, die direkte Kante zwischen Start und Ziel Vertex zurückgibt,
    std::list<graph::Edge*> tmp_list;
    std::list<graph::Edge*>::iterator it = this->outgoing_edges.begin();           //iterate about the list elements
    //iterate about the outgoing vertexes
    for(; it != this->outgoing_edges.end(); ++it){
        if(vertex==((*it)->get_target_vertex())){
            tmp_list.push_back(*it);
        }
    }
    //iterate about the ingoing vertexesget
    for(it = this->ingoing_edges.begin();  it != this->ingoing_edges.end(); ++it){
        if(vertex==((*it)->get_start_vertex())){
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







graph::Edge::Edge(Graph *graph, std::string name, graph::Vertex *start, graph::Vertex *target){
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

bool graph::Edge::set_start_vertex(graph::Vertex *vertex){
    bool success = false;
    if(this->graph->contain_vertex(vertex)){
        success = true;
        this->start_vertex =vertex;  
    }
    return success;
}

bool graph::Edge::set_target_vertex(graph::Vertex *vertex){
    bool success = false;
    if(this->graph->contain_vertex(vertex)){
        success = true;
        this->target_vertex =vertex;
    }
    return success;
}


graph::Vertex *graph::Edge::get_start_vertex(){return this->target_vertex;}
graph::Vertex *graph::Edge::get_target_vertex(){return this->start_vertex;}

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


std::list<OS::Function*> OS::Function::get_used_functions(){return this->referenced_functions;} // Gebe std::liste aller Funktionen zurück, die diese Funktion benutzen


bool OS::Function::set_referenced_function(OS::Function *function){
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
    if(this->graph->contain_vertex((Vertex*)task)){
        this->referenced_tasks.push_back(task);
        success = true;
    }
    return success;
}

std::list<OS::Function*> OS::Function::get_referenced_functions(){
    return this->referenced_functions;
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


		
void OS::Function::set_front_abb(OS::ABB * abb){
	this->front_abb = abb;
}

OS::ABB* OS::Function::get_front_abb(){
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



bool OS::ABB::set_ABB_successor(OS::ABB *basicblock){
	this->successors.push_back(basicblock);
        //TODO check if basic_block exists in module
	return true;	
}   // Speicher Referenz auf Nachfolger des BasicBlocks
bool OS::ABB::set_ABB_predecessor(OS::ABB *basicblock){
	this->predecessors.push_back(basicblock);
        //TODO check if basic_block exists in module
	return true;	
} // Speicher Referenz auf Vorgänger des BasicBlocks

std::list<OS::ABB *> OS::ABB::get_ABB_successors(){
	return this->successors;	
}      // Gebe Referenz auf Nachfolger zurück


std::list<OS::ABB *> OS::ABB::get_ABB_predecessor(){
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



bool  OS::ABB::set_parent_function(OS::Function *function){

	bool success = false;
	if(this->graph->contain_vertex((Vertex*)function)){
		success = true;
		this->parent_function = function;
	}
	return success;
}



OS::Function * OS::ABB::get_parent_function(){
	return this->parent_function;
}



void OS::ABB::set_call_name(std::string call_name){
	this->call_name = call_name;
}
std::string OS::ABB::get_call_name(){
	return this->call_name;
}






















