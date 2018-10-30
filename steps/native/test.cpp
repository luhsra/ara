// vim: set noet ts=4 sw=4:

#include "test.h"

#include <string>
#include <iostream>

namespace step {

	std::string Test0Step::get_name() {
		return "Test0Step";
	}

	std::string Test0Step::get_description() {
		return "Step for testing purposes";
	}

	void Test0Step::run(graph::Graph& graph) {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
		
		//iterate about the ABBS
		std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::ABB()).hash_code());
		for (auto &vertex : vertex_list) {
	
			//cast vertex to abb 
			std::shared_ptr<OS::ABB> abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
			
			if(abb) // always test  
			{
				//check if abb has a syscall instruction
				if( abb->get_call_type()== sys_call){ 
					//check if abb syscall is creation syscall
					if(abb->get_syscall_type() == create){
						
						const size_t target_instance = abb->get_call_target_instance();
						if(target_instance == typeid(OS::Task()).hash_code())
						{
							std::cout << "Task" << std::endl;
						}else if(target_instance == typeid(OS::Semaphore()).hash_code()){
							std::cout << "Semaphore" << std::endl;
						
							
						}else if(target_instance == typeid(OS::Event()).hash_code()){
							std::cout << "Event" << std::endl;
						
							
						}
					}
				}
			}
		}
	}

	std::vector<std::string> Test0Step::get_dependencies() {
		return {};
	}

	std::string Test2Step::get_name() {
		return "Test2Step";
	}

	std::string Test2Step::get_description() {
		return "Step for testing purposes";
	}

	void Test2Step::run(graph::Graph& graph) {
		std::cout << "Run " << get_name() << std::endl;
		std::cout << "Graph address: " << &graph << std::endl;
	}

	std::vector<std::string> Test2Step::get_dependencies() {
		return {"Test1Step"};
	}
}
