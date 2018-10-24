// vim: set noet ts=4 sw=4:



//TODO extract missing arguments


#include "llvm.h"

#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <cassert>
#include <stdexcept>

using namespace llvm;

#define PRINT_NAME(x) std::cout << #x << " - " << typeid(x).name() << '\n'



static llvm::LLVMContext context;



bool dump_argument(std::stringstream &debug_out,std::any &out,llvm::Type * type, Value *arg,llvm::Instruction* call_reference);


 //check if instruction a is before instruction b 
 bool instruction_before( Instruction *InstA,  Instruction *InstB,DominatorTree *DT) {
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




//print the argument
void debug_argument(std::any value,llvm::Type *type){
	
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


std::string print_argument(auto& argument){
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	argument->print(rso);
	return rso.str() +  "\"\n";
	
}

bool check_nullptr(std::any &out, llvm::Type *type,llvm::Value *value,std::stringstream &debug_out ){
	bool load_success = false;
	if(ConstantPointerNull  * constant_data = dyn_cast<ConstantPointerNull>(value)){
		debug_out << "CONSTANTPOINTERNULL";
		std::string tmp = "&$%NULL&$%";
		out = tmp;
		type = constant_data->getType();
		//std::cerr << "[nullptr] type: " <<print_argument(value)  <<'\n';  
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
			}
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
bool load_value(std::stringstream &debug_out,std::any &out, llvm::Type *type,Value *arg,Value *prior_arg,llvm::Instruction *call_reference) {
	
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
inline bool dump_argument(std::stringstream &debug_out,std::any &out,llvm::Type *type, Value *arg, Instruction * call_reference) {
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
				////std::cerrr << "Type: " << abb->get_call_name() <<  std::endl;
                dump_success = true;
            }
            else{
                //return type of allocated space
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
	
	

	
	//iterate about the arguments of the call
	for (unsigned i = 0; i < instruction->getNumArgOperands(); ++i) {
		
		
		std::stringstream debug_out;
		debug_out <<  func->getName().str() << "\n";
	
		std::any value_argument; 
		llvm::Type* type_argument = nullptr;
		
		//get argument
		Value *arg = instruction->getArgOperand(i);
		
		//dump argument
		if(dump_argument(debug_out,value_argument,type_argument, arg,instruction)){
			//store the dumped argument in the abb with corresponding llvm type
			abb->set_argument(value_argument, type_argument);
			//debug_argument(value_argument ,type_argument);
			
		}else{
			std::cerr << "\n";
			std::cerr << "\n------------------------------------------------- \n";
			std::cerr  << "!! Could not load argument in Function: "<< abb->get_parent_function()->get_function_name()  << " !!" << "\n\n";
 			std::cerr << debug_out.str() << "------------------------------------------------- \n";
		}
		
	}
}



//set the arguments and argument types of the abb
void set_arguments(OS::shared_abb abb){
	
	std::stringstream out;
	std::list<llvm::BasicBlock*>::iterator it;
	
	for (auto &i : abb->get_BasicBlocks()) {
		
		
		////std::cerrr  << "TEST" << std::endl;
		bool call_found = false;
		
		
		for (auto &inst : *i) {
			
			if (isa<CallInst>(inst)) {
				CallInst *call = (CallInst *)&inst;
				Function * func = call->getCalledFunction();
				if (func && !isCallToLLVMIntrinsic(call)) {
					call_found = true;
					dump_instruction(abb,func , call);
				}
			} else if (InvokeInst *invoke = dyn_cast<InvokeInst>(&inst)) {
				Function * func = invoke->getCalledFunction();
				if (func) {
					call_found = true;
					dump_instruction(abb,func , invoke);
 				}
			}
		}
		if(call_found){
			abb->set_calltype(has_call);			
		}
	}
}




//function to create all abbs in the graph
void abb_generation(graph::Graph *graph, OS::shared_function function ) {

    //get llvm function reference
    llvm::Function* llvm_reference_function = function->get_llvm_reference();

    //get first basic block of the function

    //create ABB
	auto abb = std::make_shared<OS::ABB>(graph,function,llvm_reference_function->front().getName());
	
    //store coresponding basic block in ABB
    abb->set_BasicBlock(&(llvm_reference_function->getEntryBlock()));

    //queue for new created ABBs
    std::deque<OS::shared_abb> queue; 

    //store abb in graph
	graph->set_vertex(abb);
	
    queue.push_back(abb);

    //queue with information, which abbs were already analyzed
    std::vector<size_t> visited_abbs;

    //iterate about the ABB queue
	
	//store the first abb as front abb of the function
	function->set_front_abb(queue.front());

    while(!queue.empty()) {

		//get first element of the queue
        OS::shared_abb old_abb = queue.front();
        queue.pop_front();

        //iterate about the successors of the ABB
        std::list<llvm::BasicBlock*> bbs = old_abb->get_BasicBlocks();
        std::list<llvm::BasicBlock*>::iterator it;

        //iterate about the basic block of the abb
		for (auto &it : old_abb->get_BasicBlocks()) {
			

            //iterate about the successors of the abb
            for (auto it1 = succ_begin(it); it1 != succ_end(it); ++it1){

                //get sucessor basicblock reference
                llvm::BasicBlock *succ = *it1;

                //create temporary basic block
				auto new_abb = std::make_shared<OS::ABB>(graph,function, succ->getName());

                //check if the successor abb is already stored in the list				
                if(!visited(new_abb->get_seed(), &visited_abbs)) {

                    if(succ->getName().str().empty()){
						
                        std::string type_str;
                        llvm::raw_string_ostream rso(type_str);
                        succ->print(rso);
                        //std::cerrr  << rso.str() << std::endl;
                    }
                    //store new abb in graph
                    graph->set_vertex(new_abb);
					
                    //set abb predecessor reference and bb reference 
                    new_abb->set_BasicBlock(succ);
                    new_abb->set_ABB_predecessor(old_abb);

					
                    //set successor reference of old abb 
                    old_abb->set_ABB_successor(new_abb);

                    //update the lists
                    queue.push_back(new_abb);

                    visited_abbs.push_back(new_abb->get_seed());

					//set the abb call`s argument values and types
					set_arguments(new_abb);
					
                }else{
					
                    //get the alread existing abb from the graph
					std::shared_ptr<graph::Vertex> tmp = graph->get_vertex(new_abb->get_seed());
					std::shared_ptr<OS::ABB> existing_abb = std::dynamic_pointer_cast<OS::ABB> (tmp);
				
                    if(old_abb->get_seed() != existing_abb->get_seed()){

                        //connect the abbs via reference
                        existing_abb->set_ABB_predecessor(old_abb);
                        old_abb->set_ABB_successor(existing_abb);
                    }
                }
            }
        }
    }
}

void split_basicblocks(llvm::Function *function,unsigned *split_counter) {
    std::list<llvm::BasicBlock *> bbs;
    for (llvm::BasicBlock &_bb : *function) {
        bbs.push_back(&_bb);
	
    }
    for (llvm::BasicBlock *bb : bbs) {
        llvm::BasicBlock::iterator it = bb->begin();
        while (it != bb->end()) {

            while (llvm::isa<llvm::InvokeInst>(*it) || llvm::isa<llvm::CallInst>(*it)) {
                // If the call is an artifical function (e.g. @llvm.dbg.metadata)
                if (isCallToLLVMIntrinsic(&*it)) {
                    ++it;
                    continue;
                }

                std::stringstream ss;
			
                ss << "BB" << (*split_counter)++;
                ////std::cerrr << "split_counter = " << *split_counter << std::endl;
                bb = bb->splitBasicBlock(it, ss.str());
                it = bb->begin();
                ++it;
			
                if (llvm::isa<llvm::InvokeInst>(*it) || llvm::isa<llvm::CallInst>(*it))
                    continue;

                //TODO dead code?
                ss.str("");
                ss << "BB" << (*split_counter)++;
                ////std::cerrr << "split_counter = " << *split_counter << std::endl;
                bb = bb->splitBasicBlock(it, ss.str());
                it = bb->begin();
            }
		
            ++it;
        }
    }
}

namespace passage {

	std::string LLVMPassage::get_name() {
		return "LLVMPassage";
	}

	std::string LLVMPassage::get_description() {
		return "Extracts out of LLVM.";
	}

	void LLVMPassage::run(graph::Graph& graph) {
		
		
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

		for (const auto& file : files) {
			std::cout << "File: " << file << std::endl;
		}

		//TODO read in object type
		//std::string file_name = config["input_files"]; 
		std::string file_name = files.at(0); 
		
		



		//llvm::Context context;
		llvm::SMDiagnostic Err;
		
		//llvm::Module *tmp_module = parseIRFile(file_name, Err, context);
		
		//load the IR representation file
		//std::unique_ptr<llvm::Module> module = parseIRFile(file_name, Err, Context);
		//std::unique_ptr<llvm::Module> module = parseIRFile(file_name, Err, Context);
		std::unique_ptr<llvm::Module> module = parseIRFile(file_name, Err, context);
		
		if(!module){
			std::cerr << "Could not load file:" << file_name << "\n" << std::endl;
		}
		
		//convert unique_ptr to shared_ptr
		std::shared_ptr<llvm::Module> shared_module = std::move(module);

				
		if(!module){
			std::cerr << "Unique pointer was deleted:" << file_name << "\n" << std::endl;
		}
		
	
		
		
		//set the llvm module in the graph object
		//tmp_graph.set_llvm_module(shared_module);
		graph.set_llvm_module(shared_module);
		
		//initialize the split counter
		unsigned split_counter = 0;
		
		//iterate about the functions of the llvm module
		for (auto &func : *shared_module){
			
			//create Function, set the module reference and function name and calculate the seed of the function			
			auto graph_function = std::make_shared<OS::Function>(&graph,func.getName().str());
			
			//get arguments of the function
			llvm::FunctionType *argList = func.getFunctionType();
			
			//iterate about the arguments
			for(unsigned int i = 0; i < argList->getNumParams();i++){
				//store the argument references in the argument list
				graph_function->set_argument_type(argList->getParamType(i));
			}
			
			//store the return type of the function
			graph_function->set_return_type(func.getReturnType());
			
			
			//store llvm function reference
			graph_function->set_llvm_reference(&(func));
			
			split_basicblocks( &(func), &split_counter);
			
			for (auto &bb : func) {
				
				
				// name all basic blocks
				if (!bb.getName().startswith("BB")) {
					std::stringstream ss;
					ss << "BB" << split_counter++;
					bb.setName(ss.str());
					
				}
				//std::cerrr << "basicblock_name = " << bb.getName().str() << std::endl;
			}
			
			if(!func.empty()){
				//store the generated function in the graph datastructure
				graph.set_vertex(graph_function);
				
				//generate and store the abbs of the function in the graph datatstructure
				abb_generation(&graph, graph_function );
			}
		}		
		
		
		std::cerr << "_____________________________________________________________________________" << std::endl;
		
		//TEST Abschnitt
		std::list<graph::shared_vertex> test_list =  graph.get_type_vertexes(typeid(OS::ABB()).hash_code());
		std::list<graph::shared_vertex>::iterator it = test_list.begin();       //iterate about the list elements
		for(; it != test_list.end(); ++it){
	
			std::shared_ptr<graph::Vertex> tmp = (*it);
			std::shared_ptr<OS::ABB> pDerived = std::dynamic_pointer_cast<OS::ABB> (tmp);
			
			if(pDerived) // always test  
			{
				//std::cerrr << "ABB Name: " << pDerived->get_name() << "\n" << std::endl;
				if( pDerived->get_calltype()== has_call){ 
					std::cerr << "\n" << "Name: "  << pDerived->get_name() << "\n" ;
					std::cerr  << "Call: " << pDerived->get_call_name() << "\n";
					std::list<std::tuple<std::any,llvm::Type*>> tmp_list = pDerived->get_arguments();
					//std::cerrr << "Argument: " << pDerived->get_name();
					
					for (auto &argument_tuple : tmp_list){
						debug_argument( std::get<0>(argument_tuple), std::get<1>(argument_tuple));
					}
					std::cerr  << "Parent Function: " << pDerived->get_parent_function()->get_function_name() << "\n";
				}
			}
			else
			{
				// fail to down-cast
			}
		}
		

	}
	std::vector<std::string> LLVMPassage::get_dependencies() {
		return {"OilPassage"};
	}
}
