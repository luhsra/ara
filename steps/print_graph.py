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

class PrintGraph():
	"""Implements a dominator analysis on the system level control flow
	graph. A quadradic algorithm for determining the immdoms is used.

	"""

	def __init__(self, forward=True,graph = None):

		self.graph = graph
		


	def print_function(self, function):
		
		f = open(function.get_name()+ ".dot","w+")
		
		f.write("digraph G {\n" )
		
		abb_list = function.get_atomic_basic_blocks()
		
		#iterate about the abbs of the function
		for abb in abb_list:
			for successor in abb.get_successors():
				f.write(abb.get_name() + " -> "successor.get_name() + ";\n" )
		
		if function.get_exit_block() != None:
			f.write(function.get_exit_block().get_name() + " [color=red];\n" )
		if function.get_entry_block() != None:
			f.write(function.get_entry_block().get_name() + " [color=green];\n" )
		f.write("}" )
		f.close() 
			
	
