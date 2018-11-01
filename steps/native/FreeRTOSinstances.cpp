// vim: set noet ts=4 sw=4:



//TODO extract missing arguments


#include "FreeRTOSinstances.h"

#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <cassert>
#include <stdexcept>

using namespace llvm;

bool initialize_task(OS::shared_task& task,std::list<std::tuple<std::any,llvm::Type*>>* arguments){
	
	for (auto & tuple: *arguments){
		auto llvm_type = std::get<llvm::Type*>(tuple);
		auto argument = std::get<std::any>(tuple);
		Type* ptrType = llvm_type->getPointerElementType();
		
		if (PointerType* pt = dyn_cast<PointerType>(ptrType)){
			
				if (pt->getContainedType(0)->isFunctionTy()){
					
					std::string function_name = std::any_cast<std::string>(argument);
					
					task->set_definition_function(function_name);
					break;
				}

				// This may be a pointer to a pointer to ...
		}
	}
}




namespace step {

	std::string FreeRTOSInstancesStep::get_name() {
		return "FreeRTOSInstancesStep";
	}

	std::string FreeRTOSInstancesStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances";
	}

	void FreeRTOSInstancesStep::run(graph::Graph& graph) {
		
		//std::cerr << graph.print_information();
		
		std::cout << "Run " << get_name() << std::endl;
		
		
		
		//iterate about the ABBS
		std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::ABB).hash_code());
		
		
		for (auto &vertex : vertex_list) {
			
			vertex->print_information();
			//cast vertex to abb 
			auto abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
			
			if(abb) // always test  
			{
				
				//check if abb has a syscall instruction
				if( abb->get_call_type()!= no_call){
					std::cout << vertex->get_type() << "\n";
					//check if abb syscall is creation syscall
					if(abb->get_syscall_type() == create){
						
						const size_t target_instance = abb->get_call_target_instance();
						if(target_instance == typeid(OS::Task).hash_code())
						{
							std::cout << "Task" << std::endl;
						}else if(target_instance == typeid(OS::Semaphore).hash_code()){
							std::cout << "Semaphore" << std::endl;
						
							
						}else if(target_instance == typeid(OS::Event).hash_code()){
							std::cout << "Event" << std::endl;
						
							
						}
					}
				}
			}
		}
		
		
	}
	
	
	std::vector<std::string> FreeRTOSInstancesStep::get_dependencies() {
		return {"SyscallStep"};
	}
}
