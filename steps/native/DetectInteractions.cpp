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

	

//detect interactions of OS abstractions and create the corresponding edges in the graph
bool detect_interaction(graph::Graph& graph){
	
	//get all functions, which are stored in the graph
	std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
	//iterate about the functions
	for (auto &vertex : vertex_list) {
		
		//cast the vertex in function type
		auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
		
		//get the abbs of the function
		std::list<OS::shared_abb> abb_list = function->get_atomic_basic_blocks();
		
		//iterate about the abbs
		for(auto &abb : abb_list){
			
			//check if abb contains a syscall
			if(abb->get_call_type() == sys_call  && abb->get_syscall_type() != create ){
				
				
				bool success = false;
				
				std::list<std::tuple<std::any,llvm::Type*>>* argument_list = abb->get_syscall_arguments();
				std::list<std::size_t>*  target_list = abb->get_call_target_instances();
				//load the handler name
				std::string handler_name = "";
				if(argument_list->size() >0 &&  std::get<std::any>(argument_list->front()).type().hash_code()== typeid(std::string).hash_code()){
					std::tuple<std::any,llvm::Type*> tuple  = (argument_list->front());
					auto argument = std::get<std::any>(tuple);
					handler_name = std::any_cast<std::string>(argument);
				}
				
				//iterate about the possible refereneced abstraction types
				for(auto& target: *target_list){
					
					if(target == typeid(OS::RTOS).hash_code())handler_name = "RTOS";
					//get the vertices of the specific type from the graph
					std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(target);
					
					//iterate about the vertices
					for (auto &vertex : vertex_list) {
					
						//compare the referenced handler name with the handler name of the vertex
						if(vertex->get_handler_name() == handler_name){
							
							//std::cout << handler_name << std::endl;
							//get the vertex abstraction of the function, where the syscall is called
							graph::shared_vertex start_vertex = function;
							if(function->get_definition_vertex() != nullptr)start_vertex = function->get_definition_vertex();
							
							//check if the syscall expect values
							if(abb->get_syscall_type() == receive){
								
								//TODO verifc that abb reference of the edge is a real abb
								//create the edge, which contains the start and target vertex and the arguments
								auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(),start_vertex ,vertex,abb);
								//TODO set arguments ?
								//store the edge in the graph
								graph.set_edge(edge);
								//set the success flag
								success = true;
							
							}else{	//syscall set values
								//TODO verifc that abb reference of the edge is a real abb
								//create the edge, which contains the start and target vertex and the arguments
								auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(),vertex ,start_vertex,abb);
								//TODO set arguments ?
								//store the edge in the graph
								graph.set_edge(edge);
								//set the success flag
								success = true;
							}
							break;
						}
					}
					//check if target vertex with corresponding handler name was detected
					if(success){
						std::cout << "edge created " << abb->get_syscall_name() << std::endl;
						//break the loop iteration about the possible syscall target instances
						break;
					}
				}
				if(success == false){
					std::cout << "edge could not created: " << abb->get_syscall_name() << std::endl;
					for(auto & arguments:* abb->get_arguments()){
						for(auto &tuple : arguments){
							//test_debug_argument(std::get<std::any>(tuple),std::get<llvm::Type *>(tuple));
						}
					}
				}
			}
		}
	}
}



namespace step {

	std::string DetectInteractionsStep::get_name() {
		return "DetectInteractionStep";
	}

	std::string DetectInteractionsStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances";
	}

	void DetectInteractionsStep::run(graph::Graph& graph) {
		
	
		detect_interaction(graph);
		
		
		
	}
	
	std::vector<std::string> DetectInteractionsStep::get_dependencies() {
		return {"FreeRTOSInstances_Step"};
	}
}
