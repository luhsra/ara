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




llvm::Instruction* get_element_ptr(llvm::Instruction *instr){
    
    if(auto *get_pointer_element  = dyn_cast<llvm::GetElementPtrInst>(instr)){  // U is of type User*
        get_pointer_element->getPointerOperand();
        auto tmp = get_pointer_element->getPointerOperand();
        return dyn_cast<Instruction>(tmp);
    }
    return nullptr;
}

void  print_instruction( llvm::Value *instr){
    if(nullptr==instr)return;
    std::string type_str;
    llvm::raw_string_ostream rso(type_str);
    instr->print(rso);
    std::cerr  << rso.str() <<  "\"\n";
}


llvm::Instruction* get_user_instruction(int argument,llvm::Value* instr){
    if(instr == nullptr)return nullptr;
    int reference = 0;
    for(auto user : instr->users()){  // U is of type User*
        if (auto I = dyn_cast<Instruction>(user)){
            if(reference == argument)return I;
             
        }
        reference = reference + 1;
    }
    return nullptr;
}

llvm::Instruction* get_operand(int argument, llvm::Instruction *instr){
    if(instr==nullptr)return nullptr;
    if(instr->getNumOperands()> argument){  // U is of type User*
        auto operand = instr->getOperand(argument);
        return dyn_cast<Instruction>(operand);
    }
    return nullptr;
}

int check_funtion_argument_reference(llvm::Function* function, llvm::Instruction* instr, int operand){
    if(instr==nullptr)return -1;
    if(instr->getNumOperands()> operand){ 
        int counter = 0;
        for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i){
            if( &(*i)==instr->getOperand(operand))return counter;
            ++counter;
        }
    }
    return -1;
}


void iterate_called_functions(graph::Graph& graph, graph::shared_vertex start_vertex, OS::shared_function function, std::vector<size_t>* already_visited){
    
    //return if function does not contain a syscall
    if(function == nullptr || function->has_syscall() ==false)return;
    std::hash<std::string> hash_fn;
    

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
                
                //check if the expected handler name occurs in the graph
                bool handler_found = false;
                for(auto &vertex : graph.get_vertices()){
                    if(vertex->get_handler_name() == handler_name)handler_found = true;
                }
                
                if(!handler_found){
                    //FPPassManager pass_manager;
                    //AAResults test = getAnalysis<AAResultsWrapperPass>().getAAResults(*(abb->get_parent_function()->get_llvm_reference());
                    //PassBuilder builder;
                    //auto pm = builder.buildModuleOptimizationPipeline(PassBuilder::OptimizationLevel::O3);
                    //MemoryDependenceAnalysis test= MemoryDependenceAnalysis();
                    //llvm::AnalysisManager<llvm::Function> AM;
                    //AM.clear();
                    //test.run(*(abb->get_parent_function()->get_llvm_reference()), AM);
                    //PMDataManager test = PMDataManager();
                    //DependenceAnalysis tmp ;
                    //tmp.run(*(abb->get_parent_function()->get_llvm_reference()), AM);
                    
                    //AnalysisResolver resolver = AnalysisResolver(pass_manager);
                    
                    //resolver
                    
                    //test.runOnFunction(*(abb->get_parent_function()->get_llvm_reference()));
                    
                 /*   std::string type_str;
                    llvm::raw_string_ostream rso(type_str);
                    abb->get_syscall_instruction_reference()->print(rso);
                    std::cerr <<  rso.str() <<  "\"\n";*/
                    
                    if(abb->get_syscall_instruction_reference()->getNumOperands()>= 1){  // U is of type User*
                       
                        std::cerr << "TEST" << std::endl;
                        //TODO make this more general
                        auto instr = abb->get_syscall_instruction_reference()->getOperand(0);
                        llvm::Instruction *tmp_instr = dyn_cast<llvm::Instruction>(instr);
                        print_instruction(tmp_instr);
                        
                        //load
                        tmp_instr = get_operand(0, tmp_instr);
                        print_instruction(tmp_instr);
                        
                        //get element pointer
                        tmp_instr = get_element_ptr(tmp_instr);
                        print_instruction(tmp_instr);
                        
                        //get user of element pointer
                        tmp_instr = get_user_instruction(1,tmp_instr);
                        print_instruction(tmp_instr);
                        
                        //get user of 
                        tmp_instr = get_user_instruction(0,tmp_instr);
                        print_instruction(tmp_instr);
                        tmp_instr = get_operand(0, tmp_instr);
                        print_instruction(tmp_instr);
                        tmp_instr = get_operand(0, tmp_instr);
                        print_instruction(tmp_instr);
                        tmp_instr = get_user_instruction(1,tmp_instr);
                        print_instruction(tmp_instr);
                        int argument_index = -1;
                        if(tmp_instr!=nullptr) argument_index = check_funtion_argument_reference(tmp_instr->getParent()->getParent()  ,tmp_instr,0);
                        if(argument_index>=0){
                            
                            std::vector<OS::shared_function> instance_related_functions;
                            std::stack<OS::shared_function> stack; 
                            std::list<size_t> visited_functions;
                            
                            OS::shared_function definition_function;
                            if(start_vertex->get_type() == typeid(OS::ISR).hash_code()){
                                auto isr = std::dynamic_pointer_cast<OS::ISR> (start_vertex);
                                definition_function =isr->get_definition_function();
                                
                            }else if(start_vertex->get_type() == typeid(OS::Task).hash_code()){
                                auto task = std::dynamic_pointer_cast<OS::Task> (start_vertex);
                                definition_function = task->get_definition_function();
                            }
                            
                            stack.push(definition_function);
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
                                instance_related_functions.emplace_back(function);
                            
                                //push the calling function on the stack
                                for (auto called_function: function->get_called_functions()){
                                    stack.push(called_function);
                                }
                            }
                            
                            std::vector<OS::shared_function> calling_functions = function->get_calling_functions(); 
                            
                            std::list<std::string> handler_names;
                            for(auto& definition_function :instance_related_functions){
                                for(auto& calling_function :calling_functions){
                                    if(definition_function->get_seed() == calling_function->get_seed()){
                                         for(auto user : tmp_instr->getParent()->getParent()->users()){
                                            if (auto I = dyn_cast<Instruction>(user)){// U is of type User*
                                                if(I->getParent()->getParent() == definition_function->get_llvm_reference()){
                                                    tmp_instr = get_operand(argument_index, I);
                                                    tmp_instr = get_operand(0, tmp_instr);
                                                    handler_names.emplace_back(tmp_instr->getName());
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            std::string tmp_name ;
                            bool success = true;
                            for(auto name :handler_names){
                                if(tmp_name.empty())tmp_name = name;
                                if(name != tmp_name){
                                    success = false;
                                    break;
                                }
                            }
                            if(success)handler_name = tmp_name;
                           
                         
                        }
                        
                        
                        
                        
//                        if(tmp_instr->getNumOperands()>= 1){  // U is of type User*
//                             std::string type_str;
//                             llvm::raw_string_ostream rso(type_str);
//                             auto instr = tmp_instr->getOperand(0);
//                             instr->print(rso);
//                             std::cerr <<  "load " << rso.str() <<  "\"\n";
//                             
//                             for(auto user : instr->users()){  // U is of type User*
//                                 if (auto I = dyn_cast<Instruction>(user)){
//                                     std::string type_str;
//                                     llvm::raw_string_ostream rso(type_str);
//                                     user->print(rso);
//                                     std::cerr <<  "user of allocation " << rso.str() <<  "\"\n";
//                                     
//                                     llvm::Instruction *tmp_instr = dyn_cast<llvm::Instruction>(user);
//    
//                                     if(tmp_instr->getNumOperands()>= 1){  // U is of type User*
//                                         std::string type_str;
//                                         llvm::raw_string_ostream rso(type_str);
//                                         auto instr = tmp_instr->getOperand(0);
//                                         instr->print(rso);
//                                         std::cerr <<  "last " << rso.str() <<  "\"\n";
//                                                 
//                                     }
//                                 }
//                             }
                            
//                             if(auto *get_pointer_element  = dyn_cast<llvm::GetElementPtrInst>(instr)){  // U is of type User*
//                                 get_pointer_element->getPointerOperand();
//                                 std::string type_str;
//                                 llvm::raw_string_ostream rso(type_str);
//                                 auto instr = get_pointer_element->getPointerOperand();
//                                 instr->print(rso);
//                                 std::cerr <<  "pointer operand " << rso.str() <<  "\"\n";
//                                 if(auto * loadinst = dyn_cast<llvm::LoadInst>(instr)){  // U is of type User*
//                                     std::string type_str;
//                                     llvm::raw_string_ostream rso(type_str);
//                                     auto instr = loadinst->getPointerOperand();
//                                     instr->print(rso);
//                                     std::cerr <<  "pointer operand " << rso.str() <<  "\"\n";
//                                     for(auto user : instr->users()){  // U is of type User*
//                                         if (auto I = dyn_cast<Instruction>(user)){
//                                             std::string type_str;
//                                             llvm::raw_string_ostream rso(type_str);
//                                             user->print(rso);
//                                             std::cerr <<  "user of allocation " << rso.str() <<  "\"\n";
//                                         }
//                                     }
//                                 }
//                             }
//                        }
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
                            if(abb->get_syscall_type() == receive){
                                
                                
                                //create the edge, which contains the start and target vertex and the arguments
                                auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(),start_vertex,target_vertex ,abb);
                                
                                //store the edge in the graph
                                graph.set_edge(edge);
                                
                                target_vertex->set_outgoing_edge(edge);
                                start_vertex->set_ingoing_edge(edge);
                                
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
                                 //std::cerr << "start vertex: " << start_vertex->get_name() << " target vertex: " << target_vertex->get_name() << std::endl;
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
                
//                 for(auto & task : graph.get_type_vertices(typeid(OS::Semaphore).hash_code())){
//                     std::cerr << task->get_handler_name() << std::endl;
//                 }
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
        //std::cerr << "task name: " << vertex->get_name() << std::endl;
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
        //std::cerr << "isr name: " << vertex->get_name() << std::endl;
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
        //std::cerr << "timer name: " << vertex->get_name() << std::endl;
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
