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
// 	const std::size_t tmp_long 	= typeid(long).hash_code();element.type().hash_code()
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
* @param llvm_handler llvm handler variable
* @return handlername
*/
std::string get_handler_name(llvm::Instruction * instruction, unsigned int argument_index,llvm::Value*& llvm_handler){
	
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
            llvm_handler = user->getOperand(argument_index);
			handler_name = operand->getName().str();
		}
		else if(isa<BitCastInst>(user)){
			instruction = cast<Instruction>(user);
			handler_name = get_handler_name(instruction, argument_index,llvm_handler);
		}
	}
	
	if(handler_name == ""){
        std::cerr << "ERROR no handler name" << std::endl; 
        llvm_handler = nullptr;
    }
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
   
    std::stringstream stream;
    if( argument.any_list.size() == 0)return;
    
    //check if multiple argument values are possible
    if(argument.multiple ==false){
        
        //no multiple values are possible -> select front
        any_value =  argument.any_list.front();
        llvm_value =  argument.value_list.front();
        return;
    }
    else{
        //multiple values are possible
        std::vector<std::tuple<std::any,llvm::Value*,std::vector<int>>> valid_candidates;
        char index = 0;
        stream << "-------------------------- " << std::endl;
        for(auto tmp : *call_references){
                if(tmp != nullptr)stream << "current: " << print_argument(tmp) << std::endl;
                else stream << "nullptr" << std::endl;
        }
        stream << "-------------------------- " << std::endl;
        
        
        //detect all arguments which argument calls of the possible value are also visited by the abstraction instance
        for(auto argument_calles :argument.argument_calles_list){
            
            for(auto tmp : argument_calles){
                stream << "expected: " << print_argument(tmp) << std::endl;
            }
            stream << "-------------------------- " << std::endl;

            auto tmp_argument_calles = argument_calles;
            
            //erase first call, not necassary in evaluation
            tmp_argument_calles.erase(tmp_argument_calles.begin());
            std::vector<int> missmatch_list;
            int missmatches = 0;
            
            for (auto it = call_references->rbegin(); it != call_references->rend(); ++it){
            //for(auto call_reference : *call_references){
                llvm::Instruction* call_reference = *it;
                if(call_reference == tmp_argument_calles.front()){
                    tmp_argument_calles.erase(tmp_argument_calles.begin());
                    missmatch_list.emplace_back(missmatches);
                    stream << "missmatch" << missmatches << std::endl;
                    missmatches = 0;
                }
                else ++missmatches;
            }
            if(tmp_argument_calles.empty())valid_candidates.emplace_back(std::make_tuple(argument.any_list.at(index),argument.value_list.at(index),missmatch_list));
            ++index;
        }
        
        //check if juste one match betwenn current call tree and argument possibilites call trees was found
        if(valid_candidates.size() == 1){
            //just one matching candidate was detected
            any_value = std::get<std::any>(valid_candidates.front());
            llvm_value = std::get<llvm::Value*>(valid_candidates.front());;
            return;
        }else{
            if(valid_candidates.size() == 0){
                //no matching candidate was detected
                 stream << "no argument values are possible"<< std::endl;
            }else{
                
               
                //check if all candidates have the same argument call reference order
                llvm::Value* old_value = std::get<llvm::Value*>(valid_candidates.front());
                bool success = true;
                bool first = true;
                stream << "first: " << print_argument(old_value) << std::endl;
                
                int counter = -1;
                int index = 0;
                //check if the values are equal
                for(auto data : valid_candidates){
                    ++counter;
                    if(dyn_cast<ConstantPointerNull>(std::get<llvm::Value*>(data))){
                        if(first == false)success = false;
                        else continue;
                    }
                
                    if(first == false && old_value !=std::get<llvm::Value*>(data)){
                        success = false;
                        break;
                    }
                    stream << "new: " << print_argument(std::get<llvm::Value*>(data)) << std::endl;
                    index = counter;
                    
                    first = false;
                }
                if(success){
                    //all candidates have the same argument call reference order
                    any_value = std::get<std::any>(valid_candidates.at(index));
                    llvm_value = std::get<llvm::Value*>(valid_candidates.at(index));
                    return;
                    
                }else{
                    
                    
                    int index = 0;
                    bool flag = true;
                    
                    //get the best candidate of all possible in relation to the calltree 
                    while(flag){
                        
                        
                        auto first_missmatch_list = std::get<std::vector<int>>(valid_candidates.front());
                    
                        //get the first missmatch value from first candidate
                        bool first_candidate = true;
                        int candidate_index = 0;
                        std::list<int> candidate_indexes;
                        
                        //intialize min missmatch with highest possible value
                        unsigned int min_missmatch = -1; 
                        
                        //iterate about the candidates
                        for(auto candidate : valid_candidates){
                            
                            //get the first element
                            auto missmatch_list = std::get<std::vector<int>>(candidate);
                            

                            if(missmatch_list.empty() || missmatch_list.size() < index){
                            	//if missmatch list is empty oder to small ->error detected    
                                
                            }else if(first_candidate || missmatch_list.at(index) < min_missmatch){
                                //new best candidate detected or first element
                                min_missmatch = missmatch_list.front();
                        
                                //set the current candidate list
                                candidate_indexes.clear();
                                candidate_indexes.emplace_back(candidate_index);
                                
                                //reset first candidate boolean
                                if(first_candidate)first_candidate = false;
                                
                            }else if(missmatch_list.at(index) > min_missmatch){
                                //so ignore ignore it
                                
           
                            }else if(missmatch_list.at(index) == min_missmatch){ 
                                //next possible candidate with equal min missmatch value detected, so store the candidate
                                candidate_indexes.emplace_back(candidate_index);
                            }
                            ++candidate_index;
                        }         
                        
                        //store all best candidates in tmp list
                        std::vector<std::tuple<std::any,llvm::Value*,std::vector<int>>> tmp_valid_candidates;
                        int tmp_counter = 0;
                        for(auto candidate  : valid_candidates){
                            //check if candidate is in candidate list
                            if(find (candidate_indexes.begin(), candidate_indexes.end(), tmp_counter)!= candidate_indexes.end()){
                                //store candidate in tmp list
                                tmp_valid_candidates.emplace_back(valid_candidates.at(tmp_counter));
                            };
                            ++tmp_counter;
                        }
                        valid_candidates = tmp_valid_candidates;
                        
                        //if candidate list has just size of 1 valid candidate was found
                        if(valid_candidates.size()== 1){
                            any_value = std::get<std::any>(valid_candidates.front());
                            llvm_value = std::get<llvm::Value*>(valid_candidates.front());
                            return;
                        }else if (valid_candidates.size() == 0)flag = false;
                        //error detected
                        else if(index > 100)flag = false;
                        ++index;
                        }
                        
                        
                    std::cerr << "multiple argument values are possible" <<  valid_candidates.size() << std::endl;
                }
            }
        }
    }
    //std::cerr << stream.str();
    //default value if no candidate was found
    any_value = (std::string) " ERROR multiple argument values are possible";
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
    llvm::Value* llvm_handler = argument_reference;
	std::string handler_name =  std::any_cast<std::string>(specific_argument);
	
    //if no handler name was transmitted
    if(handler_name == "&$%NULL&$%"){
        handler_name =function_reference_name;
    }
/*    
    std::cerr <<  std::endl;
    std::cerr << abb->get_name() <<  ", "  << abb->get_parent_function()->get_name() <<std::endl;
    std::cerr << "task name " << task_name << std::endl;
    std::cerr << "function name " << function_reference_name << std::endl;
    std::cerr << "task priority " << priority << std::endl;
    std::cerr << "task handler name  " << handler_name << std::endl;*/
    
    
    
	//create task and set properties
	auto task = std::make_shared<OS::Task>(&graph,task_name);
	task->set_handler_name( handler_name,llvm_handler);
	task->set_stacksize( stacksize);
	task->set_priority( priority);
	task->set_start_scheduler_creation_flag(before_scheduler_start);
	
    
    if(!task->set_definition_function(function_reference_name)){
        std::cerr << "ERROR setting defintion function!" << std::endl;
        abort();
    }
    
    bool initial = true;
    bool error = false;
    
    for(auto task_vertex :graph.get_type_vertices((typeid(OS::Task).hash_code()))){
        auto tmp_task = std::dynamic_pointer_cast<OS::Task>(task_vertex);
        if(task->get_seed() == tmp_task->get_seed()){
            
            if(task->isEqual(tmp_task)){
                initial = false;
                task =  tmp_task;
            }
            else error = true;
        }
        else{
            if(tmp_task->get_handler_value() == llvm_handler){
                if(!isa<ConstantPointerNull>(llvm_handler))error = true;
            }
        }
        
    }
    
    if(error)task = nullptr;
    else if(!initial)task->set_multiple_create(true);
 
    if(initial && !error){
        std::hash<std::string> hash_fn;
        graph::shared_vertex function_vertex = graph.get_vertex( hash_fn(function_reference_name +  typeid(OS::Function).name())); 
        auto function_reference = std::dynamic_pointer_cast<OS::Function>(function_vertex);
        function_reference->set_definition_vertex(task);
        
        graph.set_vertex(task);
      
    }
    
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
	
	llvm::Value* llvm_handler = nullptr;
	std::string handler_name = get_handler_name(instruction, 1,llvm_handler);
	
	auto semaphore = std::make_shared<OS::Semaphore>(&graph,handler_name);
	semaphore->set_semaphore_type(type);
	semaphore->set_handler_name(handler_name,llvm_handler);
	semaphore->set_start_scheduler_creation_flag(before_scheduler_start);
	
	
	//std::cout << "semaphore handler name: " <<  handler_name << std::endl;
	switch(type){
		
		case binary_semaphore:{
            
            success = true;
            
			//std::cout << "binary semaphore successfully created"<< std::endl;
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

			//std::cout << "counting semaphore successfully created"<< std::endl;
			
			break;
		}
		
		default:{
			//std::cout << "wrong semaphore type" << std::endl;
			break;
		}
	}
	if(success){
        
        bool initial = true;
        bool error = false;
        
        for(auto semaphore_vertex :graph.get_type_vertices((typeid(OS::Semaphore).hash_code()))){
            auto tmp_semaphore = std::dynamic_pointer_cast<OS::Semaphore>(semaphore_vertex);
            if(semaphore->get_seed() == tmp_semaphore->get_seed()){
                
                if(semaphore->isEqual(tmp_semaphore)){
                    initial = false;
                    semaphore =  tmp_semaphore;
                }
                else error = true;
            }
            else{
                if(tmp_semaphore->get_handler_value() == llvm_handler){
                    if(!isa<ConstantPointerNull>(llvm_handler))error = true;
                }
            }
            
        }
        
        if(error)semaphore = nullptr;
        else if(!initial)semaphore->set_multiple_create(true);
    
        if(initial && !error){
            graph.set_vertex(semaphore);
            //std::cout << "semaphore successfully created"<< std::endl;
        }
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
graph::shared_vertex create_mutex(graph::Graph& graph,OS::shared_abb abb,resource_type type , bool before_scheduler_start,std::vector<llvm::Instruction*>* call_references ){
	
    bool success = false;
    
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
		
	//create reference list for all arguments types of the task creation syscall
	std::vector<argument_data>argument_list;
	
	for(auto & argument : abb->get_syscall_arguments()){
		argument_list.emplace_back(argument);
	}
	
	llvm::Value* llvm_handler = nullptr;
	std::string handler_name = get_handler_name(instruction, 1,llvm_handler);
	
	auto resource = std::make_shared<OS::Mutex>(&graph,handler_name);
	
	resource->set_handler_name(handler_name,llvm_handler);
	resource->set_start_scheduler_creation_flag(before_scheduler_start);
	resource->set_protocol_type(protocol_type::priority_inheritance);
	
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
			
			//if(type == binary_mutex)std::cout << "mutex successfully created"<< std::endl;
			//if(type == recursive_mutex)std::cout << "recursive mutex successfully created"<< std::endl;
            resource->set_resource_type(type);
            
			break;
		
		}
		
		default:{
			std::cout << "wrong mutex type" << std::endl;
			break;
		}
	}
	if(success){
        
        
        bool initial = true;
        bool error = false;
        
        for(auto resource_vertex :graph.get_type_vertices((typeid(OS::Mutex).hash_code()))){
            auto tmp_resource = std::dynamic_pointer_cast<OS::Mutex>(resource_vertex);
            if(resource->get_seed() == tmp_resource->get_seed()){
                
                if(resource->isEqual(tmp_resource)){
                    initial = false;
                    resource =  tmp_resource;
                }
                else error = true;
            }
            else{
                if(tmp_resource->get_handler_value() == llvm_handler){
                    if(!isa<ConstantPointerNull>(llvm_handler))error = true;
                }
            }
            
        }
        
        if(error)resource = nullptr;
        else if(!initial)resource->set_multiple_create(true);
    
        if(initial && !error){
            graph.set_vertex(resource);
            //std::cout << "resource successfully created"<< std::endl;
        }
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
		
			llvm::Value* llvm_handler = nullptr;
            std::string handler_name = get_handler_name(instruction, 1,llvm_handler);
		
		
		//create queue and set properties
		auto queue = std::make_shared<OS::Queue>(&graph,handler_name);
		
		queue->set_handler_name(handler_name,llvm_handler);
		queue->set_length(queue_length);
		queue->set_item_size(item_size);
		queue->set_start_scheduler_creation_flag(before_scheduler_start);
        
        
        bool initial = true;
        bool error = false;
        
        for(auto queue_vertex :graph.get_type_vertices((typeid(OS::Queue).hash_code()))){
            auto tmp_queue = std::dynamic_pointer_cast<OS::Queue>(queue_vertex);
            if(queue->get_seed() == tmp_queue->get_seed()){
                
                if(queue->isEqual(tmp_queue)){
                    initial = false;
                    queue =  tmp_queue;
                }
                else error = true;
            }
            else{
                if(tmp_queue->get_handler_value() == llvm_handler){
                    if(!isa<ConstantPointerNull>(llvm_handler))error = true;
                }
            }
            
        }
        
        if(error)queue = nullptr;
        else if(!initial)queue->set_multiple_create(true);
    
        if(initial && !error){
            graph.set_vertex(queue);
            //std::cout << "queue successfully created"<< std::endl;
        }
       
        vertex = queue;
		
		//std::cout << "queue successfully created"<< std::endl;
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
    llvm::Value* llvm_handler = nullptr;
	std::string handler_name = get_handler_name(instruction, 1,llvm_handler);
    
	auto event_group = std::make_shared<OS::Event>(&graph,handler_name);
		
	//std::cerr <<  "EventGroupHandlerName" << handler_name << std::endl;
	event_group->set_handler_name(handler_name,llvm_handler);
    
	event_group->set_start_scheduler_creation_flag(before_scheduler_start);
    
    
    bool initial = true;
    bool error = false;
    
    for(auto event_vertex :graph.get_type_vertices((typeid(OS::Event).hash_code()))){
        auto tmp_eventgroup = std::dynamic_pointer_cast<OS::Event>(event_vertex);
        if(event_group->get_seed() == tmp_eventgroup->get_seed()){
            
            if(event_group->isEqual(tmp_eventgroup)){
                initial = false;
                event_group =  tmp_eventgroup;
            }
            else error = true;
        }
        else{
            if(tmp_eventgroup->get_handler_value() == llvm_handler){
                if(!isa<ConstantPointerNull>(llvm_handler))error = true;
            }
        }
        
    }
    
    if(error)event_group = nullptr;
    else if(!initial)event_group->set_multiple_create(true);

    if(initial && !error){
        graph.set_vertex(event_group);
        //std::cout << "event_group successfully created"<< std::endl;
    }
    
	
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
    llvm::Value* llvm_handler = nullptr;
	std::string handler_name = get_handler_name(instruction, 1,llvm_handler);
    
	auto queue_set = std::make_shared<OS::QueueSet>(&graph,handler_name);
	
	queue_set->set_handler_name(handler_name,llvm_handler);
	queue_set->set_length(queue_set_size);
	
	//std::cout << "queue set successfully created"<< std::endl;
	//set queue to graph
	queue_set->set_start_scheduler_creation_flag(before_scheduler_start);
	graph.set_vertex(queue_set);
	
    
    bool initial = true;
    bool error = false;
    
    for(auto queueset_vertex :graph.get_type_vertices((typeid(OS::QueueSet).hash_code()))){
        auto tmp_queueset= std::dynamic_pointer_cast<OS::QueueSet>(queueset_vertex);
        if(queue_set->get_seed() == tmp_queueset->get_seed()){
            
            if(queue_set->isEqual(tmp_queueset)){
                initial = false;
                queue_set =  tmp_queueset;
            }
            else error = true;
        }
        else{
            if(tmp_queueset->get_handler_value() == llvm_handler){
                if(!isa<ConstantPointerNull>(llvm_handler))error = true;
            }
        }
        
    }
    
    if(error)queue_set = nullptr;
    else if(!initial)queue_set->set_multiple_create(true);

    if(initial && !error){
        graph.set_vertex(queue_set);
        //std::cout << "queue_set successfully created"<< std::endl;
    }
    
    
    
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
	
	llvm::Value* llvm_handler = nullptr;
	std::string handler_name = get_handler_name(instruction, 1,llvm_handler);
	//create timer and set properties 
	auto timer = std::make_shared<OS::Timer>(&graph,timer_name);
	
	timer->set_periode(timer_periode);
	
    //extract timer id
	//TODO timer id
    //timer->set_timer_id(timer_id);
    
    //std::cerr << "handler name " << handler_name << std::endl;
    timer->set_handler_name(handler_name,llvm_handler);
    
	if(timer_autoreload == 0) timer->set_timer_type(oneshot);
	else timer->set_timer_type(autoreload);
	//std::cout << "timer successfully created"<< std::endl;
	//set timer to graph
	timer->set_start_scheduler_creation_flag(before_scheduler_start);
    
    
    
    //std::cerr << "timer callback function " <<timer_definition_function << std::endl;
	timer->set_callback_function(timer_definition_function);
    timer->set_timer_action_type(alarm_callback);
    
    bool initial = true;
    bool error = false;
    
    for(auto timer_vertex :graph.get_type_vertices((typeid(OS::Timer).hash_code()))){
        auto tmp_timer= std::dynamic_pointer_cast<OS::Timer>(timer_vertex);
        if(timer->get_seed() == tmp_timer->get_seed()){
            
            if(timer->isEqual(tmp_timer)){
                initial = false;
                timer =  tmp_timer;
            }
            else error = true;
        }
        else{
            if(tmp_timer->get_handler_value() == llvm_handler){
                if(!isa<ConstantPointerNull>(llvm_handler))error = true;
            }
        }
        
    }
    
    if(error)timer = nullptr;
    else if(!initial)timer->set_multiple_create(true);

    if(initial && !error){
        
        std::hash<std::string> hash_fn;
        graph::shared_vertex function_vertex = graph.get_vertex( hash_fn(timer_definition_function +  typeid(OS::Function).name())); 
        auto function_reference = std::dynamic_pointer_cast<OS::Function>(function_vertex);
        function_reference->set_definition_vertex(timer);
        
        graph.set_vertex(timer);
        //std::cout << "timer successfully created"<< std::endl;
    }
    
    

    
    
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
    llvm::Value* llvm_handler = nullptr;
	std::string handler_name = get_handler_name(instruction, 1,llvm_handler);
	auto buffer = std::make_shared<OS::Buffer>(&graph,handler_name);
	
	
	buffer->set_buffer_size(buffer_size);
	buffer->set_trigger_level(trigger_level);
	buffer->set_handler_name(handler_name,llvm_handler);
	
	buffer->set_buffer_type(type);
	
	
	//set timer to graph
	buffer->set_start_scheduler_creation_flag(before_scheduler_start);
    
    
    bool initial = true;
    bool error = false;
    
    for(auto buffer_vertex :graph.get_type_vertices((typeid(OS::Buffer).hash_code()))){
        auto tmp_buffer= std::dynamic_pointer_cast<OS::Buffer>(buffer_vertex);
        if(buffer->get_seed() == tmp_buffer->get_seed()){
            
            if(buffer->isEqual(tmp_buffer)){
                initial = false;
                buffer =  tmp_buffer;
            }
            else error = true;
        }
        else{
            if(tmp_buffer->get_handler_value() == llvm_handler){
                if(!isa<ConstantPointerNull>(llvm_handler))error = true;
            }
        }
        
    }
    
    if(error)buffer = nullptr;
    else if(!initial)buffer->set_multiple_create(true);

    if(initial && !error){
        graph.set_vertex(buffer);
        //std::cout << "buffer successfully created"<< std::endl;
    }
	
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
    llvm::Value* llvm_handler = nullptr;
	auto coroutine = std::make_shared<OS::CoRoutine>(&graph,handler_name);
	
    
	coroutine->set_id(id);
	coroutine->set_priority(priority);
	coroutine->set_definition_function(function_reference_name);
	
	//set timer to graph
	coroutine->set_start_scheduler_creation_flag(before_scheduler_start);
    
    
    
    bool initial = true;
    bool error = false;
    
    for(auto coroutine_vertex :graph.get_type_vertices((typeid(OS::CoRoutine).hash_code()))){
        auto tmp_coroutine= std::dynamic_pointer_cast<OS::CoRoutine>(coroutine_vertex);
        if(coroutine->get_seed() == tmp_coroutine->get_seed()){
            
            if(coroutine->isEqual(tmp_coroutine)){
                initial = false;
                coroutine =  tmp_coroutine;
            }
            else error = true;
        }
        else{
            if(tmp_coroutine->get_handler_value() == llvm_handler){
                if(!isa<ConstantPointerNull>(llvm_handler))error = true;
            }
        }
        
    }
    
    if(error)coroutine = nullptr;
    else if(!initial)coroutine->set_multiple_create(true);

    if(initial && !error){
        
        std::hash<std::string> hash_fn;
        graph::shared_vertex function_vertex = graph.get_vertex( hash_fn(function_reference_name +  typeid(OS::Function).name())); 
        auto function_reference = std::dynamic_pointer_cast<OS::Function>(function_vertex);
        function_reference->set_definition_vertex(coroutine);
        
        
        graph.set_vertex(coroutine);
    }

	
	return coroutine;
}
/**
* @brief detects and creates freertos isrs 
* @param graph project data structure
*/
void detect_isrs(graph::Graph& graph){
	
    //iterate about the abbs

    std::map<size_t,size_t> visited_functions;
    
    
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
                
                if(visited_functions.find(seed) != visited_functions.end() ) {
                    continue;
                }else{
                    visited_functions.insert(std::make_pair(seed, seed));
                }
                
                    

                //get the calling functions of the function
                auto calling_functions =  function->get_calling_functions();
                //check if function has no calling functions
                if(calling_functions.size() == 0){
                 
                    std::string isr_name = function->get_name();
                    auto isr = std::make_shared<OS::ISR>(&graph,isr_name);
                    graph.set_vertex(isr);
                    isr->set_definition_function(function->get_name());
                    isr->set_handler_name(function->get_name());
                    
                    function->set_definition_vertex(isr);
                    
                    success = true;
                 
                    
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
* @param warning_list list to store warning
* @return true, if the abstraction instance could created, else return false
*/
bool create_abstraction_instance(graph::Graph& graph,graph::shared_vertex start_vertex,OS::shared_abb abb,bool before_scheduler_start,std::vector<llvm::Instruction*>* already_visited_calls,bool multiple_create,std::vector<shared_warning>* warning_list){
    try{
        
        std::string target_class = "";
        graph::shared_vertex created_vertex;
        //check which target should be generated
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Task).hash_code())){
           
            created_vertex = create_task(graph,abb,before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "Task";
        }
        
            
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Queue).hash_code())){
            created_vertex = create_queue( graph,abb,before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "Queue";

        }
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Semaphore).hash_code())){
            //set semaphore
            semaphore_type type = binary_semaphore;
            std::string syscall_name = abb->get_syscall_name();
        
            if(syscall_name =="xQueueCreateCountingSemaphore")type = counting_semaphore;
            created_vertex = create_semaphore(graph, abb, type, before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "CountingSemaphore";
            
        }
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Mutex).hash_code())){
            //set semaphore
        
            resource_type type;
            std::string syscall_name = abb->get_syscall_name();
            if(syscall_name =="xQueueCreateMutex")type = binary_mutex;
            else if(syscall_name =="xSemaphoreCreateRecursiveMutex")type = recursive_mutex;
            
            //std::cerr << abb->get_parent_function()->get_name() << std::endl;
            created_vertex = create_mutex(graph, abb, type, before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "Mutex";
            
        }			
        
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Timer).hash_code())){
            created_vertex = create_timer( graph,abb,before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "Timer";
        
        }

        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Event).hash_code())){
            created_vertex = create_event_group(graph, abb,before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "Event";
        }
        
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Buffer).hash_code())){
        
            created_vertex = create_buffer(graph, abb,before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "Buffer";
        }
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::QueueSet).hash_code())){
            ;
            created_vertex = create_queue_set(graph, abb,before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "QueueSet";
        }
        if(list_contains_element(abb->get_call_target_instances(),typeid(OS::CoRoutine).hash_code())){
        
            created_vertex = create_coroutine(graph, abb,before_scheduler_start,already_visited_calls);
            if(!created_vertex)target_class = "CoRoutine";
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
            
            //function creation was not successfull
            auto warning = std::make_shared<FreeRTOSCreateInstanceWarning>(target_class, abb);
            warning_list->emplace_back(warning);
            
            return false;
        }
    }
    catch(...){
        auto warning = std::make_shared<AnyCastWarning>(abb);
        warning_list->emplace_back(warning);
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
* @param calltree_references call history
* @param warning_list list to store warning
*/
void iterate_called_functions(graph::Graph& graph, graph::shared_vertex start_vertex, OS::shared_function function, llvm::Instruction* call_reference ,std::vector<llvm::Instruction*> already_visited_calls,std::vector<llvm::Instruction*>* calltree_references,std::vector<shared_warning>* warning_list){
    
    //return if function does not contain a syscall
    if(function == nullptr || function->has_syscall() ==false)return;
    std::hash<std::string> hash_fn;
    
	//search hash value in list of already visited basic blocks
	for(auto tmp_call : already_visited_calls){
		if(call_reference == tmp_call){
			//basic block already visited
			return;
		}
	}
  
    if(call_reference != nullptr){
        calltree_references->emplace_back(call_reference);
        already_visited_calls.emplace_back(call_reference);
    }
        
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
                //std::cerr << "abb " << abb->get_name() << " with syscall "<< abb->get_syscall_name() << "in loop" << std::endl;
            }
                
            bool before_scheduler_start = false;
            
            if(abb->get_start_scheduler_relation() == before)before_scheduler_start = true;
                                    
            //check if abb syscall is creation syscall
            if(abb->get_syscall_type() == create){
                
                if(!create_abstraction_instance( graph,start_vertex,abb,before_scheduler_start,calltree_references,multiple_create,warning_list)){
                    //std::cerr << "instance could not created" << std::endl;
                }
            }
            
        }else if( abb->get_call_type()== func_call){
            //iterate about the called function
            iterate_called_functions(graph,start_vertex,abb->get_called_function(), abb->get_call_instruction_reference(),already_visited_calls,calltree_references,warning_list);
        }
    }
}

namespace step {

	std::string FreeRTOSInstancesStep::get_name() {
		return "FreeRTOSInstancesStep";
	}

	std::string FreeRTOSInstancesStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances. For each abb in ARSA-Graph which contains a create syscall a corresponding abstraction instance is generated. All initial properties are stored in the generated instances";
	}
	
    /**
    * @brief the run method of the FreeRTOSInstancesStep pass. This pass detects all FreeRTOS instances  and gets their characteristics
    * @param graph project data structure
    */

	void FreeRTOSInstancesStep::run(graph::Graph& graph) {
        
        std::cerr << "Run FreeRTOSInstancesStep" << std::endl;
    
        
        std::vector<shared_warning>* warning_list = &(this->warnings);
        
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
            std::vector<llvm::Instruction*> calltree_references;
            iterate_called_functions(graph, main_vertex , main_function,nullptr,already_visited_calls,&calltree_references,warning_list);
		
            
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
                std::vector<llvm::Instruction*> calltree_references;
                iterate_called_functions(graph, task , task_definition, nullptr ,already_visited_calls,&calltree_references,warning_list);
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
                std::vector<llvm::Instruction*> calltree_references;
                iterate_called_functions(graph, isr , isr_definition, nullptr ,already_visited_calls,&calltree_references,warning_list);
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
                std::vector<llvm::Instruction*> calltree_references;
                iterate_called_functions(graph, timer , timer_definition, nullptr ,already_visited_calls,&calltree_references,warning_list);
            }
            
            
            //get all coroutines, which are stored in the graph
            vertex_list =  graph.get_type_vertices(typeid(OS::CoRoutine).hash_code());
            //iterate about the timers
            for (auto &vertex : vertex_list) {
                
                if(list_contains_element(&already_visited, vertex->get_seed()))continue;
                else already_visited.emplace_back(vertex->get_seed());
                
                flag = true;
                
                auto coroutine = std::dynamic_pointer_cast<OS::CoRoutine> (vertex);
                OS::shared_function coroutine_definition = coroutine->get_definition_function();
                //get all interactions of the instance
                std::vector<llvm::Instruction*> already_visited_calls;
                std::vector<llvm::Instruction*> calltree_references;
                iterate_called_functions(graph, coroutine , coroutine_definition, nullptr ,already_visited_calls,&calltree_references,warning_list);
            }
            
            
        }while(flag);

	
        
       
    }
	
	
	std::vector<std::string> FreeRTOSInstancesStep::get_dependencies() {
		return {"IntermediateAnalysisStep"};
	}
}
