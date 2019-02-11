// vim: set noet ts=4 sw=4:



#include "llvm/Analysis/AssumptionCache.h"
#include "Validation.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/IR/CFG.h"
#include "llvm/Pass.h"
#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <cassert>
#include <stdexcept>
#include <functional>
#include "llvm/IR/Use.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/Analysis/MemoryDependenceAnalysis.h"
#include "llvm/PassAnalysisSupport.h"
#include "llvm/IR/LegacyPassManagers.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include <limits.h>
using namespace llvm;
using namespace OS;
using namespace graph;


shared_abb get_creation_Abb(shared_vertex vertex){
    for (auto& edge : vertex->get_ingoing_edges()) {
                            
        if (edge->get_abb_reference()->get_syscall_type() == create) {
            return edge->get_abb_reference();
        }
    }
    return nullptr;
}




/**
* @brief check if the current function is in the call tree of the definition_function of a abstraction instance
* @param definition_function definition_function of vertex, where the reachbility is analyzed
* @param current_function function which is searched in calltree
* @return return true if the current function is reachable from definition_function, else false
*/
bool is_in_calltree(shared_function definition_function,shared_function current_function){
    
    std::map<size_t,size_t> already_visited;
   
    
    std::queue<shared_function> queue; 
    queue.push(definition_function);

    //iterate about the ABB queue
	
    while(!queue.empty()) {

		//get first element of the queue
		auto function = queue.front();
		queue.pop();
        
        if(current_function->get_seed() == function->get_seed())return true;
			
        bool visited = false;
        size_t function_seed = function->get_seed();

        
        if ( already_visited.find(function_seed) != already_visited.end() ) {
            visited = true;
        } 
    
        
			
        //check if the successor abb is already stored in the list				
        if(!visited) {
            
            already_visited.insert(std::make_pair(function_seed, function_seed));
            
            for(auto called_function :function->get_called_functions()){
                
                if(called_function!=nullptr)queue.push(called_function);
            }
        }
    }
    
    return false;
}

/**
* @brief check if the end abb is reachable via BFS from start abb in Global CFG of vertex
* @param definition_function definition_function of vertex, where the reachbility is analyzed
* @param start start abb
* @param end target abb
* @return returns if the end abb is reachable via BFS from start abb
*/
bool is_reachable (shared_function definition_function,shared_abb start, shared_abb end,  std::map<size_t,size_t> *already_visited){
    
    //store coresponding basic block in ABB
    //queue for new created ABBs
    std::queue<shared_abb> queue; 
    std::map<size_t,size_t> tmp_already_visited;
    if(already_visited == nullptr)already_visited = &tmp_already_visited;

    queue.push(start);

    //iterate about the ABB queue
	
    while(!queue.empty()) {

		//get first element of the queue
		auto abb = queue.front();
		queue.pop();
        
        if(end->get_seed() == abb->get_seed())return true;
			
        bool visited = false;
        size_t abb_seed = abb->get_seed();

        if ( already_visited->find(abb_seed) != already_visited->end() ) {
            visited = true;
        } 
    
        
			
        //check if the successor abb is already stored in the list				
        if(!visited) {
            already_visited->insert(std::make_pair(abb_seed, abb_seed));
            bool call_return = true;
            if(abb->get_call_type()== func_call){
                auto called_function = abb->get_called_function();
                if(called_function!= nullptr){
                    if(called_function->get_exit_abb() == nullptr)call_return = false;
                    if(called_function!=nullptr)queue.push(called_function->get_entry_abb());
                }
            }
            
            if(call_return){
                //iterate about the successors of the abb
                for (auto successor: abb->get_ABB_successors()){
                    
                    //update the lists
                    queue.push(successor);
                }
            }
        }
    }
    
    //check if current function has a exit abb
    if(start->get_parent_function()->get_exit_abb() !=nullptr){
        // get all abbs where the function of start abb is called
        auto ingoing_edges = start->get_parent_function()->get_ingoing_edges();
        
        for(auto ingoing_edge : ingoing_edges){
            
            if(ingoing_edge->get_start_vertex()->get_type() == typeid(OS::ABB).hash_code()){
                auto calling_abb = std::dynamic_pointer_cast<OS::ABB> (ingoing_edge->get_start_vertex());
                if(is_in_calltree(definition_function, calling_abb->get_parent_function())){
                    for(auto successor : calling_abb->get_ABB_successors()){
                        if (already_visited->find(successor->get_seed()) == already_visited->end()) {
                            if(is_reachable (definition_function,successor, end, already_visited))return true;
                        }
                    }
                }
            }
        }
    }
    return false;
}
    
/**
* @brief returns the funccall or syscall llvm instruction
* @param abb abb to analyze
* @return returns the funccall or syscall llvm instruction, if abb computation abb return nullptr
*/
llvm::Instruction* get_instruction(shared_abb abb){
    
    if(abb->get_call_type() == sys_call)return abb->get_syscall_instruction_reference();
    else if(abb->get_call_type() == func_call)return abb->get_call_instruction_reference();
    else if (abb->get_call_type() == computation){
        return &abb->get_entry_bb()->front();
    }else return nullptr;
    
}


/**
* @brief return the definition_function of a task, isr or coroutine
* @param vertex vertex, which definition_function is searched
* @return return the definition_function of a task, isr or coroutine, if vertex not a class of those return nullptr
*/
shared_function get_definition_function(shared_vertex vertex){
    
    if(vertex->get_type() == typeid(OS::Task).hash_code()){
        auto task = std::dynamic_pointer_cast<OS::Task> (vertex);
        return task->get_definition_function();
    }else if(vertex->get_type() == typeid(OS::ISR).hash_code()){
        auto isr = std::dynamic_pointer_cast<OS::ISR> (vertex);
        return isr->get_definition_function();
    }else if(vertex->get_type() == typeid(OS::CoRoutine).hash_code()){
        auto coroutine = std::dynamic_pointer_cast<OS::CoRoutine> (vertex);
        return coroutine->get_definition_function();
    }
    return nullptr;
}
    

/**
* @brief check if the end abb is dominated by start abb
* @param start start abb
* @param end target abb
* @return returns true if the end abb is dominated via BFS from start abb,else false
*/
bool is_dominated (shared_function function, shared_abb start, shared_abb end, std::map<size_t,size_t>* already_visited){
    
    if(start == nullptr || end == nullptr)return false;
    
    std::map<size_t,size_t> tmp_already_visited;
    
    if(already_visited==nullptr)already_visited = &tmp_already_visited;
    
    //store coresponding basic block in ABB
    //queue for new created ABBs
    
    auto dominator_tree = start->get_parent_function()->get_dominator_tree();

    if(start->get_parent_function()->get_seed() == end->get_parent_function()->get_seed()){
        
      
        llvm::Instruction* start_instruction =  get_instruction(start);
        llvm::Instruction* end_instruction = get_instruction(end);
        
        if(dominator_tree->dominates(start_instruction,end_instruction))return true;
        else return false;
        
    }else{
        
        
        //store coresponding basic block in ABB
        //queue for new created ABBs
        std::queue<shared_abb> queue; 
        
        queue.push(start);

        //iterate about the ABB queue
        
        while(!queue.empty()) {

            //get first element of the queue
            auto abb = queue.front();
            queue.pop();
                          
            bool visited = false;
            size_t abb_seed = abb->get_seed();
           
            if(already_visited->find(abb_seed) != already_visited->end())visited = true;
    
            
            
            //check if the successor abb is already stored in the list				
            if(!visited) {
              
                
                already_visited->insert(std::pair<size_t,size_t>(abb_seed, abb_seed));

                bool call_return = true;
                
                if(abb->get_call_type()== func_call){ 
                    
                    llvm::Instruction* start_instruction =  get_instruction(start);
                    llvm::Instruction* end_instruction = get_instruction(abb);
                    
                    
                    
                    //if func call abb is dominated by start abb and called function is not already visited analyse dominance in called function recursive
                    if(dominator_tree->dominates(start_instruction,end_instruction)){
                        auto called_function = abb->get_called_function();
                        if(called_function->get_exit_abb() == nullptr)call_return = false;
                        if(already_visited->find( called_function->get_entry_abb()->get_seed()) == already_visited->end()) {
                            if(is_dominated (function, called_function->get_entry_abb(),  end, already_visited)){
                                return true;
                            }
                        }
                     }
                }
                if(call_return == true){
                    //iterate about the successors of the abb
                    for (auto successor: abb->get_ABB_successors()){
                        
                        //update the lists
                        queue.push(successor);
                    }
                }
            }
        }
    }
    
    return false;
}



/**
* @brief do a BFS in the function and set each reached abb to critical
* @param function function which is analyzed
* @param already_visited call instruction references which were alread visited
* @param recursion_upside flag if recursion upside is allowed in call tree of vertex
* @param exit_definition_function flag if end of definition function was reached with DFS
* @return if the critical region reaches exit abb, return true, else false
*/
bool detect_critical_region_in_function (shared_function definition_function,shared_function function,shared_abb entry_abb,std::map<size_t,size_t>* already_visited,bool recursion_upside, bool& exit_definition_function){
    
    if(function == nullptr) return true;
    std::queue<shared_abb> queue; 

    queue.push(entry_abb);
    
    bool reaches_exit_abb = false;
    
    shared_abb exit_abb  = nullptr;
    shared_abb definition_exit_abb = nullptr;
    
    if(function->get_exit_abb() != nullptr)exit_abb = function->get_exit_abb();
    if(definition_function->get_exit_abb() != nullptr)definition_exit_abb = definition_function->get_exit_abb();
    
    //iterate about the ABB queue
    while(!queue.empty()) {

		//get first element of the queue
		auto abb = queue.front();
		queue.pop();
        
        
			
        bool visited = false;
        size_t abb_seed = abb->get_seed();
	 
        if ( already_visited->find(abb_seed) != already_visited->end() ) {
            visited = true;
        }		
        //check if the successor abb is already stored in the list				
        if(!visited) {
            
            //check if DFS reaches the exit abb of function and store information
            if(exit_abb != nullptr && exit_abb->get_seed() == abb->get_seed())reaches_exit_abb = true;
            if(definition_exit_abb != nullptr && definition_exit_abb->get_seed() == abb->get_seed())exit_definition_function = true;
            
            already_visited->insert(std::make_pair(abb_seed, abb_seed));
            
            //std::cerr << "critical" << abb->get_name() << std::endl; 
            abb->set_critical(true);
            
            bool analyse_successors = true;
        
            if(abb->get_call_type()== func_call){
                auto called_function = abb->get_called_function();
                //do recursion of called function
                //if false returned, dont continue with successors of current abb
                if(called_function != nullptr)entry_abb = called_function->get_entry_abb(); 
                if(!detect_critical_region_in_function(definition_function,called_function,entry_abb,already_visited,false,exit_definition_function))analyse_successors = false;

            }
            if(analyse_successors){
                //iterate about the successors of the abb
                for (auto successor: abb->get_ABB_successors()){
                    //update the queue
                    queue.push(successor);
                }
            }
            
            if(exit_abb != nullptr && exit_abb->get_seed() == abb->get_seed() && !analyse_successors){
                reaches_exit_abb = false;
                abb->set_critical(false);
            }
            
            if(definition_exit_abb != nullptr && definition_exit_abb->get_seed() == abb->get_seed() && !analyse_successors){
                exit_definition_function = false;
                abb->set_critical(false);
            }
        }
    }
     //check if current function has a exit abb and upwards recursion in call tree is allowed
    if(reaches_exit_abb && recursion_upside){
        
        // get all abbs where the function of start abb is called
        auto ingoing_edges = exit_abb->get_parent_function()->get_ingoing_edges();
        
        for(auto ingoing_edge : ingoing_edges){
            
            if(ingoing_edge->get_start_vertex()->get_type() == typeid(OS::ABB).hash_code()){
                auto calling_abb = std::dynamic_pointer_cast<OS::ABB> (ingoing_edge->get_start_vertex());
                //check if calling abb is function call tree of vertex
                if(is_in_calltree(definition_function, calling_abb->get_parent_function())){
                    for(auto successor : calling_abb->get_ABB_successors()){
                        //check if successors of calling abb are not already visited
                        if (already_visited->find(successor->get_seed()) == already_visited->end()) {
                            //continue at place where the function is called
                            //std::cerr <<"exit abb upwards: " <<  exit_abb->get_name() << " " << reaches_exit_abb << std::endl;
                            detect_critical_region_in_function(definition_function,calling_abb->get_parent_function(),successor,already_visited,true,exit_definition_function);
                        }
                    }
                }
            }
        }
        return true;
        
        
    }else{
        //std::cerr <<"exit abb downwards: " << reaches_exit_abb << std::endl;
        return reaches_exit_abb;
    }
}
    
/**
* @brief start from each start call a BFS and set reached abbs to critical section
* @param definition_function definition_function of vertex which is analyzed
* @param start_calls start calls from which BFS  starts
* @param end_calls end calls, which were set to in the already_visited list to stop BFS at that point
* @return return true if the critical region reacheas the exit abb, else return false
*/
bool detect_critical_regions (shared_function definition_function, std::list<graph::shared_edge>* start_calls, std::list<graph::shared_edge>* end_calls){
    

    //get exit abb of definition function
    shared_abb exit_abb = nullptr;
    if(definition_function!=nullptr){
        exit_abb = definition_function->get_exit_abb();
    }
    
    bool exit_definition_function = false;
    
    //iterate about start calls of critical region and do dfs till end call  is reached
    for(auto start_call : *start_calls){
        
        std::map<size_t,size_t> already_visited;
        
        //set the exit calls of critical region in alread visited list to stop DFS at these vertices
        for(auto end_call : *end_calls){
            already_visited.insert(std::make_pair(end_call->get_abb_reference()->get_seed(), end_call->get_abb_reference()->get_seed()));
        }
        //start DFS at start of critical region
        shared_abb start_abb = start_call->get_abb_reference();
        
        //do DFS 
        
       
        detect_critical_region_in_function(definition_function,start_abb->get_parent_function(),start_abb,&already_visited,true,exit_definition_function);

        
    }
    
    for(auto end_call : *end_calls){
        end_call->get_abb_reference()->set_critical(true);
    }               
    
   
    //check if critical region reached exit abb of defintiion function
    if(exit_abb!= nullptr){
        //std::cerr <<"end exit abb master: " <<  exit_abb->get_name() << " " << exit_definition_function << std::endl;
        return exit_definition_function;
    }
    else return false;
}


/**
* @brief check if all mutexes were given after taken from same instance
* @param graph project data structure
*/
void verify_mutexes(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
     //get all isrs, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Resource).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto resource = std::dynamic_pointer_cast<OS::Resource> (vertex);
        
        
        //std::cerr << "resource:" <<  resource->get_name() << std::endl;
        
        auto ingoing_edges = resource->get_ingoing_edges();
        std::vector<graph::shared_edge> mutex_takes;
        std::vector<graph::shared_edge> mutex_gives;
        for(auto ingoing : ingoing_edges){
            
            if(ingoing->get_abb_reference()->get_syscall_type() == commit)mutex_gives.emplace_back(ingoing);
            //std::cerr  << "in " <<  ingoing->get_name() << std::endl;
        }
        
        auto outgoing_edges = resource->get_outgoing_edges();
        for(auto outgoing : outgoing_edges){
            if(outgoing->get_abb_reference()->get_syscall_type() == take)mutex_takes.emplace_back(outgoing);
            //std::cerr <<  "out " << outgoing->get_name() << std::endl;
        }
        

        if(resource->get_resource_type() == binary_mutex  || resource->get_resource_type() == recursive_mutex){
            std::list<std::size_t> parallel_takes;
                        
            //iterate about take instructions of resource
            for(auto take : mutex_takes){
                bool mutex_flag = false;
                //iterate about give instructions of resource
                for(auto give :mutex_gives){
                    //std::cerr <<  "start " << give->get_start_vertex()->get_name() <<  "end" <<   take->get_target_vertex()->get_name()  << std::endl;
                    //check if take and give are done by same task
                    if(give->get_start_vertex()->get_seed() == take->get_target_vertex()->get_seed()){
                        auto definition_function = get_definition_function(take->get_target_vertex());
                        if(is_reachable (definition_function,take->get_abb_reference(), give->get_abb_reference(),nullptr))mutex_flag = true;
                    }
                }
                if(!mutex_flag){
                    auto warning = std::make_shared<ResourceUseWarning>(resource, take->get_start_vertex(), take->get_abb_reference());
                    warning_list->emplace_back(warning);
                }
            }
        } 
    }
}

/**
* @brief check if semaphore are given from other instances than the waiting instance
* @param graph project data structure
*/
void verify_semaphores(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
     //get all isrs, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Semaphore).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto semaphore = std::dynamic_pointer_cast<OS::Semaphore> (vertex);
        
        
        //std::cerr << "semaphore:" <<  semaphore->get_name() << std::endl;
        
        auto ingoing_edges = semaphore->get_ingoing_edges();
        std::vector<graph::shared_edge> semaphore_takes;
        std::vector<graph::shared_edge> semaphore_gives;
        
        //store all ingoing edges which gives the semaphore
        for(auto ingoing : ingoing_edges){
    
            if(ingoing->get_abb_reference()->get_syscall_type() == commit)semaphore_gives.emplace_back(ingoing);
            //std::cerr  << "in " <<  ingoing->get_name() << std::endl;
        }
        
        //store all outgoing edges which takes the semaphore
        auto outgoing_edges = semaphore->get_outgoing_edges();
        for(auto outgoing : outgoing_edges){
            if(outgoing->get_abb_reference()->get_syscall_type() == take)semaphore_takes.emplace_back(outgoing);
            //std::cerr <<  "out " << outgoing->get_name() << std::endl;
        }
        
        
        //check if the semaphore is from right type
        if(semaphore->get_semaphore_type() == binary_semaphore  || semaphore->get_semaphore_type() == counting_semaphore){
            
            //check if for each take a corresonding give exists
            for(auto take : semaphore_takes){
                bool semaphore_flag = false;
                for(auto give :semaphore_gives){
                    //check if the give and the take is done by different abstraction instances
                    if(give->get_start_vertex()->get_seed() != take->get_target_vertex()->get_seed()){
                        semaphore_flag = true;
                    }
                }
                
                if(!semaphore_flag){
                    //error no take and give from different abstraction instances-> store warning
                    auto warning = std::make_shared<SemaphoreUseWarning>(semaphore, take->get_start_vertex(), take->get_abb_reference());
                    warning_list->emplace_back(warning);
                }
            }
            
            //check if for each give a corresonding take exists
            for(auto give :semaphore_gives){
                bool semaphore_flag = false;
                for(auto take : semaphore_takes){

                    //check if the give and the take is done by different abstraction instances
                    if(give->get_start_vertex()->get_seed() != take->get_target_vertex()->get_seed()){
                        semaphore_flag = true;
                    }
                }
                
                if(!semaphore_flag){
                    //error no take and give from different abstraction instances-> store warning
                    auto warning = std::make_shared<SemaphoreUseWarning>(semaphore, give->get_start_vertex(), give->get_abb_reference());
                    warning_list->emplace_back(warning);
                }
            }
        }
    }
}

/**
* @brief check if all event bits are set, which are waited for
* @param graph project data structure
*/
void verify_freertos_events(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    
    std::hash<std::string> hash_fn;
    std::string rtos_name = "RTOS";
    
    //load the rtos graph instance
    auto rtos_vertex = graph.get_vertex(hash_fn(rtos_name +  typeid(OS::RTOS).name()));
    
    if(rtos_vertex == nullptr){
        std::cerr << "ERROR: RTOS could not load from graph" << std::endl;
        abort();
    }
    auto rtos = std::dynamic_pointer_cast<OS::RTOS> (rtos_vertex);
    
     //get all isrs, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Event).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto event = std::dynamic_pointer_cast<OS::Event> (vertex);
        
        
        //std::cerr << "event:" <<  event->get_name() << std::endl;
        
        auto ingoing_edges = event->get_ingoing_edges();
        std::vector<graph::shared_edge> set_calls;
        std::vector<graph::shared_edge> wait_calls;
        
        for(auto ingoing : ingoing_edges){
            auto type = ingoing->get_abb_reference()->get_syscall_type();
          
            if(type == commit || type == synchronize)set_calls.emplace_back(ingoing);
            //std::cerr  << "in " <<  ingoing->get_name() << std::endl;
        }
        
        auto outgoing_edges = event->get_outgoing_edges();
        for(auto outgoing : outgoing_edges){
            auto type = outgoing->get_abb_reference()->get_syscall_type();
            if(type == wait || type == synchronize)wait_calls.emplace_back(outgoing);
            //std::cerr <<  "out " << outgoing->get_name() << std::endl;
        }
        
        
        
        for(auto wait_call : wait_calls){
            auto wait_instance = wait_call->get_start_vertex()->get_seed();
            auto call = wait_call->get_specific_call();
            bool wait_for_all_bits = true;
            bool clear_on_exit = true;
            unsigned long wait_bits = 0;
            unsigned long set_bits = 0;
            
            auto type = wait_call->get_abb_reference()->get_syscall_type();
            if(type== synchronize){
                wait_bits = std::any_cast<long>(call.arguments.at(2).any_list.front());
                set_bits =  std::any_cast<long>(call.arguments.at(1).any_list.front());
                //std::cerr << "wait bits " << wait_bits << ", set bits " << set_bits << std::endl;
                
            }else if(type == wait){
                
                wait_bits = std::any_cast<long>(call.arguments.at(1).any_list.front());
                clear_on_exit = (bool) std::any_cast<long>(call.arguments.at(2).any_list.front()); 
                wait_for_all_bits = (bool) std::any_cast<long>(call.arguments.at(3).any_list.front()); 
                //std::cerr << "wait bits " << wait_bits << ", clear on exit " << clear_on_exit << ", wait_for_all_bits " << wait_for_all_bits << std::endl;
            }
            //iterate about the set calls
            for(auto set_call : set_calls){
                
                
                auto set_instance = set_call->get_start_vertex()->get_seed();
                
                if(set_instance == wait_instance){
                    
                    auto definition_function = get_definition_function(set_call->get_start_vertex());
                    
                    if(is_reachable(definition_function,wait_call->get_abb_reference(),set_call->get_abb_reference(),nullptr))continue;
                }
                auto call = set_call->get_specific_call();
                auto type = set_call->get_abb_reference()->get_syscall_type();
                
                if(type== synchronize){
                    set_bits = set_bits | std::any_cast<long>(call.arguments.at(1).any_list.front());
                    //std::cerr << "set bits " << set_bits << std::endl;
                
                }else if(type == commit){
                    
                    set_bits = set_bits |  std::any_cast<long>(call.arguments.at(1).any_list.front());
                    //std::cerr << "set bits " << set_bits << std::endl;
                }
            }
            
            if(rtos->support_16_bit_ticks == true){
                //in this mode the event list is  8 bit large
                if(set_bits >= 256|| wait_bits >= 256){
                    unsigned long bits = 0;
                    if(set_bits > wait_bits)bits = set_bits;
                    else bits = wait_bits;
                    auto warning = std::make_shared<EventWarningWrongListSize>( event,wait_call->get_target_vertex(), bits, 8,nullptr);
                    warning_list->emplace_back(warning);
                    
                }
                
            }else{
                 //in this mode the event list is 24 bit large
                if(set_bits >= 16777216 || wait_bits >= 16777216){
                    unsigned long bits = 0;
                    if(set_bits > wait_bits)bits = set_bits;
                    else bits = wait_bits;
                    auto warning = std::make_shared<EventWarningWrongListSize>( event,wait_call->get_target_vertex(), bits, 24,nullptr);
                    warning_list->emplace_back(warning);
                }
                
                
            }
            
            if(wait_for_all_bits){
                if(!((set_bits & wait_bits) == wait_bits) ){
                 
                    auto warning = std::make_shared<EventWarning>( event,wait_call->get_target_vertex(), wait_bits, set_bits,wait_call->get_abb_reference());
                    warning_list->emplace_back(warning);
                }
            }else{
                //std::cerr << "notwaitforall, set bits " << set_bits << std::endl;
                //std::cerr << "wait bits " << wait_bits << ", clear on exit " << clear_on_exit << ", wait_for_all_bits " << wait_for_all_bits << std::endl;
                //std::cerr << (set_bits & wait_bits) << std::endl;
                if(!((set_bits & wait_bits))){
                    auto warning = std::make_shared<EventWarning>( event,wait_call->get_target_vertex(), wait_bits, set_bits,wait_call->get_abb_reference());
                    warning_list->emplace_back(warning);
                }
            }
        }
    }
}



/**
* @brief check if application contains a possible priority inversion
* @param graph project data structure
*/
void verify_priority_inversion(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    //task which use resource have different priorities
    auto resource_list =  graph.get_type_vertices(typeid(OS::Resource).hash_code());
    
    auto task_list = graph.get_type_vertices(typeid(OS::Task).hash_code());
    
	//iterate about the resources and 
    //check if the resource is accessed by other instances (task,isr) with different priorities bounded piority inversion
    //check if the resource is accessed by other instances (task,isr)  and their is another instance with a lower priority that doesnt access the resource 
	
    for (auto &vertex : resource_list){
    
        auto resource = std::dynamic_pointer_cast<OS::Resource>(vertex);
       
        
        //get all tasks with takes the resource
        for(auto outgoing_edge : resource->get_outgoing_edges()){

            auto accessed_vertex = outgoing_edge->get_target_vertex();
            //std::cerr << accessed_vertex->get_name() << std::endl;
            
            if(typeid(OS::Task).hash_code() == accessed_vertex->get_type()){
            
                auto task = std::dynamic_pointer_cast<OS::Task>(accessed_vertex);
                
                //check if task has a constant priority and takes the resource -> continue if not
                if(outgoing_edge->get_abb_reference()->get_syscall_type() != take  || !task->has_constant_priority() )continue;
                
                bool flag = false;
                std::list<shared_task> resource_task_list;
                resource_task_list.emplace_back(task);
                
                unsigned long min_priority = task->get_priority();
                unsigned long max_priority = task->get_priority();
                
                shared_task max_priority_task = task;
                shared_task min_priority_task = task;
                
                //get all tasks with takes the resource
                for(auto tmp_outgoing_edge : resource->get_outgoing_edges()){
                    
                    auto tmp_accessed_vertex = tmp_outgoing_edge->get_target_vertex();
                    //std::cerr << tmp_accessed_vertex->get_name() << std::endl;
                    if(typeid(OS::Task).hash_code() == tmp_accessed_vertex->get_type()){
                        
                        auto tmp_task = std::dynamic_pointer_cast<OS::Task>(tmp_accessed_vertex);
                
                        if(tmp_outgoing_edge->get_abb_reference()->get_syscall_type() != take || !tmp_task->has_constant_priority() )continue;
                        
                        if(tmp_task->get_seed() == task->get_seed())continue;
                        
                        //determine the task with max and min priority
                        flag =true;
                        unsigned long priority = tmp_task->get_priority();
                        if(priority > max_priority){
                            max_priority = priority;
                            max_priority_task = tmp_task;
                        }
                        if (priority < min_priority){
                            min_priority = priority;
                            min_priority_task = tmp_task;
                        }
                        resource_task_list.emplace_back(tmp_task);
                    }
                }
                if(resource_task_list.size() >= 2 && max_priority != min_priority){
                    //std::cerr << "possible bounded piority inversion: tasks of different priorities access resource " << resource->get_name() << std::endl;
                    //std::cerr << "min priority " << min_priority << " max priority " << max_priority << std::endl;
                    std::vector<shared_task> unbouded_task_list;
                    //check if there exists another task which doesnt access the resource and have a lower priority than the max priority
                    for(auto task_vertex:task_list){
                        auto task = std::dynamic_pointer_cast<OS::Task>(task_vertex);
                        bool flag = false;
                        for(auto resource_task:resource_task_list){
                            if(task->get_seed() == resource_task->get_seed())flag = true;
                        }
                        if(flag == false){
                            if(task->get_priority() <max_priority && task->get_priority() >min_priority){
                                unbouded_task_list.emplace_back(task);
                                //std::cerr << "unbouded task " << task->get_name() << std::endl;
                            }
                        }
                    }
                    if(unbouded_task_list.size() > 0){
                        shared_abb abb;
                        for (auto& edge : resource->get_ingoing_edges()) {
                        
                            if (edge->get_abb_reference()->get_syscall_type() == create) {
                                abb = edge->get_abb_reference();
                            }
                        }
                        auto warning = std::make_shared<PriorityInversionWarning>( &unbouded_task_list, min_priority_task, max_priority_task,  resource, abb);
                        warning_list->emplace_back(warning);
                    }
                }
            }
        }
    }
}



/**
* @brief check if application contains a possible cycle
* @param graph project data structure
* @return true if the graph contains a cycle
*/
bool find_cycle(graph::shared_vertex vertex,shared_abb abb,std::list<size_t>* visited,graph::Graph& graph,int depth,size_t start){
    
   
    //check if the current vertex is the start vertex and if the cycle size big enough (min. 2)
    size_t seed = vertex->get_seed();
    if(list_contains_element(visited,seed)){
        if(start == seed && depth > 2)return true;
        else return false;
    }
    visited->emplace_back(seed);
    std::list<graph::shared_edge> edges;
    
    bool resource_perspective = false;
    
    //check if the current vertex is a resource or a (task, isr) 
    if(vertex->get_type()== typeid(OS::Resource).hash_code()){
        edges = vertex->get_outgoing_edges();
        resource_perspective = true;
    }else{
        edges = vertex->get_ingoing_edges();
    }
    
        
    //from task perspective get the resource that is taken
    for (auto edge: edges) { 
               
        if(edge->get_abb_reference()->get_syscall_type() != take)continue;
        
        graph::shared_vertex target_vertex;
        if(resource_perspective){
            //from resource perspective
            target_vertex = edge->get_target_vertex();
        }else{
            //from task or isr perspective
            target_vertex = edge->get_start_vertex();
            shared_function definition_function = get_definition_function(target_vertex);
            if(target_vertex->get_type()!=typeid(OS::Resource).hash_code())continue;
            if(!is_reachable(definition_function,abb,edge->get_abb_reference(),nullptr))continue;
        }
       
        //recursion
        if (find_cycle(target_vertex,edge->get_abb_reference(),visited ,graph, depth +1  ,start))return true; 
    } 
    
    //remove current seed.
    visited->remove(seed);
    return false;
}

/**
* @brief check if application contians a possible deadlock
* @param graph project data structure
*/
void verify_deadlocks(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    //get all resources, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Resource).hash_code());
    
	//iterate about the resources
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto resource = std::dynamic_pointer_cast<OS::Resource> (vertex);
        std::list<size_t> visited;
        //check if there is cycle in the graph with starts and ends at the resource
        if(find_cycle(resource,nullptr, &visited,graph,0,resource->get_seed())){
          
            std::vector<graph::shared_vertex> deadlockchain;
            
            for(auto element_seed: visited){
            
                deadlockchain.emplace_back(graph.get_vertex(element_seed));
                
            }
             shared_abb abb;
             for (auto& edge : resource->get_ingoing_edges()) {
                        
                if (edge->get_abb_reference()->get_syscall_type() == create) {
                    abb = edge->get_abb_reference();
                }
            }
            
            //std::cerr << abb->get_name() << std::endl;
            auto warning = std::make_shared<DeadLockWarning>(&deadlockchain, abb);
            warning_list->emplace_back(warning);
            
            break;
        }
    }
}


/**
* @brief check if the priority of each task is constant or was changed after start scheduler
* @param graph project data structure
*/
void verify_task_priority(graph::Graph& graph){
    
    //get all resources, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Task).hash_code());
    
	//iterate about the tasks
	for (auto &vertex : vertex_list) {
		std::vector<llvm::Instruction*> already_visited;
        auto task = std::dynamic_pointer_cast<OS::Task> (vertex);
        for(auto ingoing_edge : task->get_ingoing_edges()){
            if(ingoing_edge->get_start_vertex()->get_type() != typeid(OS::Function).hash_code()){
                if(ingoing_edge->get_abb_reference()->get_syscall_type() == set_priority){
                    //syscall changes priority of the task
                    auto call = ingoing_edge->get_specific_call();
                    
                    //get the priority from the call
                    auto priority = std::any_cast<long>(call.arguments.at(1).any_list.front());
                    
                    //set constant priority flag false if priority is different than initial priority
                    if(priority != task->get_priority())task->set_constant_priority(false);
                }
            }
        }
    }
}

/**
* @brief //check if all interactions from type start (e.g disable) with the RTOS can be removed from interaction from type end(e.genable)
*and determine critical abb regions (region between start and end)  
* @param graph project data structure
* @param vertex RTOS instance which is analyzed
* @param start_type type of syscalls for start abbs  
* @param end_type type of sys_calls for end abbs
*/
void verify_specific_critical_region(graph::Graph& graph,graph::shared_vertex vertex, syscall_definition_type start_type , syscall_definition_type end_type,std::vector<shared_warning>* warning_list, size_t target,bool same_direction){
    
    
    //get all edges from start end end type and store them in lists
    std::list<graph::shared_edge> start_interactions;
    std::list<graph::shared_edge> end_interactions;
    if(same_direction){
        for(auto outgoing_edge : vertex->get_outgoing_edges()){
            //check if the interaction addresses the OS
            if(outgoing_edge->get_target_vertex()->get_seed() != target)continue;
            //check if the interaction disables functionalities
            if(outgoing_edge->get_abb_reference()->get_syscall_type() == start_type)start_interactions.emplace_back(outgoing_edge);
            else if(outgoing_edge->get_abb_reference()->get_syscall_type() == end_type)end_interactions.emplace_back(outgoing_edge);
        }
    }else{
        //std::cerr << "---------------------------------------------------------------------------------------------------------------------------- "  << std::endl;
         for(auto outgoing_edge : vertex->get_outgoing_edges()){
            //check if the interaction addresses the OS
            if(outgoing_edge->get_target_vertex()->get_seed() != target)continue;
            //check if the interaction disables functionalities
            if(outgoing_edge->get_abb_reference()->get_syscall_type() == end_type){
                end_interactions.emplace_back(outgoing_edge);
                //std::cerr << "end " << outgoing_edge->get_abb_reference()->get_syscall_name() << std::endl;
            }
        }
        for(auto ingoing_edge : vertex->get_ingoing_edges()){
            //check if the interaction addresses the OS
            if(ingoing_edge->get_start_vertex()->get_seed() != target)continue;
            //check if the interaction disables functionalities
            if(ingoing_edge->get_abb_reference()->get_syscall_type() == start_type){
                start_interactions.emplace_back(ingoing_edge);
                //std::cerr << "start " << ingoing_edge->get_abb_reference()->get_syscall_name() << std::endl;
            }
        }
    }
    
    bool success = true;
    shared_abb abb = nullptr;
    //check if all calls from start were stopped certainly from end calls
    
    
    
    for(auto start_interaction :start_interactions){
        bool flag = false;
        
        //check if start critical region calls exits but no end critical region call
        if(start_interactions.size() > 0 && end_interactions.size() == 0)success = false;
        else {
            

            shared_function definition_function = nullptr;
        
            for(auto end_interaction :end_interactions){
                definition_function = get_definition_function(vertex);
                if(is_reachable(definition_function,start_interaction->get_abb_reference(), end_interaction->get_abb_reference(),nullptr)) flag = true;
            }
            //detect critical region between start and end
            if(!flag)success = false;
            if(detect_critical_regions(definition_function,&start_interactions,&end_interactions))success = false;
           
        }
        if(success == false){
            
            //std::cerr << "critical region " << start_interaction->get_abb_reference()->get_name() << std::endl;
            //generate warning if critical region reaches exit abb of definition function
            auto warning = std::make_shared<CriticalRegionWarning>(vertex, start_interaction->get_abb_reference());
            warning_list->emplace_back(warning);
        }
    }

}
/*
/**
* @brief //check if all interactions from type start (e.g disable) with the RTOS were removed certainly from interaction from type end(e.genable)
*and determine critical abb regions (region between start and end)  
* @param graph project data structure
*/
void verify_critical_region(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    std::string rtos_name = "RTOS";
    std::hash<std::string> hash_fn;
    //get all tasks, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Task).hash_code());
    
    //load the rtos graph instance
    auto rtos_vertex = graph.get_vertex(hash_fn(rtos_name +  typeid(OS::RTOS).name()));
    
    if(rtos_vertex == nullptr){
        std::cerr << "ERROR: RTOS could not load from graph" << std::endl;
        abort();
    }
    auto rtos = std::dynamic_pointer_cast<OS::RTOS> (rtos_vertex);
    
    
    //iterate about the tasks
    for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
        auto task = std::dynamic_pointer_cast<OS::Task> (vertex);
        
        //check if all interactions from type start (e.g disable) with the RTOS were removed certainly from interaction from type end(e.genable)
        verify_specific_critical_region(graph,task, disable, enable,warning_list,rtos->get_seed(),true);
        verify_specific_critical_region(graph,task, suspend, resume,warning_list,rtos->get_seed(),true);
        verify_specific_critical_region(graph,task, enter_critical, exit_critical,warning_list,rtos->get_seed(),true);
        
        //check if mutex is successfully ends
        for(auto edge: vertex->get_outgoing_edges()){
            
            if(edge->get_target_vertex()->get_type() == typeid(OS::Resource).hash_code()){
                
                verify_specific_critical_region(graph,task, take, commit,warning_list,edge->get_target_vertex()->get_seed(),false);
                
            }
        }
    }
}

/**
* @brief check if all isrs use the freertos compatible api
* @param graph project data structure
*/

void verify_isrs(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    auto vertex_list =  graph.get_type_vertices(typeid(OS::ISR).hash_code());
    for (auto &vertex : vertex_list) {
        auto isr = std::dynamic_pointer_cast<OS::ISR>(vertex);
        
        std::list<size_t> already_visited;
        //store coresponding basic block in ABB
        //queue for new created ABBs
        std::queue<shared_abb> queue; 

        queue.push(isr->get_definition_function()->get_entry_abb());

        //iterate about the ABB queue
        
        while(!queue.empty()) {

            //get first element of the queue
            auto abb = queue.front();
            queue.pop();
            
            //check if the syscall of the isr contains the substring FromISR
            if(abb->get_call_type()== sys_call){
                
                
                std::size_t found = abb->get_syscall_name().find("FromISR");
                if(found==std::string::npos){                   
                    auto warning = std::make_shared<ISRSyscallWarning>( abb, isr);
                    warning_list->emplace_back(warning);
                }
            }
            bool visited = false;
            size_t abb_seed = abb->get_seed();
            for(auto seed : already_visited){
                if(seed == abb_seed)visited = true;
            }
                
            //check if the successor abb is already stored in the list				
            if(!visited) {
                already_visited.emplace_back(abb_seed);
             
                
                if(abb->get_call_type()== func_call){
                    auto called_function = abb->get_called_function();
                    if(called_function != nullptr){
                        visited = false;
                        auto entry_seed = called_function->get_entry_abb()->get_seed();
                        for(auto seed : already_visited){
                            if(seed == entry_seed){
                                visited = true;
                                break;
                            }
                        }
                        
                        if(!visited)queue.push(called_function->get_entry_abb());
                    }
                }
                //iterate about the successors of the abb
                for (auto successor: abb->get_ABB_successors()){
                    
                    //update the lists
                    queue.push(successor);
                }
            }
        }
    }
    
}


/**
* @brief check if abstraction instances are used without enable flag
* @param graph project data structure
*/

void verify_abstraction_instances_use(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    std::hash<std::string> hash_fn;
    std::string rtos_name = "RTOS";
    
    //load the rtos graph instance
    auto rtos_vertex = graph.get_vertex(hash_fn(rtos_name +  typeid(OS::RTOS).name()));
    
    if(rtos_vertex == nullptr){
        std::cerr << "ERROR: RTOS could not load from graph" << std::endl;
        abort();
    }
    auto rtos = std::dynamic_pointer_cast<OS::RTOS> (rtos_vertex);
    
    if(rtos->support_coroutines == false){
        auto co_routines = graph.get_type_vertices(typeid(OS::CoRoutine).hash_code());
        for(auto co_routine : co_routines){
            auto warning = std::make_shared<EnableWarning>("CoRoutine",co_routine, nullptr);
            warning_list->emplace_back(warning);;
        }
    };
    if(rtos->support_queue_sets == false){
        auto queue_sets = graph.get_type_vertices(typeid(OS::QueueSet).hash_code());
        for(auto queue_set : queue_sets){
            auto warning = std::make_shared<EnableWarning>("QueueSet",queue_set, nullptr);
            warning_list->emplace_back(warning);
        }
    };
    if(rtos->support_counting_semaphores == false){
        
        auto semaphores = graph.get_type_vertices(typeid(OS::Semaphore).hash_code());
        for(auto tmp_semaphore : semaphores){
            auto semaphore = std::dynamic_pointer_cast<OS::Semaphore>(tmp_semaphore);
            if(rtos->support_counting_semaphores == false  && semaphore->get_semaphore_type() == counting_semaphore){
                auto warning = std::make_shared<EnableWarning>("Counting semaphore",semaphore, nullptr);
                warning_list->emplace_back(warning);
            }
        }
        
    };
    if(rtos->support_recursive_mutexes == false || rtos->support_mutexes == false){
        
        auto resources = graph.get_type_vertices(typeid(OS::Resource).hash_code());
        for(auto tmp_resource : resources){
            auto resource = std::dynamic_pointer_cast<OS::Resource>(tmp_resource);
            if(rtos->support_recursive_mutexes == false  && resource->get_resource_type() == recursive_mutex){
                auto warning = std::make_shared<EnableWarning>("Recursive mutex",resource, nullptr);
                warning_list->emplace_back(warning);
            }
            if(rtos->support_mutexes == false  && resource->get_resource_type() == binary_mutex){
                auto warning = std::make_shared<EnableWarning>("Binary mutex", resource, nullptr);
                warning_list->emplace_back(warning);
            }
        }
    };

    if(rtos->support_task_notification == false){
        
    };
    
}

/**
* @brief check if members of queuesets are read, before the data are accessed;
* Note: If  a  queue  is  a  member  of  a  queue  set  then  do  not  read  data
* from  the  queue unless the queue’s handle has first been read from the queue set.
* @param graph project data structure
*/

void verify_queueset_members(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    //get the queuesets of the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::QueueSet).hash_code());
    for (auto &vertex : vertex_list) {
        auto queueset = std::dynamic_pointer_cast<OS::QueueSet>(vertex);
        
        //get the stored members of the queuset
        auto queueset_elements = queueset->get_queueset_elements();
        
        //check if the queueset element is reveived or taken, and before the queueset element is taken
        for(auto queueset_element :*queueset_elements){
            

            auto ingoing_edges = queueset_element->get_ingoing_edges();
            for(auto ingoing_edge:ingoing_edges){
                
                if(ingoing_edge->get_abb_reference()->get_syscall_type() == take || ingoing_edge->get_abb_reference()->get_syscall_type() == receive){
                    
                    bool success = false;
                    //TODO check outgoing /ingoing
                    for(auto queueset_ingoing_edge:queueset->get_ingoing_edges()){
                        if(queueset_ingoing_edge->get_abb_reference()->get_syscall_type() == take){
                            
                            auto definition_function = get_definition_function(queueset_ingoing_edge->get_start_vertex());
                            
                            //the queueset element get element syscall is reachable from the queueset get element syscall
                            if(is_reachable(definition_function,queueset_ingoing_edge->get_abb_reference(),ingoing_edge->get_abb_reference(),nullptr)){
                                success = true;
                                break;
                            }
                        }
                    }
                    if(!success){
                        
                        auto warning = std::make_shared<QueueSetWarning>( queueset, queueset_element,ingoing_edge->get_abb_reference());
                        warning_list->emplace_back(warning);
                    }
                }
            }
        }
    }
}


/**
* @brief check if a buffer is used in one reader and one writer mode
* @param graph project data structure
*/

void verify_buffer_access(graph::Graph& graph,std::vector<shared_warning>* warning_list){
    
    //get the buffers of the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Buffer).hash_code());
    for (auto &vertex : vertex_list) {
        auto buffer = std::dynamic_pointer_cast<OS::Buffer>(vertex);
        shared_abb abb;
        std::map<size_t,size_t> accessed_elements;
        for(auto outgoing_edge :buffer->get_outgoing_edges()){
            if(outgoing_edge->get_abb_reference()->get_syscall_type() == commit ||  outgoing_edge->get_abb_reference()->get_syscall_type() == receive){
                size_t seed = outgoing_edge->get_target_vertex()->get_seed();
                accessed_elements.insert(std::pair<size_t,size_t>(seed, seed));
                abb = outgoing_edge->get_abb_reference();
            }
        }
        for(auto ingoing_edge :buffer->get_ingoing_edges()){
            if(ingoing_edge->get_abb_reference()->get_syscall_type() == commit ||  ingoing_edge->get_abb_reference()->get_syscall_type() == receive){
                size_t seed = ingoing_edge->get_start_vertex()->get_seed();
                accessed_elements.insert(std::pair<size_t,size_t>(seed, seed));
                abb = ingoing_edge->get_abb_reference();
            }
        }
        if(accessed_elements.size() != 2){
            
            auto warning = std::make_shared<BufferWarning>(buffer, abb);
            warning_list->emplace_back(warning);
        }
    }
}

namespace step {

	std::string ValidationStep::get_name() {
		return "ValidationStep";
	}

	std::string ValidationStep::get_description() {
		return "Validates the ARSA graph regarding the right use of abstraction instances. Deadlocks, priority inversions are detected and the right use of mutexes, events and semaphore is checked. Also critical regions are determined.";
	}
	
    /**
    * @brief the run method of the ValidationStep pass. This pass detects all interactions of the instances via the RTOS. 
    * @param graph project data structure
    */
	void ValidationStep::run(graph::Graph& graph) {
		
		std::cout << "Run ValidationStep" << std::endl;
		//detect interactions of the OS abstraction instances
        
        std::vector<shared_warning>* warning_list = &(this->warnings);
         
        verify_mutexes(graph,warning_list);
        verify_semaphores(graph,warning_list);
        verify_isrs(graph,warning_list);
        verify_freertos_events(graph,warning_list);
        verify_deadlocks(graph,warning_list);
        verify_priority_inversion(graph,warning_list);
        verify_critical_region(graph,warning_list);
        
	}
	
	std::vector<std::string> ValidationStep::get_dependencies() {
        
       
        // get file arguments from config
		std::vector<std::string> files;
        
		PyObject* elem = PyDict_GetItemString(config, "os");
        
        if(elem != nullptr)std::cerr << "success" << std::endl;
		assert(PyUnicode_Check(elem));
		return {"DetectInteractionsStep"};

	}
}
//RAII
