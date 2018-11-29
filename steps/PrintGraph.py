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

class graph_print():
	"""Implements a dominator analysis on the system level control flow
	graph. A quadradic algorithm for determining the immdoms is used.

	"""

	def __init__(self,graph = None):

		self.graph = graph
		


	def print_function(self, function, folder ):
		
		path = os.getcwd() + folder +"/"

		if not os.path.exists(path):
			os.makedirs(path)
		
		f = open(path+function.get_name().decode("utf-8")+ ".dot","w+")
		
		f.write("digraph G {\n" )
		
		abb_list = function.get_atomic_basic_blocks()
		
		#iterate about the abbs of the function
		for abb in abb_list:
			for successor in abb.get_successors():
				f.write(abb.get_name().decode("utf-8") + " -> " + successor.get_name().decode("utf-8") + ";\n" )
			
			if abb.is_mergeable() == False:
				f.write(abb.get_name().decode("utf-8") + "[fillcolor=\"#FCD975\" style=filled label=<" +abb.get_name().decode("utf-8") + "<BR /> ")
				for callname in  abb.get_call_names():
				
				
					if  callname.decode("utf-8") == abb.get_syscall_name().decode("utf-8"):
						f.write("<FONT POINT-SIZE=\"10\">" + "syscall: " + callname.decode("utf-8")  + "</FONT>>")
					else:
						f.write("<FONT POINT-SIZE=\"10\">" + "call: " + callname.decode("utf-8")  + "</FONT>>")
			
				f.write("];\n") 
			else:
				f.write(abb.get_name().decode("utf-8") + "[fillcolor=\"#9ACEEB\" style=filled]" + ";\n" )
					
			for predecessor in abb.get_predecessors():
				f.write(abb.get_name().decode("utf-8") + " -> " + predecessor.get_name().decode("utf-8") +  "[color=grey];\n" )
		
		if function.get_exit_abb() != None:
			f.write(function.get_exit_abb().get_name().decode("utf-8") + " [color=red style=filled] ;\n" )
		if function.get_entry_abb() != None:
			f.write(function.get_entry_abb().get_name().decode("utf-8") + " [color=green style=filled];\n" )
		f.write("}" )
		f.close() 
			
	
