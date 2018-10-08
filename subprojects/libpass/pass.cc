#include "pass.h"


static bool isCallToLLVMIntrinsic(Instruction * inst) {
    if (CallInst* callInst = dyn_cast<CallInst>(inst)) {
        Function * func = callInst->getCalledFunction();
        if (func && func->getName().startswith("llvm.")) {
            return true;
        }
    }
    return false;
}


void split_basicblocks(Function *function,unsigned *split_counter) {
    std::list<BasicBlock *> bbs;
    for (BasicBlock &_bb : *function) {
        bbs.push_back(&_bb);
    }
    for (BasicBlock *bb : bbs) {
        BasicBlock::iterator it = bb->begin();
        while (it != bb->end()) {
            //TODO check if iterator is at end of instruction list of BasicBlock
            while (isa<InvokeInst>(*it) || isa<CallInst>(*it)) {
                // If the call is an artifical function (e.g. @llvm.dbg.metadata)
                if (isCallToLLVMIntrinsic(&*it)) {
                    ++it;
                    continue;
                }

                std::stringstream ss;
                ss << "BB" << split_counter++;
                bb = bb->splitBasicBlock(it, ss.str());
                it = bb->begin();
                ++it;

                if (isa<InvokeInst>(*it) || isa<CallInst>(*it))
                    continue;

                //TODO dead code?
                ss.str("");
                ss << "BB" << split_counter++;
                bb = bb->splitBasicBlock(it, ss.str());
                it = bb->begin();
            }
            ++it;
        }
    }
}
            
void pass::Pass::run(graph::Graph graph, std::vector<std::string> files) {
                    
    SMDiagnostic Err;
    LLVMContext Context;
    
    //load the IR representation file
    std::unique_ptr<llvm::Module> module = parseIRFile(files.at(0), Err, Context);
    if(!module){
        std::cerr << "Could not load file:" << files.at(0) << "\n" << std::endl;
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
    for(Module::iterator func = shared_module->begin(), y = shared_module->end(); func!= y; ++func){
        
        //create Function, set the module reference and function name and calculate the seed of the function
        OS::Function graph_function = OS::Function(&tmp_graph,func->getName().str());
        
        //get arguments of the function
        FunctionType *argList = func->getFunctionType();
        
        //iterate about the arguments
        for(unsigned int i = 0; i < argList->getNumParams();i++){
            //store the argument references in the argument list
            graph_function.set_argument_type(argList->getParamType(i));
        }
        
        //store the return type of the function
        graph_function.set_return_type(func->getReturnType());
        
        
        //store llvm function reference
        graph_function.set_llvm_reference(&(*func));
        
        split_basicblocks( &(*func), &split_counter);
        
        for (auto &bb : *func) {

            // Name all basic blocks
            if (!bb.getName().startswith("BB")) {
                std::stringstream ss;
                ss << "BB" << split_counter++;
                bb.setName(ss.str());
            }
        }
    
        // Only non-empty functions
        for (auto &bb : *func) {
            
            OS::ABB abb = OS::ABB(&tmp_graph, &graph_function,bb.getName().str());
            /*
            abb = self.system_graph.new_abb([bb_name])
            assert not bb_name in abbs
            abbs[bb_name] = abb
            function.add_atomic_basic_block(abb)
            */
        }
        
        //store the generated element in the graph datastructure
        tmp_graph.set_vertex(&graph_function);
    }
}

   



/*
        # Block contains a call
        if "call" in bb_struct:
            callee = bb_struct["call"]
            
            
    # Entry ABB
    function.set_entry_abb(abbs[func_struct["entry"]])
    # CFG Connections
    for bb_name, bb_struct in func_struct.items():
        if not bb_name.startswith("BB"):
            continue
        for bb_next_name in bb_struct["successors"]:
            src = abbs[bb_name]
            dst = abbs[bb_next_name]
            src.add_cfg_edge(dst, E.function_level)


    # Remove Dangling Blocks that have no incoming blocks
    # edges, but aren't the entry block. It seems llvm does
    # generate such blocks.
    for abb in function.abbs:
        if len(abb.get_incoming_nodes(E.function_level)) == 0 \
            and abb != function.entry_abb:
            function.remove_abb(abb)

# Find all return blocks for functions
for function in self.system_graph.functions:
    ret_abbs = []
    for abb in function.abbs:
        if len(abb.get_outgoing_edges(E.function_level)) == 0:
            ret_abbs.append(abb)

    if len(ret_abbs) == 0:
        logging.info("Endless loop in %s", function)
    elif len(ret_abbs) > 1:
        # Add an artificial exit block
        abb = self.system_graph.new_abb()
        function.add_atomic_basic_block(abb)
        for ret in ret_abbs:
            ret.add_cfg_edge(abb, E.function_level)
        function.set_exit_abb(abb)
    else:
        function.set_exit_abb(ret_abbs[0])

    if isinstance(function, Subtask) and function.conf.is_isr:
        if not function.exit_abb or not function.exit_abb.isA(S.iret):
            # All ISR function get an additional iret block
            iret = self.system_graph.new_abb()
            function.add_atomic_basic_block(iret)
            iret.make_it_a_syscall(S.iret, [function])
            function.exit_abb.add_cfg_edge(iret, E.function_level)
            function.set_exit_abb(iret)

# Gather all called Functions in the ABBs, this has to be done, after all ABBs are present
for func_struct in self.structure.values():
    for bb_name, bb_struct in func_struct.items():
        if not bb_name.startswith("BB"):
            continue

        # Block contains a call
        if "call" in bb_struct:
            (callee, args) = bb_struct["call"], bb_struct["arguments"]

            abbs[bb_name].directly_called_function_name = callee
            abbs[bb_name].call_sites.append( (bb_name, callee, args) )
            callee = self.system_graph.find(Function, callee)
            if callee:
                abbs[bb_name].directly_called_function = callee
                abbs[bb_name].function.called_functions.add(callee)
                callee.called_by.add(abbs[bb_name].function)

*/



