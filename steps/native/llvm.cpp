// vim: set noet ts=4 sw=4:



//TODO extract missing arguments


#include "llvm.h"

#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <cassert>
#include <stdexcept>
#include "llvm/Analysis/AssumptionCache.h"
#include "FreeRTOSinstances.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Pass.h"
#include <string>

using namespace llvm;

#define PRINT_NAME(x) std::cout << #x << " - " << typeid(x).name() << '\n'


static llvm::LLVMContext context;


bool dump_argument(std::stringstream &debug_out,std::any &out,llvm::Type *& type, Value *arg,llvm::Instruction* call_reference);




std::string print_argument(llvm::Value* argument){
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() +  "\"\n";
	
}



//check if instruction calls a llvm specific function
static bool isCallToLLVMIntrinsic(Instruction * inst) {
    if (CallInst* callInst = dyn_cast<CallInst>(inst)) {
        Function * func = callInst->getCalledFunction();
        if (func && func->getName().startswith("llvm.")) {
            return true;
        }
    }
    return false;
}

 //check if instruction a is before instruction b 
 bool instruction_before( Instruction *InstA,  Instruction *InstB,DominatorTree *DT) {
	DenseMap< BasicBlock *, std::unique_ptr<OrderedBasicBlock>> OBBMap;
	if (InstA->getParent() == InstB->getParent()){
		std::cout << "debug" << std::endl;
		BasicBlock *IBB = InstA->getParent();
		auto OBB = OBBMap.find(IBB);
		if (OBB == OBBMap.end())OBB = OBBMap.insert({IBB, make_unique<OrderedBasicBlock>(IBB)}).first;
		return OBB->second->dominates(InstA, InstB);
	}
	
	DomTreeNode *DA = DT->getNode(InstA->getParent());

	DomTreeNode *DB = DT->getNode(InstB->getParent());
	
	std::cout << "debug not same parents" <<  DA->getDFSNumIn() << ":" <<  DB->getDFSNumIn() << std::endl;
	return DA->getDFSNumIn() < DB->getDFSNumIn();
 }
 
//check if graph node is already visited
bool visited(size_t seed, std::vector<size_t> *vector){
	bool found = false;
    for (unsigned i=0; i < vector->size(); i++) {
         if(vector->at(i) == seed){
			found = true;
			break;
		}
	}
    return found;
}


//function to load the index of an array
int load_index(Value *arg) {

    int index = 0;
    if (ConstantInt * CI = dyn_cast<ConstantInt>(arg)) {

        index = CI->getSExtValue();
    }//check if argument is a constant floating point
    else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(arg)){

        index = constant_fp->getValueAPF().convertToDouble();
    }//check if argument is a binary operator
    return index;
}



bool check_nullptr(std::any &out, llvm::Type *type,llvm::Value *value,std::stringstream &debug_out ){
	bool load_success = false;
	if(ConstantPointerNull  * constant_data = dyn_cast<ConstantPointerNull>(value)){
		debug_out << "CONSTANTPOINTERNULL";
		std::string tmp = "&$%NULL&$%";
		out = tmp;
		type = constant_data->getType();
		////std::cerr << "[nullptr] type: " <<print_argument(value)  <<'\n';  
		load_success = true;
	}
	return load_success;
}


//dump a cast instruction
bool dump_cast(std::stringstream &debug_out,CastInst *cast,std::any &out, llvm::Type *type, Instruction * call_reference){
	bool cast_success = false;
	StoreInst* store_instruction = nullptr;
	int _count = 0;
	Value * cast_operand = cast->getOperand(0);
	//get control flow information of the function
	llvm::Function & tmp_function = *cast->getFunction();
	DominatorTree dominator_tree = DominatorTree(tmp_function);
	
	bool pointer_flag = true;
	
	if(AllocaInst* alloca_instruction = dyn_cast<AllocaInst>(cast_operand)){
		Value::user_iterator sUse = alloca_instruction->user_begin();
		Value::user_iterator sEnd = alloca_instruction->user_end();
		
		//iterate about the user of the allocation
		for(;sUse != sEnd; ++sUse){
			
			//check if instruction is a store instruction
			if(StoreInst *tmp_instruction = dyn_cast<StoreInst>(*sUse)){
				//check if user is before of the original call
				if(instruction_before(tmp_instruction,call_reference,&dominator_tree)){
					pointer_flag = false;
					//check if the store instruction is before the original call
					if(dominator_tree.dominates(tmp_instruction,call_reference)){
						if(store_instruction == nullptr){
							store_instruction = tmp_instruction;
						}else{
							//check if the tmp_store instruction is behind the store_instruction
							if(instruction_before(store_instruction,tmp_instruction,&dominator_tree))store_instruction = tmp_instruction;
						}
					}else{
						//check if the tmp_instruction is behind the store_instruction
						if(instruction_before(store_instruction, tmp_instruction,&dominator_tree))store_instruction = nullptr;		
					}
				}
				
			}else std::cout << "local variable was set after value" << std::endl;
			//no load between allocation and call reference
		}
		//check if a valid store instruction could be found
		if(store_instruction != nullptr){
			debug_out << "User: " << print_argument(store_instruction);
			Value * tmp = store_instruction->getOperand(0);
			debug_out << "Operand: " << print_argument(tmp);
			cast_success = dump_argument(debug_out,out,type,store_instruction->getOperand(0),call_reference);
			debug_out << print_argument(cast_operand);
		}else{
			if(pointer_flag){
				cast_success = true;
				type = cast->getDestTy();
				
				std::string tmp_string = print_argument(alloca_instruction);
				out = tmp_string.substr(tmp_string.find("%"),tmp_string.find("=")-3); 
			}
		}
	}
	return cast_success;
}







//function to get the global information of variable
bool load_value(std::stringstream &debug_out,std::any &out, llvm::Type*& type,Value *arg,Value *prior_arg,llvm::Instruction *call_reference) {
	
    //debug data
    debug_out << "ENTRYLOAD" << "\n";    

    std::string type_str;
    llvm::raw_string_ostream rso(type_str);

    bool load_success = false;
	
	//check if arg is a null ptr
	if(check_nullptr(out,type,arg,debug_out)){
		
		return true;
	}

     if (GlobalVariable *global_var = dyn_cast<GlobalVariable>(arg)){
		
	
        debug_out << "GLOBALVALUE" << "\n"; 
		debug_out << print_argument(global_var);
		

	
        //check if the global variable has a loadable value             
        if(global_var->hasInitializer()){
			debug_out << "HASINITIALIZER" << "\n";
		
            if(ConstantData  * constant_data = dyn_cast<ConstantData>(global_var->getInitializer())){
				debug_out << "CONSTANTDATA" << "\n";
                if(ConstantDataSequential  * constant_sequential = dyn_cast<ConstantDataSequential>(constant_data)){
					debug_out << "CONSTANTDATASEQUIENTIAL" << "\n";
                    if (ConstantDataArray  * constant_array = dyn_cast<ConstantDataArray>(constant_sequential)){
				debug_out << "CONSTANTDATAARRAY" << "\n";
                        //global variable is a constant array
                        if (constant_array->isCString()){
							out = constant_array->getAsCString().str();
                            load_success = true;
							type = constant_array->getType();
                        } else debug_out << "Keine konstante sequentielle Date geladen" << "\n";
                    }
                }//check if global variable is contant integer
                else if (ConstantInt  * constant_int = dyn_cast<ConstantInt>(constant_data)) {
					debug_out << "CONSTANTDATAINT" << "\n";
                    out = constant_int->getSExtValue();
					type = constant_int->getType();
					
                    load_success = true;
                }//check if global variable is contant floating point
                else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(constant_data)){
					debug_out << "CONSTANTDATAFLOATING" << "\n";
                    out = constant_fp->getValueAPF().convertToDouble(); 
					type = constant_fp->getType();
					

                    load_success = true;
                }//check if global variable is contant null pointer
                else if(ConstantPointerNull  * null_ptr = dyn_cast<ConstantPointerNull>(constant_data)){
					debug_out << "CONSTANTPOINTERNULL" << "\n";
                    //print name of null pointer because there is no other content
                    if(global_var->hasName()){
                        out = global_var->getName().str();
						type = global_var->getType();
						//debug_out << "TEST" << "\n";
                        load_success = true;

						
					}else{
                        debug_out << "Globaler Null Ptr hat keinen Namen" << "\n";
                    }
                }else debug_out << "Constante vom Typ UndefValue/ConstantTokenNone" << "\n";

			//check if global varialbe is a constant expression
            }else if(ConstantExpr  * constant_expr = dyn_cast<ConstantExpr>(global_var->getInitializer())){
				debug_out << "CONSTANTEXPRESSION" << "\n";
                //check if value is from type value 
                if (Value  * tmp_arg = dyn_cast<Value>(constant_expr)){
                    //get the value
                    load_success = dump_argument(debug_out,out,type, tmp_arg,call_reference);
                }
			
            //check if global variable is from type constant aggregate
            }else if(ConstantAggregate  * constant_aggregate = dyn_cast<ConstantAggregate>(global_var->getInitializer())){
                //check if global variable is from type constant array
				debug_out << "CONSTANTAGGREGATE" << "\n";
                if (ConstantArray  * constant_array = dyn_cast<ConstantArray>(constant_aggregate)) {
				
				
                    if(User * user = dyn_cast<User>(prior_arg)){


                        Value * N =user->getOperand(2);
					
					
                        //Value * M =user->getOperand(3);
                        //TODO make laoding of array indizes more generel
                        int index_n =load_index(N);
                        //int index_m =load_index(N);
                        debug_out << "\n" << index_n << "\n";
					
                        //constant_array->getOperand(index_n)->print(rso);
                        Value *aggregate_operand = constant_array->getOperand(index_n);
					
					
                        load_success = dump_argument(debug_out,out,type,aggregate_operand,call_reference);
					
                    }
				
                }//check if global variable is from type constant struct
                else if(ConstantStruct  * constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)){
                    debug_out << "Constant Struct";
                }//check if global variable is from type constant vector
                else if(ConstantVector  * constant_vector = dyn_cast<ConstantVector>(constant_aggregate)){
                debug_out << "Constant Vector";
                }
            }else{
				debug_out << "GLOBALVALUE" << "\n";
				
			}
		
        }else {
            //check if the global variable has a name
            if(global_var->hasName()){
                //save the name
                out  = global_var->getName().str();
				type = global_var->getType();
                load_success = true;
            }else debug_out << "Nicht ladbare globale Variable hat keinen Namen";
        }
	
     }else{

         if(ConstantAggregate  * constant_aggregate = dyn_cast<ConstantAggregate>(arg)){
				debug_out << "CONSTANTAGGREGATE";
                //check if global variable is from type constant array
                if (ConstantArray  * constant_array = dyn_cast<ConstantArray>(constant_aggregate)) {
                    debug_out << "Constant Array";
				
                }//check if global variable is from type constant struct
                else if(ConstantStruct  * constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)){
                    debug_out << "Constant Struct";
				
                    Constant *content = constant_struct->getAggregateElement(0u);
				
                    for(unsigned int i = 1;  content!= nullptr;i++){
					
                        if (ConstantInt * CI = dyn_cast<ConstantInt>(content)) {
                            debug_out << "CONSTANT INT" << "\n";
                            out = CI->getSExtValue();
							type = CI->getType();
                            load_success = true;
                        }//check if argument is a constant floating point
                        else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(content)){
                            debug_out << "CONSTANT FP" << "\n";
                            out = constant_fp->getValueAPF().convertToDouble();
							type = constant_fp->getType();
                            load_success = true;
                        }
                        content = constant_struct->getAggregateElement(i);
                    }
				
                }//check if global variable is from type constant vector
                else if(ConstantVector  * constant_vector = dyn_cast<ConstantVector>(constant_aggregate)){
					debug_out << "Constant Vector";
                }
         }
     }
	
	
    debug_out << "EXITLOAD: " <<  load_success << "\n";     
    return load_success;

}

//st = myString.substr(0, myString.size()-1);
//function to get the dump information of the argument
bool dump_argument(std::stringstream &debug_out,std::any &out,llvm::Type *&type, Value *arg, Instruction * call_reference) {
    debug_out << "ENTRYDUMP" << "\n"; 
    bool dump_success = false;
	
	Type * Ty = arg->getType();


    //check if argument is an instruction
    if(Instruction *instr = dyn_cast<Instruction>(arg)){
        debug_out << "INSTRUCTION" << "\n";
        //check if argument is a load instruction
        if (LoadInst *load = dyn_cast<LoadInst>(instr)) {
            debug_out << "LOAD INSTRUCTION" << "\n";
            //check if argument is a global variable
            if (GlobalVariable *global_var = dyn_cast<GlobalVariable>(load->getOperand(0))) {
                debug_out << "LOAD GLOBAL" << "\n";
                //load the global information
                dump_success = load_value(debug_out,out,type, load->getOperand(0),arg,call_reference);
            }
        //check if instruction is an alloca instruction
        }else if (AllocaInst *alloca = dyn_cast<AllocaInst>(instr)) {
            debug_out << "ALLOCA INSTRUCTION" << "\n";
            if(alloca->hasName()){
                //return name of allocated space
                out = alloca->getName().str();
				type = alloca->getType();
				//////std::cerrr << "Type: " << abb->get_call_name() <<  std::endl;
                dump_success = true;
            }
            else{
                //return type of allocated space/*
                std::string type_str;
                llvm::raw_string_ostream rso(type_str);
                alloca->getType()->print(rso);
                out = rso.str();
				type = alloca->getType();
                dump_success = true;
            }
        }else if (CastInst *cast = dyn_cast<CastInst>(instr)) {
            debug_out << "CAST INSTRUCTION" << "\n";
			dump_success = dump_cast(debug_out,cast,out,type,call_reference );
			debug_out << print_argument(cast);
		
        }else if (StoreInst *store = dyn_cast<StoreInst>(instr)) {
            debug_out << "STORE INSTRUCTION" << "\n";
			dump_success = load_value(debug_out,out,type,store->getOperand(1),arg,call_reference );
			debug_out << print_argument(store);
		
        }
    }//check if argument is a constant integer
    else if (ConstantInt * CI = dyn_cast<ConstantInt>(arg)) {
        debug_out << "CONSTANT INT" << "\n";
        out = CI->getSExtValue();
		type = CI->getType();

		
		
		
        dump_success = true;
    }//check if argument is a constant floating point
    else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(arg)){
        debug_out << "CONSTANT FP" << "\n";
        out = constant_fp->getValueAPF().convertToDouble ();
		type = constant_fp->getType();
        dump_success = true;
    }//check if argument is a binary operator
    else if (BinaryOperator *binop = dyn_cast<BinaryOperator>(arg)) {
        if (binop->getOpcode() == Instruction::BinaryOps::Or) {
			//TODO adapt binary adapter
			/*
            out << "(";
            dump_argument(debug_out,out, binop->getOperand(0));
            out << ", ";
            dump_argument(debug_out,out, binop->getOperand(1));
            out << ")";
			*/
            dump_success = true;
        }
    }//check if argument is a pointer
    else if (PointerType * PT = dyn_cast<PointerType>(Ty)) {       
        debug_out << "POINTER" << "\n";
        Type* elementType = PT->getElementType();
		
		//check if arg is a null ptr
		if(check_nullptr(out,type,arg,debug_out)){
			return true;
		}
	
        //check if pointer points to function
        if (FunctionType * FT = dyn_cast<FunctionType>(elementType)) {  //check pointer to function 
            //check if argument has a name
            if(arg->hasName()){
                debug_out << "POINTER TO FUNCTION" << "\n";
                out = arg->getName().str();
				type = arg->getType();
                dump_success = true;
            }
        }//check if pointer points to pointer
        else if (PT->getContainedType(0)->isPointerTy()){
            debug_out << "POINTER TO POINTER" << "\n";
            //check if pointer target is a global variable
			
			//load the global information
			dump_success = load_value(debug_out,out, type,arg,arg,call_reference);
			debug_out << "Pointer to pointer: " << print_argument(arg);
		
        }//check if value is a constant value
        else if(GlobalVariable  * global_var = dyn_cast<GlobalVariable>(arg)) {
            debug_out << "POINTER TO GLOBAL" << "\n";
            dump_success = load_value(debug_out,out, type,arg,arg,call_reference);


        }else if (Constant * constant = dyn_cast<ConstantExpr>(arg) ){ //check if value is a constant value
            //check if the constant value is global global variable
            if (GlobalVariable  * global_var = dyn_cast<GlobalVariable>(constant->getOperand(0))) {
                debug_out << "POINTER TO CONSTANT GLOBAL" << "\n";
                dump_success = load_value(debug_out,out, type,constant->getOperand(0),arg,call_reference);
            }
		
        }else{
			debug_out << print_argument(arg);
		}
    }
    else{
	
        std::string type_str;
        llvm::raw_string_ostream rso(type_str);
        arg->getType()->print(rso);
        debug_out << rso.str() << "\n";
	
        dump_success = load_value(debug_out,out, type,arg,arg,call_reference);
        if(!dump_success)debug_out << "Kein Load/Instruction/Pointer" << "\n";
    }
	
    debug_out  << "EXITDUMP: " << dump_success << "\n"; 
    return dump_success;
}


//iterate about the arguments of the instruction and dump the value
void dump_instruction(OS::shared_abb abb,llvm::Function * func , auto& instruction){
	//store the name of the called function
	abb->set_call_name(func->getName().str());
	
	//store the llvm call instruction reference
	abb->set_call_instruction_reference(instruction);
	
	std::list<std::tuple<std::any,llvm::Type*>> arguments;
	
	//iterate about the arguments of the call
	for (unsigned i = 0; i < instruction->getNumArgOperands(); ++i) {
	
		//debug string
		std::stringstream debug_out;
		debug_out <<  func->getName().str() << "\n";

		std::any value_argument; 
		
		llvm::Type* type_argument;
		//get argument
		Value *arg = instruction->getArgOperand(i);
		
		
		//dump argument and check if it was successfull
		if(dump_argument(debug_out,value_argument,type_argument, arg,instruction)){
			//store the dumped argument in the abb with corresponding llvm type
			arguments.push_back(std::make_tuple (value_argument,type_argument));
		}else{
			//TODO
			//std::cerr << "ERROR: instruction argument dump was not successfull" << '\n';
			//std::cerr <<  print_argument(instruction) << '\n';
			//abort();
		}
	}
	
	if(arguments.size() == 0){
		std::any tmp_any = "void";
		llvm::Type* tmp_type = nullptr;
		arguments.emplace_back(std::make_tuple (tmp_any,tmp_type));
	}
	abb->set_arguments(arguments);
	//std::cout << abb->print_information();
}



//set the arguments and argument types of the abb
void set_arguments(OS::shared_abb abb){

	int bb_count = 0;
	
	//iterate about the basic blocks of the abb
	for (auto &bb : abb->get_BasicBlocks()) {
		
		int call_count =0;
		++bb_count;
		
		//call found flag
		bool call_found = false;
		
		
		//iterate about the instructions of the bb
		for (auto &inst : *bb) {
			//check if instruction is a call instruction
			if (isa<CallInst>(inst)) {
				CallInst *call = (CallInst *)&inst;
				Function * func = call->getCalledFunction();
				if (func && !isCallToLLVMIntrinsic(call)) {
					call_found = true;
					//get and store the called arguments values
					dump_instruction(abb,func , call);
					++call_count;
				}
			}else if (InvokeInst *invoke = dyn_cast<InvokeInst>(&inst)) {
				Function * func = invoke->getCalledFunction();
				if (func && !isCallToLLVMIntrinsic(invoke)) {
					call_found = true;
					//get and store the called arguments values
					dump_instruction(abb,func , invoke);
					++call_count;
 				}
			}
		}
		if(call_count > 1){
			std::cerr << abb->get_name() << " has more than one call instructions: "  << call_count << std::endl;
			abort();
		}
		if(call_found){
			abb->set_call_type(has_call);	
			//std::cout << abb->print_information();
		}
	}
	if(bb_count > 1){
		std::cerr << abb->get_name() << " has more than one llvm basic block: "  << bb_count << std::endl;
		abort();
	}
}




//function to create all abbs and store them in the graph
void abb_generation(graph::Graph *graph, OS::shared_function function ) {

    //get llvm function reference
    llvm::Function* llvm_reference_function = function->get_llvm_reference();

    //create ABB
	auto abb = std::make_shared<OS::ABB>(graph,function,llvm_reference_function->front().getName());
	
    //store coresponding basic block in ABB
    abb->set_BasicBlock(&(llvm_reference_function->getEntryBlock()));
	abb->set_exit_bb(&(llvm_reference_function->getEntryBlock()));
	abb->set_entry_bb(&(llvm_reference_function->getEntryBlock()));
	
	
	function->set_atomic_basic_block(abb);
	
    //queue for new created ABBs
    std::deque<OS::shared_abb> queue; 

    //store abb in graph
	graph->set_vertex(abb);

	
    queue.push_back(abb);

    //queue with information, which abbs were already analyzed
    std::vector<size_t> visited_abbs;
	
	//store the first abb as front abb of the function
	function->set_entry_abb(queue.front());
	
	//iterate about the ABB queue
    while(!queue.empty()) {

		//get first element of the queue
        OS::shared_abb old_abb = queue.front();
        queue.pop_front();

        //iterate about the successors of the ABB
        std::list<llvm::BasicBlock*> bbs = old_abb->get_BasicBlocks();
        std::list<llvm::BasicBlock*>::iterator it;

        //iterate about the basic block of the abb
		for (llvm::BasicBlock *bb : old_abb->get_BasicBlocks()) {
			

            //iterate about the successors of the abb
            for (auto it = succ_begin(bb); it != succ_end(bb); ++it){

                //get sucessor basicblock reference
                llvm::BasicBlock *succ = *it;

                //create temporary basic block
				auto new_abb = std::make_shared<OS::ABB>(graph,function, succ->getName());
				
                //check if the successor abb is already stored in the list				
                if(!visited(new_abb->get_seed(), &visited_abbs)) {
                    if(succ->getName().str().empty()){
						std::cerr << "ERROR: basic block has no name" << '\n';
						std::cerr <<  print_argument(succ) << '\n';
						abort();
                    }else{
						for(auto & tmp_bb : *llvm_reference_function){
							if(succ->getName().str() == tmp_bb.getName().str()){
								succ = &tmp_bb;
								break;
							}
						}
						
					}
                    //store new abb in graph
                    graph->set_vertex(new_abb);
					
					function->set_atomic_basic_block(new_abb);
				
                    //set abb predecessor reference and bb reference 
                    new_abb->set_BasicBlock(succ);
					new_abb->set_exit_bb(succ);
					new_abb->set_entry_bb(succ);
			
					
                    new_abb->set_ABB_predecessor(old_abb);

                    //set successor reference of old abb 
                    old_abb->set_ABB_successor(new_abb);

                    //update the lists
                    queue.push_back(new_abb);

                    visited_abbs.push_back(new_abb->get_seed());

					//set the abb call`s argument values and types
					set_arguments(new_abb);
					//std::cout<< new_abb->get_arguments()->size() << std::endl;
					//std::cout << new_abb->print_information();
					
                }else{
					
                    //get the alread existing abb from the graph
					std::shared_ptr<graph::Vertex> vertex = graph->get_vertex(new_abb->get_seed());
					std::shared_ptr<OS::ABB> existing_abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
				
					//TODO basic block can be connected with itself
                    if(old_abb->get_seed() != existing_abb->get_seed()){
                        //connect the abbs via reference
                        existing_abb->set_ABB_predecessor(old_abb);
                        old_abb->set_ABB_successor(existing_abb);
                    }else{
						existing_abb->set_ABB_predecessor(old_abb);
                        old_abb->set_ABB_successor(existing_abb);
					}
                }
            }
        }
    }
}

//split the basic blocks, so that just one call exists per instance
void split_basicblocks(llvm::Function *function,unsigned *split_counter) {
	//store the basic blocks in a list
    std::list<llvm::BasicBlock *> bbs;
    for (llvm::BasicBlock &_bb : *function) {
        bbs.push_back(&_bb);
    }
    //iterate about the basic blocks
    for (llvm::BasicBlock *bb : bbs) {
		
		//iterate about the instruction
        llvm::BasicBlock::iterator it = bb->begin();
        while (it != bb->end()) {
			//check if the instruction is a call instruction
            if(llvm::isa<llvm::InvokeInst>(*it) || llvm::isa<llvm::CallInst>(*it)) {
                // check if call is targete is an artifical function (e.g. @llvm.dbg.metadata)
                if (isCallToLLVMIntrinsic(&*it)) {
                    ++it;
                    continue;
                }
                //split the basic block and rename it
                std::stringstream ss;
                ss << "BB" << (*split_counter)++;
                bb = bb->splitBasicBlock(it, ss.str());
                it = bb->begin();
            }
            ++it;
        }
    }
}

namespace step {

	std::string LLVMStep::get_name() {
		return "LLVMStep";
	}

	std::string LLVMStep::get_description() {
		return "Extracts out of LLVM.";
	}

	void LLVMStep::run(graph::Graph& graph) {

		// get file arguments from config
		std::vector<std::string> files;
		std::cout << "Run " << get_name() << std::endl;
		PyObject* input_files = PyDict_GetItemString(config, "input_files");
		assert(input_files != nullptr && PyList_Check(input_files));
		for (Py_ssize_t i = 0; i < PyList_Size(input_files); ++i) {
			PyObject* elem = PyList_GetItem(input_files, i);
			assert(PyUnicode_Check(elem));
			files.push_back(std::string(PyUnicode_AsUTF8(elem)));
		}

	
		//TODO read in files and link them to one function
		std::string file_name = files.at(0); 
		
		//llvm::Context context;
		llvm::SMDiagnostic Err;
		
		
		std::unique_ptr<llvm::Module> module = parseIRFile(file_name, Err, context);
		
		if(!module){
			std::cerr << "ERROR: could not load the module IR file: " << file_name << '\n';
			abort();
		}
		
		//convert unique_ptr to shared_ptr
		std::shared_ptr<llvm::Module> shared_module = std::move(module);

		//set llvm module in the graph object
		graph.set_llvm_module(shared_module);
		
		//initialize the split counter
		unsigned split_counter = 0;
		
		//create and store the OS instance in the graph
		auto rtos = std::make_shared<OS::RTOS>(&graph,"RTOS");
		graph.set_vertex(rtos);	
		
		//iterate about llvm functions of llvm module
		for (auto &func : *shared_module){
			
			//check if llvm function has definition
			if(!func.empty()){
				
				//intialize a graph function			
				auto graph_function = std::make_shared<OS::Function>(&graph,func.getName().str());
				
				//get defined arguments of  function
				llvm::FunctionType *argList = func.getFunctionType();
				
				//iterate about  arguments
				for(unsigned int i = 0; i < argList->getNumParams();i++){
					//store  argument references in  argument list
					graph_function->set_argument_type(argList->getParamType(i));
				}
				
				//store  return type of  function
				graph_function->set_return_type(func.getReturnType());
				
				//store llvm function reference
				graph_function->set_llvm_reference(&(func));
				
				//split  llvm basic blocks, so that just one call exits per instance 
				split_basicblocks( &(func), &split_counter);
				
				//iterate about  splitted llvm basic blocks of llvm function an set their name
				for (auto &bb : func) {
					
					// name all basic blocks
					if (!bb.getName().startswith("BB")) {
						std::stringstream ss;
						ss << "BB" << split_counter++;
						bb.setName(ss.str());
						
					}
				}
				//store the generated function in the graph datastructure
				graph.set_vertex(graph_function);
				
				//generate and store the abbs of the function in the graph datatstructure
				abb_generation(&graph, graph_function );
			}
		}
		
		//set called functions for each abb
		std::list<graph::shared_vertex> vertex_list =  graph.get_type_vertices(typeid(OS::ABB).hash_code());
		for (auto &vertex : vertex_list) {

			//cast vertex to abb 
			auto abb = std::dynamic_pointer_cast<OS::ABB> (vertex);
			//std::cout<< "function name " << abb->get_name()<< std::endl;
			for(auto *instr : abb->get_call_instruction_references()){
				if(CallInst* tmp = dyn_cast<CallInst>((instr))){
					llvm::Function* llvm_function = tmp->getCalledFunction();
					std::hash<std::string> hash_fn;
					//std::cout<< "function name " << llvm_function->getName().str()<< std::endl;
					graph::shared_vertex vertex = graph.get_vertex(hash_fn(llvm_function->getName().str() +  typeid(OS::Function).name()));
					if(vertex != nullptr){
						//TODO set edge
						vertex->get_type();
						//std::cout <<  "success" << vertex->get_name() << std::endl;
						auto function =  std::dynamic_pointer_cast<OS::Function>(vertex);
						abb->set_called_function( function);
					}
				}
				if(InvokeInst* tmp = dyn_cast<InvokeInst>((instr))){
					llvm::Function* llvm_function = tmp->getCalledFunction();
					std::hash<std::string> hash_fn;
					//std::cout<< "function name" << llvm_function->getName().str();
					graph::shared_vertex vertex = graph.get_vertex(hash_fn(llvm_function->getName().str() +  typeid(OS::Function).name()));
					if(vertex != nullptr){
						//std::cout << "success" <<  vertex->get_name() << std::endl;
						vertex->get_type();
						//TODO set edge
						auto function =  std::dynamic_pointer_cast<OS::Function>(vertex);
						abb->set_called_function( function);
					}
				}
			}
		}
		
		//set an entry abb for each function
		vertex_list =  graph.get_type_vertices(typeid(OS::Function).hash_code());
		for (auto &vertex : vertex_list) {

			//cast vertex to abb 
			auto function = std::dynamic_pointer_cast<OS::Function> (vertex);
	
            std::list<OS::shared_abb> return_abbs;
			
            for(auto abb : function->get_atomic_basic_blocks()){
				if( abb->get_ABB_successors().size()== 0){
                    return_abbs.emplace_back(abb);
				}
			}
			//TODO log endless loop bzw. use llvm for exit loop detection
            if(return_abbs.size() >1){
				//std::cerr << "size" << return_abbs.size() << std::endl;
				std::stringstream ss;
				ss << "BB" << split_counter++;
				auto new_abb = std::make_shared<OS::ABB>(&graph,function, ss.str());
				graph.set_vertex(new_abb);
                function->set_atomic_basic_block(new_abb);
                for(auto ret : return_abbs){
                    ret->set_ABB_successor(new_abb);
					new_abb->set_ABB_predecessor(ret);
				}
                function->set_exit_abb(new_abb);
			}else{
				if(return_abbs.size() ==1) function->set_exit_abb(return_abbs.front());
			}
		}
	}
	
	
	std::vector<std::string> LLVMStep::get_dependencies() {
		return {};
	}
}
