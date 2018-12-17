// vim: set noet ts=4 sw=4:



//TODO extract missing arguments


#include "llvm.h"
#include "llvm/IR/TypeFinder.h"
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


#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/TypeFinder.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Metadata.h"
#include "llvm/Analysis/Loads.h"
#include "llvm/Analysis/MemorySSA.h"

using namespace llvm;

#define PRINT_NAME(x) std::cout << #x << " - " << typeid(x).name() << '\n'


static llvm::LLVMContext context;


bool dump_argument(std::stringstream &debug_out,std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list, Value *arg, std::list<llvm::Instruction*>* already_visited);




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
	
	//std::cout << "debug not same parents" <<  DA->getDFSNumIn() << ":" <<  DB->getDFSNumIn() << std::endl;
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



bool check_nullptr(std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list,llvm::Value* arg,std::stringstream &debug_out ){
	bool load_success = false;
	if(ConstantPointerNull  * constant_data = dyn_cast<ConstantPointerNull>(arg)){
		debug_out << "CONSTANTPOINTERNULL";
		std::string tmp = "&$%NULL&$%";
		any_list->emplace_back(tmp);
		value_list->emplace_back(constant_data);
		////std::cerr << "[nullptr] type: " <<print_argument(value)  <<'\n';  
		load_success = true;
	}
	return load_success;
}


bool check_function_class_reference_type(llvm::Function* function, llvm::Type* type){
    if(type==nullptr || function==nullptr)return -1;
   
    for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i){
            if( (*i).getType()==type && (*i).getName().str()== "this"){
                return true;
            }
            else return false;
    }
    return false;
}

bool check_get_element_ptr_indizes(std::vector<size_t>* reference, llvm::GetElementPtrInst * instr){
    int counter = 0;
    for (auto i = instr->idx_begin(), ie = instr->idx_end (); i != ie; ++i){
        int index = -1;
        if (llvm::ConstantInt* CI = dyn_cast<llvm::ConstantInt>(((*i).get()))) {
                index =CI->getLimitedValue();
            };
        if(index!=reference->at(counter))return false;
        ++counter;
    }
    return true;
}

bool get_class_attribute_value(std::stringstream &debug_out,llvm::Instruction *inst,std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list, std::list<llvm::Instruction*>* already_visited,std::vector<size_t>* indizes){
    bool success = true;
    bool flag = false;
    //get module
    llvm::Module* mod = inst->getFunction()->getParent();
    //iterate about the module
    for(auto& function :*mod){
        //iterate about the arguments of the function
        for (auto i = function.arg_begin(), ie = function.arg_end(); i != ie; ++i){
            //check if the function is a method of the class
            if( (*i).getType()==inst->getType()){
                //std::cerr << "class specific get element ptr operation" << print_argument(inst);
                //iterate about the basic blocks of the function
                for (llvm::BasicBlock &bb : function){
                    //iterate about the instructions of the function
                    for (llvm::Instruction& instr : bb){
                        //get pointerelement instruction 
                        if(auto *get_pointer_element  = dyn_cast<llvm::GetElementPtrInst>(&instr)){  // U is of type User*
                            //check if the get pointer operand instruction is a load instruciton
                            if(check_function_class_reference_type(instr.getFunction(),get_pointer_element->getPointerOperandType())&& check_get_element_ptr_indizes(indizes,get_pointer_element)){  
                                
                                for(auto user : get_pointer_element->users()){  // U is of type User*
                                    //get all users of get pointer element instruction
                                    if (auto store = dyn_cast<StoreInst>(user)){
                                        flag = true;
                                        //std::cerr << "user" << std::endl;
                                        if(!dump_argument(debug_out,any_list, value_list, store->getOperand(0),already_visited))success = false;
                                    }
                                }
                            }
                        }
                    }
                }
            //function is not a method of the class
            }else break;
        }
        
    }
    if(!flag)return false;
    else return success;
}



bool get_element_ptr(std::stringstream &debug_out,llvm::Instruction *inst,std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list, std::list<llvm::Instruction*>* already_visited){
    
    bool success = false;
    // check if this is a element ptr
    if(auto *get_pointer_element  = dyn_cast<llvm::GetElementPtrInst>(inst)){  // U is of type User*
        std::vector<size_t> indizes;
        //get indizes of the element ptr
        for (auto i = get_pointer_element->idx_begin(), ie = get_pointer_element->idx_end (); i != ie; ++i){
            llvm::Value* tmp = ((*i).get());
            if (llvm::ConstantInt* CI = dyn_cast<llvm::ConstantInt>(tmp)) {
                indizes.emplace_back(CI->getLimitedValue());
            };
        };
        //get operand of the GetElementPtrInst
        if (auto load = dyn_cast<LoadInst>(get_pointer_element->getPointerOperand())){

            //check if the address is a class specific address
            if(check_function_class_reference_type(inst->getFunction(),get_pointer_element->getPointerOperandType())){
                
                //std::cerr << "class specific get element ptr operation" << print_argument(inst);
                           
                //get store instructions
                success = get_class_attribute_value(debug_out,load,any_list,value_list,already_visited, &indizes);
                //std::cerr << success<< std::endl;
            }
            
        };
    }
    return success;
}



//dump a cast instruction
bool get_store_instruction(std::stringstream &debug_out,llvm::Instruction *inst,std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list, std::list<llvm::Instruction*>* already_visited){
	
    bool success = false;

	//get control flow information of the function
	llvm::Function & tmp_function = *inst->getFunction();
	DominatorTree dominator_tree = DominatorTree(tmp_function);
	
    Triple ModuleTriple(llvm::sys::getDefaultTargetTriple());
	TargetLibraryInfoImpl TLII = TargetLibraryInfoImpl(ModuleTriple);
    TargetLibraryInfo TLI = TargetLibraryInfo(TLII);
    AAResults results = AAResults(TLI);
       
    MemorySSA ssa = MemorySSA (tmp_function, &results, &dominator_tree);
    ssa.verifyMemorySSA();
    MemorySSAWalker  *walker = ssa.getWalker();
    
    MemoryAccess* access = walker->getClobberingMemoryAccess(inst);
    
    
    if(access != nullptr){
        if(auto def_access = dyn_cast<MemoryDef>(access)){
            
            if(StoreInst *store_inst = dyn_cast<StoreInst>(def_access->getMemoryInst())){
                /*std::cerr << "store" << std::endl;
                std::cerr <<  print_argument(store_inst) << std::endl;
                 std::cerr << "source" << std::endl;
                std::cerr <<  print_argument(inst) << std::endl;
                std::cerr << "STORE TO ALLOCA" << std::endl << print_argument(store_inst);*/
                success = dump_argument(debug_out,any_list,value_list,store_inst->getOperand(0),already_visited);
            }
        }
    }
        /*
//         auto test=  access->getIterator();
//         
//         while(!test.isEnd()){
//            (*test)->print_argument
//             test++;
//         }
        for(auto it = access->defs_begin(); it != access->defs_end();++it){
            
            if((*it)==nullptr)continue;
            
            //std::cerr << "useordef" <<   print_argument((*it)) << std::endl;
            /*if(auto useordef_tmp = dyn_cast<MemoryUseOrDef>((*it))){
                std::string type_str;
                llvm::raw_string_ostream rso(type_str);
                if(useordef_tmp->getMemoryInst()!=nullptr){
                    if(StoreInst *store_inst = dyn_cast<StoreInst>(useordef_tmp->getMemoryInst())){
                        std::cerr << "source" << std::endl;
                        std::cerr <<  print_argument(store_inst) << std::endl;
                        debug_out << "STORE TO ALLOCA" << std::endl << print_argument(store_inst);
                        success = dump_argument(debug_out,any_list,value_list,store_inst->getOperand(0),already_visited);
                    }
                }
            }
        }
        
    }
    
    /*
    std::cerr << "target" << std::endl;
    std::cerr <<  print_argument(inst) << std::endl;
    
//     MemoryUseOrDef * useordef = ssa.getMemoryAccess (inst);
//     if(useordef != nullptr){
//         for(auto it = useordef->getDefiningAccess()->defs_begin(); it != useordef->getDefiningAccess()->defs_end();++it){

	bool pointer_flag = true;
	
	if(AllocaInst* alloca_instruction = dyn_cast<AllocaInst>(inst)){
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
				
			}else{
                //TODO
                //std::cout << "local variable was set after value" << std::endl;
            }
			//no load between allocation and call reference
		}
		//check if a valid store instruction could be found
		if(store_instruction != nullptr){
			
	}
	if(!cast_success)debug_out << "alloca instruction: " << print_argument(inst);
    */
    
	return success;
}



bool load_function_argument(std::stringstream &debug_out,std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list,Function *function, std::list<llvm::Instruction*>* already_visited,int arg_counter) {
    
    auto sUse = function->user_begin();
    auto sEnd = function->user_end();
    
    
    bool success = true;
    //iterate about the user of the allocation
    for(;sUse != sEnd; ++sUse){
        
        //check if instruction is a store instruction
        if(Instruction *instr = dyn_cast<Instruction>(*sUse)){
            bool flag = true;
            for(auto * element: *already_visited){
                if(element == instr){
                    flag = false;
                    break;
                }
            }
            if(!flag)break;
            
            already_visited->emplace_back(instr);
            
            debug_out << "LOADFUNKTIONARGUMENT" << "\n";
            if(!dump_argument(debug_out,any_list,value_list, instr->getOperand(arg_counter), already_visited))success = false;;
            //std::cerr << "user of function argument " << print_argument(instr) << std::endl;
        }
    }
    
    for(auto element : *value_list){
        //std::cerr << "element" << print_argument(element) << std::endl;
        
    }
    debug_out << "ENDLOADFUNKTIONARGUMENT" << "\n";
    return success;
}

//function to get the global information of variable
bool load_value(std::stringstream &debug_out,std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list,Value *arg,Value *prior_arg,std::list<llvm::Instruction*>* already_visited) {
	
    //debug data
    debug_out << "ENTRYLOAD" << "\n";    

    std::string type_str;
    llvm::raw_string_ostream rso(type_str);

    bool load_success = false;
	
	//check if arg is a null ptr
	if(check_nullptr(any_list,value_list,arg,debug_out)){
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
							any_list->emplace_back(constant_array->getAsCString().str());
                            load_success = true;
                            value_list->emplace_back(constant_array);
							
                        } else debug_out << "Keine konstante sequentielle Date geladen" << "\n";
                    }
                }//check if global variable is contant integer
                else if (ConstantInt  * constant_int = dyn_cast<ConstantInt>(constant_data)) {
					debug_out << "CONSTANTDATAINT" << "\n";
                 
					any_list->emplace_back(constant_int->getSExtValue());
                    value_list->emplace_back(constant_int);
                    load_success = true;
                    
                }//check if global variable is contant floating point
                else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(constant_data)){
					debug_out << "CONSTANTDATAFLOATING" << "\n";
                    
                    any_list->emplace_back(constant_fp->getValueAPF().convertToDouble());
                    value_list->emplace_back(constant_fp);
                    load_success = true;
                }//check if global variable is contant null pointer
                else if(ConstantPointerNull  * null_ptr = dyn_cast<ConstantPointerNull>(constant_data)){
					debug_out << "CONSTANTPOINTERNULL" << "\n";
                    //print name of null pointer because there is no other content
                    if(global_var->hasName()){
                        any_list->emplace_back(global_var->getName().str());
                        value_list->emplace_back(global_var);
                        load_success = true;

						
					}else{
                        debug_out << "Globaler Null Ptr hat keinen Namen" << "\n";
                    }
                }else{
                    any_list->emplace_back(global_var->getName().str());
                    value_list->emplace_back(global_var);
                    load_success = true;
                    debug_out << "CONSTANTUNDEF/TOKENNONE" << "\n";
                }
			//check if global varialbe is a constant expression
            }else if(ConstantExpr  * constant_expr = dyn_cast<ConstantExpr>(global_var->getInitializer())){
				debug_out << "CONSTANTEXPRESSION" << "\n";
                //check if value is from type value 
                if (Value  * tmp_arg = dyn_cast<Value>(constant_expr)){
                    //get the value
                    load_success = dump_argument(debug_out,any_list, value_list, tmp_arg,already_visited);
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

                        load_success = dump_argument(debug_out,any_list, value_list,aggregate_operand,already_visited);
					
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
                any_list->emplace_back(global_var->getName().str());
                value_list->emplace_back(global_var);
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

                            any_list->emplace_back(CI->getSExtValue());
                            value_list->emplace_back(CI);
                            
                            load_success = true;
                        }//check if argument is a constant floating point
                        else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(content)){
                            debug_out << "CONSTANT FP" << "\n";
                            
                            any_list->emplace_back(constant_fp->getValueAPF().convertToDouble());
                            value_list->emplace_back(constant_fp);
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
bool dump_argument(std::stringstream &debug_out,std::vector<std::any>* any_list,std::vector<llvm::Value*> * value_list, Value *arg, std::list<Instruction*>* already_visited) {
    
    
    
    if(arg==nullptr)return false;
    //std::cerr << "instruction" << print_argument(arg);
    if(Instruction *instr = dyn_cast<Instruction>(arg)){
        llvm::Function * function = already_visited->back()->getParent()->getParent();
        
        int arg_counter = 0;
        for (auto i = function->arg_begin(), ie = function->arg_end(); i != ie; ++i){
            auto sUse = (*i).user_begin();
            auto sEnd = (*i).user_end();
          
            //iterate about the user of the allocation
            for(;sUse != sEnd; ++sUse){
                
                if (StoreInst *store = dyn_cast<StoreInst>(*sUse)) {
                    //std::cerr << "store" << print_argument(store);
                    if(store->getOperand(0) == &(*i) && store->getOperand(1) == instr->getOperand(0))return load_function_argument(debug_out,any_list,value_list,function,already_visited, arg_counter);
                }
            }
            ++arg_counter;
        }
    }
    
    debug_out << "ENTRYDUMP" << "\n"; 
    bool dump_success = false;
	
	Type * Ty = arg->getType();
    
    //TODO argument of function

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
                dump_success = load_value(debug_out,any_list,value_list, load->getOperand(0),arg,already_visited);
            }else if(instr->getNumOperands() == 1){
               debug_out << "ONEOPERAND" << "\n";
               
                if(isa<AllocaInst>(load->getOperand(0))){
                    //std::cerr << "---------------------" << std::endl << "function" << print_argument(load->getParent()->getParent()) << std::endl;
                    //std::cerr << "---------------------" << std::endl << "alloca reference" << print_argument(load) << std::endl;
                    dump_success = get_store_instruction(debug_out,load,any_list,value_list,already_visited );
                }
                else dump_success = dump_argument(debug_out,any_list,value_list, load->getOperand(0), already_visited);
               
            }
        //check if instruction is an alloca instruction
        }else if (AllocaInst *alloca = dyn_cast<AllocaInst>(instr)) {
            debug_out << "ALLOCA INSTRUCTION" << "\n";
            if(alloca->hasName()){
                //dump_success = get_store_instruction(debug_out,alloca,any_list,value_list,already_visited );
                //any_list->emplace_back(alloca->getName().str());
				//value_list->emplace_back(alloca);
                dump_success = true;
            }
            else{
                //return type of allocated space/*
                std::string type_str;
                llvm::raw_string_ostream rso(type_str);
                alloca->getType()->print(rso);
                any_list->emplace_back(rso.str());
				value_list->emplace_back(alloca);
                dump_success = true;
            }
        }else if (CastInst *cast = dyn_cast<CastInst>(instr)) {
            debug_out << "CAST INSTRUCTION" << "\n";
			dump_success =  dump_argument(debug_out,any_list,value_list,cast->getOperand(0), already_visited);
			debug_out << print_argument(cast);
		
        }else if (StoreInst *store = dyn_cast<StoreInst>(instr)) {
            debug_out << "STORE INSTRUCTION" << "\n";
			dump_success = load_value(debug_out,any_list,value_list,store->getOperand(0),arg,already_visited );
			debug_out << print_argument(store);
		
        }else if(auto *geptr  = dyn_cast<llvm::GetElementPtrInst>(instr)){
            debug_out << "ELEMENTPTRINST INSTRUCTION" << "\n";
            dump_success  = get_element_ptr(debug_out,geptr, any_list,value_list, already_visited);
        }
    }//check if argument is a constant integer
    else if (ConstantInt * CI = dyn_cast<ConstantInt>(arg)) {
        debug_out << "CONSTANT INT" << "\n";
        any_list->emplace_back(CI->getSExtValue());
        value_list->emplace_back(CI);
        dump_success = true;
    }//check if argument is a constant floating point
    else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(arg)){
        debug_out << "CONSTANT FP" << "\n";
        any_list->emplace_back(constant_fp->getValueAPF().convertToDouble ());
        value_list->emplace_back(constant_fp);
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
		if(check_nullptr(any_list,value_list,arg,debug_out)){
			return true;
		}
        //check if pointer points to function
        if (FunctionType * FT = dyn_cast<FunctionType>(elementType)) {  //check pointer to function 
            //check if argument has a name
            if(arg->hasName()){
                debug_out << "POINTER TO FUNCTION" << "\n";
                any_list->emplace_back(arg->getName().str());
                value_list->emplace_back(arg);
                dump_success = true;
            }
        }//check if pointer points to pointer
        else if (PT->getContainedType(0)->isPointerTy()){
            debug_out << "POINTER TO POINTER" << "\n";
            //check if pointer target is a global variable
            debug_out << "Pointer to pointer: " << print_argument(arg);
			//load the global information
			dump_success = load_value(debug_out,any_list,value_list, arg,arg,already_visited);

		
        }//check if value is a constant value
        else if(GlobalVariable  * global_var = dyn_cast<GlobalVariable>(arg)) {
            debug_out << "POINTER TO GLOBAL" << "\n";
            dump_success = load_value(debug_out,any_list,value_list, arg,arg,already_visited);


        }else if (Constant * constant = dyn_cast<ConstantExpr>(arg) ){ //check if value is a constant value
            //check if the constant value is global global variable
            if (GlobalVariable  * global_var = dyn_cast<GlobalVariable>(constant->getOperand(0))) {
                debug_out << "POINTER TO CONSTANT GLOBAL" << "\n";
                dump_success = load_value(debug_out,any_list,value_list, constant->getOperand(0),arg,already_visited);
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
	
        dump_success = load_value(debug_out,any_list,value_list, arg,arg,already_visited);
        if(!dump_success)debug_out << "Kein Load/Instruction/Pointer" << "\n";
    }
	
	if(!dump_success){
        std::string arg_name = arg->getName().str();
        
        if(arg_name.length() > 0){
            debug_out << "DEFAULTNAME" << "\n";
            
            any_list->emplace_back(arg_name);
            value_list->emplace_back(arg);
            dump_success = true;
        }
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
	
	 std::list<argument_data> arguments;
	 std::cerr << "call" << print_argument(instruction) << std::endl;
	//iterate about the arguments of the call
	for (unsigned i = 0; i < instruction->getNumArgOperands(); ++i) {
	
		//debug string
		std::stringstream debug_out;
		debug_out <<  func->getName().str() << "\n";

		std::vector<std::any> any_list; 
		
		std::vector<llvm::Value*> value_list;
        std::list<llvm::Instruction*> already_visited;
        already_visited.emplace_back(instruction);
		//get argument
		Value *arg = instruction->getArgOperand(i);
		
		//std::cerr << "arg: " << print_argument(arg) << std::endl;
		//dump argument and check if it was successfull
		if(dump_argument(debug_out,&any_list,&value_list, arg,&already_visited)){
            
            for(auto element : value_list){
                std::cerr << "element: " << print_argument(element) << std::endl;
            }
            argument_data tmp_arguments;
            tmp_arguments.any_list =any_list;
            tmp_arguments.value_list = value_list;
            if(any_list.size() > 1)tmp_arguments.multiple = true;
            
            //std::cerr << debug_out.str() << std::endl;
			//store the dumped argument in the abb with corresponding llvm type
			arguments.emplace_back(tmp_arguments);
		}else{
			//TODO
			/*std::cerr << "ERROR: instruction argument dump was not successfull, Operand: " << i << '\n';
			std::cerr <<  print_argument(instruction) << '\n';
			std::cerr << debug_out.str() << std::endl;
			*///abort();
		}
	}
	
	if(arguments.size() == 0){
		argument_data tmp_arguments;
		arguments.emplace_back(tmp_arguments);
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

std::unique_ptr<Module> LoadFile(std::string argv, const std::string &FN,
                                               LLVMContext& Context) {
    SMDiagnostic Err;
    //if (Verbose) errs() << "Loading '" << FN << "'\n";

    std::unique_ptr<Module> Result = 0;
    Result = parseIRFile(FN, Err, Context);
    if (Result) return Result;

    //Err.print(argv0, errs());
    return NULL;
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
		
		
		unsigned BaseArg = 0;
		std::string ErrorMessage;
		
		std::string argv = "lvm.cpp";
		
		auto Composite = LoadFile(argv, files.at(BaseArg), context);
		if (Composite.get() == 0) {
			std::cerr << argv << ": error loading file '"
				<< files.at(BaseArg) << "'\n";
			abort();
		}

		Linker L(*Composite);

		for (unsigned i = BaseArg+1; i < files.size(); ++i) {
            auto M = LoadFile(argv, files.at(i), context);
            if (M.get() == 0) {
                std::cerr << argv << ": error loading file '" << files.at(i) << "'\n";
                abort();
            }

            for (auto it = M->global_begin(); it != M->global_end(); ++it)
            {
                GlobalVariable& gv = *it;
                if (!gv.isDeclaration())
                gv.setLinkage(GlobalValue::LinkOnceAnyLinkage);
            }

            for (auto it = M->alias_begin(); it != M->alias_end(); ++it)
            {
                GlobalAlias& ga = *it;
                if (!ga.isDeclaration())
                ga.setLinkage(GlobalValue::LinkOnceAnyLinkage);
            }

            // set linkage information of all functions
            for (auto &F : *M) {
                StringRef Name = F.getName();
                // Leave library functions alone because their presence or absence
                // could affect the behaviour of other passes.
                if (F.isDeclaration())continue;
                F.setLinkage(GlobalValue::WeakAnyLinkage);
            }
            
            if (L.linkInModule(std::move(M))) {
                std::cerr << argv << ": link error in '" << files.at(i);
                abort();
            }
        }

		
		//convert unique_ptr to shared_ptr
		std::shared_ptr<llvm::Module> shared_module = std::move(Composite);

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
				
				//split  llvm basic blocks, so that just one call exits per instance 
				split_basicblocks( &(func), &split_counter);
				
                //store llvm function reference
				graph_function->set_llvm_reference(&(func));
                
                //update dominator tree and postdominator tree
				graph_function->initialize_dominator_tree(&(func));
                graph_function->initialize_postdominator_tree(&(func));
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

						vertex->get_type();
						//std::cout <<  "success" << vertex->get_name() << std::endl;
						auto function =  std::dynamic_pointer_cast<OS::Function>(vertex);
						abb->set_called_function(function,instr);
                        abb->get_parent_function()->set_called_function(function,abb);
                        
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

						auto function =  std::dynamic_pointer_cast<OS::Function>(vertex);
						abb->set_called_function( function,instr);
                        
                        abb->get_parent_function()->set_called_function(function,abb);
                        
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


		
// 		for (auto it = shared_module->global_begin(); it != shared_module->global_end(); ++it){
//            
//             GlobalVariable& gv = *it;
//             //if (gv.isDeclaration()){
//                 
//                 std::cerr <<  print_argument(&gv) << std::endl;
//                 
//             //}
//         }
/*
        llvm::TypeFinder StructTypes;
        StructTypes.run(shared_module, true);

        for (auto *STy : StructTypes)std::cerr <<  print_argument(STy) << std::endl;
		*/
		
		
	}
	
	
	std::vector<std::string> LLVMStep::get_dependencies() {
        
		return {};
	}
}
