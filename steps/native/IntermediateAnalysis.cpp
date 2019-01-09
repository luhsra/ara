// vim: set noet ts=4 sw=4:



#include "llvm/Analysis/AssumptionCache.h"
#include "IntermediateAnalysis.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "FreeRTOSinstances.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/AliasAnalysis.h"
//#include "llvm/IR/CFG.h"
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
#include "CFG.h"
#include "llvm/ADT/PostOrderIterator.h" 
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Passes/PassBuilder.h"

using namespace llvm;


start_scheduler_relation before_scheduler_instructions(graph::Graph& graph,OS::shared_function function,std::vector<std::size_t> *already_visited);


/**
* @brief returns the string representation of llvm value
* @param val llvm value which string represantion is returned
* @return returns the string representation of llvm value
*/
std::string print_tmp(llvm::Value* val){
    std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	val->print(rso);
	return rso.str() ;
}

/**
* @brief return true if instruction is reachable from a instruction from the list
* @param instruction_list list of llvm instructions
* @param instruction llvm instruction
* @param dominator_tree dominator_tree of the function
* @return true if instruction is reachable from a instruction from the list
*/
bool validate_instructions_reachability(std::vector<llvm::Instruction*> *instruction_list, llvm::Instruction* instruction,llvm::DominatorTree *dominator_tree){
	bool success = false;
	for(auto * tmp_instruction:*instruction_list){
        if(instruction == nullptr)std::cerr << "ERROR";
		if(llvm::isPotentiallyReachable(tmp_instruction,instruction,dominator_tree,nullptr)){
			success = true;
			break;
		}
	}

	return success;
}

/**
* @brief return true if instruction is dominated by all instructions from the list
* @param instruction_list list of llvm instructions
* @param instruction llvm instruction
* @param dominator_tree dominator_tree of the function
* @return true if instruction is dominated by all instructions from the list
*/
bool validate_instructions_dominance(std::vector<llvm::Instruction*> *instruction_list, llvm::Instruction* instruction,llvm::DominatorTree *dominator_tree){
	bool success = true;
	for(auto * tmp_instruction:*instruction_list){
		if(!dominator_tree->dominates(tmp_instruction,instruction)){
			success = false;
			break;
		}
	}

	return success;
}


/**
* @brief return true if instruction is dominated by one instruction from the list
* @param instruction_list list of llvm instructions
* @param instruction llvm instruction
* @param dominator_tree dominator_tree of the function
* @return true if instruction is dominated by one instruction from the list
*/
bool validate_one_instructions_dominance(std::vector<llvm::Instruction*> *instruction_list, llvm::Instruction* instruction,llvm::DominatorTree *dominator_tree){
	bool success = false;
	for(auto * tmp_instruction:*instruction_list){
		if(dominator_tree->dominates(tmp_instruction,instruction)){
			success = true;
			break;
		}
	}

	return success;
}


/**
* @brief set all abbs of function to equal start scheduler relation
* @param graph project data structure
* @param function function which abbs are set to equal start scheduler relation
* @param already_visited already visited calls
* @param state start scheduler relation of all abb in function
*/
void update_called_functions(graph::Graph& graph,OS::shared_function function,std::vector<std::size_t> *already_visited ,start_scheduler_relation state){
    
	//check if valid function pointer was committed
	if(function == nullptr) return;
		
	std::hash<std::string> hash_fn;

	size_t hash_value = hash_fn(function->get_name());
	
	//search hash value in list of already visited basic blocks
	for(auto hash : *already_visited){
		if(hash_value == hash){
			//function already visited
			return;
		}
	}
	
	for(auto & abb : function->get_atomic_basic_blocks()){
		abb->set_start_scheduler_relation(state);
	}
	
	
	//set function as already visited
	already_visited->emplace_back(hash_value);
    
    auto called_functions =  function->get_called_functions();
    //check if function has no calling functions
    
    //push the calling function on the stack
    for (auto called_function: called_functions){
       update_called_functions(graph,called_function,already_visited , state);
    }
}

/**
* @brief get all instructions of the function that call the start scheduler syscall
* @param function list of llvm instructions
* @return vector of instructions which starts the scheduler
*/
std::vector<llvm::Instruction*> get_start_scheduler_instruction(OS::shared_function function){
	std::vector<llvm::Instruction*> instruction_vector;
	for(auto & abb : function->get_atomic_basic_blocks()){
		if(abb->get_call_type() == sys_call){
			//std::cout << abb->get_call_name() << std::endl; 
            if(start_scheduler == abb->get_syscall_type())instruction_vector.push_back(abb->get_syscall_instruction_reference());
		}
	}
	return instruction_vector;
}

/**
* @brief set for each abb in the main function the information if the abb is before, uncertain oder behind the start scheduler call
* @param graph project data structure
* @param instr llvm instruction
* @param already_visited call instruction which were alread visited
* @param state relation of the abb to the start scheduler
* @param start_scheduler_func_calls all calls with contain functions which the start scheduler is called certainly
* @param uncertain_start_scheduler_func_calls all calls with addresses functions which the start scheduler is not called certainly
* @return information if the last function abb is before, uncertain or after the start scheduler syscall
*/
void recursive_before_scheduler_instructions(graph::Graph& graph,llvm::Instruction* instr,start_scheduler_relation& state,std::vector<std::size_t> *already_visited,std::vector<llvm::Instruction*>* start_scheduler_func_calls,std::vector<llvm::Instruction*>* uncertain_start_scheduler_func_calls){
    
    std::hash<std::string> hash_fn;
    
    llvm::Function* called_function = nullptr;
    if(llvm::CallInst* call_instruction = dyn_cast<CallInst>(instr)){
        called_function = call_instruction->getCalledFunction();
    }else if(llvm::InvokeInst* call_instruction = dyn_cast<InvokeInst>(instr)){
        called_function = call_instruction->getCalledFunction();
    }
   
    start_scheduler_relation result;
   
    if(called_function != nullptr){
        graph::shared_vertex target_vertex = graph.get_vertex( hash_fn(called_function->getName().str() +  typeid(OS::Function).name())); 
        auto target_function = std::dynamic_pointer_cast<OS::Function>(target_vertex);
        result = before_scheduler_instructions(graph,target_function  ,already_visited);
        
        
        if(result == after){
            //in the called function a start scheduler instruction is inevitably executed
            start_scheduler_func_calls->emplace_back(instr);
            if (state == before)state = uncertain; 
        }
        else{
            if (result == uncertain){
                //in the called function a start scheduler instruction is executed, but not inevitably
                uncertain_start_scheduler_func_calls->emplace_back(instr);
                //if the current state of the function is before and the result of the called function is uncertain, then set state to uncertain 
                if (state == before)state = uncertain; 
            }
        }
    }
}

/**
* @brief set for each abb in the main function the information if the abb is before, uncertain oder behind the start scheduler call
* @param graph project data structure
* @param already_visited call instruction which were alread visited
* @param function main function
* @return information if the last function abb is before, uncertain or after the start scheduler syscall
*/
start_scheduler_relation before_scheduler_instructions(graph::Graph& graph,OS::shared_function function,std::vector<std::size_t> *already_visited){
    

	//default start scheduler relation state of the function 
	start_scheduler_relation state = uncertain;
	
	//check if valid function pointer was committed
	if(function == nullptr) return not_defined;
	
    
	std::vector<llvm::Instruction*> start_scheduler_func_calls;
	std::vector<llvm::Instruction*> uncertain_start_scheduler_func_calls;
	std::vector<llvm::Instruction*> return_instructions;
		
	std::hash<std::string> hash_fn;
    
    
    //generate hash value of the functionname
	size_t hash_value = hash_fn(function->get_name());
	
	//search hash value in list of already visited basic blocks
	for(auto hash : *already_visited){
		if(hash_value == hash){
			//function already visited
			return not_defined;
		}
	}
	//set function as already visited 
	already_visited->emplace_back(hash_value);
	
	//get all start scheduler instructions of the current function (not the subfunctions)
	start_scheduler_func_calls = get_start_scheduler_instruction(function);
    
    
	
	//generate dominator tree
	llvm::DominatorTree* dominator_tree = function->get_dominator_tree();
	
	//check if a start scheduler call was found in current function
	if(start_scheduler_func_calls.size() == 0){
        //set scheduler relation state of function to before
		state = before;
	}
        
    //get all return instructions of the function and store them
    for(auto &abb : function->get_atomic_basic_blocks()){
        for(llvm::BasicBlock* bb : *abb->get_BasicBlocks()){
            for(auto &instr:*bb){
                if(isa<ReturnInst>(instr)){
                    return_instructions.emplace_back(&instr);
                }
            }
        }
    }

	
	//iterate about abbs which contain a func call and detect function calls and execute the recursive analysis for the called function
	for(auto &abb : function->get_atomic_basic_blocks()){
        if(abb->get_call_type() != func_call)continue;
		for(llvm::BasicBlock* bb : *abb->get_BasicBlocks()){
            for(auto &instruction:*bb){
                auto *instr = abb->get_call_instruction_reference();
                //start the recursion for the called function
                recursive_before_scheduler_instructions( graph,instr, state,already_visited,&start_scheduler_func_calls,&uncertain_start_scheduler_func_calls);
                
			}
		}
	}
	
	//check if certain und uncertain start scheduler calls exists
	if(state ==uncertain){
		for(auto &abb : function->get_atomic_basic_blocks()){
            bool before_flag = false;
            bool uncertain_flag = false;
			
            for(auto &instruction:*abb->get_entry_bb()){
                //check if the instruction is not reachable from all certain and uncertain start scheduler instructions
                if(!validate_instructions_reachability(&start_scheduler_func_calls,&instruction, dominator_tree ) && !validate_instructions_reachability(&uncertain_start_scheduler_func_calls,&instruction, dominator_tree ) ){
                        //instruction is not reachable from a uncertain or certain start scheduler instruction 
                    before_flag = true;
                    
                }else{
                    before_flag = false;
                    
                    //check if the instruction is reachable from a uncertain start scheduler instruction
                    if(validate_one_instructions_dominance(&start_scheduler_func_calls,&instruction, dominator_tree ))uncertain_flag = false;
                    else if(validate_instructions_reachability(&uncertain_start_scheduler_func_calls,&instruction,dominator_tree) || validate_instructions_reachability(&start_scheduler_func_calls,&instruction,dominator_tree) ){
                        //instruction is reachable from a uncertain start scheduler instruction 
                        uncertain_flag = true;
                    }
                }
                break;
            }
			if(before_flag){
                abb->set_start_scheduler_relation(before);
            }
            else if(uncertain_flag){
                abb->set_start_scheduler_relation(uncertain);
            }
        }
		
		bool flag = true;
		for(auto instr : return_instructions){
            //check if return instruction is dominated by all certain start scheduler instructions
			if(!validate_instructions_dominance(&start_scheduler_func_calls,instr, dominator_tree ))flag = false;
		}
		
		//state is after if all retrun instructions were dominated by a certain start scheduler instruction
		if(flag)state = after;
	}
	
    std::vector<std::size_t> tmp_already_visited;
    //iterate about the abbs of the function
    for(auto &abb : function->get_atomic_basic_blocks()){
        
        if(abb->get_start_scheduler_relation() == after){
            //iterate about the called function of the abb
            //set all abbs, which are reachable from a after start scheduler abb from the main function, to after start scheduler 
            update_called_functions(graph, abb->get_called_function()  ,&tmp_already_visited,after);
        }
    }
	return state;
}



/**
* @brief sort the abbs of each function in topological order
* @param graph project data structure
*/
void sort_abbs(graph::Graph& graph){
    
    //get all functions of the application
    std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
    
    //iterate about the application
    for (auto &vertex : vertex_list) {
        
        std::list<llvm::BasicBlock*> tmp_topological_order;
        
        //cast vertex to abb 
        auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
       
        // Use LLVM's Strongly Connected Components (SCCs) iterator to produce
        // a reverse topological sort of SCCs.
       
       
        //iterate about the bbs of the function in reversed topological order and store the bbs in vector
        for (scc_iterator<llvm::Function *> I = scc_begin(function->get_llvm_reference()), IE = scc_end(function->get_llvm_reference());I != IE; ++I) {
            // Obtain the vector of BBs in this SCC and print it out.
            const std::vector<BasicBlock *> &SCCBBs = *I;
            for (std::vector<BasicBlock *>::const_iterator BBI = SCCBBs.begin(), BBIE = SCCBBs.end(); BBI != BBIE; ++BBI) {
                tmp_topological_order.emplace_front(*BBI);
            }
        }
        
        std::vector<llvm::BasicBlock*> topological_order;
         
        //bbs are sorted in inversed topological order, so reverse them
        for(auto element : tmp_topological_order){
             topological_order.emplace_back(element);
         }
        
        //generate dominator tree
        llvm::DominatorTree* dominator_tree = function->get_dominator_tree();
        
        
        std::list<OS::shared_abb> abb_list = function->get_atomic_basic_blocks();
        std::list<OS::shared_abb> sorted_abb_list;
        int counter = 0;
        
        //map the order of the bbs to the order of the abbs
        while(counter < topological_order.size()){
            
            auto order_reference = topological_order[counter];
            
            bool flag = false;
            //iterate about the abb list
            for(auto& abb: abb_list){
                
                std::vector<llvm::BasicBlock*>* unsorted_bb_list = abb->get_BasicBlocks();
                
                //check if abb contains bbs which are store in the order reference list
                for(auto bb :*unsorted_bb_list){
                    if(order_reference ==bb)flag = true;
                    else break;
                }
                
                //check if the entry bb of the abb is equal to the topological bb reference
                if(flag){
                      
                    sorted_abb_list.emplace_back(abb);
                    std::vector<llvm::BasicBlock*> sorted_bb_list(unsorted_bb_list->size());
                    
                    for(auto bb: *unsorted_bb_list){
                        
                        int tmp_counter = 0;
                        bool tmp_flag = false;
                        while((counter+tmp_counter) < topological_order.size() && tmp_counter < sorted_bb_list.size()){                             
                            if(topological_order[counter + tmp_counter] ==bb){
                                sorted_bb_list.at(tmp_counter) = bb;
                                tmp_flag = true;
                                break;
                             }
                             ++tmp_counter;
                        }
                        if(!tmp_flag)std::cerr << "ERROR abb " << abb->get_name() << "contains wrong bb "   << print_tmp(bb) <<  std::endl;
                    }
                    
                    counter += unsorted_bb_list->size();
                    break;
                }
            }
            if(!flag){
                std::cerr << "ERROR in topological ordering of bb " << (order_reference->getName().str()) << std::endl;
                ++counter;
            }
        }
        
        
        
        if(abb_list.size() == sorted_abb_list.size()){
            //list of sorted and unsorted abbs are equal, so set the ordered list to the abb
            function->set_atomic_basic_blocks(&sorted_abb_list);
        }
        else{
            //list of sorted and unsorted abbs are not equal
            bool flag = true;
            for(auto abb :sorted_abb_list){
                if(function->get_exit_abb()->get_seed() == abb->get_seed())flag = false;
            }
            //check if missing abb is the exit abb of the function (because the exit abb may contain no bb)
            if(flag && abb_list.size() > sorted_abb_list.size() && function->get_exit_abb() != nullptr && function->get_exit_abb()->get_seed() != sorted_abb_list.back()->get_seed()){
                sorted_abb_list.emplace_back(function->get_exit_abb());
                function->set_atomic_basic_blocks(&sorted_abb_list);
            }else{
                
                std::cerr << "could not sort the abbs of function " << function->get_name() << " in topological order" << std::endl;
//                 for(auto abb :abb_list){
//                     std::cerr  << "unsorted abb: " << abb->get_name() << std::endl;
//                 }
//                 for(auto abb :sorted_abb_list){
//                     std::cerr  << "sorted abb: " << abb->get_name() << std::endl;
//                 }
            }
        }
    }
}


namespace step {

	std::string IntermediateAnalysisStep::get_name() {
		return "IntermediateAnalysisStep";
	}

	std::string IntermediateAnalysisStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances";
	}
	
    /**
    * @brief the run method of the IntermediateAnalysisStep pass. This pass detects all interactions of the instances via the RTOS. 
    * @param graph project data structure
    */
	void IntermediateAnalysisStep::run(graph::Graph& graph) {
		
		std::cout << "Run IntermediateAnalysisStep" << std::endl;
		
        sort_abbs(graph);
        
		std::cout << "Run " << get_name() << std::endl;
			
		std::hash<std::string> hash_fn;
		
		//get function with name main from graph
		std::string start_function_name = "main";  
		
		graph::shared_vertex main_vertex = graph.get_vertex( hash_fn(start_function_name +  typeid(OS::Function).name())); 
		
        OS::shared_function main_function;
        
		//check if graph contains main function
		if(main_vertex != nullptr){
			std::vector<std::size_t> already_visited;
			main_function = std::dynamic_pointer_cast<OS::Function>(main_vertex);
			before_scheduler_instructions(graph, main_function  ,&already_visited);
      
        }else{
            std::cerr << "no main function in programm" << std::endl;
            abort();
        }
		

	}
	
	std::vector<std::string> IntermediateAnalysisStep::get_dependencies() {
        
        // get file arguments from config
		std::vector<std::string> files;
        
		PyObject* elem = PyDict_GetItemString(config, "os");
        
        if(elem != nullptr)std::cerr << "success" << std::endl;
		assert(PyUnicode_Check(elem));
		return {"ABB_MergeStep"};

	}
}
//RAII