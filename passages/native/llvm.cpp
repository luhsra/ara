// vim: set noet ts=4 sw=4:

#include "llvm.h"

#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <cassert>
#include <stdexcept>

using namespace llvm;

#define PRINT_NAME(x) std::cout << #x << " - " << typeid(x).name() << '\n'


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


bool dump_argument(std::stringstream &debug_out,std::any &out,llvm::Type * type, Value *arg);


static bool isCallToLLVMIntrinsic(Instruction * inst) {
    if (CallInst* callInst = dyn_cast<CallInst>(inst)) {
        Function * func = callInst->getCalledFunction();
        if (func && func->getName().startswith("llvm.")) {
            return true;
        }
    }
    return false;
}



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


//function to get the global information of variable
bool load_value(std::stringstream &debug_out,std::any &out, llvm::Type *type,Value *arg,Value *prior_arg) {
	
    //debug data
    debug_out << "ENTRYLOAD" << "\n";    

    std::string type_str;
    llvm::raw_string_ostream rso(type_str);

    bool load_success = false;


     if (GlobalVariable *global_var = dyn_cast<GlobalVariable>(arg)){
		
	
        debug_out << "GLOBALVALUE" << "\n"; 
	
        global_var->print(rso);
        arg->print(rso);
        debug_out <<  rso.str() << "\"\n";
	
        //check if the global variable has a loadable value             
        if(global_var->hasInitializer()){
		
		
            if(ConstantData  * constant_data = dyn_cast<ConstantData>(global_var->getInitializer())){
			
                if(ConstantDataSequential  * constant_sequential = dyn_cast<ConstantDataSequential>(constant_data)){
                    if (ConstantDataArray  * constant_array = dyn_cast<ConstantDataArray>(constant_sequential)){
                        //global variable is a constant array
                        if (constant_array->isCString()){
                            load_success = true;
                        } else debug_out << "Keine konstante sequentielle Date geladen" << "\n";
                    }
                }//check if global variable is contant integer
                else if (ConstantInt  * constant_int = dyn_cast<ConstantInt>(constant_data)) {
                    out = constant_int->getSExtValue();
					type = constant_int->getType();
					
                    load_success = true;
                }//check if global variable is contant floating point
                else if(ConstantFP  * constant_fp = dyn_cast<ConstantFP>(constant_data)){
                    out = constant_fp->getValueAPF().convertToDouble(); 
					type = constant_fp->getType();
					

                    load_success = true;
                }//check if global variable is contant null pointer
                else if(ConstantPointerNull  * null_ptr = dyn_cast<ConstantPointerNull>(constant_data)){
                    //print name of null pointer because there is no other content
                    if(global_var->hasName()){
                        out = global_var->getName().str();
						type = global_var->getType();
						
                        load_success = true;

						
					}else{
                        debug_out << "Globaler Null Ptr hat keinen Namen" << "\n";
                        llvm::raw_string_ostream rso(type_str);
                        null_ptr->print(rso);
                        debug_out << rso.str() << "\n";
                    }
                }else debug_out << "Constante vom Typ UndefValue/ConstantTokenNone" << "\n";

			//check if global varialbe is a constant expression
            }else if(ConstantExpr  * constant_expr = dyn_cast<ConstantExpr>(global_var->getInitializer())){
                //check if value is from type value 
                if (Value  * tmp_arg = dyn_cast<Value>(constant_expr)){
                    //get the value
                    load_success = dump_argument(debug_out,out,type, tmp_arg);
                }
			
            //check if global variable is from type constant aggregate
            }else if(ConstantAggregate  * constant_aggregate = dyn_cast<ConstantAggregate>(global_var->getInitializer())){
                //check if global variable is from type constant array
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
					
					
                        load_success = dump_argument(debug_out,out,type,aggregate_operand);
					
                    }
				
                }//check if global variable is from type constant struct
                else if(ConstantStruct  * constant_struct = dyn_cast<ConstantStruct>(constant_aggregate)){
                    debug_out << "Constant Struct";
                }//check if global variable is from type constant vector
                else if(ConstantVector  * constant_vector = dyn_cast<ConstantVector>(constant_aggregate)){
                debug_out << "Constant Vector";
                }
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
	
	
    debug_out << "EXITLOAD" << "\n";     
    return load_success;
}

//st = myString.substr(0, myString.size()-1);
//function to get the dump information of the argument
inline bool dump_argument(std::stringstream &debug_out,std::any &out,llvm::Type *type, Value *arg) {
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
                dump_success = load_value(debug_out,out,type, load->getOperand(0),arg);
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
            if(GlobalVariable  * global_var = dyn_cast<GlobalVariable>(arg)){
                //load the global information
                dump_success = load_value(debug_out,out, type,arg,arg);
            }
        }//check if value is a constant value
        else if(GlobalVariable  * global_var = dyn_cast<GlobalVariable>(arg)) {
            debug_out << "POINTER TO GLOBAL" << "\n";
            dump_success = load_value(debug_out,out, type,arg,arg);


        }else if (Constant * constant = dyn_cast<ConstantExpr>(arg) ){ //check if value is a constant value
            //check if the constant value is global global variable
            if (GlobalVariable  * global_var = dyn_cast<GlobalVariable>(constant->getOperand(0))) {
                debug_out << "POINTER TO CONSTANT GLOBAL" << "\n";
                dump_success = load_value(debug_out,out, type,constant->getOperand(0),arg);
            }
		
        }
    }
    else{
	
        std::string type_str;
        llvm::raw_string_ostream rso(type_str);
        arg->getType()->print(rso);
        debug_out << rso.str() << "\n";
	
        dump_success = load_value(debug_out,out, type,arg,arg);
        if(!dump_success)debug_out << "Kein Load/Instruction/Pointer" << "\n";
    }



    debug_out  << "EXITDUMP" << "\n"; 
    return dump_success;
}



//set the arguments and argument types of the abb
void set_arguments(OS::ABB * abb){
	
	
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
					std::stringstream debug_out;
					abb->set_call_name(func->getName().str());
					std::cerr <<  std::endl << "Call: " << abb->get_call_name() <<  std::endl;
					for (unsigned i = 0; i < call->getNumArgOperands(); ++i) {
						std::any value_argument; 
						llvm::Type* type_argument = nullptr;
						Value *arg = call->getArgOperand(i);
						if(dump_argument(debug_out,value_argument,type_argument, arg)){
							abb->set_argument(type_argument, type_argument);
							debug_argument(value_argument ,type_argument);
							//std::cerr << "\n------------------------------------------------- \n" << debug_out.str() << "\n------------------------------------------------- \n";
						}
					}

				}
			} else if (InvokeInst *invoke = dyn_cast<InvokeInst>(&inst)) {
				Function * func = invoke->getCalledFunction();
				if (func) {
					call_found = true;
					abb->set_call_name(func->getName().str());
					std::stringstream debug_out;
					std::cerr <<  std::endl << "Call: " << abb->get_call_name() <<  std::endl;
					debug_out <<  func->getName().str() << "\"";
					for (unsigned i = 0; i < invoke->getNumArgOperands(); ++i) {
						std::any value_argument; 
						llvm::Type* type_argument = nullptr;
						
						Value *arg = invoke->getArgOperand(i);
						if(dump_argument(debug_out,value_argument,type_argument, arg)){
							abb->set_argument(type_argument, type_argument);
							debug_argument(value_argument ,type_argument);
							//std::cerr << "\n------------------------------------------------- \n" << debug_out.str() << "\n------------------------------------------------- \n";
						}
					}
 				}
			}
		}
	}
}




//function to create all abbs in the graph
void abb_generation(graph::Graph *graph, OS::Function *function ) {

    //get llvm function reference
    llvm::Function* llvm_reference_function = function->get_llvm_reference();

    //get first basic block of the function

    //create ABB
    OS::ABB abb = OS::ABB(graph,typeid(OS::ABB()).hash_code(),function,llvm_reference_function->front().getName());

    //store coresponding basic block in ABB
    abb.set_BasicBlock(&(llvm_reference_function->getEntryBlock()));

    //queue for new created ABBs
    std::deque<OS::ABB*> queue; 

    //store abb in graph
    queue.push_back((OS::ABB *)graph->set_vertex(&abb));

    //queue with information, which abbs were already analyzed
    std::vector<size_t> visited_abbs;
    ////std::cerrr << "[set basicblock] basicblock_name = " << llvm_reference_function->front().getName().str() << std::endl;
    //iterate about the ABB queue

    while(!queue.empty()) {

		//get first element of the queue
        OS::ABB * old_abb = queue.front();
        queue.pop_front();

        //iterate about the successors of the ABB
        std::list<llvm::BasicBlock*> bbs = old_abb->get_BasicBlocks();
        std::list<llvm::BasicBlock*>::iterator it;

        //iterate about the basic block of the abb
		for (auto &it : old_abb->get_BasicBlocks()) {
			

            ////std::cerrr << "[master] basicblock_name = " << it->getName().str() << std::endl;
            //iterate about the successors of the abb
            for (auto it1 = succ_begin(it); it1 != succ_end(it); ++it1){

                ////std::cerrr << "[successor basicblock] basicblock_name = " << (*it1)->getName().str() << std::endl;
                //get sucessor basicblock reference
                llvm::BasicBlock *succ = *it1;

                //create temporary basic block
                OS::ABB new_abb = OS::ABB(graph, typeid(OS::ABB()).hash_code(),function, succ->getName());

                //check if the successor abb is already stored in the list
				
                if(!visited(new_abb.get_seed(), &visited_abbs)) {

                    if(succ->getName().str().empty()){
						
                        std::string type_str;
                        llvm::raw_string_ostream rso(type_str);
                        succ->print(rso);
                        //std::cerrr  << rso.str() << std::endl;
                    }
                    //store new abb in graph
                    OS::ABB * new_abb_reference = (OS::ABB *)graph->set_vertex(&new_abb);
					
                    //set abb predecessor reference and bb reference 
                    new_abb_reference->set_BasicBlock(succ);
                    new_abb_reference->set_ABB_predecessor(old_abb);

					
                    //set successor reference of old abb 
                    old_abb->set_ABB_successor(new_abb_reference);

                    //update the lists
                    queue.push_back(new_abb_reference);

                    visited_abbs.push_back(new_abb_reference->get_seed());

					//set the abb call`s argument values and types
					set_arguments(new_abb_reference);
                }else{
					
                    //get the alread existing abb from the graph
                    OS::ABB * existing_abb = (OS::ABB*) graph->get_vertex(new_abb.get_seed());

                    if(old_abb->get_seed() != existing_abb->get_seed()){
                        ////std::cerrr << "Connect:" << old_abb->get_name() << " with " << existing_abb->get_name() << std::endl;
						
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
		
            //TODO check if iterator is at end of instruction list of BasicBlock

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

	void LLVMPassage::run(graph::Graph graph) {
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
		
		
		
		llvm::SMDiagnostic Err;
		llvm::LLVMContext Context;
		
		//load the IR representation file
		std::unique_ptr<llvm::Module> module = parseIRFile(file_name, Err, Context);
		if(!module){
			std::cerr << "Could not load file:" << file_name << "\n" << std::endl;
		}
		
		//convert unique_ptr to shared_ptr
		std::shared_ptr<llvm::Module> shared_module = std::move(module);

		
		//graph module can just be created in the pass
		graph::Graph tmp_graph =  graph::Graph(shared_module);
		
		//graph.set_llvm_module(shared_module);
		
		//set the llvm module in the graph object
		tmp_graph.set_llvm_module(shared_module);
		
		//initialize the split counter
		unsigned split_counter = 0;
		
		
		//iterate about the functions of the llvm module
		for (auto &func : *shared_module){
			
			//create Function, set the module reference and function name and calculate the seed of the function
			OS::Function graph_function = OS::Function(&tmp_graph,typeid(OS::Function()).hash_code(),func.getName().str());
			
			
			//get arguments of the function
			llvm::FunctionType *argList = func.getFunctionType();
			
			//iterate about the arguments
			for(unsigned int i = 0; i < argList->getNumParams();i++){
				//store the argument references in the argument list
				graph_function.set_argument_type(argList->getParamType(i));
			}
			
			//store the return type of the function
			graph_function.set_return_type(func.getReturnType());
			
			
			//store llvm function reference
			graph_function.set_llvm_reference(&(func));
			
			split_basicblocks( &(func), &split_counter);
			
			for (auto &bb : func) {
				
				// Name all basic blocks
				if (!bb.getName().startswith("BB")) {
					std::stringstream ss;
					ss << "BB" << split_counter++;
					bb.setName(ss.str());
					
					/*
					if(bb.getName().startswith("BB6")) {
						
						std::string type_str;
						llvm::raw_string_ostream rso(type_str);
						bb.print(rso);
						//std::cerrr  << rso.str() << std::endl;
						
					}*/
				}
				//std::cerrr << "basicblock_name = " << bb.getName().str() << std::endl;
			}

			//store the generated function in the graph datastructure
			OS::Function * function_reference = (OS::Function*)tmp_graph.set_vertex(&graph_function);
			
			//generate and store the abbs of the function in the graph datatstructure
			abb_generation(&tmp_graph, function_reference );
		}
		
		
		
		
		
		
		
		
		//TEST Abschnitt
		std::list<graph::Vertex*> test_list =  tmp_graph.get_type_vertexes(typeid(OS::ABB()).hash_code());
		std::list<graph::Vertex*>::iterator it = test_list.begin();       //iterate about the list elements
		for(; it != test_list.end(); ++it){
	
			
			OS::ABB* pDerived = (OS::ABB*)(*it);
			if(pDerived) // always test  
			{
				//std::cerrr << "ABB Name: " << pDerived->get_name() << "\n" << std::endl;
				if(pDerived->get_name().empty()){
					
					/*
					//std::cerrr << "Empty" << std::endl;
					std::string type_str;
					llvm::raw_string_ostream rso(type_str);
					pDerived->get_BasicBlocks().front()->print(rso);
					//std::cerrr  << rso.str() << std::endl;
					*/
					
					
				}else{
					
					std::list<std::tuple<std::any,llvm::Type*>> tmp_list = pDerived->get_arguments();
					//std::cerrr << "Argument: " << pDerived->get_name();
					
					for (auto &argument_tuple : tmp_list){
						

						
						

						
					}	
				}
			}
			else
			{
				// fail to down-cast
			}
		}
		
		/*
		PRINT_NAME(char);
		PRINT_NAME(signed char);
		PRINT_NAME(unsigned char);
		PRINT_NAME(short);
		PRINT_NAME(unsigned short);
		PRINT_NAME(int);
		PRINT_NAME(unsigned int);
		PRINT_NAME(long);
		PRINT_NAME(unsigned long);
		PRINT_NAME(float);
		PRINT_NAME(double);
		PRINT_NAME(long double);
		PRINT_NAME(char*);
		PRINT_NAME(const char*);
		*/
	}
	std::vector<std::string> LLVMPassage::get_dependencies() {
		return {"OilPassage"};
	}
}
