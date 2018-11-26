// vim: set noet ts=4 sw=4:



#include "llvm/Analysis/AssumptionCache.h"
#include "FreeRTOSinstances.h"
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
#include "llvm/ADT/APFloat.h"
using namespace llvm;

enum scheduler_return_value { not_found , found , uncertain };


//print the argument
void test_debug_argument(std::any value,llvm::Type *type){
	
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



std::vector<llvm::Instruction*> get_start_scheduler_instruction(OS::shared_function function){
	std::vector<llvm::Instruction*> instruction_vector;
	for(auto & abb : function->get_atomic_basic_blocks()){
		if(abb->get_call_type() != no_call){
			//std::cout << abb->get_call_name() << std::endl; 
			for(auto& call_name : abb->get_call_names() ){
				if(call_name == "vTaskStartScheduler")instruction_vector.push_back(abb->get_syscall_instruction_reference());
			}
		}
	}
	return instruction_vector;
}

//return false if instruction is  before scheduler start or and the scheduler start does  dominate the instruction
bool validate_start_scheduler_instruction_relations(std::vector<llvm::Instruction*> *start_scheduler_func_calls, llvm::Instruction* instruction,llvm::DominatorTree *dominator_tree){
	bool success = false;
	for(auto * start_scheduler:*start_scheduler_func_calls){
		if((dominator_tree->dominates(start_scheduler,instruction))){
			success = true;
			break;
		}
	}
	return success;
}


int bfs_level(std::vector<std::tuple<int, llvm::BasicBlock*>>*bfs_reference , llvm::Instruction*  instruction ) {
	for(auto& tuple :*bfs_reference){
		llvm::BasicBlock* bb = std::get<llvm::BasicBlock*>(tuple);
		if(bb->getName() == instruction->getParent()->getName()){
			return std::get<int>(tuple);;
		}
	}
	return -1;
}



//function to create all abbs in the graph
//TODO adapt branches backwards if they merge with a branch with lower level
std::vector<std::tuple<int, llvm::BasicBlock*>> generate_bfs(llvm::Function*  function ) {
	
	std::hash<std::string> hash_fn;
	

	std::vector<std::tuple<int,llvm::BasicBlock*>> bfs_reference;
    //get first basic block of the function

    //create ABB
	llvm::BasicBlock& entry_bb = function->getEntryBlock();
	
    //store coresponding basic block in ABB
    //queue for new created ABBs
    std::queue<std::tuple<int, llvm::BasicBlock*>> queue; 
	
	auto tmp = std::make_tuple (0,&entry_bb);
	
	
	bfs_reference.push_back(tmp);
    queue.push(tmp);

    //queue with information, which abbs were already analyzed
    std::vector<size_t> visited_bbs;

    //iterate about the ABB queue
	

    while(!queue.empty()) {

		//get first element of the queue
		auto tuple = queue.front();
		queue.pop();
		auto old_bb = std::get<llvm::BasicBlock*>(tuple);
		auto old_bb_level = std::get<int>(tuple);
        queue.front();

		//iterate about the successors of the abb
		for (auto it = succ_begin(old_bb); it != succ_end(old_bb); ++it){

			//get sucessor basicblock reference
			llvm::BasicBlock *succ = *it;
			
			bool visited =false;
			
			size_t succ_seed =  hash_fn(succ->getName().str());
			
			for(auto seed : visited_bbs){
				if(seed ==  succ_seed)visited = true;
				
			}
			
			//check if the successor abb is already stored in the list				
			if(!visited) {
				auto tmp = std::make_tuple (old_bb_level+1,succ);
				//update the lists
				queue.push(tmp);
				bfs_reference.push_back(tmp);
				visited_bbs.push_back(succ_seed);
            }
        }
    }
    return bfs_reference;
}


bool is_reachable(std::vector<llvm::Instruction*> *start_scheduler_func_calls, llvm::BasicBlock *bb, std::vector<size_t> *already_visited){
	
	std::hash<std::string> hash_fn;
	size_t hash_value = hash_fn(bb->getName().str());
	//std::cout << "callname" << call_name << std::endl;
	//search hash value in list of already visited basic blocks
	for(auto hash : *already_visited){
		if(hash_value == hash){
			//basic block already visited
			return false;
		}
	}
	//insert bb in alread visited
	already_visited->emplace_back(hash_value);
	
	for (BasicBlock::iterator i = bb->begin(), e = bb->end(); i != e; ++i) {
		for(llvm::Instruction* start_scheduler : *start_scheduler_func_calls){
			llvm::Instruction* instr = &*i;
			if(instr == start_scheduler)return true;
		}
	}

	for (auto it = pred_begin(bb), et = pred_end(bb); it != et; ++it){
		if(is_reachable(start_scheduler_func_calls, *it, already_visited))return true;
	}
	return false;
}


bool verify_instruction_order(llvm::Instruction* expected_front, llvm::Instruction* expected_back,std::vector<std::tuple<int, llvm::BasicBlock*>>*bfs_reference){
	
	if(bfs_level( bfs_reference ,expected_front) <  bfs_level( bfs_reference ,expected_back) )return true;
	else return false;
}
//TODO case: where in func call uncertain start scheduler exists
//TODO BFS instead of DFS for basic block order
scheduler_return_value before_scheduler_instructions(graph::Graph& graph,std::list<size_t> *instruction_list, std::vector<size_t> *uncertain_instruction_list,OS::shared_function function,std::vector<std::size_t> *already_visited){

	
	scheduler_return_value success = not_found;
	
	//check if valid function pointer was committed
	if(function == nullptr) return not_found;
	
	std::vector<llvm::Instruction*> start_scheduler_func_calls;
	std::vector<llvm::Instruction*> uncertain_start_scheduler_func_calls;
	std::vector<llvm::Instruction*> return_instructions;
		
	std::hash<std::string> hash_fn;

	size_t hash_value = hash_fn(function->get_name());
	
	//search hash value in list of already visited basic blocks
	for(auto hash : *already_visited){
		if(hash_value == hash){
			//function already visited
			return not_found;
		}
	}
	//set function as already visited
	already_visited->emplace_back(hash_value);
	
	//get all start scheduler instructions of the function
	start_scheduler_func_calls = get_start_scheduler_instruction(function);
	
	//generate bfs order of basicblocks //TODO
	std::vector<std::tuple<int, llvm::BasicBlock*>> bfs = generate_bfs(function->get_llvm_reference());
	
	//generate dominator tree
	DominatorTree dominator_tree = DominatorTree();
	dominator_tree.recalculate(*(function->get_llvm_reference()));
	dominator_tree.updateDFSNumbers();
	
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	//dominator_tree.print(rso);
	std::cout<< "dominator tree "<< std::endl  <<  rso.str() << std::endl;
	
	//check if scheduler start instruction was found in function
	if(start_scheduler_func_calls.size() == 0){
		success = not_found;
	}else{
		
	
		for(auto &abb : function->get_atomic_basic_blocks()){
			for(llvm::BasicBlock* bb : abb->get_BasicBlocks()){
				for(auto &instr:*bb){
					if(isa<ReturnInst>(instr)){
						std::cerr << "return instrcution found" << std::endl;
						return_instructions.emplace_back(&instr);
					}
				}
			}
		}
		
		for(auto& instruction:start_scheduler_func_calls){
			if(dominator_tree.dominates(  &function->get_llvm_reference()->getEntryBlock(),instruction->getParent()))success= found;
		}
		//if(success == not_found)success = uncertain;
	}
	
	//iterate about the basic blocks of the abb
	for(auto &abb : function->get_atomic_basic_blocks()){
			
		for(llvm::BasicBlock* bb : abb->get_BasicBlocks()){
			
			for(auto &instruction:*bb){
				if(abb->get_call_type()== func_call){
					scheduler_return_value result;
					for(auto *instr :abb->get_call_instruction_references()){
						if(llvm::CallInst* call_instruction = dyn_cast<CallInst>(instr)){
							llvm::Function* called_function = call_instruction->getCalledFunction();
							if(called_function != nullptr){
								graph::shared_vertex target_vertex = graph.get_vertex( hash_fn(called_function->getName().str() +  typeid(OS::Function).name())); 
								auto target_function = std::dynamic_pointer_cast<OS::Function>(target_vertex);
								result = before_scheduler_instructions(graph,instruction_list,uncertain_instruction_list,target_function  ,already_visited);
								if(result == found){
									start_scheduler_func_calls.emplace_back(call_instruction);
									success = found;
								}
								else{
									if (result == uncertain) uncertain_start_scheduler_func_calls.emplace_back(call_instruction);
							
								}
							}
						}else if(llvm::InvokeInst* call_instruction = dyn_cast<InvokeInst>(instr)){
							llvm::Function* called_function = call_instruction->getCalledFunction();
							if(called_function != nullptr){
								graph::shared_vertex target_vertex = graph.get_vertex( hash_fn(called_function->getName().str() +  typeid(OS::Function).name())); 
								auto target_function = std::dynamic_pointer_cast<OS::Function>(target_vertex);
								result = before_scheduler_instructions(graph,instruction_list,uncertain_instruction_list,target_function  ,already_visited);
								if(result == found){
									start_scheduler_func_calls.emplace_back(call_instruction);
									success = found;
								}
								else{
									if (result == uncertain) uncertain_start_scheduler_func_calls.emplace_back(call_instruction);
								}
							}
						}
					}
				}
			}
		}
	}
		
		
	if(success !=not_found){
		for(auto &abb : function->get_atomic_basic_blocks()){
			for(llvm::BasicBlock* bb : abb->get_BasicBlocks()){
				if(abb->get_call_type()== sys_call){
					
					for(auto &instruction:*bb){
						//check if the abb contains a syscall
						//continue if, no start scheduler syscall is in function, the instruction is before all the start scheduler instruction and the scheduler instrcutions dont dominate the instrcution 
						if(validate_start_scheduler_instruction_relations(&start_scheduler_func_calls,&instruction, &dominator_tree )){
							//if instruction is a syscall set the instruction in the before scheduler start list
							instruction_list->emplace_back(hash_fn(bb->getName().str()));
							
						}else{
							//check if the instruction is reachable from a start scheduler instruction 
							std::vector<size_t> already_visited_abbs;
							if(is_reachable(&start_scheduler_func_calls,instruction.getParent(),&already_visited_abbs)){
								uncertain_instruction_list->emplace_back();
							}
						}
					}
				}
			}
		}
		//check return value is that a start scheduler call is certainly or uncertainly called 
		bool uncertain_flag = false;
		bool found_flag = true;
		for(auto instr : return_instructions){
			if(validate_start_scheduler_instruction_relations(&start_scheduler_func_calls,instr, &dominator_tree ))uncertain_flag = true;
			else found_flag = false;
		}
		
		if(found_flag)success = found;
		else{
			if(uncertain_flag)success = uncertain;
		}
	}
	
	return success;
	
}



//function to extract the handler name of the instance
std::string get_handler_name(llvm::Instruction * instruction, unsigned int argument_index){
	//llvm::Instruction * next_instruction = instruction->getNextNonDebugInstruction();
	
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
			
			
			//std::cout << operand->getName().str() << std::endl;
			handler_name = operand->getName().str();
		}
	}
	return handler_name;
}

/*
bool verify_arguments(std::vector<size_t> &forced_arguments_types ,std::vector<std::tuple<std::any,llvm::Type*>>& arguments){
	

	//iterate about the demanded arguments
	unsigned int counter = 0;
	bool success = true;
	
	if(forced_arguments_types.size() != arguments.size()){
		success = false;
		std::cout << "exptected argument size " << forced_arguments_types.size()  << " and real argument size " << arguments.size()  << "  are not equal" << std::endl;
	}else{
		std::cout << "exptected argument size " << forced_arguments_types.size()  << " and real argument size " << arguments.size()  << "  are not equal" << std::endl;
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
	else{
		std::cout << forced_arguments_types.size()<< " " << arguments.size() << std::endl;
		for (auto & forced_argument_type: forced_arguments_types){
			std::size_t argument_type = arguments.at(counter);
			
			if(argument_type != forced_argument_type){
				std::cerr << "error: " << argument_type << "counter: " << counter << std::endl;
				success = false;
				break;
			}
			counter++;
		}
	}
	//std::cerr << success << std::endl;
	return success;
}


*/




bool validate_loop(llvm::BasicBlock *bb, std::vector<std::size_t>* already_visited){
	//generate hash code of basic block name
	std::hash<std::string> hash_fn;
	size_t hash_value = hash_fn(bb->getName().str());
	//std::cout << "callname" << call_name << std::endl;
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

	llvm::LoopInfoBase<llvm::BasicBlock, llvm::Loop>* LIB = new llvm::LoopInfoBase<llvm::BasicBlock, llvm::Loop>();
	LIB->releaseMemory();
	LIB->analyze(DT);
	llvm::Loop * L = LIB->getLoopFor(bb);
	
	

	
	//check if basic block is in loop
	//TODO get loop count
	if(L != nullptr){
		AssumptionCache AC = AssumptionCache(*bb->getParent());
	
		Triple ModuleTriple(llvm::sys::getDefaultTargetTriple());
		TargetLibraryInfoImpl TLII(ModuleTriple);
		//TODO check behavoiur
		TLII.disableAllFunctions();
		TargetLibraryInfoWrapperPass TLI = TargetLibraryInfoWrapperPass(TLII);
		
		//TODO getExitBlock - If getExitBlocks would return exactly one block, return that block.
		
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
		L->getUniqueExitBlocks(blocks);
		
		//std::cout << blocks.size() << std::endl;
		for(auto & exit_block: blocks){
			/*
			std::cout << "test" << std::endl;
				
			std::string type_str;
			llvm::raw_string_ostream rso(type_str);
			exit_block->print(rso);
			std::cout <<  rso.str() << std::endl;
			*/
			
		}
		//std::cout << "trip count " <<  SE.getSmallConstantTripCount(L) << std::endl; 
		{
			
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		L->print(rso);
		//std::cout <<  rso.str() << std::endl;
	
		}
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
				success = validate_loop(instruction->getParent() ,already_visited);
				if(success == false)break;
			}
		}

	}
	//free dynamic memory
	delete LIB;
	return success;
}

//xTaskCreate
bool create_task(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start){
	
	bool success = true;
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>argument_list;
	
	for(auto & tuple : *(abb->get_syscall_arguments())){
		argument_list.emplace_back(tuple);
	}

	//load the arguments
	std::tuple<std::any,llvm::Type*> tuple = argument_list.at(0);
	auto argument = std::get<std::any>(tuple);
	std::string function_reference_name =  std::any_cast<std::string>(argument);
	
	tuple = argument_list.at(1);
	argument = std::get<std::any>(tuple);
	std::string task_name =  std::any_cast<std::string>(argument);
	
	tuple = argument_list.at(2);
	argument = std::get<std::any>(tuple);
	unsigned long stacksize =  std::any_cast<long>(argument);
	
	tuple = argument_list.at(3);
	argument = std::get<std::any>(tuple);
	std::string task_argument =  std::any_cast<std::string>(argument);
	
	tuple = argument_list.at(4);
	argument = std::get<std::any>(tuple);
	unsigned long priority =  std::any_cast<long>(argument);
	
	tuple = argument_list.at(5);
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

	return success;
}




//..Semaphore...Create
//{ binary, counting, mutex, recursive_mutex }semaphore_type;
bool create_semaphore(graph::Graph& graph,OS::shared_abb abb,semaphore_type type , bool before_scheduler_start){
	
	bool success = true;
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
		
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>argument_list;
	
	for(auto & tuple : *abb->get_syscall_arguments()){
		argument_list.emplace_back(tuple);
	}
	
	std::string handler_name = get_handler_name(instruction, 1);
	
	auto semaphore = std::make_shared<OS::Semaphore>(&graph,handler_name);
	semaphore->set_semaphore_type(type);
	semaphore->set_handler_name(handler_name);
	semaphore->set_start_scheduler_creation_flag(before_scheduler_start);
	
	
	//std::cout << "semaphore handler name: " <<  handler_name << std::endl;
	switch(type){
		
		case binary:{
		
			std::cout << "binary semaphore successfully created"<< std::endl;
			break;
		}
		
		case counting:{
			
			//load the arguments
			std::tuple<std::any,llvm::Type*> tuple  = argument_list.at(1);
			auto argument = std::get<std::any>(tuple);
			unsigned long initial_count =  std::any_cast<long>(argument);
			
			tuple  = argument_list.at(0);
			argument = std::get<std::any>(tuple);
			unsigned long max_count =  std::any_cast<long>(argument);
			

			semaphore->set_initial_count(initial_count);
			semaphore->set_max_count(max_count);

			std::cout << "counting semaphore successfully created"<< std::endl;
			
			break;
		}
		
		
		case mutex:{
			
			
			//load the arguments
			std::tuple<std::any,llvm::Type*> tuple  = argument_list.at(0);
			auto argument = std::get<std::any>(tuple);
			unsigned long mutex_type =  std::any_cast<long>(argument);
			
			//set the mutex type (mutex, recursive mutex)
			type = (semaphore_type) mutex_type;
			
			semaphore->set_semaphore_type(type);
			if(type == mutex)std::cout << "mutex successfully created"<< std::endl;
			if(type == recursive_mutex)std::cout << "recursive mutex successfully created"<< std::endl;

			break;
		
		}
		default:{
				
			success = false;
			std::cout << "wrong semaphore type" << std::endl;
			break;
		}
	}
	
	if(success)graph.set_vertex(semaphore);
	
	return success;
}

//xQueueCreate
bool create_queue(graph::Graph& graph, OS::shared_abb abb ,bool before_scheduler_start){
	
	bool success = true;
	
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>argument_list;
	
	for(auto & tuple : *abb->get_syscall_arguments()){
		argument_list.emplace_back(tuple);
	}
		
	//load the arguments
	std::tuple<std::any,llvm::Type*> tuple  = argument_list.at(0);
	auto argument = std::get<std::any>(tuple);
	
	long queue_length =  std::any_cast<long>(argument);
	
	tuple  = argument_list.at(1);
	argument = std::get<std::any>(tuple);
	long item_size =  std::any_cast<long>(argument);

	tuple  = argument_list.at(2);
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
		success = create_semaphore(graph,abb,binary, before_scheduler_start);
	}

	return success;
}


//xQueueCreate
bool create_event_group(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start){
	
	bool success = true;
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>argument_list;
	
	for(auto & tuple : *abb->get_syscall_arguments()){
		argument_list.emplace_back(tuple);
	}
		
	//create queue and set properties 
	std::string handler_name = get_handler_name(instruction, 1);
	auto event_group = std::make_shared<OS::EventGroup>(&graph,handler_name);
		
	event_group->set_handler_name(handler_name);
	event_group->set_start_scheduler_creation_flag(before_scheduler_start);
	graph.set_vertex(event_group);
	std::cout << "event group successfully created"<< std::endl;
		
	
	return success;
}




//xQueueSet
bool create_queue_set(graph::Graph& graph, OS::shared_abb abb,  bool before_scheduler_start){
	
	bool success = true;

	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	
	
	//create reference list for all arguments types of the task creation syscall
	std::vector<std::tuple<std::any,llvm::Type*>>argument_list;
	
	for(auto & tuple : *abb->get_syscall_arguments()){
		argument_list.emplace_back(tuple);
	}
		
	//load the arguments
	std::tuple<std::any,llvm::Type*> tuple  = argument_list.at(0);
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
	
	return success;
}

//xTimerCreate
bool create_timer(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start){
	
	bool success = true;
	
	std::vector<std::tuple<std::any,llvm::Type*>>argument_list;
	
	for(auto & tuple : *abb->get_syscall_arguments()){
		argument_list.emplace_back(tuple);
	}
	//load the arguments
	std::tuple<std::any,llvm::Type*> tuple  = argument_list.at(0);
	auto argument = std::get<std::any>(tuple);
	std::string timer_name =  std::any_cast<std::string>(argument);
	
	tuple  = argument_list.at(1);
	argument = std::get<std::any>(tuple);
	long timer_periode =  std::any_cast<long>(argument);

	tuple  = argument_list.at(2);
	argument = std::get<std::any>(tuple);
	long timer_autoreload =  std::any_cast<long>(argument);
	
	tuple  = argument_list.at(3);
	argument = std::get<std::any>(tuple);
	std::string timer_id =  std::any_cast<std::string>(argument);
	
	tuple  = argument_list.at(4);
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
	
	return success;
}


//xTimerCreate
bool create_buffer(graph::Graph& graph,OS::shared_abb abb, bool before_scheduler_start){
	
	bool success = true;
	
	llvm::Instruction* instruction = abb->get_syscall_instruction_reference();
	//create reference list for all arguments types of the task creation syscall
	

	//get the typeid hashcode of the expected arguments
	std::vector<std::tuple<std::any,llvm::Type*>>argument_list;
	
	for(auto & tuple : *abb->get_syscall_arguments()){
		argument_list.emplace_back(tuple);
	}
			
	//load the arguments
	std::tuple<std::any,llvm::Type*> tuple  = argument_list.at(2);
	auto argument = std::get<std::any>(tuple);
	buffer_type type = (buffer_type) std::any_cast<long>(argument);
	
	//std::cout << "buffer type: "<< std::any_cast<long>(argument)<< std::endl;
	
	tuple  = argument_list.at(1);
	argument = std::get<std::any>(tuple);
	long trigger_level =  std::any_cast<long>(argument);

	tuple  = argument_list.at(0);
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

bool verify_isr_prefix(llvm::Function *function){
	bool success = false;
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	function->print(rso);
	std::stringstream ss(rso.str());
	std::string line;
	int line_ctr = 0;
	while(std::getline(ss,line,'\n') && line_ctr < 3){
		if(line.find("x86_intrcc")!=std::string::npos)success =true;
		line_ctr++;
	}
	return success;
}
	
//detect isrs
bool detect_isrs(graph::Graph& graph){
	std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
	//iterate about the functions
	for (auto &vertex : vertex_list) {
		
		//cast the vertex in function type
		auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
		llvm::Function* llvm_function = function->get_llvm_reference();
		if(verify_isr_prefix(llvm_function)){
			
			auto isr = std::make_shared<OS::ISR>(&graph,function->get_name());
			isr->set_definition_function(function->get_name());
			graph.set_vertex(isr);
		
			std::cout << "ISR detected" <<  function->get_name() << std::endl;
			
		}
		

	}
	

}

//detect interactions of OS abstractions and create the corresponding edges in the graph
bool detect_interaction(graph::Graph& graph){
	
	//get all functions, which are stored in the graph
	std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
	//iterate about the functions
	for (auto &vertex : vertex_list) {
		
		//cast the vertex in function type
		auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
		
		//get the abbs of the function
		std::list<OS::shared_abb> abb_list = function->get_atomic_basic_blocks();
		
		//iterate about the abbs
		for(auto &abb : abb_list){
			
			//check if abb contains a syscall
			if(abb->get_call_type() == sys_call  && abb->get_syscall_type() != create ){
				
				
				bool success = false;
				
				std::list<std::tuple<std::any,llvm::Type*>>* argument_list = abb->get_syscall_arguments();
				std::list<std::size_t>*  target_list = abb->get_call_target_instances();
				//load the handler name
				std::string handler_name = "";
				if(argument_list->size() >0 &&  std::get<std::any>(argument_list->front()).type().hash_code()== typeid(std::string).hash_code()){
					std::tuple<std::any,llvm::Type*> tuple  = (argument_list->front());
					auto argument = std::get<std::any>(tuple);
					handler_name = std::any_cast<std::string>(argument);
				}
				
				//iterate about the possible refereneced abstraction types
				for(auto& target: *target_list){
					
					if(target == typeid(OS::RTOS).hash_code())handler_name = "RTOS";
					//get the vertices of the specific type from the graph
					std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(target);
					
					//iterate about the vertices
					for (auto &vertex : vertex_list) {
					
						//compare the referenced handler name with the handler name of the vertex
						if(vertex->get_handler_name() == handler_name){
							
							//std::cout << handler_name << std::endl;
							//get the vertex abstraction of the function, where the syscall is called
							graph::shared_vertex start_vertex = function;
							if(function->get_definition_vertex() != nullptr)start_vertex = function->get_definition_vertex();
							
							//check if the syscall expect values
							if(abb->get_syscall_type() == receive){
								
								//TODO verifc that abb reference of the edge is a real abb
								//create the edge, which contains the start and target vertex and the arguments
								auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(),start_vertex ,vertex,abb);
								//TODO set arguments ?
								//store the edge in the graph
								graph.set_edge(edge);
								//set the success flag
								success = true;
							
							}else{	//syscall set values
								//TODO verifc that abb reference of the edge is a real abb
								//create the edge, which contains the start and target vertex and the arguments
								auto edge = std::make_shared<graph::Edge>(&graph,abb->get_syscall_name(),vertex ,start_vertex,abb);
								//TODO set arguments ?
								//store the edge in the graph
								graph.set_edge(edge);
								//set the success flag
								success = true;
							}
							break;
						}
					}
					//check if target vertex with corresponding handler name was detected
					if(success){
						std::cout << "edge created " << abb->get_syscall_name() << std::endl;
						//break the loop iteration about the possible syscall target instances
						break;
					}
				}
				if(success == false){
					std::cout << "edge could not created: " << abb->get_syscall_name() << std::endl;
					for(auto & arguments:* abb->get_arguments()){
						for(auto &tuple : arguments){
							test_debug_argument(std::get<std::any>(tuple),std::get<llvm::Type *>(tuple));
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
		
		//std::cout  << graph.print_information();
		//std::cerr << graph.print_information();
		
		std::cout << "Run " << get_name() << std::endl;
			
		std::hash<std::string> hash_fn;

		
		//graph.print_information();
		
		std::list<size_t> before_scheduler;
		std::vector<size_t> uncertain_instruction_list;
		std::vector<std::size_t> already_visited;
		
		//get function with name main from graph
		std::string start_function_name = "main";  
		
		graph::shared_vertex target_vertex = graph.get_vertex( hash_fn(start_function_name +  typeid(OS::Function).name())); 
		
		//check if graph contains main function
		if(target_vertex != nullptr){
			
			auto target_function = std::dynamic_pointer_cast<OS::Function>(target_vertex);
			before_scheduler_instructions(graph,&before_scheduler, &uncertain_instruction_list, target_function  ,&already_visited);
		}else std::cout << "no main function in programm" << std::endl;
	
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
				if( abb->get_call_type()== sys_call){
					
					
					std::vector<std::size_t> already_visited;

					
					//validate if sysccall is in loop
					if(validate_loop(llvm_abbs.front(),&already_visited)){
						
						bool before_scheduler_start = false;
						
						//check if instruction is before start scheduler instruction
						for(auto & hash_value : before_scheduler){
							//std::cout << hash_value << std::endl;
							for(auto &bb :abb->get_BasicBlocks()){
								
								if(hash_value == hash_fn(bb->getName().str())){
									before_scheduler_start = true;
									break;
								}
							}
						}
						
						//if(before_scheduler_start)std::cout << "before_scheduler_start " <<  callname		<< std::endl;
						//else std::cout << "!!!!!!!!!!!!!!!1after_scheduler_start " <<  	callname	<< std::endl;
						//check if abb syscall is creation syscall
						if(abb->get_syscall_type() == create){
							
							//check which target should be generated
							if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Task).hash_code())){
								//std::cout << "TASKCREATE" << name << ":" << tmp << std::endl;
								if(!create_task(graph,abb,before_scheduler_start))std::cout << "Task could not created" << std::endl;
							}
								
							if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Queue).hash_code())){
								if(!create_queue( graph,abb,before_scheduler_start))std::cout << "Queue could not created" << std::endl;

							}
							if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Semaphore).hash_code())){
								//TODO set semaphore
								semaphore_type type;
								for(auto& callname: abb->get_call_names()){
									if(callname =="xQueueCreateMutex")type = mutex;
									if(callname =="xSemaphoreCreateRecursiveMutex")type = recursive_mutex;
									if(callname =="xQueueCreateCountingSemaphore")type = counting;
								}
								if(!create_semaphore(graph, abb, type, before_scheduler_start))std::cout << "CountingSemaphore/Mutex could not created" << std::endl;
								
							}						
							if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Timer).hash_code())){
								if(!create_timer( graph,abb,before_scheduler_start))std::cout << "Timer could not created" << std::endl;
							}

							if(list_contains_element(abb->get_call_target_instances(),typeid(OS::EventGroup).hash_code())){
								//std::cout << callname << std::endl;
								if(!create_event_group(graph, abb,before_scheduler_start))std::cout << "Event Group could not created" << std::endl;
							}
							
							if(list_contains_element(abb->get_call_target_instances(),typeid(OS::Buffer).hash_code())){
								//std::cout << callname << std::endl;
								if(!create_buffer(graph, abb,before_scheduler_start))std::cout << "Buffer could not created" << std::endl;
							}
							if(list_contains_element(abb->get_call_target_instances(),typeid(OS::QueueSet).hash_code())){
								//std::cout << callname << std::endl;
								if(!create_queue_set(graph, abb,before_scheduler_start))std::cout << "Queue Set could not created" << std::endl;
							}
						}
					}
					else{
						/*
						std::cout << "element is in loop" << std::endl;
						std::string type_str;
						llvm::raw_string_ostream rso(type_str);
						llvm_abbs.front()->print(rso);
						std::cout<< rso.str() ;
						*/
					}
				}
			}
			
		}
		
		
		detect_isrs(graph);
		detect_interaction(graph);
		
		
		
	}
	
	std::vector<std::string> FreeRTOSInstancesStep::get_dependencies() {
		return {"ABB_MergeStep"};
	}
}
