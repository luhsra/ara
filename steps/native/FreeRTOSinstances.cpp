// vim: set noet ts=4 sw=4:



#include "llvm/Analysis/AssumptionCache.h"
#include "FreeRTOSinstances.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Pass.h"
#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <cassert>
#include <stdexcept>
#include <functional>

using namespace llvm;



bool list_contains_element(std::list<std::size_t>* list, size_t target){
	
	for(auto element : *list){
		if(element == target)return true;
	}
	return false;
}

//check if instruction a is before instruction b 
 bool check_instruction_order( Instruction *InstA,  Instruction *InstB,DominatorTree *DT) {
	DenseMap< BasicBlock *, std::unique_ptr<OrderedBasicBlock>> OBBMap;
	if (InstA->getParent() == InstB->getParent()){
		BasicBlock *IBB = InstA->getParent();
		auto OBB = OBBMap.find(IBB);
		if (OBB == OBBMap.end())OBB = OBBMap.insert({IBB, make_unique<OrderedBasicBlock>(IBB)}).first;
		return OBB->second->dominates(InstA, InstB);
	}
	DomTreeNode *DA = DT->getNode(InstA->getParent());
	DomTreeNode *DB = DT->getNode(InstB->getParent());
	return DA->getDFSNumIn() < DB->getDFSNumIn();
 }



llvm::Instruction* get_start_scheduler_instruction(OS::shared_function function){
	for(auto & abb : function->get_atomic_basic_blocks()){
		if(abb->get_call_type() != no_call){
			std::cout << abb->get_call_name() << std::endl; 
			if(abb->get_call_name() == "vTaskStartScheduler")return abb->get_call_instruction_reference();
		}
	}
	return nullptr;
}


void append_instructions(llvm::Function* function,std::vector<std::size_t>* already_visited,std::list<size_t> *instruction_list){
	
	std::hash<std::string> hash_fn;
	size_t hash_value = hash_fn(function->getName().str());
	
	//search hash value in list of already visited basic blocks
	for(auto hash : *already_visited){
		
		if(hash_value == hash){
			//function already visited
			return;
		}
	}
	already_visited->emplace_back(hash_value);
	for(llvm::BasicBlock &bb :*function){
		std::cout << "insert hash in " << function->getName().str() << " " << bb.getName().str() << " : " << hash_fn(bb.getName().str()) << std::endl;
		for(llvm::Instruction &instruction :bb){
			
			instruction_list->emplace_back(hash_fn(bb.getName().str()));
			if(isa<llvm::CallInst>(instruction)){
				llvm::CallInst& call_instruction = cast<CallInst>(instruction);
				llvm::Function* called_function = call_instruction.getCalledFunction();
				if(called_function != nullptr){
					append_instructions(function,already_visited,instruction_list);
				}
			}else if(isa<llvm::InvokeInst>(instruction)){
				llvm::InvokeInst& call_instruction = cast<InvokeInst>(instruction);
				llvm::Function* called_function = call_instruction.getCalledFunction();
				if(called_function != nullptr){
					append_instructions(function,already_visited,instruction_list);
				}
			}
		}
	}
}



void before_scheduler_instructions(graph::Graph& graph,std::list<size_t> *instruction_list){
	
	std::hash<std::string> hash_fn;
	
	
	std::vector<std::size_t> already_visited;
	std::cout << "get instruction before  scheduler start"  << std::endl;
	std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
	for (auto &vertex : vertex_list) {
		auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
		
		if(function->get_name()=="main"){

			std::cout << "function name: " << function->get_name() << std::endl;
		
			llvm::Instruction* start_scheduler = get_start_scheduler_instruction(function);
			if(start_scheduler == nullptr)std::cout << "scheduler instruction could not find in main function" << std::endl; 
			{
				std::string type_str;
				llvm::raw_string_ostream rso(type_str);
				start_scheduler->print(rso);
				std::cout<< "scheduler instruction" <<  rso.str() << std::endl;
			}
			DominatorTree dominator_tree = DominatorTree();
			dominator_tree.recalculate(*(function->get_llvm_reference()));
			dominator_tree.updateDFSNumbers();
			for(auto &abb : function->get_atomic_basic_blocks()){
					
				for(llvm::BasicBlock* bb : abb->get_BasicBlocks()){
					
					for(auto &instruction:*bb){
						if(check_instruction_order(&instruction,start_scheduler,&dominator_tree)&& !dominator_tree.dominates(start_scheduler,&instruction)){
							{/*
								std::string type_str;
								llvm::raw_string_ostream rso(type_str);
								bb->print(rso);
								std::cout<< "before scheduler instruction" <<  rso.str() << std::endl;*/
							}
							if(abb->get_call_type()== sys_call){
								instruction_list->emplace_back(hash_fn(bb->getName().str()));
								std::cout << "insert hash in main " << bb->getName().str() << " : " << hash_fn(bb->getName().str()) << std::endl;
							}else if(abb->get_call_type()== func_call){
								if(llvm::CallInst* call_instruction = dyn_cast<CallInst>(abb->get_call_instruction_reference())){
									llvm::Function* called_function = call_instruction->getCalledFunction();
									if(called_function != nullptr){
										append_instructions(called_function,&already_visited,instruction_list);
									}
								}else if(llvm::InvokeInst* call_instruction = dyn_cast<InvokeInst>(abb->get_call_instruction_reference())){
									llvm::Function* called_function = call_instruction->getCalledFunction();
									if(called_function != nullptr){
										append_instructions(called_function,&already_visited,instruction_list);
									}
								}
							}
						}else{
							{/*
								std::string type_str;
								llvm::raw_string_ostream rso(type_str);
								bb->print(rso);
								std::cout<< "after scheduler instruction" <<  rso.str() << std::endl;
								*/
							}
							
						}
					}
				}
			}
			break;

		}
	}
	std::cout << "end instruction before start scheduler start" << std::endl;
}


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
	
	if(forced_arguments_types.size() != arguments.size()){
		success = false;
		std::cout << "exptected argument size " << forced_arguments_types.size()  << " and real argument size " << arguments.size()  << "  are not equal" << std::endl;
	}else{
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
	}
	//std::cerr << success << std::endl;
	return success;
}

bool verify_syscall_arguments(std::vector<size_t> &forced_arguments_types ,std::vector<size_t>& arguments){
	

	//iterate about the demanded arguments
	unsigned int counter = 0;
	bool success = true;
	
	if(forced_arguments_types.size() != arguments.size())success = false;
	for (auto & forced_argument_type: forced_arguments_types){
		std::size_t argument_type = arguments.at(counter);
		
		if(argument_type != forced_argument_type){
			std::cerr << "error: " << argument_type << "counter: " << counter << std::endl;
			success = false;
			break;
		}
		counter++;
	}
	//std::cerr << success << std::endl;
	return success;
}




bool validate_loop(llvm::BasicBlock *bb, std::string call_name,std::vector<std::size_t>* already_visited){
	//generate hash code of basic block name
	std::hash<std::string> hash_fn;
	size_t hash_value = hash_fn(bb->getName().str());
	
	//search hash value in list of already visited basic blocks
	for(auto hash : *already_visited){
		
		if(hash_value == hash){
			//basic block already visited
			return true;
			break;
		}
	}
	//set basic block hash value in already visited list
	already_visited->push_back(hash_value);
	
	bool success = true;
	//search loop of function
	llvm::DominatorTree DT = llvm::DominatorTree();
	DT.recalculate(*bb->getParent());
	DT.updateDFSNumbers();
	/*{
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		DT.print(rso);
		std::cout<< "loop: " <<  rso.str() << std::endl;
	
	}*/
	llvm::LoopInfoBase<llvm::BasicBlock, llvm::Loop>* LIB = new llvm::LoopInfoBase<llvm::BasicBlock, llvm::Loop>();
	LIB->releaseMemory();
	LIB->analyze(DT);
	llvm::Loop * L = LIB->getLoopFor(bb);
	AssumptionCache AC = AssumptionCache(*bb->getParent());
	TargetLibraryInfoWrapperPass TLI = TargetLibraryInfoWrapperPass(Triple (Twine(llvm::sys::getDefaultTargetTriple())));
	
	//TODO getExitBlock - If getExitBlocks would return exactly one block, return that block.
	
	LoopInfo LI = LoopInfo(DT);
	ScalarEvolution SE = ScalarEvolution(*bb->getParent(), TLI.getTLI(),AC, DT, LI);
	
	{/*
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		SE.print(rso);
		std::cout<< "loop: " <<  rso.str() << std::endl;
	*/
	}
	//check if basic block is in loop
	//TODO get loop count
	if(L != nullptr){
		//std::cout << "element is in loop" << std::endl;
		//std::cout << "loop count:" << SE.getSmallConstantMaxTripCount(L);
		//std::cout << "loop count:" << SE.getSmallConstantTripCount(L);
	
		//std::cout << "warning" << std::endl;
		//std::cout << "loop depth: " << LIB->getLoopDepth(bb) << std::endl;
		//std::cout << "loop depth: " << LI.getLoopDepth(bb) << std::endl;
		//std::cout << "call name: " << call_name << std::endl;
		success = false;
	}else{
		//check if function of basic block is called in a loop of other function
		for(auto user : bb->getParent()->users()){  // U is of type User*
			
			if(CallInst* instruction = dyn_cast<CallInst>(user)){
				//analyse basic block of call instruction 
				success = validate_loop(instruction->getParent(), "recursive step" ,already_visited);
				if(success == false)break;
			}
		}

	}
	//free dynamic memory
	delete LIB;
	return success;
}

//xTaskCreate
bool create_task(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments, bool before_scheduler_start){
	
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
		task->set_start_scheduler_creation_flag(before_scheduler_start);
		graph.set_vertex(task);
		
		std::hash<std::string> hash_fn;
		
		graph::shared_vertex vertex = nullptr;
		vertex =  graph.get_vertex(hash_fn(function_reference_name +  typeid(OS::Function).name()));

		
		auto function_reference = std::dynamic_pointer_cast<OS::Function> (vertex);

		function_reference->set_definition_vertex(task);
		
		std::cout << "task successfully created"<< std::endl;
	}
	return success;
}




//..Semaphore...Create
//{ binary, counting, mutex, recursive_mutex }semaphore_type;
bool create_semaphore(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,semaphore_type type ,llvm::Instruction* instruction, bool before_scheduler_start){
	
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

	std::cout << "semaphore handler name: " <<  handler_name << std::endl;
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
			
			std::cout << "create mutex" << std::endl;
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
	semaphore->set_start_scheduler_creation_flag(before_scheduler_start);
	if(success)graph.set_vertex(semaphore);
	
	return success;
}

//xQueueCreate
bool create_queue(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,llvm::Instruction* instruction, bool before_scheduler_start){
	
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
			queue->set_start_scheduler_creation_flag(before_scheduler_start);
			graph.set_vertex(queue);
			
			std::cout << "queue successfully created"<< std::endl;
		}else{
			success = create_semaphore(graph,arguments,binary,instruction, before_scheduler_start);
		}
	}
	return success;
}


//xQueueCreate
bool create_event_group(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,llvm::Instruction* instruction, bool before_scheduler_start){
	
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
		event_group->set_start_scheduler_creation_flag(before_scheduler_start);
		graph.set_vertex(event_group);
		std::cout << "event group successfully created"<< std::endl;
		
	}
	return success;
}




//xQueueSet
bool create_queue_set(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,llvm::Instruction* instruction, bool before_scheduler_start){
	
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
		queue_set->set_start_scheduler_creation_flag(before_scheduler_start);
		graph.set_vertex(queue_set);
	
	}
	return success;
}

//xTimerCreate
bool create_timer(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments, bool before_scheduler_start){
	
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
		timer->set_start_scheduler_creation_flag(before_scheduler_start);
		graph.set_vertex(timer);
	
	}
	return success;
}


//xTimerCreate
bool create_buffer(graph::Graph& graph,std::list<std::tuple<std::any,llvm::Type*>>* arguments,llvm::Instruction* instruction, bool before_scheduler_start){
	
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
		std::tuple<std::any,llvm::Type*> tuple  = tmp_arguments.at(2);
		auto argument = std::get<std::any>(tuple);
		buffer_type type = (buffer_type) std::any_cast<long>(argument);
		
		std::cout << "buffer type: "<< std::any_cast<long>(argument)<< std::endl;
		
		tuple  = tmp_arguments.at(1);
		argument = std::get<std::any>(tuple);
		long trigger_level =  std::any_cast<long>(argument);
	
		tuple  = tmp_arguments.at(0);
		argument = std::get<std::any>(tuple);
		long buffer_size =  std::any_cast<long>(argument);
		
		//create timer and set properties 
		//create queue set and set properties 
		std::string handler_name = get_handler_name(instruction, 1);
		auto buffer = std::make_shared<OS::Buffer>(&graph,handler_name);
		
		
		buffer->set_buffer_size(buffer_size);
		buffer->set_trigger_level(trigger_level);
		buffer->set_handler_name(handler_name);
		
		buffer->set_buffer_type(type);
		
		std::cout << "buffer successfully created"<< std::endl;
		//set timer to graph
		buffer->set_start_scheduler_creation_flag(before_scheduler_start);
		graph.set_vertex(buffer);
	
	}
	return success;
}

/*shared_abb get_scheduler_abb(graph::Graph& graph){
	
	
	
	
};
bool validate_start_scheduler
*/
void debug_arguments(std::any value,llvm::Type *type){

	std::size_t const tmp = value.type().hash_code();
	const std::size_t  tmp_int = typeid(int).hash_code();
	const std::size_t  tmp_double = typeid(double).hash_code();
	const std::size_t  tmp_string = typeid(std::string).hash_code();
	const std::size_t tmp_long      = typeid(long).hash_code();
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


bool detect_interaction(graph::Graph& graph){
	
	std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
	for (auto &vertex : vertex_list) {
		
		auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
		
		std::list<OS::shared_abb> abb_list = function->get_atomic_basic_blocks();
		
		for(auto &abb : abb_list){
			std::list<std::tuple<std::any,llvm::Type*>>* argument_list = abb->get_arguments();
			std::list<std::size_t> expected_argument_type_list  = abb->get_expected_syscall_argument_type();
			std::list<std::size_t>* target_list = abb->get_call_target_instance();
			
			if(abb->get_call_type() == sys_call ){
				
				
				
				bool success = false;

				std::vector<size_t> expected_argument_types(argument_list->size());
				for(auto& argument_type: expected_argument_type_list){
					expected_argument_types.emplace_back(argument_type);
				}
				
				std::vector<size_t>arguments_types(argument_list->size());
	
				for(auto & tuple : *argument_list){
					 
					arguments_types.emplace_back(std::get<std::any>(tuple).type().hash_code());
					
				}
				

				
				
				//verify the arguments
				if(!verify_syscall_arguments(expected_argument_types,arguments_types)){
					success = false;
				}else{
					
					{
						std::string type_str;
						llvm::raw_string_ostream rso(type_str);
						abb->get_call_instruction_reference()->print(rso);
						std::cout<< "instruction: " <<  rso.str() << std::endl;
					
					}
					
					//load the handler name
					std::string handler_name = "";
					if(argument_list->size() >0){
						std::tuple<std::any,llvm::Type*> tuple  = (argument_list->front());
						auto argument = std::get<std::any>(tuple);
						handler_name = std::any_cast<std::string>(argument);
					}
					std::cout << "handler_name " << handler_name<<  std::endl;
					for(auto& target: *target_list){
				
						//TODO eventually cast the vertex to the specific type
						std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(target);

						for (auto &vertex : vertex_list) {
							std::cout << "existiing handler_name " << vertex->get_handler_name() <<  std::endl;
							if(vertex->get_handler_name() == handler_name){
								std::cout << "Edge created" << std::endl;
								graph::shared_vertex start_vertex = function;
								if(function->get_definition_vertex() != nullptr)start_vertex = function->get_definition_vertex();
								
								if(abb->get_syscall_type() == receive){
									//TODO verifc that abb reference of the edge is a real abb
									auto edge = std::make_shared<graph::Edge>(&graph,abb->get_call_name(),start_vertex ,vertex,abb);
									//TODO set arguments ?
									graph.set_edge(edge);
									success = true;

								}else{
									//TODO verifc that abb reference of the edge is a real abb
									auto edge = std::make_shared<graph::Edge>(&graph,abb->get_call_name(),vertex ,start_vertex,abb);
									//TODO set arguments ?
									graph.set_edge(edge);
									success = true;
									std::cout << get_handler_name << std::endl;
								}
								break;
							}
						}
						if(success){
							break;
							std::cout << "Edge created" << std::endl;
						}
					}
				}
			}
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
		
		std::hash<std::string> hash_fn;

		
		std::list<size_t> instruction_list;
		before_scheduler_instructions(graph,&instruction_list);
		
		//iterate about the ABBS
		std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::ABB).hash_code());
		
		for(auto & hash_value : instruction_list){
			std::cout << hash_value << std::endl;
		}
		for (auto &vertex : vertex_list) {
			
			//vertex->print_information();
			//cast vertex to abb 
			auto abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
			
			//get the list of referenced llvm bb
			std::list<llvm::BasicBlock*> llvm_abbs = abb->get_BasicBlocks();
			
			if(llvm_abbs.size() == 1) // always test  
			{	
				{
					std::string callname = abb->get_call_name();
					std::vector<std::size_t> already_visited;
					validate_loop(llvm_abbs.front(),callname,&already_visited);
				}
				//check if abb has a syscall instruction
				if( abb->get_call_type()== sys_call){
					
					std::string callname = abb->get_call_name();
					std::vector<std::size_t> already_visited;
					
					
					
					//validate if sysccall is in loop
					if(validate_loop(llvm_abbs.front(),callname,&already_visited)){
						
						bool before_scheduler_start = false;
						size_t tmp = 0;
						std::string name = "";
						for(auto & hash_value : instruction_list){
							//std::cout << hash_value << std::endl;
							for(auto &bb :abb->get_BasicBlocks()){
								
								if(hash_value == hash_fn(bb->getName().str())){
									tmp = hash_value;
									name =bb->getName().str();
									before_scheduler_start = true;
									break;
								}
							}
						}
						
						if(before_scheduler_start)std::cout << "before_scheduler_start " <<  callname		<< std::endl;
						else std::cout << "!!!!!!!!!!!!!!!1after_scheduler_start " <<  	callname	<< std::endl;
						//check if abb syscall is creation syscall
						if(abb->get_syscall_type() == create){
							
							//check which target should be generated
							if(list_contains_element(abb->get_call_target_instance(),typeid(OS::Task).hash_code())){
								std::cout << "TASKCREATE" << name << ":" << tmp << std::endl;
								if(!create_task(graph,abb->get_arguments(),before_scheduler_start))std::cout << "Task could not created" << std::endl;
							}
								
							if(list_contains_element(abb->get_call_target_instance(),typeid(OS::Queue).hash_code())){
								if(!create_queue( graph,abb->get_arguments(),abb->get_call_instruction_reference(),before_scheduler_start))std::cout << "Queue could not created" << std::endl;

							}
							if(list_contains_element(abb->get_call_target_instance(),typeid(OS::Semaphore).hash_code())){
								//TODO set semaphore
								semaphore_type type;
								if(abb->get_call_name() =="xQueueCreateMutex")type = mutex;
								if(abb->get_call_name() =="xSemaphoreCreateRecursiveMutex")type = recursive_mutex;
								if(abb->get_call_name() =="xQueueCreateCountingSemaphore")type = counting;

								if(!create_semaphore(graph, abb->get_arguments(), type,abb->get_call_instruction_reference(),  before_scheduler_start))std::cout << "CountingSemaphore/Mutex could not created" << std::endl;
								
							}						
							if(list_contains_element(abb->get_call_target_instance(),typeid(OS::Timer).hash_code())){
								if(!create_timer( graph,abb->get_arguments(),before_scheduler_start))std::cout << "Timer could not created" << std::endl;
							}

							if(list_contains_element(abb->get_call_target_instance(),typeid(OS::EventGroup).hash_code())){
								//std::cout << callname << std::endl;
								if(!create_event_group(graph, abb->get_arguments(),abb->get_call_instruction_reference(),before_scheduler_start))std::cout << "Event Group could not created" << std::endl;
							}
							
							if(list_contains_element(abb->get_call_target_instance(),typeid(OS::Buffer).hash_code())){
								//std::cout << callname << std::endl;
								if(!create_buffer(graph, abb->get_arguments(),abb->get_call_instruction_reference(),before_scheduler_start))std::cout << "Buffer could not created" << std::endl;
							}
							if(list_contains_element(abb->get_call_target_instance(),typeid(OS::QueueSet).hash_code())){
								//std::cout << callname << std::endl;
								if(!create_queue_set(graph, abb->get_arguments(),abb->get_call_instruction_reference(),before_scheduler_start))std::cout << "Queue Set could not created" << std::endl;
							}
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
		detect_interaction(graph);

		
		
	}
	
	std::vector<std::string> FreeRTOSInstancesStep::get_dependencies() {
		return {"SyscallStep"};
	}
}
