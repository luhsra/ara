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

class DominanceAnalysis():
	"""Implements a dominator analysis on the system level control flow
	graph. A quadradic algorithm for determining the immdoms is used.

	"""

	def __init__(self, forward=True,graph = None):

		self.graph = graph
		self.immdom_tree = None
		self.forward = forward


	def incoming(self, node):
		if self.forward:
			return node.get_predecessors()
		else:
			return node.get_successors()

	def outgoing(self, node):
		if self.forward:
			return node.get_successors()
		else:
			return node.get_predecessors()

	def find_dominators(self):
		# Each node is mapped to the set of its dominators
		dom = {}
		start_nodes = set()
		for abb in self.nodes:
			# The start node dominates itself
			if len(self.incoming(abb)) == 0 and\
				len(self.outgoing(abb)) > 0:
				dom[abb.get_seed()] = set([abb])
				start_nodes.add(abb)
			elif len(self.incoming(abb)) == 0 and len(self.outgoing(abb)) == 0:
				pass
			else:
				dom[abb.get_seed()] = set(self.nodes)
	
		#for key, value in dom.items():
			#print(key,"--------------")
			#for abb in value:
				#print(abb.get_seed())
		
		changes = True
		while changes:
			changes = False
			
			for abb in self.nodes:
				
				for tmp_abb in start_nodes:
					if abb.get_seed() == tmp_abb.get_seed():
						continue
			
				if not abb.get_seed() in dom:
					continue
				
			
				
				dominators = [dom[x.get_seed()] for x in self.incoming(abb)]
				
				#print("------dominator--------")
				#print(dominators)
				##for set_value in dominators:
					##for tmp in set_value:
						##print(tmp.get_name())
				#print("--------end-----------")
				
				#print(dominators)
				
				if dominators:
					intersection = reduce(lambda x, y: x & y, dominators)
				else:
					intersection = set()
					
				#print("-----intersection----")
				#print(intersection)
				#print("--------end-----------")
				
				new = set([abb]) | intersection
				
				tmp_new = []
				for element in new:
					tmp_new.append(element.get_seed())
				
				tmp_dom = []
				for element in dom[abb.get_seed()]:
					tmp_dom.append(element.get_seed())
				
				if set(tmp_dom) != set(tmp_new):
					changes = True
					dom[abb.get_seed()] = new
					
		return start_nodes, dom

	def find_imdom(self, abb, dominators, visited, cur):
		imdom = None
		visited.add(cur)
		# Is one of the direct predecessors a dominator?
		# -> Return it
		for pred in self.incoming(cur):
			for tmp_abb in dominators:
				if pred.get_seed() == tmp_abb.get_seed():
					#print("immediate dom:",pred.get_name())
					return pred

		# Otherwise: Depth-first search!
		for pred in self.incoming(cur):
			for tmp_abb in visited:
				if pred.get_seed() == tmp_abb.get_seed():
					continue
			
			ret = self.find_imdom(abb, dominators, visited, pred)
			# If we have found an immediate dominator, we return
			# it. Otherwise we use the next possible path.
			if ret:
				#print("bfs dom:",pred.get_name())
				return ret
		# On this path we found a loop
		return None

	def do(self,g: graph.PyGraph, nodes=None , entry = None):
		if nodes is not None:
			self.nodes = nodes
		else:
			print("no abbs were commited to the dominance tree analysis")

		start_nodes, dom = self.find_dominators()
		
		#check if the entry argument is a real start abb
		check = None
		for start_node in start_nodes:
			if start_node.get_seed() == entry.get_seed():
				check = start_node
				
		assert check != None
		
		self.immdom_tree = dict()
		
		for x in start_nodes:
			if x.get_seed() == check.get_seed():
				self.immdom_tree[x.get_seed()] = None
			else:
				self.immdom_tree[x.get_seed()] = check
					
		
		
		self.immdom_tree_keys = []
		for start_node in start_nodes:
			#print("start_node:",start_node.get_name())
			self.immdom_tree[start_node.get_seed()] = None
		
		for abb_seed in dom:
			
			continue_flag = False
			
			abb = g.get_vertex(abb_seed)
			for tmp_abb in start_nodes:
				if abb.get_seed() == tmp_abb.get_seed():
					continue_flag = True
			#print("abb  node:",abb.get_name())
			if continue_flag == True:
				#print("continued start node")
				continue
			
			visited = set()
			
			dominators = []
			
			for element in dom[abb.get_seed()]:
				if element.get_seed() != abb.get_seed():
					#print("dominator node:",element.get_name())
					dominators.append(element)
					
			
			#print(dom[abb.get_seed()])
			imdom = self.find_imdom(abb, dominators, visited, abb)
			#print("indom name:" , imdom.get_name())
			assert abb.get_seed()!= imdom.get_seed() and imdom != None
			
			self.immdom_tree[abb.get_seed()] = imdom
			self.immdom_tree_keys.append(abb.get_name())
