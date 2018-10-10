#include "llvm.h"

#include <string>
#include <iostream>
#include <vector>

#include <cassert>
#include <stdexcept>


bool visited(size_t seed, std::vector<size_t> *vector){
    for (unsigned i=0; i < vector->size(); i++) {
        
        if(vector->at(i) == seed)return true;
    }
    return false;
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
    //std::cerr << "[set basicblock] basicblock_name = " << llvm_reference_function->front().getName().str() << std::endl;
    //iterate about the ABB queue
    while(!queue.empty()) {
    
        //get first element of the queue
        OS::ABB * old_abb = queue.front();
        queue.pop_front();
        
        
        
        //iterate about the successors of the ABB
        std::list<llvm::BasicBlock*> bbs = old_abb->get_BasicBlocks();
        std::list<llvm::BasicBlock*>::iterator it;
        
        //iterate about the basic block of the abb
        for (it = bbs.begin(); it != bbs.end(); ++it){

            std::cerr << "[master] basicblock_name = " << (*it)->getName().str() << std::endl;
            //iterate about the successors of the abb
            for (auto it1 = succ_begin(*it); it1 != succ_end(*it); ++it1){
                
                std::cerr << "[successor basicblock] basicblock_name = " << (*it1)->getName().str() << std::endl;
                //get sucessor basicblock reference
                llvm::BasicBlock *succ = *it1;
                
                //create temporary basic block
                OS::ABB new_abb = OS::ABB(graph, typeid(OS::ABB()).hash_code(),function, succ->getName());
                
                //check if the abb is already stored in the list
                if(!visited(new_abb.get_seed(), &visited_abbs)) {
                    
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

                    
                    
                }else{
                    
                    //get the alread existing abb from the graph
                    OS::ABB * existing_abb = (OS::ABB*) graph->get_vertex(new_abb.get_seed());
                    
                    //connect the abbs via reference
                    existing_abb->set_ABB_predecessor(old_abb);
                    old_abb->set_ABB_successor(existing_abb);                    
                }
            }
        }
    }
}




static bool isCallToLLVMIntrinsic(llvm::Instruction * inst) {
    if (llvm::CallInst* callInst = llvm::dyn_cast<llvm::CallInst>(inst)) {
        llvm::Function * func = callInst->getCalledFunction();
        if (func && func->getName().startswith("llvm.")) {
            return true;
        }
    }
    return false;
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
                //std::cerr << "split_counter = " << *split_counter << std::endl;
                bb = bb->splitBasicBlock(it, ss.str());
                it = bb->begin();
                ++it;
                
                if (llvm::isa<llvm::InvokeInst>(*it) || llvm::isa<llvm::CallInst>(*it))
                    continue;

                //TODO dead code?
                ss.str("");
                ss << "BB" << (*split_counter)++;
                //std::cerr << "split_counter = " << *split_counter << std::endl;
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
            std::string file_name = "/srv/scratch/steinmeier/ma-ben-steinmeier/arsa/test/appl.ll"; 
            
            
            
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
                        if(!bb.getName().startswith("BB6")) {
                           // std::cerr << "basicblock_name = " << bb.getSingleSuccessor()->getName().str() << std::endl;
                            
                        }
                    }
                    std::cerr << "basicblock_name = " << bb.getName().str() << std::endl;
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
                    std::cerr << "ABB Name: " << pDerived->get_name() << "\n" << std::endl;
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
