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


def validate_syscalls( valid_calls,vertex, inverse):
    
    for outgoing_edge in vertex.get_outgoing_edges():
        
        valid = False
        #check if the syscall is in list of valid syscalls
        for valid_call in valid_calls:
            #taget abstraction class
            target_class = valid_call[0]
            #target syscall type
            syscall_type = valid_call[1]
            
            abb = outgoing_edge.get_abb_reference()
            
            abb_syscall_type = abb.get_syscall_type()
            
            if syscall_type == abb_syscall_type:
                
                valid = True
                break
        
        if inverse == valid:
            print("Warning: invalid syscall typ", syscall_type, "in vertex" , vertex.get_name())
            break


def validate_osek_syscalls_in_different_abstractions( g: graph.PyGraph ):
    
    isr_list = g.get_type_vertices("ISR")
        
    #iterate about the isrs
    for isr in isr_list:
        
        #different syscalls allwoend in isrs from different type
        if isr.get_category() == 1:
            
            #list of all valid syscalls
            valid_calls = [ (graph.get_type_hash("RTOS"),graph.syscall_definition_type.enable),
                            (graph.get_type_hash("RTOS"), graph.syscall_definition_type.disable),
                            (graph.get_type_hash("RTOS"), graph.syscall_definition_type.suspend),
                            (graph.get_type_hash("RTOS"), graph.syscall_definition_type.resume)
            ]
            validate_syscalls(valid_calls,isr,False)

        
        elif isr.get_category() == 2:
            
            #list of all invalid syscalls
            valid_calls = [ (graph.get_type_hash("RTOS"), graph.syscall_definition_type.start_scheduler),
                            (graph.get_type_hash("Event"), graph.syscall_definition_type.receive),
                            (graph.get_type_hash("Event"), graph.syscall_definition_type.destroy),
                            (graph.get_type_hash("Task"), graph.syscall_definition_type.chain)
                            (graph.get_type_hash("Task"), graph.syscall_definition_type.destroy),
                            (graph.get_type_hash("RTOS"), graph.syscall_definition_type.schedule)
            ]
            validate_syscalls(valid_calls,isr,True)
    
    task_list = g.get_type_vertices("Task")
    
    #iterate about the tasks
    for task in task_list:
        
            #list of all invalid syscalls
            valid_calls = [ (graph.get_type_hash("RTOS"), graph.syscall_definition_type.start_scheduler),

            ]
            validate_syscalls(valid_calls,task,True)
    
    hook_list = g.get_type_vertices("Hook")
    
    #iterate about the hooks
    for hook in hook_list:
        
        if hook.get_hook_type() != graph.hook_type.no_hook:
            #list of all valid syscalls
            valid_calls = [ (graph.get_type_hash("RTOS"), graph.syscall_definition_type.start_scheduler),
                            (graph.get_type_hash("Event"), graph.syscall_definition_type.receive),
                            (graph.get_type_hash("Alarm"), graph.syscall_definition_type.receive)
                            (graph.get_type_hash("RTOS"), graph.syscall_definition_type.suspend),
                            (graph.get_type_hash("RTOS"), graph.syscall_definition_type.receive)
            ]
            validate_syscalls(valid_calls,hook,False)


def validate_osek_task_termination(g: graph.PyGraph ):
    task_list = g.get_type_vertices("Task")
        
    #iterate about the tasks
    for task in task_list:
        #get last outgoing syscall 
        edges = task.get_outgoing_edges()
        if not edges:
            continue
        last_syscall = edges[-1]
        #get abb reference from syscall
        abb_reference = last_syscall.get_abb_reference()
        if abb_reference is not None: 
            #check if last outgoing syscall is a termination or chain task syscall
            syscall_type = abb_reference.get_syscall_type()
            if syscall_type is not graph.syscall_definition_type.destroy and syscall_type is not graph.syscall_definition_type.chain:
                print("Warning: No termination or chain as last syscall in task", task.get_name())
            
            #TODO check that termination/chain syscall postdominates all other 
            #else:
                ##terminate or chain syscall detected, so this syscall has to postdominate all other
                #for syscall in edges:
                    #tmp_abb_reference = syscall.get_abb_reference()
                    ##dont check equal abbs
                    #if abb_reference.get_seed() != tmp_abb_reference.get_seed():
                        ##check that abb is postdominated by chain/terminate syscall
                        #if not abb_reference.postdominates(tmp_abb_reference):
                            #print("warning")
        
        
        
        
    
    


class Python_ValidationStep(Step):
    """Merges the ABB."""
        
    def get_dependencies(self):
        
        return ['ValidationStep']
    
    

    def run(self, g: graph.PyGraph):
        
        print("Run PythonValidationStep")
        
        os =  self._config["os"]
        
        if os == "osek":
            validate_osek_syscalls_in_different_abstractions(g)
            
            validate_osek_task_termination(g)
                    
                
        
            
          
                    
                
