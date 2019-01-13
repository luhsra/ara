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
#include "llvm/ADT/APFloat.h"
#include "llvm/IR/TypeFinder.h"

#include "llvm/ADT/PostOrderIterator.h" 
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Passes/PassBuilder.h"


using namespace llvm;




// void test_debug_argument(argument_data argument){
// 	
// 	
// 	const std::size_t  tmp_int = typeid(int).hash_code();
// 	const std::size_t  tmp_double = typeid(double).hash_code();
// 	const std::size_t  tmp_string = typeid(std::string).hash_code();
// 	const std::size_t tmp_long 	= typeid(long).hash_code();
// 	std::cerr << "Argument: ";
// 	/*
// 	std::string type_str;
// 	llvm::raw_string_ostream rso(type_str);
// 	type->print(rso);
// 	std::cout<< rso.str() << std::endl ;
// 	*/
// 	//std::cout << "reference: " << tmp_int << " " << tmp_double << " " << tmp_string << " " << tmp_long << std::endl;
// 	
// 	for(auto element : argument.any_list){
//         std::size_t const tmp = element.type().hash_code();
//         if(tmp_int == tmp){
//             std::cerr << std::any_cast<int>(element)   ;
//         }else if(tmp_double == tmp){ 
//             std::cerr << std::any_cast<double>(element) ;
//         }else if(tmp_string == tmp){
//             std::cerr << std::any_cast<std::string>(element)  ;  
//         }else if(tmp_long == tmp){
//             std::cerr << std::any_cast<long>(element) ;  
//         }else{
//             std::cerr << "[warning: cast not possible] type: " <<element.type().name() ;  
//         }
//         std::cerr << ", ";
//     }
//     std::cerr << std::endl;
//     for(auto element : argument.value_list){
//         if(element == nullptr)continue;
//         std::string type_str;
//         llvm::raw_string_ostream rso(type_str);
//         element->print(rso);
//         std::cerr << rso.str() << std::endl << "," ;
//     }
//     std::cerr << std::endl;
// }


/**
* @brief checks if the list contains the target seed
* @param list list with seed references
* @param target target seed
* @return if the list contains the target seed return true, else false
*/
bool list_contains_element(std::list<std::size_t>* list, size_t target){
	for(auto element : *list){
		if(element == target)return true;
	}
	return false;
}






/**
* @brief returns the handler name, which is one argument of the call  
* @param instruction instruction where the handler is an argument
* @param argument_index argument index
* @return handlername
*/
std::string get_handler_name(llvm::Instruction * instruction, unsigned int argument_index){
	
	if(instruction == nullptr)std::cerr << "ERROR" << std::endl;
	
	std::string handler_name = "";	
	//check if call instruction has one user
	if(instruction->hasOneUse()){
		//get the user of the call instruction
		llvm::User* user = instruction->user_back();
		//check if user is store instruction
		if(isa<StoreInst>(user)){
			//get name of specific operand (-> handler name)
			Value * operand = user->getOperand(argument_index);
			handler_name = operand->getName().str();
		}
		else if(isa<BitCastInst>(user)){
			instruction = cast<Instruction>(user);
			handler_name = get_handler_name(instruction, argument_index);
		}
	}
	
	if(handler_name == "")std::cerr << "ERROR no handler name" << std::endl;
	return handler_name;
}



/**
* @brief gets all of the specific argument of all possible varations, E.g if the call argument is also the function argument, there could be many possible values
* The function selects the right one, by comparing the argument instruction references with the call references of the current abstraction instance
* @param arguments all arguments
* @param call_instruction_reference llvm instruction reference of the call
* @param call_name name of call
* @param call_references call instructions which were already visited
*/
call_data get_syscall_relative_arguments(std::vector<argument_data>* arguments,std::vector<llvm::Instruction*>*call_references,llvm::Instruction* call_instruction_reference,std::string call_name){
    call_data specific_call_data;
    
    specific_call_data.sys_call = true;
    specific_call_data.call_name = call_name  ;
    specific_call_data.call_instruction = call_instruction_reference;
    
    for(auto argument : *arguments){
        argument_data tmp_argument;
        std::any any_value;
        llvm::Value* llvm_reference;
        argument_data specific_argument;
        get_call_relative_argument(any_value,llvm_reference, argument,call_references);
                
        
        tmp_argument.any_list.emplace_back(any_value);
        tmp_argument.value_list.emplace_back(llvm_reference);
        specific_argument.multiple = false;
        specific_call_data.arguments.emplace_back(tmp_argument);
        
    }
    return specific_call_data;
}

/**
* @brief gets the specific argument of all possible varations, E.g if the call argument is also the function argument, there could be many possible values
* The function selects the right one, by comparing the argument instruction references with the call references of the current abstraction instance
* @param any_value specific  value of argument
* @param llvm_value specific llvm value of argument
* @param argument argument, with all possible values
* @param call_references call instructions which were already visited
*/
void get_call_relative_argument(std::any &any_value,llvm::Value* &llvm_value,argument_data argument,std::vector<llvm::Instruction*>*call_references){
   
    if( argument.any_list.size() == 0)return;
    
    //check if multiple argument values are possible
    if(argument.multiple ==false){
        any_value =  argument.any_list.front();
        llvm_value =  argument.value_list.front();
        return;
    }
    else{
        std::vector<std::tuple<std::any,llvm::Value*,std::vector<char>>> valid_candidates;
        char index = 0;
        
        //detect all arguments which argument calls of the possible value are also visited by the abstraction instance
        for(auto argument_calles :argument.argument_calles_list){

            auto tmp_argument_calles = argument_calles;
            //erase first call, not necassary in evaluation
            tmp_argument_calles.erase(tmp_argument_calles.begin());
            std::vector<char> missmatch_list;
            char missmatches = 0;
            for(auto call_reference : *call_references){
               
                if(call_reference == tmp_argument_calles.front()){
                    tmp_argument_calles.erase(tmp_argument_calles.begin());
                    missmatch_list.emplace_back(missmatches);
                    missmatches = 0;
                }
                else ++missmatches;
            }
            if(tmp_argument_calles.empty())valid_candidates.emplace_back( std::make_tuple(argument.any_list.at(index),argument.value_list.at(index),missmatch_list));
            ++index;
        }
        
        if(valid_candidates.size() == 1){
            //just one matching candidate was detected
            any_value = std::get<std::any>(valid_candidates.front());
            llvm_value = std::get<llvm::Value*>(valid_candidates.front());;
            return;
        }else{
            if(valid_candidates.size() == 0){
                //no matching candidate was detected
                 std::cerr << "no argument values are possible"<< std::endl;
            }else{
                //check if all candidates have the same argument call reference order
                llvm::Value* old_value = std::get<llvm::Value*>(valid_candidates.front());
                bool success = true;
                for(auto data : valid_candidates){
                    if(old_value !=std::get<llvm::Value*>(data)){
                        success = false;
                        break;
                    }
                }
                if(success){
                    //all candidates have the same argument call reference order
                    any_value = std::get<std::any>(valid_candidates.front());
                    llvm_value = std::get<llvm::Value*>(valid_candidates.front());
                    return;
                    
                }else{
                    std::cerr << "multiple argument values are possible" <<  valid_candidates.size() << std::endl;
                    //TODO select the best 
                }
            }
        }
    }
    //default value if no candidate was found
    any_value = (std::string) "multiple argument values are possible";
    llvm_value = nullptr;
}



/**
* @brief creates the freertos abstraction instance from type task
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_task(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start,std::vector<llvm::Instruction*>*call_references ){
	
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
    
    
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
    std::any specific_argument;
    llvm::Value* argument_reference;
	//load the arguments
	argument_data argument= argument_list.at(0);
	
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string function_reference_name =  std::any_cast<std::string>(specific_argument);
	
	argument = argument_list.at(1);
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string task_name =  std::any_cast<std::string>(specific_argument);
	
	argument = argument_list.at(2);
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	unsigned long stacksize =  std::any_cast<long>(specific_argument);
	
	argument = argument_list.at(3);
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string task_argument =  std::any_cast<std::string>(specific_argument);
	
	argument = argument_list.at(4);
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	unsigned long priority =  std::any_cast<long>(specific_argument);
	
	argument = argument_list.at(5);
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string handler_name =  std::any_cast<std::string>(specific_argument);
	
    //if no handler name was transmitted
    if(handler_name == "&$%NULL&$%"){
        handler_name =function_reference_name;
    }
	
	//create task and set properties
	auto task = std::make_shared<OS::Task>(&graph,task_name);
	task->set_handler_name( handler_name);
	task->set_stacksize( stacksize);
	task->set_priority( priority);
	task->set_start_scheduler_creation_flag(before_scheduler_start);
	graph.set_vertex(task);
	
    
    if(!task->set_definition_function(function_reference_name)){
        std::cerr << "ERROR setting defintion function!" << std::endl;
        abort();
    }
    
	std::hash<std::string> hash_fn;
	
	graph::shared_vertex vertex = nullptr;
	vertex =  graph.get_vertex(hash_fn(function_reference_name +  typeid(OS::Function).name()));

	if(vertex != nullptr){
		auto function_reference = std::dynamic_pointer_cast<OS::Function> (vertex);
		function_reference->set_definition_vertex(task);
	}else{
		std::cerr << "ERROR task definition function does not exist " << function_reference_name << std::endl;
		abort();
	}
	
	std::cout << "task successfully created"<< std::endl;
   
    
	return task;
}





/**
* @brief creates the freertos abstraction instance from type semaphore
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_semaphore(graph::Graph& graph,OS::shared_abb abb,semaphore_type type , bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references ){
	
    bool success = false;
    
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
		
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
	std::string handler_name = get_handler_name(instruction, 1);
	
	auto semaphore = std::make_shared<OS::Semaphore>(&graph,handler_name);
	semaphore->set_semaphore_type(type);
	semaphore->set_handler_name(handler_name);
	semaphore->set_start_scheduler_creation_flag(before_scheduler_start);
	
	
	//std::cout << "semaphore handler name: " <<  handler_name << std::endl;
	switch(type){
		
		case binary_semaphore:{
            
            success = true;
            
			std::cout << "binary semaphore successfully created"<< std::endl;
			break;
		}
		
		case counting_semaphore:{
            
			success = true;
            std::any specific_argument;
            llvm::Value* argument_reference;
	
			//load the arguments
			argument_data argument  = argument_list.at(1);
            get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
			unsigned long initial_count =  std::any_cast<long>(specific_argument);
			
			argument  = argument_list.at(0);
			get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
			unsigned long max_count =  std::any_cast<long>(specific_argument);
			

			semaphore->set_initial_count(initial_count);
			semaphore->set_max_count(max_count);

			std::cout << "counting semaphore successfully created"<< std::endl;
			
			break;
		}
		
		default:{
			std::cout << "wrong semaphore type" << std::endl;
			break;
		}
	}
	if(success){
        graph.set_vertex(semaphore);
        return semaphore;
    }else{
        return nullptr;
    }
}



/**
* @brief creates the freertos abstraction instance from type resource
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_resource(graph::Graph& graph,OS::shared_abb abb,resource_type type , bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references ){
	
    bool success = false;
    
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
		
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
	std::string handler_name = get_handler_name(instruction, 1);
	
	auto resource = std::make_shared<OS::Resource>(&graph,handler_name);
	
	resource->set_handler_name(handler_name);
	resource->set_start_scheduler_creation_flag(before_scheduler_start);
	
	
	switch(type){
		
        case binary_mutex:{
			
			success = true;
            std::any specific_argument;
            llvm::Value* argument_reference;
			//load the arguments
			argument_data argument  = argument_list.at(0);
			get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
			unsigned long type_mutex =  std::any_cast<long>(specific_argument);
			
			//set the mutex type (mutex, recursive mutex)
			type = (resource_type) type_mutex;
			
			if(type == binary_mutex)std::cout << "mutex successfully created"<< std::endl;
			if(type == recursive_mutex)std::cout << "recursive mutex successfully created"<< std::endl;
            resource->set_resource_type(type);
            
			break;
		
		}
		
		default:{
			std::cout << "wrong mutex type" << std::endl;
			break;
		}
	}
	if(success){
        graph.set_vertex(resource);
        return resource;
    }else{
        return nullptr;
    }
}


/**
* @brief creates the freertos abstraction instance from type queue
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_queue(graph::Graph& graph, OS::shared_abb abb ,bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references){
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
    std::any specific_argument;
    llvm::Value* argument_reference;
	
	//load the arguments
	argument_data argument   = argument_list.at(0);
    
   
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	long queue_length =  std::any_cast<long>(specific_argument);
	
	argument  = argument_list.at(1);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
    long item_size =  std::any_cast<long>(specific_argument);

	argument  = argument_list.at(2);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	long queue_type =  std::any_cast<long>(specific_argument);
	
	semaphore_type type = (semaphore_type) queue_type;
	
    graph::shared_vertex vertex = nullptr;
    
	if(type != binary_semaphore){
		
		std::string handler_name = get_handler_name(instruction, 1);
		
		
		//create queue and set properties
		auto queue = std::make_shared<OS::Queue>(&graph,handler_name);
		
		queue->set_handler_name(handler_name);
		queue->set_length(queue_length);
		queue->set_item_size(item_size);
		queue->set_start_scheduler_creation_flag(before_scheduler_start);
		graph.set_vertex(queue);
       
        vertex = queue;
		
		std::cout << "queue successfully created"<< std::endl;
	}else{
		vertex = create_semaphore(graph,abb,binary_semaphore, before_scheduler_start,call_references);
	}

	return vertex;
}


/**
* @brief creates the freertos abstraction instance from type event
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_event_group(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references){
	
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	//create queue and set properties 
	std::string handler_name = get_handler_name(instruction, 1);
	auto event_group = std::make_shared<OS::Event>(&graph,handler_name);
		
	//std::cerr <<  "EventGroupHandlerName" << handler_name << std::endl;
	event_group->set_handler_name(handler_name);
    
    std::cerr << "event group handler name " << handler_name << std::endl;
	event_group->set_start_scheduler_creation_flag(before_scheduler_start);
	graph.set_vertex(event_group);
	std::cout << "event group successfully created" <<  std::endl;
		
	
	return event_group;
}



/**
* @brief creates the freertos abstraction instance from type queueset
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_queue_set(graph::Graph& graph, OS::shared_abb abb,  bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references){
	

	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
    std::any specific_argument;
    llvm::Value* argument_reference;
	
	//load the arguments
    argument_data argument   = argument_list.at(0);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	unsigned long queue_set_size =  std::any_cast<long>(specific_argument);
	

	//create queue set and set properties 
	std::string handler_name = get_handler_name(instruction, 1);
	auto queue_set = std::make_shared<OS::QueueSet>(&graph,handler_name);
	
	queue_set->set_handler_name(handler_name);
	queue_set->set_length(queue_set_size);
	
	std::cout << "queue set successfully created"<< std::endl;
	//set queue to graph
	queue_set->set_start_scheduler_creation_flag(before_scheduler_start);
	graph.set_vertex(queue_set);
	
	return queue_set;
}

/**
* @brief creates the freertos abstraction instance from type timer
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_timer(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references){
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
    
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
    std::any specific_argument;
    llvm::Value* argument_reference;
	
	//load the arguments
	argument_data argument   = argument_list.at(0);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string timer_name =  std::any_cast<std::string>(specific_argument);
	
	argument  = argument_list.at(1);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	long timer_periode =  std::any_cast<long>(specific_argument);

	argument  = argument_list.at(2);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	long timer_autoreload =  std::any_cast<long>(specific_argument);
	
	argument  = argument_list.at(3);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string timer_id =  std::any_cast<std::string>(specific_argument);
	
	argument  = argument_list.at(4);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string timer_definition_function =  std::any_cast<std::string>(specific_argument);
	
    std::string handler_name = get_handler_name(instruction, 1);
	//create timer and set properties 
	auto timer = std::make_shared<OS::Timer>(&graph,timer_name);
	
	timer->set_periode(timer_periode);
	
    //extract timer id
	//TODO timer id
    //timer->set_timer_id(timer_id);
    
    std::cerr << "handler name " << handler_name << std::endl;
    timer->set_handler_name(handler_name);
    
	if(timer_autoreload == 0) timer->set_timer_type(oneshot);
	else timer->set_timer_type(autoreload);
	std::cout << "timer successfully created"<< std::endl;
	//set timer to graph
	timer->set_start_scheduler_creation_flag(before_scheduler_start);
	graph.set_vertex(timer);
    
    std::cerr << "timer callback function " <<timer_definition_function << std::endl;
	timer->set_callback_function(timer_definition_function);
    timer->set_timer_action_type(alarm_callback);
    
    
	return timer;
}


/**
* @brief creates the freertos abstraction instance from type buffer
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_buffer(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references){
	
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	//create reference list for all arguments types of the task creation syscall
	

	//get the typeid hashcode of the expected arguments
		std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
	std::any specific_argument;
    llvm::Value* argument_reference;
			
	//load the arguments
	argument_data argument   = argument_list.at(2);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	buffer_type type = (buffer_type) std::any_cast<long>(specific_argument);
	
	//std::cout << "buffer type: "<< std::any_cast<long>(argument)<< std::endl;
	
	argument  = argument_list.at(1);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	long trigger_level =  std::any_cast<long>(specific_argument);

	argument  = argument_list.at(0);
    get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	long buffer_size =  std::any_cast<long>(specific_argument);
	
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
	
	return buffer;
}

/**
* @brief creates the freertos abstraction instance from type queueset
* @param graph project data structure
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param call_references call instructions which were already visited
* @return a shared pointer of the created abstraction instance
*/
graph::shared_vertex create_coroutine(graph::Graph& graph, OS::shared_abb abb,  bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references){
	

	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
    std::any specific_argument;
    llvm::Value* argument_reference;
	
	
	//load the arguments
	argument_data argument= argument_list.at(0);
	
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	std::string function_reference_name =  std::any_cast<std::string>(specific_argument);
	
	argument = argument_list.at(1);
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	unsigned long priority =  std::any_cast<long>(specific_argument);
	
	argument = argument_list.at(2);
	get_call_relative_argument(specific_argument, argument_reference,argument,call_references);
	unsigned long id =  std::any_cast<long>(specific_argument);
    
    
	//create queue set and set properties 
	std::string handler_name = function_reference_name  + std::to_string(id);
	auto coroutine = std::make_shared<OS::CoRoutine>(&graph,handler_name);
	
	coroutine->set_id(id);
	coroutine->set_priority(priority);
	coroutine->set_definition_function(function_reference_name);
	std::cout << "queue set successfully created"<< std::endl;
	//set timer to graph
	coroutine->set_start_scheduler_creation_flag(before_scheduler_start);
	graph.set_vertex(coroutine);
	
	return coroutine;
}
/**
* @brief detects and creates freertos isrs 
* @param graph project data structure
*/
void detect_isrs(graph::Graph& graph){
	
    //iterate about the abbs
    std::vector<size_t> visited_functions;
    
    std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::ABB).hash_code());

    for (auto &vertex : vertex_list) {
        
        //cast vertex to abb 
        auto abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
        //check if syscall is isr specific 
        if(abb->get_syscall_name().find("FromISR") != std::string::npos){
            
            bool success = false;
            //queue for functions
            std::stack<OS::shared_function> stack; 
            
            
            stack.push(abb->get_parent_function());
            //iterate about the stack 
            while(stack.size()!=0) {
                
                //get first element of the queue
                OS::shared_function function = stack.top();
                stack.pop();
                //check if the function was already visited by DFS
                size_t seed =  function->get_seed();
                for(auto tmp_seed : visited_functions){
                    if(seed == tmp_seed)continue;
                }
                //set the function to the already visited functions
                visited_functions.emplace_back(seed);

                //get the calling functions of the function
                auto calling_functions =  function->get_calling_functions();
                //check if function has no calling functions
                if(calling_functions.size() == 0){
                    
                    std::string isr_name = function->get_name();
                    auto isr = std::make_shared<OS::ISR>(&graph,isr_name);
                    graph.set_vertex(isr);
                    isr->set_definition_function(function->get_name());
                    isr->set_handler_name(function->get_name());
                    
                    success = true;
                    std::cerr << "isr successfully created" << std::endl;
                    
                }else{
                    //push the calling function on the stack
                    for (auto calling_function: calling_functions){
                        stack.push(calling_function);
                    }
                }
            }
            if(!success)std::cerr << "isr could not created, because of recursion" << std::endl;
        }
    }
}

/**
* @brief creates the freertos abstraction instance which is created in current abb
* @param graph project data structure
* @param start_vertex abstraction instance which is iterated
* @param abb abb that contains the creation call
* @param before_scheduler_start information about the instance relation in context of the function
* @param already_visited call instructions which were already visited
* @param multiple_create information if abb, which contains create call, is in loop
* @return true, if the abstraction instance could created, else return false
*/
bool create_abstraction_instance(graph::Graph& graph,graph::shared_vertex start_vertex,OS::shared_abb abb,bool before_scheduler_start,std::vector<llvm::Instruction*>* already_visited_calls,bool multiple_create){

    graph::shared_vertex created_vertex;
    //check which target should be generated
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Task).hash_code())){
        //std::cout << "TASKCREATE" << name << ":" << tmp << std::endl;
        created_vertex = create_task(graph,abb,before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "Task could not created" << std::endl;
    }
    
        
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Queue).hash_code())){
        created_vertex = create_queue( graph,abb,before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "Queue could not created" << std::endl;

    }
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Semaphore).hash_code())){
        //set semaphore
        semaphore_type type = binary_semaphore;
        std::string syscall_name = abb->get_syscall_name();
       
        if(syscall_name =="xQueueCreateCountingSemaphore")type = counting_semaphore;
        created_vertex = create_semaphore(graph, abb, type, before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "CountingSemaphore could not created" << std::endl;
        
    }
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Resource).hash_code())){
        //set semaphore
       
        resource_type type;
        std::string syscall_name = abb->get_syscall_name();
        if(syscall_name =="xQueueCreateMutex")type = binary_mutex;
        else if(syscall_name =="xSemaphoreCreateRecursiveMutex")type = recursive_mutex;
        
        created_vertex = create_resource(graph, abb, type, before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "Mutex could not created" << std::endl;
        
    }			
    
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Timer).hash_code())){
        created_vertex = create_timer( graph,abb,before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "Timer could not created" << std::endl;
      
    }

    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Event).hash_code())){
        created_vertex = create_event_group(graph, abb,before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "Event Group could not created" << std::endl;
    }
    
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Buffer).hash_code())){
       
        created_vertex = create_buffer(graph, abb,before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "Buffer could not created" << std::endl;
    }
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::QueueSet).hash_code())){
        ;
        created_vertex = create_queue_set(graph, abb,before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "Queue Set could not created" << std::endl;
    }
    if(list_contains_element(abb->get_call_target_instances(),typeid(OS::CoRoutine).hash_code())){
      
        created_vertex = create_coroutine(graph, abb,before_scheduler_start,already_visited_calls);
        if(!created_vertex)std::cout << "CoRoutine could not created" << std::endl;
    }
    if(created_vertex){
        
        //set information if created instance is created in loop
        created_vertex->set_multiple_create(multiple_create);
        //set static flag, if the creatoin syscall contains Static substring
        if(abb->get_syscall_name().find("Static") !=  std::string::npos){
            created_vertex->set_static_create(true);
        }
        
        auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(), start_vertex,created_vertex,abb);
        //store the edge in the graph
        graph.set_edge(edge);
        
        start_vertex->set_outgoing_edge(edge);
        created_vertex->set_ingoing_edge(edge);
        edge->set_instruction_reference( abb->get_syscall_instruction_reference());
        auto arguments = abb->get_syscall_arguments();
        auto syscall_reference = abb->get_syscall_instruction_reference();
        auto specific_arguments=  get_syscall_relative_arguments( &arguments, already_visited_calls,syscall_reference,abb->get_syscall_name());
        edge->set_specific_call(&specific_arguments);
        return true;
    }else{
        return false;
    }
}



/**
* @brief iterates recursive about the functions of the instance and creates new instances 
* @param graph project data structure
* @param start_vertex abstraction instance which is iterated
* @param function current function of abstraction instance
* @param call_reference function call instruction
* @param already_visited call instructions which were already iterated
*/
void iterate_called_functions(graph::Graph& graph, graph::shared_vertex start_vertex, OS::shared_function function, llvm::Instruction* call_reference ,std::vector<llvm::Instruction*>* already_visited_calls){
    
    //return if function does not contain a syscall
    if(function == nullptr || function->has_syscall() ==false)return;
    std::hash<std::string> hash_fn;
    
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
        
        //get the list of referenced llvm bb
        std::vector<llvm::BasicBlock*>* llvm_bbs = abb->get_BasicBlocks();
            
        //check if abb has a syscall instruction
        if( abb->get_call_type()== sys_call){
            
            std::vector<std::size_t> already_visited;
            
            bool multiple_create = false;
            //validate if sysccall is not in loop
            if(abb->get_loop_information()){
                multiple_create = true;
                std::cerr << "abb " << abb->get_name() << " with syscall "<< abb->get_syscall_name() << "in loop" << std::endl;
            }
                
            bool before_scheduler_start = false;
            
            if(abb->get_start_scheduler_relation() == before)before_scheduler_start = true;
                                    
            //check if abb syscall is creation syscall
            if(abb->get_syscall_type() == create){
                
                if(!create_abstraction_instance( graph,start_vertex,abb,before_scheduler_start,already_visited_calls,multiple_create)){
                    std::cerr << "instance could not created" << std::endl;
                }
            }
            
        }else if( abb->get_call_type()== func_call){
            //iterate about the called function
            iterate_called_functions(graph,start_vertex,abb->get_called_function(), abb->get_call_instruction_reference(),already_visited_calls);
        }
        
        /*for(auto& edge : abb->get_outgoing_edges()){
            graph::shared_vertex vertex =edge->get_target_vertex();
            //std::cerr << "edge target " << vertex->get_name() << std::endl;
            if(typeid(OS::Function).hash_code() == vertex->get_type()){
                auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
                iterate_called_functions(graph,start_vertex,function, edge->get_instruction_reference(),already_visited_calls);
                
            }
        }*/
    }
}

namespace step {

	std::string FreeRTOSInstancesStep::get_name() {
		return "FreeRTOSInstancesStep";
	}

	std::string FreeRTOSInstancesStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances";
	}
	
    /**
    * @brief the run method of the FreeRTOSInstancesStep pass. This pass detects all FreeRTOS instances  and gets their characteristics
    * @param graph project data structure
    */

	void FreeRTOSInstancesStep::run(graph::Graph& graph) {
    
        //detect isrs based of the isr specific freertos api 
        detect_isrs(graph);
        
        //get function with name main from graph
		std::string start_function_name = "main";  
        std::hash<std::string> hash_fn;
        graph::shared_vertex main_vertex = graph.get_vertex( hash_fn(start_function_name +  typeid(OS::Function).name())); 
        
        OS::shared_function main_function;
        
		//check if graph contains main function
		if(main_vertex != nullptr){
			std::vector<std::size_t> already_visited;
			main_function = std::dynamic_pointer_cast<OS::Function>(main_vertex);
			            
            //iterate about the main function context and detect abstraction instances
            std::vector<llvm::Instruction*> already_visited_calls;
            iterate_called_functions(graph, main_vertex , main_function,nullptr,&already_visited_calls);
		
            
        }else{
            std::cerr << "no main function in programm" << std::endl;
            abort();
        }
      
        //iterate about the isrs
        std::list<size_t> already_visited;
        bool flag = false;
        
        do{
            flag = false;
            
            //get all tasks, which are stored in the graph
            std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Task).hash_code());
        
            for (auto &vertex : vertex_list) {
                
                if(list_contains_element(&already_visited, vertex->get_seed()))continue;
                else already_visited.emplace_back(vertex->get_seed());
                
                flag = true;
                
                //std::cerr << "task name: " << vertex->get_name() << std::endl;
                auto task = std::dynamic_pointer_cast<OS::Task> (vertex);
                OS::shared_function task_definition = task->get_definition_function();
                //get all interactions of the instance
                std::vector<llvm::Instruction*> already_visited_calls;
                iterate_called_functions(graph, task , task_definition, nullptr ,&already_visited_calls);
            }
        
        
        
            //get all isrs, which are stored in the graph
            vertex_list =  graph.get_type_vertices(typeid(OS::ISR).hash_code());
            //iterate about the isrs
            for (auto &vertex : vertex_list) {
                
                if(list_contains_element(&already_visited, vertex->get_seed()))continue;
                else already_visited.emplace_back(vertex->get_seed());
                
                flag = true;
                
                auto isr = std::dynamic_pointer_cast<OS::ISR> (vertex);
                OS::shared_function isr_definition = isr->get_definition_function();
                //get all interactions of the instance
                std::vector<llvm::Instruction*> already_visited_calls;
                iterate_called_functions(graph, isr , isr_definition, nullptr ,&already_visited_calls);
            }
            
            
            //get all timers, which are stored in the graph
            vertex_list =  graph.get_type_vertices(typeid(OS::Timer).hash_code());
            //iterate about the timers
            for (auto &vertex : vertex_list) {
                
                if(list_contains_element(&already_visited, vertex->get_seed()))continue;
                else already_visited.emplace_back(vertex->get_seed());
                
                flag = true;
                
                auto timer = std::dynamic_pointer_cast<OS::Timer> (vertex);
                OS::shared_function timer_definition = timer->get_callback_function();
                //get all interactions of the instance
                std::vector<llvm::Instruction*> already_visited_calls;
                iterate_called_functions(graph, timer , timer_definition, nullptr ,&already_visited_calls);
            }
            
            
        }while(flag);

	
        
        //identifiy hooks and mark corresponding functions
        std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
        for (auto &vertex : vertex_list) {
                
            auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
            
            hook_type hook = no_hook;
            if(function->get_name().find("PostTaskHook") != std::string::npos){
                hook = post_task;
            }else if(function->get_name().find("PreTaskHook") != std::string::npos){
                hook = pre_task;
            }else if(function->get_name().find("ErrorHook") != std::string::npos){
                hook = error;
//             }else if(function->get_name().find("ShutdownHook") != std::string::npos){
                hook = shut_down;
            }else if(function->get_name().find("StartupHook") != std::string::npos){
                hook = start_up;
            }else if(function->get_name().find("vApplicationMallocFailedHook") != std::string::npos){
                hook = failed;
            }else if(function->get_name().find("vApplicationIdleHook") != std::string::npos){
                hook = idle;
            }else if(function->get_name().find("vApplicationStackOverflowHook") != std::string::npos){
                hook = stack_overflow;
            }else if(function->get_name().find("vApplicationTickHook") != std::string::npos){
                hook = tick;
            }
            if(hook != no_hook)function->set_hook_type(hook);
        }
    }
	
	
	std::vector<std::string> FreeRTOSInstancesStep::get_dependencies() {
		return {"IntermediateAnalysisStep"};
	}
}
