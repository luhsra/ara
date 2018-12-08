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
#include "llvm/ADT/APFloat.h"
using namespace llvm;

	
//print the argument
void debug_argument_test(std::any value,llvm::Type *type){
	
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





void iterate_called_functions(graph::Graph& graph, graph::shared_vertex start_vertex, OS::shared_function function, std::vector<size_t>* already_visited){
    
    //return if function does not contain a syscall
    if(function == nullptr || function->has_syscall() ==false)return;
    std::hash<std::string> hash_fn;
    
    std::cerr << "Function: " << function->get_name() << std::endl;
    
    
	size_t seed = function->get_seed();

	//search hash value in list of already visited basic blocks
	for(auto tmp_seed : *already_visited){
		if(tmp_seed == seed){
			//basic block already visited
			return;
		}
	}
    already_visited->emplace_back(seed);
    
    
	
    //get the abbs of the function
    std::list<OS::shared_abb> abb_list = function->get_atomic_basic_blocks();
    
    //iterate about the abbs
    for(auto &abb : abb_list){


        //check if abb contains a syscall and it is not a creational syscall
        if(abb->get_call_type() == sys_call  && abb->get_syscall_type() != create ){
            
            //std::cout << abb->get_name() << std::endl;
            //for(auto& name: abb->get_call_names()){
                //std::cout << name << std::endl;
            //}
            
            bool success = false;
            std::list<std::tuple<std::any,llvm::Type*>>* argument_list = abb->get_syscall_arguments();
            std::list<std::size_t>*  target_list = abb->get_call_target_instances();
        
            //load the handler name
            std::string handler_name = "";
            if(argument_list->size() >0 &&  std::get<std::any>(argument_list->front()).type().hash_code()== typeid(std::string).hash_code()){
                std::tuple<std::any,llvm::Type*> tuple  = (argument_list->front());
                auto argument = std::get<std::any>(tuple);
                handler_name = std::any_cast<std::string>(argument);
                std::cerr<< "edge handler name " << handler_name << std::endl;
                
                
            }
            
            for(auto & tuple:*(abb->get_syscall_arguments())){
                debug_argument_test(std::get<std::any>(tuple),std::get<llvm::Type *>(tuple));
            }
            
            
            //iterate about the possible refereneced(syscall targets) abstraction types
            for(auto& target: *target_list){
                
                
                //the RTOS has the handler name RTOS
                if(target == typeid(OS::RTOS).hash_code())handler_name = "RTOS";
                
                //std::cerr << target << std::endl;
                //get the vertices of the specific type from the graph
                std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(target);
                
                
                //iterate about the vertices
                for (auto &target_vertex : vertex_list) {
                    
                    //std::cerr << "TEST"<< std::endl;
                    //std::cerr<< "handler name " << vertex->get_handler_name() << std::endl;
                    //compare the referenced handler name with the handler name of the vertex
                    if(target_vertex->get_handler_name() == handler_name){
                        
                        //std::cout << handler_name << std::endl;
                        //get the vertex abstraction of the function, where the syscall is called
                        //graph::shared_vertex start_vertex = function;
                        //if(function->get_definition_vertex() != nullptr)start_vertex = function->get_definition_vertex();
                        
                        if(start_vertex != nullptr && target_vertex !=nullptr){
                            //check if the syscall expect values from target or commits values to target
                            if(abb->get_syscall_type() == receive){
                                
                                
                                //create the edge, which contains the start and target vertex and the arguments
                                auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(),start_vertex,target_vertex ,abb);
                                
                                //store the edge in the graph
                                graph.set_edge(edge);
                                
                                target_vertex->set_outgoing_edge(edge);
                                start_vertex->set_ingoing_edge(edge);
                                
                                std::cerr << "start vertex: " << start_vertex->get_name() << " target vertex: " << target_vertex->get_name() << std::endl;
                                //set the success flag
                                success = true;
                            
                            }else{	//syscall set values
                                
                                //create the edge, which contains the start and target vertex and the arguments
                                auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(), start_vertex,target_vertex,abb);
    
                                //store the edge in the graph
                                graph.set_edge(edge);
                                
                                start_vertex->set_outgoing_edge(edge);
                                target_vertex->set_ingoing_edge(edge);
                                //set the success flag
                                success = true;
                                 std::cerr << "start vertex: " << start_vertex->get_name() << " target vertex: " << target_vertex->get_name() << std::endl;
                            }
                        }
                        break;
                    }
                }
                //check if target vertex with corresponding handler name was detected
                if(success){
                    //std::cout << "edge created " << abb->get_syscall_name() << std::endl;
                    //break the loop iteration about the possible syscall target instances
                    break;
                }
            }
            if(success == false){
                std::cout << "edge could not created: " << abb->get_syscall_name() <<  " in function " <<  abb->get_parent_function()->get_name()  << " in vertex " << start_vertex->get_name() <<  std::endl;
                std::cerr << "expected handler name " << handler_name	<< std::endl;
            }
        }
        //analyze the called functions of the function
        for(auto called_function : abb->get_called_functions()){
            iterate_called_functions(graph,start_vertex,called_function, already_visited);
        }
    }
}




//detect interactions of OS abstractions and create the corresponding edges in the graph
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
        std::vector<size_t> already_visited;
        iterate_called_functions(graph, main_function, main_function, &already_visited);
    }
    
    
	//get all tasks, which are stored in the graph
	std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Task).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        std::cerr << "task name: " << vertex->get_name() << std::endl;
		std::vector<size_t> already_visited;
        auto task = std::dynamic_pointer_cast<OS::Task> (vertex);
        OS::shared_function task_definition = task->get_definition_function();
        //get all interactions of the instance
        iterate_called_functions(graph, vertex, task_definition, &already_visited);
    }
    
    //get all isrs, which are stored in the graph
    vertex_list =  graph.get_type_vertices(typeid(OS::ISR).hash_code());
	//iterate about the isrs
	for (auto &vertex : vertex_list) {
        std::cerr << "isr name: " << vertex->get_name() << std::endl;
		std::vector<size_t> already_visited;
        auto timer = std::dynamic_pointer_cast<OS::ISR> (vertex);
        OS::shared_function timer_definition = timer->get_definition_function();
        //get all interactions of the instance
        iterate_called_functions(graph, vertex, timer_definition, &already_visited);
    }
        
    //get all timers of the graph
    vertex_list =  graph.get_type_vertices(typeid(OS::Timer).hash_code());
	//iterate about the timers
	for (auto &vertex : vertex_list) {
        std::cerr << "timer name: " << vertex->get_name() << std::endl;
		std::vector<size_t> already_visited;
        auto isr = std::dynamic_pointer_cast<OS::Timer> (vertex);
        OS::shared_function isr_definition = isr->get_definition_function();
        //get all interactions of the instance
        iterate_called_functions(graph, vertex, isr_definition, &already_visited);
    }
        
}




namespace step {

	std::string DetectInteractionsStep::get_name() {
		return "DetectInteractionsStep";
	}

	std::string DetectInteractionsStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances";
	}

	void DetectInteractionsStep::run(graph::Graph& graph) {
		
		std::cout << "Run DetectInteractionsStep" << std::endl;
		//detect interactions of the OS abstraction instances
		
		//graph.print_information();
		detect_interactions(graph);
		
	}
	
	std::vector<std::string> DetectInteractionsStep::get_dependencies() {
		return {"FreeRTOSInstancesStep"};
	}
}
