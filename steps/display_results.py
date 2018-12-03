import graph
import os
import sys
from collections import namedtuple

import logging
from .PrintGraph import DotFileParser

#import syscalls_references

from native_step import Step
from itertools import chain
from collections import Iterable
from functools import reduce

class DisplayResultsStep(Step):
	"""Merges the ABB."""
				
	def get_dependencies(self):
		return ['DetectInteractionsStep']

	def run(self, g: graph.PyGraph):
		
				
		printer = DotFileParser(g)
		
		printer.print_instances(g,"instances")
		
		


		
		
