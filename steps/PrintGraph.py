import graph
import os
import sys
from collections import namedtuple

import logging
#from .DominatorTree import DominanceAnalysis
#import syscalls_references

from native_step import Step
from itertools import chain
from collections import Iterable
from functools import reduce

class DotFileParser():
    """Implements a dominator analysis on the system level control flow
    graph. A quadradic algorithm for determining the immdoms is used.

    """

    def __init__(self,graph = None):

        self.graph = graph
        


    def print_functions(self, g, folder ):
        
        path = os.getcwd() + folder +"/"

        if not os.path.exists(path):
            os.makedirs(path)
        
        f = open(path+"functions_overview.dot","w+")
        
        f.write("digraph G {\n" )
        
        function_list = g.get_type_vertices("Function")
        for function in function_list:
            f.write("\tsubgraph " + function.get_name().decode("utf-8").replace(" ", "").replace(".", "_")  + "{\n") 
            
            f.write("\t\tnode [style=filled];\n")
            abb_list = function.get_atomic_basic_blocks()
            f.write("\t\t")
            #iterate about the abbs of the function
            for abb in abb_list:
                f.write("\""+ abb.get_name().decode("utf-8").replace(" ", "")+"\" ")
            
            f.write(";\n") 
            for abb in abb_list:
                for successor in abb.get_successors():
                    f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + " -> " + successor.get_name().decode("utf-8").replace(" ", "") + ";\n" )
                
                if abb.is_mergeable() == False:
                    f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"#FCD975\" style=filled label=<" +abb.get_name().decode("utf-8").replace(" ", "") + "<BR />\n")
                    for callname in  abb.get_call_names():
                    
                    
                        if  callname.decode("utf-8") == abb.get_syscall_name().decode("utf-8"):
                            f.write("<FONT POINT-SIZE=\"10\">" + "syscall: " + callname.decode("utf-8")  + "</FONT>>")
                        else:
                            f.write("<FONT POINT-SIZE=\"10\">" + "call: " + callname.decode("utf-8")  + "</FONT>>")
                
                    f.write("];\n") 
                else:
                    f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"#9ACEEB\" style=filled]" + ";\n" )
                        
                for predecessor in abb.get_predecessors():
                    f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + " -> " + predecessor.get_name().decode("utf-8").replace(" ", "") +  "[color=grey];\n" )
            
            if function.get_exit_abb() != None:
                f.write("\t\t"+function.get_exit_abb().get_name().decode("utf-8").replace(" ", "") + " [color=red style=filled] ;\n" )
            if function.get_entry_abb() != None:
                f.write("\t\t"+function.get_entry_abb().get_name().decode("utf-8").replace(" ", "") + " [color=green style=filled];\n" )
                
            f.write("\t\tlabel = \"" + function.get_name().decode("utf-8").replace(" ", "")  + "\";\n") 
            f.write("\t}\n") 
        f.write("}" )
            
        f.close() 
        
    
    def print_function_definition_relation(self,g, f, element):
        
        function = element.get_definition_function()
        f.write(element.get_name() + " -> " + function.get_name() + "\n")
        
    def print_os_instance_function_mapping(self,g, folder):
        
        path = os.getcwd() +"/"+ folder +"/"

        if not os.path.exists(path):
            os.makedirs(path)
        
        f = open(path+"instance_function_mapping.dot","w+")
        
        f.write("digraph G {\n" )
        
        self.print_instance_class( g,f,"Task", "salmon")
        self.print_instance_class( g,f,"Timer", "gold")
        self.print_instance_class( g,f,"ISR", "cadetblue1")

    
    
    
    def print_interactions(self,g, f, element):
        
        
        interactions = element.get_outgoing_edges()
        for interaction in interactions:
            print(type(interaction))
            start = element.get_name().decode("utf-8").replace(" ", "")
            print("HELLO")
            target = interaction.get_target_vertex()
            
            target_name = target.get_name().decode("utf-8").replace(" ", "")
            
            f.write(start + " -> " + target_name + "\n")
            
        
    
    def print_instance_class(self,g, f,instance_type, print_type,color):
        
        element_list = g.get_type_vertices(instance_type)
        
        for element in element_list:
            print(element.get_name())
            name = element.get_name().decode("utf-8").replace(" ", "")
            print(name)
            f.write("\t\t"+ name + "[fillcolor="+ color +" style=filled label=<" + name + "<BR />>];\n")
            if print_type == 0:
                self.print_interactions(g,f,element)
            if print_type == 1:
                 self.print_function_definition_relation(g,f,element)
        
    def print_instances(self, g, folder ):
        
        path = os.getcwd() + folder +"/"

        if not os.path.exists(path):
            os.makedirs(path)
        
        f = open(path+"instances_overview.dot","w+")
        
        f.write("digraph G {\n" )
        
        self.print_instance_class( g,f,"Task",0, "salmon")
        self.print_instance_class( g,f,"Event", 0,"darkseagreen1")
        self.print_instance_class( g,f,"Queue", 0,"deepskyblue")
        self.print_instance_class( g,f,"Alarm", 0,"grey")
        self.print_instance_class( g,f,"Timer", 0,"gold")
        self.print_instance_class( g,f,"Semaphore", 0,"cadetblue1")
        self.print_instance_class( g,f,"Buffer",0, "chocolate1")
        self.print_instance_class( g,f,"EventGroup",0, "aquamarine")
        
        f.write("\n}" )
            
        f.close() 
                
        

        
