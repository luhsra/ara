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
#include <map>
#include "llvm/IR/Module.h"

using namespace llvm;

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
* @param already_visited call instruction which were alread visited ->detect recursion
* @param call_tree call instruction which were alread visited -> store call tree history
* @param function main function
* @param start_relation start_scheduler relation of entry abb of function
* @return information if the last function abb is before, uncertain or after the start scheduler syscall
*/
start_scheduler_relation before_scheduler_instructions(graph::Graph& graph,OS::shared_function function,std::map<std::size_t,std::size_t> already_visited,std::map<std::size_t,std::size_t>* call_tree,start_scheduler_relation start_relation){
    

	//default start scheduler relation state of the function 
	start_scheduler_relation state = uncertain;
	
	//check if valid function pointer was committed
	if(function == nullptr) return not_defined;
	
    
	std::vector<llvm::Instruction*> start_scheduler_func_calls;
	std::vector<llvm::Instruction*> uncertain_start_scheduler_func_calls;
		
	std::hash<std::string> hash_fn;
    
    //generate dominator tree
	llvm::DominatorTree* dominator_tree = function->get_dominator_tree();
    
    //generate hash value of the functionname
	size_t hash_value = hash_fn(function->get_name());
	bool visited_flag =  false;
    bool calltree_flag = false;
    
	//search hash value in list of already visited basic blocks
    if ( already_visited.find(hash_value) != already_visited.end() ) {
        visited_flag = true;
    }
    
    //search hash value in list of already visited basic blocks
    if ( call_tree->find(hash_value) != call_tree->end() ) {
        calltree_flag = true;
        //std::cerr << "---------------------" << std::endl;
    }

    if(!visited_flag){//set function as already visited 
        already_visited.insert(std::make_pair(hash_value, hash_value));
        call_tree->insert(std::make_pair(hash_value, hash_value));
        
        std::vector<llvm::Instruction*> start_scheduler_func_calls;
        std::vector<llvm::Instruction*> uncertain_start_scheduler_func_calls;
        
        auto entry_abb = function->get_entry_abb();
        
        if(entry_abb == nullptr){
            std::cerr << "Function" << function->get_name() << "has no entry abb" <<std::endl;
            abort();
        }
        
        //iterate about the abbs of function in topoligal order
        for(auto &abb : function->get_atomic_basic_blocks()){
            
            bool before_flag= false;
            bool after_flag = false;
            bool uncertain_flag =false;
            for(auto predecessor :abb->get_ABB_predecessors()){
                //std::cerr << "predecessor " << predecessor->get_name() << std::endl;
                if(predecessor->get_start_scheduler_relation() == before)before_flag = true;
                if(predecessor->get_start_scheduler_relation() == after)after_flag = true; 
                if(predecessor->get_start_scheduler_relation() == uncertain)uncertain_flag = true; 
            }
            
            start_scheduler_relation tmp_state = uncertain;
            
            if(abb->get_seed() == entry_abb->get_seed())tmp_state = start_relation;
            else{
                
                if(before_flag && !after_flag && !uncertain_flag)tmp_state = before;
                else if(!before_flag && after_flag && !uncertain_flag)tmp_state = after;
            }
            //std::cerr << abb->get_name() << "tmp 1 relation " << tmp_state  << std::endl;
            
            if(abb->get_call_type() == sys_call){
                //std::cout << abb->get_call_name() << std::endl; 
                if(start_scheduler == abb->get_syscall_type())tmp_state = after;
            }else if(abb->get_call_type() == func_call){
                if(tmp_state == after) before_scheduler_instructions(graph,abb->get_called_function(),already_visited,call_tree,tmp_state);
                else tmp_state = before_scheduler_instructions(graph,abb->get_called_function(),already_visited,call_tree,tmp_state);
            }
            
            //std::cerr << abb->get_name() << "tmp 2 relation " << tmp_state  << std::endl;
            
            if(tmp_state == uncertain){
                if(abb->get_entry_bb() != nullptr){
                    
                    uncertain_start_scheduler_func_calls.emplace_back(&abb->get_entry_bb()->front());
                }
            }else if(tmp_state == after){
                if(abb->get_entry_bb() != nullptr){
                    start_scheduler_func_calls.emplace_back(&(abb->get_entry_bb()->front()));
                }
            }else if(tmp_state == before){
                if(abb->get_entry_bb()!=nullptr){
                    if(validate_instructions_reachability(&start_scheduler_func_calls,&(abb->get_entry_bb()->front()), dominator_tree ) || validate_instructions_reachability(&uncertain_start_scheduler_func_calls,&(abb->get_entry_bb()->front()), dominator_tree ))tmp_state = uncertain;
                }
            }
            //std::cerr << abb->get_name() << "tmp 3 relation " << tmp_state  << std::endl;
            
            if(tmp_state == before && abb->get_start_scheduler_relation() == uncertain ){
                //std::cerr << "variant1" << std::endl;
                abb->set_start_scheduler_relation(uncertain);
            }else if (tmp_state == after && abb->get_start_scheduler_relation() != after ){
                //std::cerr << "variant2" << std::endl;
                abb->set_start_scheduler_relation(uncertain);
            }else if (tmp_state == before && abb->get_start_scheduler_relation() == after && calltree_flag ){
                //std::cerr << "variant3"<< std::endl;
                abb->set_start_scheduler_relation(uncertain);
            }else abb->set_start_scheduler_relation(tmp_state);
            
            //std::cerr << abb->get_name() << " relation " << abb->get_start_scheduler_relation()  << std::endl;
        }
    }
        
    if(function->get_exit_abb() != nullptr)return function->get_exit_abb()->get_start_scheduler_relation();
    else return after;
}






/**
* @brief sort the bbs of the SCC in topolical order -> is possible because loops are broken at entry bb
* @param bb curren bb which shalle analyzed
* @param open_predecessors map which contains the bbs which were visited but have unvisted precdessors
* @param already_visited map which stores all bbs which were already visited
* @param topological_order list which stores the topolical order of SCC
* @param end basicblock with is at the end of SCC
*/
void SCC_topological_sort(llvm::BasicBlock* bb, std::map<std::string,std::string>* open_predecessors , std::map<std::string,std::string>* already_visited, std::list<llvm::BasicBlock*> * topological_order, llvm::BasicBlock* end){
    
    //search abb in open predecessor map
    auto it_predecessor = open_predecessors->find(bb->getName().str());
    auto it_already_visited = already_visited->find(bb->getName().str());
    
    //std::cerr << "TMP1 topological: " << bb->getName().str() << std::endl;
    
    bool predecessor_flag =false;
    
    if (it_predecessor != open_predecessors->end()){
        predecessor_flag = true;
    }else if(it_already_visited != already_visited->end()){
        return;
    }else{
        already_visited->insert(std::pair<std::string,std::string>(bb->getName().str(),bb->getName().str()));
    }
    
    //std::cerr << "TMP2 topological: " << bb->getName().str() << std::endl;
    int predecessorcount = 0;
    
    
    
    for (pred_iterator pit = pred_begin(bb), pet = pred_end(bb); pit != pet; ++pit){
    //for(auto predecessor : abb->get_ABB_predecessors()){
        it_already_visited = already_visited->find((*pit)->getName().str());
        if (it_already_visited == already_visited->end()){
            ++predecessorcount;
        }
    }
    //std::cerr << "TMP2 predecessor count : " << predecessorcount << std::endl;
    if( predecessorcount > 0 && !predecessor_flag && bb != end){ 
        open_predecessors->insert(std::pair<std::string,std::string>(bb->getName().str(),bb->getName().str()));
        return;
    }else if( predecessorcount == 0 && predecessor_flag){ 
        open_predecessors->erase(it_predecessor);
    }
    
    topological_order->emplace_front(bb);
    //std::cerr << "TMP topological: " << bb->getName().str() << std::endl;
    
    //for(auto  successor : abb->get_ABB_sucessors()){
    for (succ_iterator pit = succ_begin(bb), pet = succ_end(bb); pit != pet; ++pit){
        //std::cerr << "TMP successor: " << (*pit)->getName().str() << std::endl;
        if((*pit) == end)continue;
        SCC_topological_sort((*pit) ,  open_predecessors, already_visited ,topological_order,end );
    }
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
        std::cerr << std::endl;
       
        //iterate about the bbs of the function in reversed topological order and store the bbs in vector
        for (scc_iterator<llvm::Function *> I = scc_begin(function->get_llvm_reference()), IE = scc_end(function->get_llvm_reference());I != IE; ++I) {
            // Obtain the vector of BBs in this SCC and print it out.
            const std::vector<BasicBlock *> &SCCBBs = *I;
            std::cerr << std::endl;
            llvm::BasicBlock* first =nullptr;
            std::list<llvm::BasicBlock*> scc_topological_order;
            std::list<llvm::BasicBlock*> self_topological_order;
            
            for (std::vector<BasicBlock *>::const_iterator BBI = SCCBBs.begin(), BBIE = SCCBBs.end(); BBI != BBIE; ++BBI) {
                scc_topological_order.emplace_back(*BBI);
                first = *BBI;
                //std::cerr << "Iterator" << (*BBI)->getName().str() << std::endl;
            }
            
            bool success = false;
            if(scc_topological_order.size()>1){
                success = true;
                std::map<std::string,std::string> already_visited;
                std::map<std::string,std::string> open_predecessors;
                
            
                SCCtopological_sort(first, &open_predecessors , &already_visited, &self_topological_order, first);
                
                if(self_topological_order.size() == scc_topological_order.size()){
                    for(auto topological_element: self_topological_order){
                        bool match = false;
                        for(auto scc_element: scc_topological_order){
                            if(scc_element == topological_element){
                                match = true;
                                break;
                            }
                        }
                        if(match == false){
                            success = false;
                            break;
                        }
                        
                    }
                }else{
                    success = false;
                }
            }
            if(success){
                for(auto topological_element: self_topological_order){
                    //std::cerr << "selftopolical" << topological_element->getName().str() << std::endl;
                    tmp_topological_order.emplace_back(topological_element);
                }
            }else{
                for(auto topological_element: scc_topological_order){
                    //std::cerr << "scctopolical" << topological_element->getName().str() << std::endl;
                    tmp_topological_order.emplace_back(topological_element);
                }
            }
            
            
            //if(success)std::cerr << "HEEEEEEEEEEEEEEEEEEEYA" << std::endl;
            //if(success) tmp_topological_order.insert(tmp_topological_order.begin(),self_topological_order.begin(),self_topological_order.end());
            //else tmp_topological_order.insert(tmp_topological_order.begin(),scc_topological_order.begin(),scc_topological_order.end());
        }
        
        std::vector<llvm::BasicBlock*> topological_order;
         
        
        //bbs are sorted in inversed topological order, so reverse them
        //for(auto element : tmp_topological_order){
        for (auto it = tmp_topological_order.rbegin(); it != tmp_topological_order.rend(); it++){
             topological_order.emplace_back(*it);
             std::cerr << "topolical" << (*it)->getName().str() << std::endl;
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
            for(auto tmp : sorted_abb_list){
                std::cerr << tmp->get_name() << std::endl;
            }
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
                for(auto tmp : sorted_abb_list){
                    std::cerr << tmp->get_name() << std::endl;
                }
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



/**
* @brief checks recursive if the basicblock is in a loop
* @param bb basicblock which is analyzed
* @param already_visited call instructions which were already visited
* @return if bb is inside a loop false, else true
**/

bool validate_loop(OS::shared_abb abb, std::map<size_t, size_t>* already_visited){
    
	//generate hash code of basic block name
	size_t seed = abb->get_seed();

    //check if seed in map of already visited basic blocks exist,
    if ( already_visited->find(seed) != already_visited->end() ) {
        //found -> recursion exists
        std::cerr << "recursive loop detected " << abb->get_parent_function()->get_name()<<   std::endl;
        
        return false;
    } 
    
    already_visited->insert(std::make_pair(seed, seed));
    
	//set basic block hash value in already visited list

	bool success = true;
    
	//search loop of function
	
    
    
    
    auto LIB = abb->get_parent_function()->get_loop_info_base();
    
    llvm::Instruction* instr = nullptr;
    
    
    if (abb->get_call_type() == sys_call)instr = abb->get_syscall_instruction_reference();
    else  if (abb->get_call_type() == func_call)instr = abb->get_call_instruction_reference();
    else{
        std::cerr << "ERROR: syscall abb type " << std::endl;
        abort();
    }
    if(instr == nullptr){
     std::cerr << "ERROR: no syscall instruction reference " << std::endl;
     abort();
        
    }
    //std::cerr << print_tmp(instr->getParent()) << std::endl;
    
	llvm::Loop * L = LIB->getLoopFor(instr->getParent());
    
//     FunctionPassManager FPM;
//     FPM.addPass(ScalarEvolutionAnalysis());
// q
//     FunctionAnalysisManager FAM;
// 
//     PassBuilder PB;
//     PB.registerFunctionAnalyses(FAM);
// 
//     FPM.run(bb->getParent(), FAM);
	//check if basic block is in loop
	//TODO get loop count
    
    //std::cerr << "Loop analyse" << std::endl;
	if(L != nullptr){
        /*
		AssumptionCache AC = AssumptionCache(*bb->getParent());
		Triple ModuleTriple(llvm::sys::getDefaultTargetTriple());
		TargetLibraryInfoImpl TLII(ModuleTriple);
		
		TLII.disableAllFunctions();
		TargetLibraryInfoWrapperPass TLI = TargetLibraryInfoWrapperPass(TLII);
		LoopInfo LI = LoopInfo(DT);
		LI.analyze (DT);
		ScalarEvolution SE = ScalarEvolution(*bb->getParent(), TLI.getTLI(),AC, DT, LI);
		//SE.verify();
		SmallVector<BasicBlock *,10> blocks;
		if(L->getExitingBlock()==nullptr){
			//std::cout << "loop has more or no exiting blocks" << std::endl;
		}
		else{
			//std::cout << "loop has one exiting block" << std::endl;
			//const SCEVConstant *ExitCount = dyn_cast<SCEVConstant>(getExitCount(L, ExitingBlock));
			//std::cout << "finaler Test" << SE.getSmallConstantTripCount (L, L->getExitingBlock()) << std::endl;
		}
		//auto  blocks;
		//llvm::SmallVectorImpl< llvm::BasicBlock *> blocks = llvm::SmallVectorImpl< llvm::BasicBlock *> ();
		//L->getUniqueExitBlocks(blocks);
		*/
        
        //std::cerr << "Loop detected" << std::endl;
        //std::cerr << "direct loop detected " << abb->get_parent_function()->get_name()<<   std::endl;
		success = false;
        
	}else{
        //std::cerr << "Loop not detected" << std::endl;
        //abb is not direct in loop
        auto function = abb->get_parent_function();
        
        //iterate about the abbs, which calls the function, that contains the abb, and execute recursive analysis 
        for(auto edge : function->get_ingoing_edges()){
			if(edge->get_start_vertex()->get_type() == typeid(OS::ABB).hash_code()){
				//analyse basic block of call instruction 
                auto call_abb = std::dynamic_pointer_cast<OS::ABB> (edge->get_start_vertex());
				success = validate_loop(call_abb ,already_visited);
				if(success == false)break;
			}
		}
	}
	return success;
}

/**
* @brief stores all system informationm which are stored in global llvm values. This global value are generated with defines from the original configuration rtos configuration files with the preprocessor
* @param graph project data structure
**/
void get_predefined_system_information(graph::Graph& graph){
    
    std::hash<std::string> hash_fn;
    std::string rtos_name = "RTOS";
    
    //load the rtos graph instance
    auto rtos_vertex = graph.get_vertex(hash_fn(rtos_name +  typeid(OS::RTOS).name()));
    
    if(rtos_vertex == nullptr){
        std::cerr << "ERROR: RTOS could not load from graph" << std::endl;
        abort();
    }
    auto rtos = std::dynamic_pointer_cast<OS::RTOS> (rtos_vertex);
    
    //iterate about the global llvm values
    auto module = graph.get_llvm_module();
    for(Module::global_iterator gi = module->global_begin(), gend = module->global_end();gi != gend; ++gi){
        
        auto global = &(*gi);
    
        
        //check if name of variable starts with self defined string
        std::string s = global->getName().str();
        std::string delimiter = "FreeRTOS_config";
        
        size_t pos = 0;
        std::string token;
        //load the value from the global variable
        while ((pos = s.find(delimiter)) != std::string::npos) {
            token = s.substr(0, pos);
            //std::cerr << token << std::endl;
            s.erase(0, pos + delimiter.length());
        
            
            //check if variable has intial value
            if(global->hasInitializer()){
                long config_value = -1;
                
                if (ConstantInt * CI = dyn_cast<ConstantInt>(global->getInitializer())) {

                    config_value = CI->getSExtValue();
                }
                
                if(s == "USE_PREEMPTION"){
                    rtos->preemption = config_value;
                }else if(s == "USE_PORT_OPTIMISED_TASK_SELECTION"){
                    //rtos-> = config_value;
                }else if(s == "USE_TICKLESS_IDLE"){
                    //rtos-> = config_value;
                }else if(s == "CPU_CLOCK_HZ"){
                    rtos->cpu_clock_hz = config_value;
                }else if(s == "TICK_RATE_HZ"){
                    rtos->tick_rate_hz = config_value;
                }else if(s == "MAX_PRIORITIES"){
                    //rtos-> = config_value;
                }else if(s == "MINIMAL_STACK_SIZE"){
                    //rtos-> = config_value;
                }else if(s == "MAX_TASK_NAME_LEN"){
                    //rtos-> = config_value;
                }else if(s == "USE_16_BIT_TICKS"){
                    rtos->support_16_bit_ticks = config_value;
                    
                }else if(s == "IDLE_SHOULD_YIELD"){
                    rtos->should_yield = config_value;
                }else if(s == "USE_TASK_NOTIFICATIONS"){
                    rtos->support_task_notification = config_value;
                }else if(s == "USE_MUTEXES"){
                    rtos->support_mutexes = config_value;
                }else if(s == "USE_RECURSIVE_MUTEXES"){
                    //rtos-> = config_value;
                }else if(s == "USE_COUNTING_SEMAPHORES"){
                    rtos->support_counting_semaphores = config_value;
                }else if(s == "USE_ALTERNATIVE_API"){
                    //rtos-> = config_value;
                }else if(s == "QUEUE_REGISTRY_SIZE"){
                    //rtos-> = config_value;
                }else if(s == "USE_QUEUE_SETS"){
                    rtos->support_queue_sets = config_value;
                }else if(s == "USE_TIME_SLICING"){
                    rtos->time_slicing = config_value;
                }else if(s == "USE_NEWLIB_REENTRANT"){
                    //rtos-> = config_value;
                }else if(s == "ENABLE_BACKWARD_COMPATIBILITY"){
                    //rtos-> = config_value;
                }else if(s == "NUM_THREAD_LOCAL_STORAGE_POINTERS"){
                    //rtos-> = config_value;
                }else if(s == "SUPPORT_STATIC_ALLOCATION"){
                    rtos->support_static_allocation = config_value;
                }else if(s == "SUPPORT_DYNAMIC_ALLOCATION"){
                    rtos->support_dynamic_allocation = config_value;
                }else if(s == "TOTAL_HEAP_SIZE"){
                    rtos->total_heap_size = config_value;
                }else if(s == "APPLICATION_ALLOCATED_HEAP"){
                    rtos->heap_type = config_value;
                }else if(s == "USE_IDLE_HOOK"){
                    rtos->idle_hook = config_value;
                }else if(s == "USE_TICK_HOOK"){
                    rtos->tick_hook = config_value;
                }else if(s == "CHECK_FOR_STACK_OVERFLOW"){
                    //rtos-> = config_value;
                }else if(s == "USE_MALLOC_FAILED_HOOK"){
                    rtos->malloc_failed_hook = config_value;
                }else if(s == "USE_DAEMON_TASK_STARTUP_HOOK"){
                    rtos->daemon_task_startup_hook = config_value;
                }else if(s == "GENERATE_RUN_TIME_STATS"){
                    //rtos-> = config_value;
                }else if(s == "USE_TRACE_FACILITY"){
                    //rtos-> = config_value;
                }else if(s == "USE_STATS_FORMATTING_FUNCTIONS"){
                    //rtos-> = config_value;
                }else if(s == "USE_CO_ROUTINES"){
                    rtos->support_coroutines = config_value;
                }else if(s == "MAX_CO_ROUTINE_PRIORITIES"){
                    //rtos-> = config_value;
                }else if(s == "USE_TIMERS"){
                    //rtos-> = config_value;
                }else if(s == "TIMER_TASK_PRIORITY"){
                    //rtos-> = config_value;
                }else if(s == "TIMER_QUEUE_LENGTH"){
                    //rtos-> = config_value;
                }else if(s == "TIMER_TASK_STACK_DEPTH"){
                    //rtos-> = config_value;
                }else if(s == "KERNEL_INTERRUPT_PRIORITY"){
                    //rtos-> = config_value;
                }else if(s == "MAX_SYSCALL_INTERRUPT_PRIORITY"){
                    //rtos-> = config_value;
                }else if(s == "MAX_API_CALL_INTERRUPT_PRIORITY"){
                    
                }
            }
            break;
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
        		
		std::hash<std::string> hash_fn;
		
		//get function with name main from graph
		std::string start_function_name = "main";  
		
		graph::shared_vertex main_vertex = graph.get_vertex( hash_fn(start_function_name +  typeid(OS::Function).name())); 
		
        OS::shared_function main_function;
        
		//check if graph contains main function
		if(main_vertex != nullptr){

			main_function = std::dynamic_pointer_cast<OS::Function>(main_vertex);
            std::map<std::size_t,std::size_t> already_visited;
            std::map<std::size_t,std::size_t> call_tree;
            
			before_scheduler_instructions(graph, main_function  ,already_visited,&call_tree,before);
      
        }else{
            std::cerr << "no main function in programm" << std::endl;
            abort();
        }
        
        std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::ABB).hash_code());
        
        //iterate about abbs
        for (auto &vertex : vertex_list) {
        
            //cast vertex to abb 
            auto abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
            
            //check if abb is a syscall abb
            if(abb->get_call_type() == sys_call){
                
                //check if syscall ab is in direct, indirect or recursion loop
                std::map<size_t, size_t> already_visited;
                               
                if(!validate_loop(abb, &already_visited)){
                    //set loop information
                    abb->set_loop_information(true);
                }
            }
        }
        //get confing information
        get_predefined_system_information(graph);
        
	}

	
	std::vector<std::string> IntermediateAnalysisStep::get_dependencies() {
        
		return {"ABB_MergeStep"};

	}
}
//RAII
