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
        
        path = os.getcwd() + "/"+ folder +"/"

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
                
                if  abb.get_call_type() != graph.call_definition_type.computation:
                    
                    
                   

                    if abb.get_call_type() == graph.call_definition_type.func_call:
                         f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"palegreen\" style=filled label=<" +abb.get_name().decode("utf-8").replace(" ", "") + "<BR />\n")
                         f.write("<FONT POINT-SIZE=\"10\">" + "call: " +  abb.get_call_name().decode("utf-8")  + "</FONT>>")
                    
                    elif abb.get_call_type() == graph.call_definition_type.sys_call:
                        f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"#FCD975\" style=filled label=<" +abb.get_name().decode("utf-8").replace(" ", "") + "<BR />\n")
                        f.write("<FONT POINT-SIZE=\"10\">" + "syscall: " + abb.get_syscall_name().decode("utf-8")  + "</FONT>>")
 
                    else:
                        f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"#FCD975\" style=filled label=<" +abb.get_name().decode("utf-8").replace(" ", "") + "<BR />\n")
                        f.write("<FONT POINT-SIZE=\"10\">" + "ERROR</FONT>>")
                        
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
        
    
    def print_bb_functions(self, g, folder ):
        
        path = os.getcwd() + "/"+ folder +"/"

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
                
                if  abb.get_call_type() != graph.call_definition_type.computation:
                    
                    
                   

                    if abb.get_call_type() == graph.call_definition_type.func_call:
                         f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"#9ACEEB\" style=filled label=<" +abb.get_name().decode("utf-8").replace(" ", "") + "<BR />\n")
                         f.write("<FONT POINT-SIZE=\"10\">" + "call: " +  abb.get_call_name().decode("utf-8")  + "</FONT>>")
                    
                    elif abb.get_call_type() == graph.call_definition_type.sys_call:
                        f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"#9ACEEB\" style=filled label=<" +abb.get_name().decode("utf-8").replace(" ", "") + "<BR />\n")
                        f.write("<FONT POINT-SIZE=\"10\">" + "call: " + abb.get_syscall_name().decode("utf-8")  + "</FONT>>")
 
                    else:
                        f.write("\t\t"+abb.get_name().decode("utf-8").replace(" ", "") + "[fillcolor=\"#9ACEEB\" style=filled label=<" +abb.get_name().decode("utf-8").replace(" ", "") + "<BR />\n")
                        f.write("<FONT POINT-SIZE=\"10\">" + "ERROR</FONT>>")
                        
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
        f.write(element.get_name().decode("utf-8").replace(" ", "").replace(".", "_") + " -> " + function.get_name().decode("utf-8").replace(" ", "").replace(".", "_") + "\n")
        
        
    def print_os_instance_function_mapping(self,g, folder):
        
        path = os.getcwd() +"/"+ folder +"/"

        if not os.path.exists(path):
            os.makedirs(path)
        
        f = open(path+"instance_function_mapping.dot","w+")
        
        f.write("digraph G {\n" )
        
        self.print_instance_class( g,f,"Task",1,"salmon")
        self.print_instance_class( g,f,"Timer",1, "gold")
        self.print_instance_class( g,f,"ISR",1, "cadetblue1")

        f.write("\n}" )
            
        f.close() 
    
    
    def print_interactions(self,g, f, element):
        
        
        interactions = element.get_outgoing_edges()
        for interaction in interactions:
            edge_name = interaction.get_name().decode("utf-8").replace(" ", "").replace(".", "_") 
            target = interaction.get_target_vertex()
            start = interaction.get_start_vertex()
            if start.get_type() != graph.get_type_hash("ABB") and target.get_type() != graph.get_type_hash("Function"): 
                target_name = target.get_name().decode("utf-8").replace(" ", "").replace(".", "_") 
                start_name = start.get_name().decode("utf-8").replace(" ", "").replace(".", "_") 
                f.write(start_name + " -> " + target_name +  " [ label=\"" + edge_name  +   "\"];\n")
            
        
    def print_called_functions(self,g, f,element):
        for called_function in element.get_called_functions():
            f.write("\t\t"+element.get_name().decode("utf-8").replace(" ", "").replace(".", "_")  + " -> " + called_function.get_name().decode("utf-8").replace(" ", "").replace(".", "_")  +  "[color=black];\n" )
           
           
           
    def print_main(self,g, f,color):
        
        element_list = g.get_type_vertices("Function")
        
        main = element_list.pop()
        
        for function in element_list:
            if function.get_name().decode("utf-8") == "main":
                element_list.clear()
                main = function
                print("main found")
                break
    
        name = main.get_name().decode("utf-8").replace(" ", "").replace(".", "_") 
        
        f.write("\t\t"+ name + "[fillcolor="+ color +" style=filled label=<" + name + "<BR />>];\n")
        self.print_interactions(g,f,main)
           
    
    def print_instance_class(self,g, f,instance_type, print_type,color):
        
        element_list = g.get_type_vertices(instance_type)
        
        for element in element_list:
            
            name = element.get_name().decode("utf-8").replace(" ", "").replace(".", "_") 
          
            f.write("\t\t"+ name + "[fillcolor="+ color +" style=filled label=<" + name + "<BR />>];\n")
            if print_type == 0:
                self.print_interactions(g,f,element)
            elif print_type == 1:
                self.print_function_definition_relation(g,f,element)
            elif print_type == 2:
                self.print_called_functions(g,f,element)
        
    def print_instances(self, g, folder ):
        
        path = os.getcwd()+"/"+ folder +"/"
        
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
        self.print_instance_class( g,f,"ISR",0, "ivory")
        self.print_instance_class( g,f,"Resource",0, "orange")
        self.print_instance_class( g,f,"QueueSet",0, "yellow")
        self.print_main(g, f,"green")
        
        f.write("\n}" )
            
        f.close() 
                

    def print_function_interactions(self, g, folder ):
            
            path = os.getcwd() +"/"+ folder +"/"

            if not os.path.exists(path):
                os.makedirs(path)
            
            f = open(path+"function_interactions.dot","w+")
            
            f.write("digraph G {\n" )
            
            self.print_instance_class( g,f,"Function",2, "lavender")

            
            f.write("\n}" )
                
            f.close() 

        