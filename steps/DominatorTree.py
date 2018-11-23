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
				dom[abb] = set([abb])
				start_nodes.add(abb)
			elif len(self.incoming(abb)) == 0 and len(self.outgoing(abb)) == 0:
				pass
			else:
				dom[abb] = set(self.nodes)

		changes = True
		while changes:
			changes = False
			for abb in self.nodes:
				if abb in start_nodes:
					continue
				if not abb in dom:
					continue
				dominators = [dom[x] for x in self.incoming(abb)]
				if dominators:
					intersection = reduce(lambda x, y: x & y, dominators)
				else:
					intersection = set()
				new = set([abb]) | intersection
				if new != dom[abb]:
					changes = True
					dom[abb] = new
		return start_nodes, dom

	def find_imdom(self, abb, dominators, visited, cur):
		imdom = None
		visited.add(cur)
		# Is one of the direct predecessors a dominator?
		# -> Return it
		for pred in self.incoming(cur):
			if pred in dominators:
				return pred

		# Otherwise: Depth-first search!
		for pred in self.incoming(cur):
			if pred in visited:
				continue
			ret = self.find_imdom(abb, dominators, visited, pred)
			# If we have found an immediate dominator, we return
			# it. Otherwise we use the next possible path.
			if ret:
				return ret
		# On this path we found a loop
		return None

	def do(self, nodes=None):
		if nodes is not None:
			self.nodes = nodes
		else:
			print("no abbs were commited to the dominance tree analysis")

		start_nodes, dom = self.find_dominators()

		for abb in dom:
			if abb in start_nodes:
				continue
			visited = set()
			dominators = dom[abb] - set([abb])
			imdom = self.find_imdom(abb, dominators, visited, abb)
			assert abb != imdom and imdom != None
			self.immdom_tree[abb] = imdom

