// vim: set noet ts=4 sw=4:



#include "llvm/Analysis/AssumptionCache.h"
#include "DetectInteractions.h"
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


//print the argument
void debug_argument_test(std::any value){
	
	std::size_t const tmp = value.type().hash_code();
	const std::size_t  tmp_int = typeid(int).hash_code();
	const std::size_t  tmp_double = typeid(double).hash_code();
	const std::size_t  tmp_string = typeid(std::string).hash_code();
	const std::size_t tmp_long 	= typeid(long).hash_code();
	std::cerr << "Argument: ";
	
		
	if(tmp_int == tmp){
		std::cerr << std::any_cast<int>(value)   <<'\n';
	}else if(tmp_double == tmp){ 
		std::cerr << std::any_cast<double>(value)  << '\n';
	}else if(tmp_string == tmp){
		std::cerr << std::any_cast<std::string>(value)  <<'\n';  
	}else if(tmp_long == tmp){
		std::cerr << std::any_cast<long>(value)   <<'\n';  
	}else{
		std::cerr << "[warning: cast not possible] type: " <<value.type().name()   <<'\n';  
	}
}

/**
* @brief do a BFS in the function and set each reached abb to critical
* @param function function which is analyzed
* @param already_visited call instruction references which were alread visited
* @return if the critical region reaches exit abb, return true, else false
*/
bool detect_critical_region_in_subfunction (shared_function function,std::list<size_t>* already_visited){
    
    if(function == nullptr) return false;
    std::queue<shared_abb> queue; 

    queue.push(function->get_entry_abb());
    
    bool reach_exit = false;
    
    size_t exit_seed = function->get_exit_abb()->get_seed();
    //iterate about the ABB queue
	
    while(!queue.empty()) {

		//get first element of the queue
		auto abb = queue.front();
		queue.pop();
        
        if(exit_seed== abb->get_seed())reach_exit = true;
			
        bool visited = false;
        size_t abb_seed = abb->get_seed();
        for(auto seed : *already_visited){
            if(seed == abb_seed)visited = true;
        }
			
        //check if the successor abb is already stored in the list				
        if(!visited) {
            std::cerr << "critical" << abb->get_name() << std::endl; 
            abb->set_critical(true);
            bool analyse_successors = true;
            already_visited->emplace_back(abb->get_seed());
            if(abb->get_call_type()== func_call){
                auto called_function = abb->get_called_function();
                //do recursion of called function
                //if false returned, dont continue with successors of current abb
                if(called_function != nullptr && !detect_critical_region_in_subfunction(called_function,already_visited))analyse_successors = false;

            }
            if(analyse_successors){
                //iterate about the successors of the abb
                for (auto successor: abb->get_ABB_successors()){
                    //update the lists
                    queue.push(successor);
                }
            }
        }
    }
    std::cerr << "reach exit" << reach_exit << std::endl;
    return reach_exit;
}

/**
* @brief check if the end abb is reachable via BFS from start abb
* @param start start abb
* @param end target abb
*/
bool is_reachable (shared_abb start, shared_abb end){
    
    std::list<size_t> already_visited;
    //store coresponding basic block in ABB
    //queue for new created ABBs
    std::queue<shared_abb> queue; 

    queue.push(start);

    //iterate about the ABB queue
	
    while(!queue.empty()) {

		//get first element of the queue
		auto abb = queue.front();
		queue.pop();
        
        if(end->get_seed() == abb->get_seed())return true;
			
        bool visited = false;
        size_t abb_seed = abb->get_seed();
        for(auto seed : already_visited){
            if(seed == abb_seed)visited = true;
        }
			
        //check if the successor abb is already stored in the list				
        if(!visited) {
            already_visited.emplace_back(abb->get_seed());
            if(abb->get_call_type()== func_call){
                auto called_function = abb->get_called_function();
                if(called_function!=nullptr)queue.push(called_function->get_entry_abb());
            }
            
            //iterate about the successors of the abb
            for (auto successor: abb->get_ABB_successors()){
                
				//update the lists
				queue.push(successor);
            }
        }
    }
    return false;
}
    

    
/**
* @brief start from each start call a BFS and set reached abbs to critical section
* @param start_calls start calls from which BFS  starts
* @param end_calls end calls, which were set to in the already_visited list to stop BFS at that point
*/
void detect_critical_regions (std::list<graph::shared_edge>* start_calls, std::list<graph::shared_edge>* end_calls){
    
    
    for(auto start_call : *start_calls){
        
        std::list<size_t> already_visited;
        
        for(auto end_call : *end_calls){
            end_call->get_abb_reference()->set_critical(true);
            already_visited.emplace_back(end_call->get_abb_reference()->get_seed());
        }
        //store coresponding basic block in ABB
        //queue for new created ABBs
        std::queue<shared_abb> queue; 
        
        start_call->get_abb_reference()->set_critical(true);
        queue.push(start_call->get_abb_reference());

        //iterate about the ABB queue
        
        while(!queue.empty()) {

            //get first element of the queue
            auto abb = queue.front();
            queue.pop();
                          
            bool visited = false;
            size_t abb_seed = abb->get_seed();
            for(auto seed : already_visited){
                if(seed == abb_seed)visited = true;
            }
            
            
            //check if the successor abb is already stored in the list				
            if(!visited) {
                abb->set_critical(true);
                std::cerr << "critical" << abb->get_name() << std::endl; 
                bool analyse_successors = true;
                already_visited.emplace_back(abb->get_seed());
                
                if(abb->get_call_type()== func_call){ 
                    auto called_function = abb->get_called_function();

                    if(called_function != nullptr && !detect_critical_region_in_subfunction(called_function,&already_visited))analyse_successors = false;
                }
                if(analyse_successors){
                    //iterate about the successors of the abb
                    for (auto successor: abb->get_ABB_successors()){
                        //update the lists
                        queue.push(successor);
                    }
                }
            }
        }
    }
}

/**
* @brief cast specific generic api calls to their corresponding individual name
* @param call call data contianer with arguments
* @param abb abb which contains a syscall
*/
void convert_syscall_name(call_data call,shared_abb abb){
    
    if(call.call_name.find("xTimerGenericCommand") !=  std::string::npos){
        
        std::string call_name;
        auto any_value = call.arguments.at(1).any_list.front();
        if(any_value.type().hash_code() == typeid(long).hash_code()){
            
            auto command_id = std::any_cast<long>(any_value);    
            
            switch(command_id){
            
                /*
                #TODO second argument = command id xCommandID
                #define tmrCOMMAND_EXECUTE_CALLBACK_FROM_ISR 	( ( BaseType_t ) -2 )
                #define tmrCOMMAND_EXECUTE_CALLBACK				( ( BaseType_t ) -1 )
                #define tmrCOMMAND_START_DONT_TRACE				( ( BaseType_t ) 0 )
                #define tmrCOMMAND_START					    ( ( BaseType_t ) 1 )
                #define tmrCOMMAND_RESET						( ( BaseType_t ) 2 )
                #define tmrCOMMAND_STOP							( ( BaseType_t ) 3 )
                #define tmrCOMMAND_CHANGE_PERIOD				( ( BaseType_t ) 4 )
                #define tmrCOMMAND_DELETE						( ( BaseType_t ) 5 )
                #define tmrFIRST_FROM_ISR_COMMAND				( ( BaseType_t ) 6 )
                #define tmrCOMMAND_START_FROM_ISR				( ( BaseType_t ) 6 )
                #define tmrCOMMAND_RESET_FROM_ISR				( ( BaseType_t ) 7 )
                #define tmrCOMMAND_STOP_FROM_ISR				( ( BaseType_t ) 8 )
                #define tmrCOMMAND_CHANGE_PERIOD_FROM_ISR		( ( BaseType_t ) 9 )
                */
                case -2: call_name = "tmrCOMMAND_EXECUTE_CALLBACK_FROM_ISR"; break;
                case -1: call_name = "tmrCOMMAND_EXECUTE_CALLBACK"; break;
                case 0: call_name = "tmrCOMMAND_START_DONT_TRACE"; break;
                case 1: call_name = "tmrCOMMAND_START"; break;
                case 2: call_name = "tmrCOMMAND_RESET"; break;
                case 3: call_name = "tmrCOMMAND_STOP"; break;
                case 4: call_name = "tmrCOMMAND_CHANGE_PERIOD"; break;
                case 5: call_name = "tmrCOMMAND_DELETE"; break;
                case 6: call_name = "tmrFIRST_FROM_ISR_COMMAND"; break;
                case 7: call_name = "tmrCOMMAND_START_FROM_ISR"; break;
                case 8: call_name = "tmrCOMMAND_RESET_FROM_ISR"; break;
                case 9: call_name = "tmrCOMMAND_STOP_FROM_ISR"; break;
                case 10: call_name = "tmrCOMMAND_CHANGE_PERIOD_FROM_ISR"; break;
                default: call_name = call.call_name; break;
            }
            abb->set_syscall_name(call_name);
            call.call_name = call_name;
        }
    }else if(call.call_name.find("xTaskGenericNotify") !=  std::string::npos){
        
        std::string call_name;
        auto any_value = call.arguments.at(2).any_list.front();
        if(any_value.type().hash_code() == typeid(long).hash_code()){
            
            auto command_id = std::any_cast<long>(any_value);    
            
            switch(command_id){
                /*
                eNoAction = 0,				Notify the task without updating its notify value.
                eSetBits,					Set bits in the task's notification value.
                eIncrement,				    Increment the task's notification value.
                eSetValueWithOverwrite,		Set the task's notification value to a specific value even if the previous value has not yet been read by the task.
                eSetValueWithoutOverwrite
                */
                case 0: call_name = "xTaskNotifyNoAction"; break;
                case 1: call_name = "xTaskNotifySetBits"; break;
                case 2: call_name = "xTaskNotifyIncrement"; break;
                case 3: call_name = "xTaskNotifySetValueWithOverwrite"; break;
                case 4: call_name = "xTaskNotifySetValueWithoutOverwrite"; break;
                default: call_name = call.call_name; break;
            }
            abb->set_syscall_name(call_name);
            call.call_name = call_name;
        }
    }
}

/**
* @brief detect interactions of OS abstractions and create the corresponding edges in the graph
* @param graph project data structure
* @param start_vertex abstraction instance which is iterated
* @param function current function of abstraction instance
* @param call_reference function call instruction
* @param already_visited call instructions which were already iterated
*/
void iterate_called_functions_interactions(graph::Graph& graph, graph::shared_vertex start_vertex, OS::shared_function function,  llvm::Instruction* call_reference ,std::vector<llvm::Instruction*>* already_visited_calls){
    
    //return if function does not contain a syscall
    if(function == nullptr || function->has_syscall() ==false)return;


	//search hash value in list of already visited basic blocks
	for(auto tmp_call : *already_visited_calls){
		if(call_reference == tmp_call){
			//basic block already visited
			return;
		}
	}
    already_visited_calls->emplace_back(call_reference);
    
    
	
    //get the abbs of the function
    std::list<OS::shared_abb> abb_list = function->get_atomic_basic_blocks();
    
    //iterate about the abbs
    for(auto &abb : abb_list){


        //check if abb contains a syscall and it is not a creational syscall
        if(abb->get_call_type() == sys_call  && abb->get_syscall_type() != create ){

            bool success = false;
            std::vector<argument_data> argument_list = abb->get_syscall_arguments();
            std::list<std::size_t>*  target_list = abb->get_call_target_instances();
        
            //load the handler name
            std::string handler_name = "";
            
            argument_data argument_candidats;
            
            //get the handler name of the target instance
            if(abb->get_handler_argument_index() != 9999){
                argument_candidats  = (argument_list.at(abb->get_handler_argument_index()));
                if(argument_list.size() > 0 && argument_candidats.any_list.size() > 0){
                    
                    auto any_argument = argument_candidats.any_list.front();
                    llvm::Value* llvm_argument_reference = nullptr;
                    if(argument_candidats.any_list.size() > 1){
                    
                        std::cerr << abb->get_syscall_name() << argument_candidats.any_list.size() << std::endl;
                        get_call_relative_argument(any_argument,llvm_argument_reference, argument_candidats,already_visited_calls);                
                    }
                    
                    
                    if(any_argument.type().hash_code() ==  typeid(std::string).hash_code()){

                        handler_name = std::any_cast<std::string>(any_argument);
                        std::cerr << handler_name << std::endl;
                        //check if the expected handler name occurs in the graph
                        bool handler_found = false;
                        for(auto &vertex : graph.get_vertices()){
                            if(vertex->get_handler_name() == handler_name)handler_found = true;
                        }
                        
                        if(!handler_found){
                            std::cerr << "handler does not exist in graph " << handler_name << std::endl;
                        }
                    }else{
                        std::cerr << "handler argument is no string" << std::endl;
                        debug_argument_test(any_argument);
                    }
                }
            }
            //iterate about the possible refereneced(syscall targets) abstraction types
            for(auto& target: *target_list){
                
                
                //the RTOS has the handler name RTOS
                if(target == typeid(OS::RTOS).hash_code())handler_name = "RTOS";
                
                //get the vertices of the specific type from the graph
                std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(target);
                
                
                //iterate about the vertices
                for (auto &target_vertex : vertex_list) {
                    
                   
                    //compare the referenced handler name with the handler name of the vertex
                    if(target_vertex->get_handler_name() == handler_name){
                        
                       
                        //get the vertex abstraction of the function, where the syscall is called
                        if(start_vertex != nullptr && target_vertex !=nullptr){
                            //check if the syscall expect values from target or commits values to target
                            if(abb->get_syscall_type() == receive || abb->get_syscall_type() == wait ){
                                
                                
                                //create the edge, which contains the start and target vertex and the arguments
                                auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(),start_vertex,target_vertex ,abb);
                                
                                //store the edge in the graph
                                graph.set_edge(edge);
                                
                                target_vertex->set_outgoing_edge(edge);
                                start_vertex->set_ingoing_edge(edge);
                                edge->set_instruction_reference( abb->get_syscall_instruction_reference());
                                //set the success flag
                                success = true;
                                
                                //get the call specific arguments 
                                auto arguments = abb->get_syscall_arguments();
                                auto syscall_reference = abb->get_syscall_instruction_reference();
                                auto specific_arguments=  get_syscall_relative_arguments( &arguments, already_visited_calls,syscall_reference,abb->get_syscall_name());
                                convert_syscall_name(specific_arguments,abb);
                                edge->set_specific_call(&specific_arguments);
                            
                            }else{	//syscall set values
                                
                                //create the edge, which contains the start and target vertex and the arguments
                                auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(), start_vertex,target_vertex,abb);
    
                                //store the edge in the graph
                                graph.set_edge(edge);
                                
                                start_vertex->set_outgoing_edge(edge);
                                target_vertex->set_ingoing_edge(edge);
                                edge->set_instruction_reference( abb->get_syscall_instruction_reference());
                                //set the success flag
                                success = true;
                                
                                //get the call specific arguments 
                                auto arguments = abb->get_syscall_arguments();
                                auto syscall_reference = abb->get_syscall_instruction_reference();
                                auto specific_arguments=  get_syscall_relative_arguments( &arguments, already_visited_calls,syscall_reference,abb->get_syscall_name());
                                convert_syscall_name(specific_arguments,abb);
                                edge->set_specific_call(&specific_arguments);
                            }
                        }
                        break;
                    }
                }
                //check if target vertex with corresponding handler name was detected
                if(success){
                    //break the loop iteration about the possible syscall target instances
                    break;
                }
            }
            if(success == false){
                //edge could not created, print warning
                if(start_vertex->get_type() == typeid(OS::Timer).hash_code()){
                }
                
                std::cout << "edge could not created: " << abb->get_syscall_name() <<  " in function " <<  abb->get_parent_function()->get_name()  << " in vertex " << start_vertex->get_name() <<  std::endl;
                debug_argument_test(argument_candidats.any_list.front());                
                std::cerr << "expected handler name " << handler_name	<< std::endl;
                abb->print_information();
            }
        }else if( abb->get_call_type()== func_call){
            //iterate about the called function
            iterate_called_functions_interactions(graph,start_vertex,abb->get_called_function(), abb->get_call_instruction_reference(),already_visited_calls  );
        }
    }
}



/**
* @brief detect interactions of OS abstractions and create the corresponding edges in the graph
* @param graph project data structure
*/
bool detect_interactions(graph::Graph& graph){
	
    
    //TODO maybe differen main functions in OSEK and FreeRTOS
    //get main function from the graph
    std::string main_function_name = "main";
    std::hash<std::string> hash_fn;
    auto main_vertex = graph.get_vertex(hash_fn(main_function_name +  typeid(OS::Function).name()));
    
    if(main_vertex==nullptr){
        std::cerr << "ERROR, application contains no main function" << std::endl;
        abort();
    }else{
        auto main_function = std::dynamic_pointer_cast<OS::Function> (main_vertex);
        //get all interactions of the main functions and their called function with other os instances
        std::vector<llvm::Instruction*> already_visited;
        iterate_called_functions_interactions(graph, main_function, main_function,nullptr, &already_visited);
    }
    
    
	//get all tasks, which are stored in the graph
	std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Task).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "task name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto task = std::dynamic_pointer_cast<OS::Task> (vertex);
        OS::shared_function task_definition = task->get_definition_function();
        //get all interactions of the instance
        iterate_called_functions_interactions(graph, vertex, task_definition,nullptr, &already_visited);
    }
    
    //get all isrs, which are stored in the graph
    vertex_list =  graph.get_type_vertices(typeid(OS::ISR).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto timer = std::dynamic_pointer_cast<OS::ISR> (vertex);
        OS::shared_function timer_definition = timer->get_definition_function();
        //get all interactions of the instance
        iterate_called_functions_interactions(graph, vertex, timer_definition,nullptr, &already_visited);
    }
        
    //get all timers of the graph
    vertex_list =  graph.get_type_vertices(typeid(OS::Timer).hash_code());
	//iterate about the timers
	for (auto &vertex : vertex_list) {
        //std::cerr << "timer name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*>  already_visited;
        auto isr = std::dynamic_pointer_cast<OS::Timer> (vertex);
        OS::shared_function isr_definition = isr->get_definition_function();
        //get all interactions of the instance
        iterate_called_functions_interactions(graph, vertex, isr_definition,nullptr, &already_visited);
    }
}

/**
* @brief check if all isrs use the freertos compatible api
* @param graph project data structure
*/
void verify_isrs(graph::Graph& graph){
    
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
                if(found==std::string::npos)std::cerr << "ISR syscall without FROMISR" << std::endl;
                abb->print_information();
            }
            bool visited = false;
            size_t abb_seed = abb->get_seed();
            for(auto seed : already_visited){
                if(seed == abb_seed)visited = true;
            }
                
            //check if the successor abb is already stored in the list				
            if(!visited) {
                if(abb->get_call_type()== sys_call){
                    auto called_function = abb->get_called_function();
                    if(called_function != nullptr){
                        queue.push(called_function->get_entry_abb());
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
* @brief add all instances to a queueset
* @param graph project data structure
*/
void add_to_queue_set(graph::Graph& graph){
    
     //get all queuesets, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::QueueSet).hash_code());
	//iterate about the queuesets
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
        
        auto queueset = std::dynamic_pointer_cast<OS::QueueSet>(vertex);
        
        auto ingoing_edges = queueset->get_ingoing_edges();
        
        //detect all calls that add a instance to qeueset
        for(auto ingoing : ingoing_edges){
            
            if(ingoing->get_abb_reference()->get_syscall_type() == add){
                
                auto call = ingoing->get_specific_call();
                
                
                //get element to set to queueset via the handlername from syscall
                if(call.arguments.front().multiple ==false){
                    
                    if(call.arguments.front().any_list.front().type().hash_code() == typeid(std::string).hash_code()){
                        
                        std::string handler_name = std::any_cast<std::string>(call.arguments.front().any_list.front());
                        std::cerr << handler_name << std::endl;
                        
                        std::hash<std::string> hash_fn;
	
                        graph::shared_vertex queue_set_element = nullptr;
                        
                        queue_set_element =  graph.get_vertex(hash_fn(handler_name +  typeid(OS::Resource).name()));
                        if(queue_set_element== nullptr)queue_set_element = graph.get_vertex(hash_fn(handler_name +  typeid(OS::Queue).name()));
                        if(queue_set_element== nullptr)queue_set_element = graph.get_vertex(hash_fn(handler_name +  typeid(OS::Semaphore).name()));
                        
                        
                        //set element to queueset
                        if(queue_set_element!= nullptr)queueset->set_queue_element(queue_set_element);
                        else std::cerr << "element " << handler_name << " could not added to queue set" << std::endl;
                    }    
                }else{
                    //ERROR 
                }
            }
        }
    }
}

    
/**
* @brief check if all mutexes were given after taken from same instance
* @param graph project data structure
*/
void verify_mutexes(graph::Graph& graph){
    
     //get all isrs, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Resource).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto resource = std::dynamic_pointer_cast<OS::Resource> (vertex);
        
        
        std::cerr << "resource:" <<  resource->get_name() << std::endl;
        
        bool create_call = false;
        auto ingoing_edges = resource->get_ingoing_edges();
        std::vector<graph::shared_edge> mutex_takes;
        std::vector<graph::shared_edge> mutex_gives;
        for(auto ingoing : ingoing_edges){
            
            if(ingoing->get_abb_reference()->get_syscall_type() == create)create_call = true;
            if(ingoing->get_abb_reference()->get_syscall_type() == commit)mutex_gives.emplace_back(ingoing);
            std::cerr  << "in " <<  ingoing->get_name() << std::endl;
        }
        
        auto outgoing_edges = resource->get_outgoing_edges();
        for(auto outgoing : outgoing_edges){
            if(outgoing->get_abb_reference()->get_syscall_type() == take)mutex_takes.emplace_back(outgoing);
            std::cerr <<  "out " << outgoing->get_name() << std::endl;
        }
        
        
        if(!create_call)std::cerr << "resource was not created" << std::endl;
        else{
            
            if(resource->get_resource_type() == binary_mutex  || resource->get_resource_type() == recursive_mutex){
                std::list<std::size_t> parallel_takes;
                
                for(auto outgoing : outgoing_edges){
                    for(auto tmp_outgoing : outgoing_edges){
                        if(outgoing->get_seed() == tmp_outgoing->get_seed())continue;
                        if(list_contains_element(&parallel_takes , tmp_outgoing->get_seed())&&list_contains_element(&parallel_takes ,outgoing->get_seed()))continue;
                        if(!is_reachable(outgoing->get_abb_reference(),tmp_outgoing->get_abb_reference()) && !is_reachable(tmp_outgoing->get_abb_reference(),outgoing->get_abb_reference())){
                            parallel_takes.emplace_back(outgoing->get_seed());
                            parallel_takes.emplace_back(tmp_outgoing->get_seed());
                        }
                    }
                }
                
                for(auto take : mutex_takes){
                    bool mutex_flag = false;
                    for(auto give :mutex_gives){
                        if(give->get_start_vertex()->get_seed() == take->get_start_vertex()->get_seed()){
                            if(is_reachable (take->get_abb_reference(), give->get_abb_reference()))mutex_flag = true;
                        }
                    }
                    if(!mutex_flag)std::cerr << "resource was not given after taken" << std::endl;
                }
            }
        } 
    }
}

/**
* @brief check if semaphore are given from other instances than the waiting instance
* @param graph project data structure
*/
void verify_semaphores(graph::Graph& graph){
    
     //get all isrs, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Semaphore).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto semaphore = std::dynamic_pointer_cast<OS::Semaphore> (vertex);
        
        
        std::cerr << "semaphore:" <<  semaphore->get_name() << std::endl;
        
        auto ingoing_edges = semaphore->get_ingoing_edges();
        std::vector<graph::shared_edge> mutex_takes;
        std::vector<graph::shared_edge> mutex_gives;
        for(auto ingoing : ingoing_edges){
    
            if(ingoing->get_abb_reference()->get_syscall_type() == commit)mutex_gives.emplace_back(ingoing);
            std::cerr  << "in " <<  ingoing->get_name() << std::endl;
        }
        
        auto outgoing_edges = semaphore->get_outgoing_edges();
        for(auto outgoing : outgoing_edges){
            if(outgoing->get_abb_reference()->get_syscall_type() == take)mutex_takes.emplace_back(outgoing);
            std::cerr <<  "out " << outgoing->get_name() << std::endl;
        }
        
        
        
        if(semaphore->get_semaphore_type() == binary_mutex  || semaphore->get_semaphore_type() == recursive_mutex){
            for(auto take : mutex_takes){
                bool semaphore_flag = false;
                for(auto give :mutex_gives){
                    if(give->get_start_vertex()->get_seed() != take->get_target_vertex()->get_seed()){
                        semaphore_flag = true;
                    }
                }
                if(!semaphore_flag)std::cerr << "semaphore was not given in other instance/better use a mutex" << std::endl;
            }
        }
    }
}

/**
* @brief check if all event bits are set, which are waited for
* @param graph project data structure
*/
void verify_events(graph::Graph& graph){
    
     //get all isrs, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Event).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto event = std::dynamic_pointer_cast<OS::Event> (vertex);
        
        
        std::cerr << "event:" <<  event->get_name() << std::endl;
        
        auto ingoing_edges = event->get_ingoing_edges();
        std::vector<graph::shared_edge> set_calls;
        std::vector<graph::shared_edge> wait_calls;
        
        for(auto ingoing : ingoing_edges){
            auto type = ingoing->get_abb_reference()->get_syscall_type();
          
            if(type == commit || type == synchronize)set_calls.emplace_back(ingoing);
            std::cerr  << "in " <<  ingoing->get_name() << std::endl;
        }
        
        auto outgoing_edges = event->get_outgoing_edges();
        for(auto outgoing : outgoing_edges){
            auto type = outgoing->get_abb_reference()->get_syscall_type();
            if(type == wait || type == synchronize)wait_calls.emplace_back(outgoing);
            std::cerr <<  "out " << outgoing->get_name() << std::endl;
        }
        
        
        
        for(auto wait_call : wait_calls){
            auto wait_instance = wait_call->get_start_vertex()->get_seed();
            auto call = wait_call->get_specific_call();
            bool wait_for_all_bits = true;
            bool clear_on_exit = true;
            long wait_bits = 0;
            long set_bits = 0;
            
            auto type = wait_call->get_abb_reference()->get_syscall_type();
            if(type== synchronize){
                wait_bits = std::any_cast<long>(call.arguments.at(2).any_list.front());
                set_bits =  std::any_cast<long>(call.arguments.at(1).any_list.front());
                std::cerr << "wait bits " << wait_bits << ", set bits " << set_bits << std::endl;
                
            }else if(type == wait){
                
                wait_bits = std::any_cast<long>(call.arguments.at(1).any_list.front());
                clear_on_exit = (bool) std::any_cast<long>(call.arguments.at(2).any_list.front()); 
                wait_for_all_bits = (bool) std::any_cast<long>(call.arguments.at(3).any_list.front()); 
                std::cerr << "wait bits " << wait_bits << ", clear on exit " << clear_on_exit << ", wait_for_all_bits " << wait_for_all_bits << std::endl;
            }
            for(auto set_call : set_calls){
                
                auto set_instance = set_call->get_start_vertex()->get_seed();
                
                if(set_instance == wait_instance){
                    
                    if(is_reachable(wait_call->get_abb_reference(),set_call->get_abb_reference()))continue;
                }
                auto call = set_call->get_specific_call();
                auto type = set_call->get_abb_reference()->get_syscall_type();
                
                if(type== synchronize){
                    set_bits = set_bits | std::any_cast<long>(call.arguments.at(1).any_list.front());
                    std::cerr << "set bits " << set_bits << std::endl;
                
                }else if(type == commit){
                    
                    set_bits = set_bits |  std::any_cast<long>(call.arguments.at(1).any_list.front());
                    std::cerr << "set bits " << set_bits << std::endl;
                }
            }
            if(wait_for_all_bits){
                if(!((set_bits & wait_bits) == wait_bits))std::cerr << "event bits were not certainly set" << std::endl;
            }else{
                if(!((set_bits | wait_bits)))std::cerr << "event bits were not certainly set" << std::endl;
            }
        }
    }
}


/**
* @brief check if application contains a possible cycle
* @param graph project data structure
*/
bool find_cycle(graph::shared_vertex vertex, std::list<size_t>* visited,graph::Graph& graph,int depth,size_t start){
    
    
    //check if the current vertex is the start vertex and if the cycle size big enough (min. 2)
    size_t seed = vertex->get_seed();
    if(list_contains_element(visited,seed)){
        if(start == seed && depth > 2)return true;
        else return false;
    }
    visited->emplace_back(seed);
    std::list<graph::shared_edge> edges;
    
    bool resource_perspective = false;
    
    //check if the current vertex is a resource or a (taks or isr)
    if(vertex->get_type()== typeid(OS::Resource).hash_code()){
        edges = vertex->get_ingoing_edges();
        resource_perspective = true;
    }else{
        edges = vertex->get_outgoing_edges();
    }
    
    //from resource perspective get the instance that takes the resource
    //from task isr perspective get the resource that is taken
    for (auto edge: edges) { 
    
        if(edge->get_abb_reference()->get_syscall_type() != take)continue;
        graph::shared_vertex target_vertex;
        if(resource_perspective){
            target_vertex = edge->get_start_vertex();
        }else{
            target_vertex = edge->get_target_vertex();
            if(target_vertex->get_type()!=typeid(OS::Resource).hash_code())continue;
        }
             
        //recursion
        if (find_cycle(target_vertex,visited ,graph,depth + 1 ,start))return true; 
    } 
    
    visited->remove(seed);
    return false;
}


/**
* @brief check if application contains a possible priority inversion
* @param graph project data structure
*/
void verify_priority_inversion(graph::Graph& graph){
    
    //task which use resource have different priorities
    auto resource_list =  graph.get_type_vertices(typeid(OS::Resource).hash_code());
    
    auto task_list = graph.get_type_vertices(typeid(OS::Task).hash_code());
    
	//iterate about the resources and 
    //check if the resource is accessed by other instances (task,isr) with different priorities bounded piority inversion
    //check if the resource is accessed by other instances (task,isr)  and their is another instance with a lower priority that doesnt access the resource 
	
    for (auto &vertex : resource_list){
        
        unsigned long min_priority = -1;
        unsigned long max_priority = 0;
    
		std::vector<llvm::Instruction*> already_visited;
        std::list<shared_task> resource_task_list;
        auto resource = std::dynamic_pointer_cast<OS::Resource>(vertex);
        bool flag = false;
        
        //get all tasks with takes the resource
        for(auto ingoing_edge : resource->get_ingoing_edges()){
            auto accessed_vertex = ingoing_edge->get_start_vertex();
            if(typeid(OS::Task).hash_code() == accessed_vertex->get_type()){
                auto task = std::dynamic_pointer_cast<OS::Task>(accessed_vertex);
                if(ingoing_edge->get_abb_reference()->get_syscall_type() != take || !task->has_constant_priority() )continue;
                
                //determine the task with max and min priority
                flag =true;
                unsigned long priority = task->get_priority();
                if(priority > max_priority)max_priority = priority;
                if (priority < min_priority)min_priority = priority;
                resource_task_list.emplace_back(task);
            }
        }
        if(flag && max_priority != min_priority){
            std::cerr << "possible bounded piority inversion: tasks of different priorities access resource " << resource->get_name() << std::endl;
        }
        
        //check if there exists another task which doesnt access the resource and have a lower priority than the max priority
        for(auto task_vertex:task_list){
            auto task = std::dynamic_pointer_cast<OS::Task>(task_vertex);
            bool flag = false;
            for(auto resource_task:resource_task_list){
                if(task->get_seed() == resource_task->get_seed())flag = true;
            }
            if(flag == false){
                if(task->get_priority() <max_priority) std::cerr << "possible unbounded piority inversion: tasks of different priorities access resource and another task exists" << resource->get_name() << std::endl;
            }
        }
    }
}

/**
* @brief check if application contians a possible deadlock
* @param graph project data structure
*/
void verify_deadlocks(graph::Graph& graph){
    
    //get all resources, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Resource).hash_code());
    
	//iterate about the resources
	for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<llvm::Instruction*> already_visited;
        auto resource = std::dynamic_pointer_cast<OS::Resource> (vertex);
        std::list<size_t> visited;
        //check if there is cycle in the graph with starts and ends at the resource
        if(find_cycle(resource, &visited,graph,0,resource->get_seed())){
            std::cerr << "possible deadlock detected" << std::endl;
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
void verify_specific_scheduler_access(graph::Graph& graph,graph::shared_vertex vertex, syscall_definition_type start_type , syscall_definition_type end_type){
    
    
    //get all edges from start end end type and store them in lists
    std::list<graph::shared_edge> start_interactions;
    std::list<graph::shared_edge> end_interactions;
    
    for(auto outgoing_edge : vertex->get_outgoing_edges()){
        //check if the interaction addresses the OS
        if(outgoing_edge->get_target_vertex()->get_type() != typeid(OS::RTOS).hash_code())continue;
        //check if the interaction disables functionalities
        if(outgoing_edge->get_abb_reference()->get_syscall_type() == start_type)start_interactions.emplace_back(outgoing_edge);
        else if(outgoing_edge->get_abb_reference()->get_syscall_type() == end_type)end_interactions.emplace_back(outgoing_edge);
    }
    
    //check if all calls from start were certainly from end calls
    if(start_interactions.size() > 0 && end_interactions.size() == 0)std::cerr << vertex->get_name() <<  ": scheduler adaption is not removed in the same instance" << std::endl;
    else{
        
        for(auto start_interaction :start_interactions){
            bool flag = false;
            for(auto end_interaction :end_interactions){
                if(is_reachable(start_interaction->get_abb_reference(), end_interaction->get_abb_reference())) flag = true;
            }
            //detect critical region between start and end
            if(flag)detect_critical_regions(&start_interactions,&end_interactions);
            else std::cerr << vertex->get_name() <<  ": scheduler adaption is not removed in the same instance" << std::endl;
        }
    }
}

/**
* @brief //check if all interactions from type start (e.g disable) with the RTOS were removed certainly from interaction from type end(e.genable)
*and determine critical abb regions (region between start and end)  
* @param graph project data structure
*/
void verify_scheduler_access(graph::Graph& graph){
    
    //get all tasks, which are stored in the graph
    auto vertex_list =  graph.get_type_vertices(typeid(OS::Task).hash_code());
    
    //iterate about the tasks
    for (auto &vertex : vertex_list) {
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
        auto task = std::dynamic_pointer_cast<OS::Task> (vertex);
        
        //check if all interactions from type start (e.g disable) with the RTOS were removed certainly from interaction from type end(e.genable)
        verify_specific_scheduler_access(graph,task, disable, enable);
        verify_specific_scheduler_access(graph,task, suspend, resume);
        verify_specific_scheduler_access(graph,task, enter_critical, exit_critical);
    }
}


//TODO message single write single read
//TODO freertos static instances
//TODO timer id

namespace step {

	std::string DetectInteractionsStep::get_name() {
		return "DetectInteractionsStep";
	}

	std::string DetectInteractionsStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances";
	}
	
    /**
    * @brief the run method of the DetectInteractionsStep pass. This pass detects all interactions of the instances via the RTOS. 
    * @param graph project data structure
    */
	void DetectInteractionsStep::run(graph::Graph& graph) {
		
		std::cout << "Run DetectInteractionsStep" << std::endl;
		//detect interactions of the OS abstraction instances
		
		//graph.print_information();
		detect_interactions(graph);
        add_to_queue_set(graph);
        
        
		verify_mutexes(graph);
        verify_semaphores(graph);
        verify_isrs(graph);

        verify_events(graph);
        verify_deadlocks(graph);
        verify_priority_inversion(graph);
        verify_scheduler_access(graph);
	}
	
	std::vector<std::string> DetectInteractionsStep::get_dependencies() {
        
        // get file arguments from config
		std::vector<std::string> files;
        
		PyObject* elem = PyDict_GetItemString(config, "os");
        
        if(elem != nullptr)std::cerr << "success" << std::endl;
		assert(PyUnicode_Check(elem));
		if(strcmp("freertos", PyUnicode_AsUTF8(elem))==0)return {"FreeRTOSInstancesStep"};
        else if(strcmp("osek", PyUnicode_AsUTF8(elem))==0)return {"OilStep"};
		
		
	}
}
//TODO RAII
