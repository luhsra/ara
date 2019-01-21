import graph
import os
import sys
from collections import namedtuple

import logging
#import syscalls_references

from native_step import Step
from itertools import chain
from collections import Iterable
from functools import reduce


def validate_syscalls(valid_calls,vertex, inverse):
    
    for outgoing_edge in vertex.get_outgoing_edges():
        
        valid = False
        
        for valid_call in valid_calls:
            target_class = valid_calls[0]
            syscall_type = valid_calls[1]
            
            abb = outgoing_edge.get_abb_reference()
            
            abb_syscall_type = abb.get_syscall_type()
            
            if syscall_type == abb_syscall_type:
                
                valid = True
                break
        
        if invers == valid:
            print("warning")



class Python_ValidationStep(Step):
    """Merges the ABB."""
        
    def get_dependencies(self):
        
        return ['ValidationStep']
    
    
    

    
    def run(self, g: graph.PyGraph):
        
        
        print("Python validation")
        
        isr_list = g.get_type_vertices("ISR")
        
        
        #iterate about the isrs
        for isr in isr_list:
            
            if isr.get_category() == 1:
                
                valid_calls = [ (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.enable),
                                (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.disable),
                                (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.suspend),
                                (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.resume)
                ]
                validate_syscalls(valid_calls,isr,False)

            
            elif isr.get_category() == 2:
                
                valid_calls = [ (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.start_scheduler),
                                (graph.get_type_hash("Event"), cgraph.graph.syscall_definition_type.receive),
                                (graph.get_type_hash("Event"), cgraph.graph.syscall_definition_type.destroy),
                                (graph.get_type_hash("Task"), cgraph.graph.syscall_definition_type.chain)
                                (graph.get_type_hash("Task"), cgraph.graph.syscall_definition_type.destroy),
                                (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.schedule)
                ]
                validate_syscalls(valid_calls,isr,True)
        
        
        task_list = g.get_type_vertices("Task")
        
        #iterate about the isrs
        for task in task_list:
            
                valid_calls = [ (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.start_scheduler),

                ]
                validate_syscalls(valid_calls,task,False)
        
        hook_list = g.get_type_vertices("Hook")
        
        for hook in hook_list:
            
            if hook.get_hook_type() != cgraph.graph.hook_type.no_hook:
                valid_calls = [ (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.start_scheduler),
                                (graph.get_type_hash("Event"), cgraph.graph.syscall_definition_type.receive),
                                (graph.get_type_hash("Alarm"), cgraph.graph.syscall_definition_type.receive)
                                (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.suspend),
                                (graph.get_type_hash("RTOS"), cgraph.graph.syscall_definition_type.receive)
                ]
        
                validate_syscalls(valid_calls,hook,False)
            
          
                    
                
