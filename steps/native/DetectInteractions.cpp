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
void detect_interactions(graph::Graph& graph){
	
    
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

    

//TODO uxBitsToWaitFor must not be set to 0
//TODO message single write single read
//TODO timer id
//TODO appmode types
//TODO element in queueset is accessed directy must no allowed
//TODO if configUSE_16_BIT_TICKS eventqueue size
//TODO OSEK Schedule also resource
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
//RAII
