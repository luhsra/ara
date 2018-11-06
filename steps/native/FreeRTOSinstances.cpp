// vim: set noet ts=4 sw=4:




#include "FreeRTOSinstances.h"
#include "llvm/Analysis/LoopInfo.h"
#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <cassert>
#include <stdexcept>

using namespace llvm;


//function to extract the handler name of the instance
std::string get_handler_name(llvm::Instruction * instruction, unsigned int argument_index){
	//llvm::Instruction * next_instruction = instruction->getNextNonDebugInstruction();
	
	std::string handler_name = "";
	//check if call instruction has one user
	if(instruction->hasOneUse()){
		//get the user of the call instruction
		llvm::User* user = instruction->user_back();
		//check if user is store instruction
		if(isa<StoreInst>(user)){
			//get name of specific operand (-> handler name)
			Value * operand = user->getOperand(argument_index);
			
			
			std::cout << operand->getName().str() << std::endl;
			handler_name = operand->getName().str();
		}
	}
	return handler_name;
}

bool verify_arguments(std::vector<size_t> &forced_arguments_types ,std::vector<std::tuple<std::any,llvm::Type*>>& arguments){
	

	//iterate about the demanded arguments
	unsigned int counter = 0;
	bool success = true;
	
	if(forced_arguments_types.size() != arguments.size())success = false;
	for (auto & argument_type: forced_arguments_types){
		std::tuple<std::any,llvm::Type*> tuple = arguments.at(counter);
		auto argument = std::get<std::any>(tuple);
		if(argument_type != argument.type().hash_code()){
			std::cerr << "error: " << argument.type().name() << "counter: " << counter << std::endl;
			success = false;
			break;
		}
		counter++;
	}
	//std::cerr << success << std::endl;
	return success;
}


//xTaskCreate
bool create_task(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments){
	
	bool success = true;
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>tmp_arguments(arguments->size());
	
	int counter = 0;
	for(auto & tuple : *arguments){
		
		tmp_arguments.at(counter) = tuple;
		counter++;
	}
	
	//TODO cast long in unsigned long
	std::vector<size_t> forced_arguments_types(6);
	forced_arguments_types.at(0) = (typeid(std::string).hash_code());
	forced_arguments_types.at(1) = (typeid(std::string).hash_code());
	forced_arguments_types.at(2) = (typeid(long).hash_code());
	forced_arguments_types.at(3) = (typeid(std::string).hash_code());
	forced_arguments_types.at(4) = (typeid(long).hash_code());
	forced_arguments_types.at(5) = (typeid(std::string).hash_code());
	
	//verify the arguments
	if(!verify_arguments(forced_arguments_types,tmp_arguments)){
		success = false;
	}else{

		//load the arguments
		std::tuple<std::any,llvm::Type*> tuple = tmp_arguments.at(0);
		auto argument = std::get<std::any>(tuple);
		std::string function_reference_name =  std::any_cast<std::string>(argument);
		
		tuple = tmp_arguments.at(1);
		argument = std::get<std::any>(tuple);
		std::string task_name =  std::any_cast<std::string>(argument);
		
		tuple = tmp_arguments.at(2);
		argument = std::get<std::any>(tuple);
		unsigned long stacksize =  std::any_cast<long>(argument);
		
		tuple = tmp_arguments.at(3);
		argument = std::get<std::any>(tuple);
		std::string task_argument =  std::any_cast<std::string>(argument);
		
		tuple = tmp_arguments.at(4);
		argument = std::get<std::any>(tuple);
		unsigned long priority =  std::any_cast<long>(argument);
		
		tuple = tmp_arguments.at(5);
		argument = std::get<std::any>(tuple);
		std::string handler_name =  std::any_cast<std::string>(argument);
		

		
		//create task and set properties
		auto task = std::make_shared<OS::Task>(&graph,task_name);
		task->set_definition_function(function_reference_name);
		task->set_handler_name( handler_name);
		task->set_stacksize( stacksize);
		task->set_priority( priority);
		graph.set_vertex(task);
		std::cout << "task successfully created"<< std::endl;
	}
	return success;
}




//..Semaphore...Create
//{ binary, counting, mutex, recursive_mutex }semaphore_type;
bool create_semaphore(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,semaphore_type type ,llvm::Instruction* instruction){
	
	bool success = true;
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>tmp_arguments(arguments->size());
	
	int counter = 0;
	for(auto & tuple : *arguments){
		
		tmp_arguments.at(counter) = tuple;
		counter++;
	}
	
	
	//create counting semaphore and set properties 
	std::string handler_name = get_handler_name(instruction, 1);
	
	
	auto semaphore = std::make_shared<OS::Semaphore>(&graph,handler_name);
	semaphore->set_semaphore_type(type);
	semaphore->set_handler_name(handler_name);
	
	switch(type){
		
		case binary:{
			
			std::vector<size_t> forced_arguments_types(3);
			forced_arguments_types.at(0) = (typeid(long).hash_code());
			forced_arguments_types.at(1) = (typeid(long).hash_code());
			forced_arguments_types.at(2) = (typeid(long).hash_code());
			
			//verify the arguments
			if(!verify_arguments(forced_arguments_types,tmp_arguments)){
				success = false;
			}else{
					std::cout << "binary semaphore successfully created"<< std::endl;
			}
			break;
		}
		
		case counting:{
			
			std::vector<size_t> forced_arguments_types(2);
			forced_arguments_types.at(0) = (typeid(long).hash_code());
			forced_arguments_types.at(1) = (typeid(long).hash_code());

					
			//verify the arguments
			if(!verify_arguments(forced_arguments_types,tmp_arguments)){
				success = false;
			}else{
				
				//load the arguments
				std::tuple<std::any,llvm::Type*> tuple  = tmp_arguments.at(1);
				auto argument = std::get<std::any>(tuple);
				unsigned long initial_count =  std::any_cast<long>(argument);
				
				tuple  = tmp_arguments.at(0);
				argument = std::get<std::any>(tuple);
				unsigned long max_count =  std::any_cast<long>(argument);
			

				semaphore->set_initial_count(initial_count);
				semaphore->set_max_count(max_count);

				std::cout << "counting semaphore successfully created"<< std::endl;
				
			}
			break;
		}
		
		
		case mutex:{
			
			std::vector<size_t> forced_arguments_types(1);
			forced_arguments_types.at(0) = (typeid(long).hash_code());
		
			//verify the arguments
			if(!verify_arguments(forced_arguments_types,tmp_arguments)){
				success = false;
			}else{
				
				//load the arguments
				std::tuple<std::any,llvm::Type*> tuple  = tmp_arguments.at(0);
				auto argument = std::get<std::any>(tuple);
				unsigned long mutex_type =  std::any_cast<long>(argument);
				
				//set the mutex type (mutex, recursive mutex)
				type = (semaphore_type) mutex_type;
				
				semaphore->set_semaphore_type(type);
				if(type == mutex)std::cout << "mutex successfully created"<< std::endl;
				if(type == recursive_mutex)std::cout << "recursive mutex successfully created"<< std::endl;
				
			}			
			
			break;
		
		}
		default:{
				
			break;
		}
	}
	
	if(success)graph.set_vertex(semaphore);
	
	return success;
}

//xQueueCreate
bool create_queue(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,llvm::Instruction* instruction){
	
	bool success = true;
	
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>tmp_arguments(arguments->size());
	
	int counter = 0;
	for(auto & tuple : *arguments){
		
		tmp_arguments.at(counter) = tuple;
		counter++;
	}
	std::vector<size_t> forced_arguments_types(3);
	forced_arguments_types.at(0) = (typeid(long).hash_code());
	forced_arguments_types.at(1) = (typeid(long).hash_code());
	forced_arguments_types.at(2) = (typeid(long).hash_code());
	
	//verify the arguments
	if(!verify_arguments(forced_arguments_types,tmp_arguments)){
		success = false;
	}else{
		
		//load the arguments
		std::tuple<std::any,llvm::Type*> tuple  = tmp_arguments.at(0);
		auto argument = std::get<std::any>(tuple);
		
		long queue_length =  std::any_cast<long>(argument);
		
		tuple  = tmp_arguments.at(1);
		argument = std::get<std::any>(tuple);
		long item_size =  std::any_cast<long>(argument);
	
		tuple  = tmp_arguments.at(2);
		argument = std::get<std::any>(tuple);
		long queue_type =  std::any_cast<long>(argument);
		
		semaphore_type type = (semaphore_type) queue_type;
		
		if(type != binary){
			
			std::string handler_name = get_handler_name(instruction, 1);
			//create queue and set properties
			auto queue = std::make_shared<OS::Queue>(&graph,handler_name);
			
			queue->set_handler_name(handler_name);
			queue->set_length(queue_length);
			queue->set_item_size(item_size);
			graph.set_vertex(queue);
			std::cout << "queue successfully created"<< std::endl;
		}else{
			success = create_semaphore(graph,arguments,binary,instruction);
		}
	}
	return success;
}


//xQueueCreate
bool create_event_group(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,llvm::Instruction* instruction){
	
	bool success = true;
	
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>tmp_arguments(arguments->size());
	
	int counter = 0;
	for(auto & tuple : *arguments){
		
		tmp_arguments.at(counter) = tuple;
		counter++;
	}
	std::vector<size_t> forced_arguments_types(0);

	
	//verify the arguments
	if(!verify_arguments(forced_arguments_types,tmp_arguments)){
		success = false;
	}else{
		
		
		//create queue and set properties 
		std::string handler_name = get_handler_name(instruction, 1);
		auto event_group = std::make_shared<OS::EventGroup>(&graph,handler_name);
			
		event_group->set_handler_name(handler_name);
		graph.set_vertex(event_group);
		std::cout << "event group successfully created"<< std::endl;
		
	}
	return success;
}




//xQueueSet
bool create_queue_set(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,llvm::Instruction* instruction){
	
	bool success = true;
	
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>tmp_arguments(arguments->size());
	
	int counter = 0;
	for(auto & tuple : *arguments){
		
		tmp_arguments.at(counter) = tuple;
		counter++;
	}
	std::vector<size_t> forced_arguments_types(1);
	forced_arguments_types.at(0) = (typeid(long).hash_code());
	
	//verify the arguments
	if(!verify_arguments(forced_arguments_types,tmp_arguments)){
		success = false;
	}else{
		
		//load the arguments
		std::tuple<std::any,llvm::Type*> tuple  = tmp_arguments.at(0);
		auto argument = std::get<std::any>(tuple);
		unsigned long queue_set_size =  std::any_cast<long>(argument);
		
	
		//create queue set and set properties 
		std::string handler_name = get_handler_name(instruction, 1);
		auto queue_set = std::make_shared<OS::QueueSet>(&graph,handler_name);
		
		queue_set->set_handler_name(handler_name);
		queue_set->set_length(queue_set_size);
		
		std::cout << "queue set successfully created"<< std::endl;
		//set timer to graph
		graph.set_vertex(queue_set);
	
	}
	return success;
}

//xTimerCreate
bool create_timer(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments){
	
	bool success = true;
	
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>tmp_arguments(arguments->size());
	
	int counter = 0;
	for(auto & tuple : *arguments){
		
		tmp_arguments.at(counter) = tuple;
		counter++;
	}
	std::vector<size_t> forced_arguments_types(5);
	forced_arguments_types.at(0) = (typeid(std::string).hash_code());
	forced_arguments_types.at(1) = (typeid(long).hash_code());
	forced_arguments_types.at(2) = (typeid(long).hash_code());
	forced_arguments_types.at(3) = (typeid(std::string).hash_code());
	forced_arguments_types.at(4) = (typeid(std::string).hash_code());
			
	//verify the arguments
	if(!verify_arguments(forced_arguments_types,tmp_arguments)){
		success = false;
	}else{
		
		//load the arguments
		std::tuple<std::any,llvm::Type*> tuple  = tmp_arguments.at(0);
		auto argument = std::get<std::any>(tuple);
		std::string timer_name =  std::any_cast<std::string>(argument);
		
		tuple  = tmp_arguments.at(1);
		argument = std::get<std::any>(tuple);
		long timer_periode =  std::any_cast<long>(argument);
	
		tuple  = tmp_arguments.at(2);
		argument = std::get<std::any>(tuple);
		long timer_autoreload =  std::any_cast<long>(argument);
		
		tuple  = tmp_arguments.at(3);
		argument = std::get<std::any>(tuple);
		std::string timer_id =  std::any_cast<std::string>(argument);
		
		tuple  = tmp_arguments.at(4);
		argument = std::get<std::any>(tuple);
		std::string timer_definition_function =  std::any_cast<std::string>(argument);
		
		//create timer and set properties 
		auto timer = std::make_shared<OS::Timer>(&graph,timer_name);
		
		timer->set_periode(timer_periode);
		//TODO extract timer id
		//std::cout << timer_id << std::endl;
		//timer->set_timer_id(timer_id);
		timer->set_definition_function(timer_definition_function);
		if(timer_autoreload == 0) timer->set_timer_type(oneshot);
		else timer->set_timer_type(autoreload);
		std::cout << "timer successfully created"<< std::endl;
		//set timer to graph
		graph.set_vertex(timer);
	
	}
	return success;
}



bool validate_loop(llvm::BasicBlock *bb){
	
	bool success = true;
	//std::cerr << "TEST" << std::endl;
	llvm::DominatorTree DT = llvm::DominatorTree();
	DT.recalculate(*bb->getParent());
	llvm::LoopInfoBase<llvm::BasicBlock, llvm::Loop>* LoopInfo = new llvm::LoopInfoBase<llvm::BasicBlock, llvm::Loop>();
	LoopInfo->releaseMemory();
	LoopInfo->analyze(DT);
	
	if(LoopInfo->getLoopFor(bb)!= nullptr){
		success = false;
		std::cout << "loop depth: " << LoopInfo->getLoopDepth(bb) << std::endl;
		
	}
	return success;
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
			
			//vertex->print_information();
			//cast vertex to abb 
			auto abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
			
			//get the list of referenced llvm bb
			std::list<llvm::BasicBlock*> llvm_abbs = abb->get_BasicBlocks();
			
			if(llvm_abbs.size() == 1) // always test  
			{
				
				//check if abb has a syscall instruction
				if( abb->get_call_type()!= no_call){
					//TODO validate the loopinformation
					//if(true||validate_loop(llvm_abbs.front()))
					{

					//std::cout << vertex->get_type() << "\n";
					//check if abb syscall is creation syscall
					//if(abb->get_syscall_type() == create)
						std::string callname = abb->get_call_name();
						//if(target_instance == typeid(OS::Task).hash_code())
					
						//std::cout << callname << std::endl;
						if(callname  == "xTaskCreate"){
							if(!create_task(graph,abb->get_arguments()))std::cout << "Task could not created" << std::endl;
						}
							
						if(callname  == "xQueueGenericCreate"){
							if(!create_queue( graph,abb->get_arguments(),abb->get_call_instruction_reference()))std::cout << "Queue could not created" << std::endl;

						}
						if(callname  == "xQueueCreateCountingSemaphore"){
							if(!create_semaphore(graph, abb->get_arguments(), counting,abb->get_call_instruction_reference()))std::cout << "CountingSemaphore could not created" << std::endl;
							
						}
						if(callname  == "xQueueCreateMutex"){
							if(!create_semaphore(graph, abb->get_arguments(), mutex,abb->get_call_instruction_reference()))std::cout << "Mutex could not created" << std::endl;;

						}

						if(callname  == "xTimerCreate"){
							if(!create_timer( graph,abb->get_arguments()))std::cout << "Timer could not created" << std::endl;
						}

						if(callname  == "xEventGroupCreate"){
							//std::cout << callname << std::endl;
							if(!create_event_group(graph, abb->get_arguments(),abb->get_call_instruction_reference()))std::cout << "Event Group could not created" << std::endl;
						}
						
						if(callname  == "xStreamBufferCreate"){
							//std::cout << callname << std::endl;
						}
						if(callname  == "xQueueCreateSet"){
							//std::cout << callname << std::endl;
							if(!create_queue_set(graph, abb->get_arguments(),abb->get_call_instruction_reference()))std::cout << "Queue Set could not created" << std::endl;
						}
					}
					//else{
						/*
						std::cout << "element is in loop" << std::endl;
						std::string type_str;
						llvm::raw_string_ostream rso(type_str);
						llvm_abbs.front()->print(rso);
						std::cout<< rso.str() ;
						*/
					//}
					
				}
			}
		}
		
		
	}
	
	
	std::vector<std::string> FreeRTOSInstancesStep::get_dependencies() {
		return {"SyscallStep"};
	}
}
