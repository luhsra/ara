import graph
import os


from native_step import Step



class SyscallStep(Step):
	"""Reads an oil file and writes all information to the graph."""
	

	def run(self, g: graph.PyGraph):

		print("I'm an SyscallStep")
					


		
		
