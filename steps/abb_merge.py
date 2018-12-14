import graph
import os
import sys
from collections import namedtuple

import logging
from .PrintGraph import DotFileParser
from .DominatorTree import DominanceAnalysis
#import syscalls_references

from native_step import Step
from itertools import chain
from collections import Iterable
from functools import reduce

class ABB_MergeStep(Step):
    """Merges the ABB."""
        
    def get_dependencies(self):
        
        return ['SyscallStep']
    
    
    MergeCandidates = namedtuple('MergeCandidates', 'entry_abb exit_abb inner_abbs')
    
    def merge_linear_abbs(self,g: graph.PyGraph):
        anyChanges = True
        while anyChanges:
            anyChanges = False
            # copy original dict
                            
            abb_list = g.get_type_vertices("ABB")
            
            for abb in abb_list:
                
                # Iterate over list of abbs dict KeysView
                #if abb.has_single_successor(E.function_level):
                #    successor = abb.definite_after(E.function_level)
                #print("abb",abb.get_name())
                
                for successor in abb.get_successors():
                    #print(successor.get_name())
                    #print("successor",successor.get_name())
                    #print("check merge",print(type(abb)),print(type(successor)))
                    if successor and self.can_be_merged(abb, successor):
                        self.do_merge(g,abb, successor)
                        anyChanges = True


    def find_branches_to_merge(self, abb):
        successors = abb.get_successors()
        if not len(successors) == 2:
            return None

        left_succ = successors[0]
        right_succ = successors[1]

        #   O abb
        #  | \
        #  | O right_succ
        #  | /
        #   O left_succ
        #
        if right_succ.has_single_successor():
            rss = right_succ.get_single_successor()
            if rss.get_seed() == left_succ.get_seed():
                return self.MergeCandidates(entry_abb = abb, exit_abb = left_succ, inner_abbs = set([right_succ]))

        #   O abb
        #  /|
        # O | left_succ
        # \ |
        #  O  right_succ
        #
        if left_succ.has_single_successor():
            lss = left_succ.get_single_successor()
            if lss.get_seed() == right_succ.get_seed():
                return self.MergeCandidates(entry_abb = abb, exit_abb = right_succ, inner_abbs = set([left_succ]))

        #
        #   O abb
        #  / \
        # O   O right_succ
        #  \ /
        #   O rss/lss
        if left_succ.has_single_successor() and right_succ.has_single_successor():
            lss = left_succ.get_single_successor()
            rss = right_succ.get_single_successor()
            if lss.get_seed() == rss.get_seed():
                return self.MergeCandidates(entry_abb = abb, exit_abb = lss, inner_abbs = set([right_succ, left_succ]))

        return None

    def merge_branches(self,g: graph.PyGraph):
        """
        Try to merge if - else branches with the following pattern:
                O      O
                / \     |\
                O  O     |O
                \/      |/
                O       O
        """
        anyChanges = True
        while anyChanges:
            anyChanges = False
            for abb in g.get_type_vertices("ABB"):
                mc = self.find_branches_to_merge(abb)
                #if mc and mc.entry_abb and mc.exit_abb:
                #	print("branch entry", mc.entry_abb.get_name(), "branch exit",mc.exit_abb.get_name())
                if mc and self.can_be_merged(mc.entry_abb, mc.exit_abb, mc.inner_abbs):
                #	print("can be merged")
                    self.do_merge(g,mc.entry_abb, mc.exit_abb, mc.inner_abbs)
                    anyChanges = True
                #else:
                #	print("can not be merged")


        #self.merge_stats.after_branch_merge = len(self.system_graph.abbs)

    def find_loops_to_merge(self,abb):
        # |
        # o<--->o
        # |
        successors = abb.get_successors()
        if not len(successors) == 2:
            return None

        left_succ = successors[0]
        right_succ = successors[1]

        if left_succ.has_single_successor():
            succ = left_succ.get_single_successor()
            if succ.get_seed() == abb.get_seed():
                return self.MergeCandidates(entry_abb = abb, exit_abb = abb,inner_abbs = {left_succ})
        if right_succ.has_single_successor():
            succ = right_succ.get_single_successor()
            if succ.get_seed() == abb.get_seed():
                return self.MergeCandidates(entry_abb = abb, exit_abb = abb,inner_abbs = {right_succ})

        return None

    def merge_loops(self,g: graph.PyGraph):
        anyChanges = True
        while anyChanges:
            anyChanges = False
            for abb in g.get_type_vertices("ABB"):
                mc = self.find_loops_to_merge(abb)
                if mc and self.can_be_merged(mc.entry_abb, mc.exit_abb, mc.inner_abbs):
                    self.do_merge(g,mc.entry_abb, mc.exit_abb, mc.inner_abbs)
                    anyChanges = True

        #self.merge_stats.after_loop_merge = len(g.get_type_vertices("ABB"))
            
    def do_merge( self,g: graph.PyGraph,entry_abb, exit_abb, inner_abbs = set()):
        
        #print("merge entry abb" , entry_abb.get_name())
        #print("merge exit abb" , exit_abb.get_name())
        #entry_abb.print_information()
        #exit_abb.print_information()
        #print('Trying to merge:', inner_abbs, exit_abb, 'into', entry_abb)
        assert not entry_abb.get_seed() == exit_abb.get_seed(), 'Entry ABB cannot merge itself into itself'
        #assert not entry_abb in inner_abbs
        
        #assert not entry_abb.relevant_callees and not exit_abb.relevant_callees, 'Mergeable ABBs may not call relevant functions'

        parent_function = entry_abb.get_parent_function()
        
        
        # adopt basic blocks and call sites
        for abb in (inner_abbs | {exit_abb}) - {entry_abb}:
            if abb.get_seed() != entry_abb.get_seed():

                if entry_abb.append_basic_blocks(abb) == False:
                    print("ERROR: abb to merge not in graph")
                    
                # Collect all call sites
                entry_abb.expend_call_sites(abb)
        
        
        
            
        # We merge everything into the entry block of a region.
        # Therefore, we just update the exit node of the entry to
        # preserve a correct entry/exit region
        entry_abb.adapt_exit_bb(exit_abb)

        
        # adopt outgoing edges
        for successor in exit_abb.get_successors():
            exit_abb.remove_successor(successor)
            seed = successor.get_seed()
            if not seed == entry_abb.get_seed(): # omit self loop
                entry_abb.set_successor(successor)
                successor.set_predecessor(entry_abb)
                successor.remove_predecessor(exit_abb)
                
        # Remove edges between entry and inner_abbs/exit
        for abb in inner_abbs | {entry_abb}:
            for successor in abb.get_successors():
                seed = successor.get_seed()
                for element in inner_abbs | {exit_abb}:
                    if element.get_seed() == seed:
                        abb.remove_successor(successor)
                        successor.remove_predecessor(abb)
                        
        # remove conflict when entry abb has the exit abb as predecessor 
        for predecessor in entry_abb.get_predecessors():
            seed = predecessor.get_seed()
            if exit_abb.get_seed() == seed:
                entry_abb.remove_predecessor(exit_abb)

        for abb in (inner_abbs | {exit_abb}):
            # Adapt exit ABB in corresponding function
            function_exit_abb = parent_function.get_exit_abb()
            
            if function_exit_abb!= None and function_exit_abb.get_seed() == abb.get_seed():
                parent_function.set_exit_abb(entry_abb)


        # Remove merged successors from any existing list
        for abb in (inner_abbs | {exit_abb}) - {entry_abb}:
            
            if not parent_function.remove_abb(abb.get_seed()):
                sys.exit("abb could not removed from function"+abb.get_name().decode("utf-8") )
                
            if not g.remove_vertex(abb.get_seed()):
                sys.exit("abb could not removed from graph")
    
        
        #entry_abb.print_information()

        
        #print("Merged: ", successor, "into:", abb)
        #print(abb.outgoing_edges)
        

    def can_be_merged(self,  entry_abb,  exit_abb, inner_abbs = set()):
        #print("can be merged entry")
        #Checks if a set of ABBs can be merged 
        
        for abb in inner_abbs:
            if not abb.is_mergeable() or entry_abb == None:
                return False
            
        for abb in  { entry_abb, exit_abb}:
            if not abb.is_mergeable() or entry_abb == None:
                return False
            
        
        
        if entry_abb.get_seed() != exit_abb.get_seed():
            
            for exit_successor in exit_abb.get_successors():
                #The exit node may not have any edge to an inner ABB
                seed = exit_successor.get_seed()
                for element in inner_abbs:
                    if seed == element.get_seed():
                        return False

            for exit_predecessor in exit_abb.get_predecessors():
                # The exit node may not be reachable from the outside
                flag = False
                seed = exit_predecessor.get_seed()
                for element in inner_abbs :
                    if element.get_seed() == seed:
                        flag = True
                        break
                    
                if entry_abb.get_seed() == seed:
                        flag = True
                
                if flag == False:
                    return False
                
            for entry_successor in entry_abb.get_successors():
                # The entry node may only be followed by any inner ABB or the exit ABB
                seed = entry_successor.get_seed()
                flag = False
                for element in inner_abbs:
                    if seed == element.get_seed():
                        flag = True
                        break
                        
                if seed == exit_abb.get_seed():
                    flag = True
                    
                if flag == False:
                    return False
                
        else: # entry_abb == exit_abb
            #TODO bug
            if len(inner_abbs) == 0:
                return False
            # Intentionally left blank:
            # We can only check if "some" predecessors are within the inner_abb region
        
        for inner_abb in inner_abbs:
            
            # Any inner ABB may only succeed any other inner ABB or the entry ABB
            for inner_predecessor in inner_abb.get_predecessors():
                flag = False
                seed = inner_predecessor.get_seed()
                for element in inner_abbs:
                    if element.get_seed() == seed:
                        flag = True
                if entry_abb.get_seed() == seed:
                    flag = True
                
                #if flag == False:
                if not flag:
                    return False
            
        return True



    def find_region(self, start, end):
        region = set([start, end])
        ws = []
        visited = set()
        
        visited.add(start.get_name())
        visited.add(end.get_name())
        ws.append(start)
        #print(visited)
        while len(ws)>0:
            cur = ws.pop()
            visited.add(cur.get_name())
            region.add(cur)
            for node in cur.get_successors():
                flag = True
                for element in visited:
                    if element == node.get_name():
                        flag = False
                        break
                    
                if  flag == True:
                    #print("append" , node.get_name(),node.get_seed())
                    ws.append(node)
        
        
        return region
    
    def merge_dominance(self,g: graph.PyGraph):

        for func in g.get_type_vertices("Function"):
            # Filter some functions
            
            function_abbs = func.get_atomic_basic_blocks()
            
            #TODO
            #if func.get_has_syscall() == False:
            #	continue
            
            
            if len(function_abbs) <= 3 or func.get_exit_abb() == None:
                continue

            # Forward analysis

            #print("dom" , func.get_entry_abb())
            dom = DominanceAnalysis(forward = True)
            dom.do(g,nodes=function_abbs,entry =func.get_entry_abb())

            # Backward analysis
            #print("post_dom" , func.get_exit_abb())
            post_dom = DominanceAnalysis(forward = False)
            post_dom.do(g,nodes=function_abbs,entry =func.get_exit_abb())
            removed = set()
            #print("HELLO")
            #print(dom.immdom_tree)
            #print(post_dom.immdom_tree)
            
            for abb in function_abbs:
                if abb.get_seed() in removed:
                    continue
                
                #if func.get_entry_abb().get_seed == abb.get_seed():
                #	continue
                
                #print( dom.immdom_tree)
                
                #start = dom.immdom_tree[abb.get_seed()]
                #end   = post_dom.immdom_tree[abb.get_seed()]
                #TODO validate
                
                start = abb.get_dominator();
                end = abb.get_postdominator();
                
                    
                if start and end and start != end:

                    
                    region = self.find_region(start, end)
                    
                        
                    
                    inner = set()
                    
                    for element in region:
                        if element.get_seed() != start.get_seed() and element.get_seed() != end.get_seed():
                            inner.add(element)
                    
                    
                    # Was there already some subset removed?
                    if start.get_seed() in removed or end.get_seed() in removed:
                        continue
                    
                    tmp_inner = inner
                    inner = set()
                    
                    for inner_element in tmp_inner:
                        #print("tmp inner" , inner_element.get_name())
                        if not inner_element.get_seed() in removed:
                            inner.add(inner_element)

                            
                            
                    #print("start",start.get_name(),"end", end.get_name())
                    
                    #for element in inner:
                        #print("inner",element.get_name())
                    
                    if self.can_be_merged(start, end, inner):
                        
                        self.do_merge(g,start, end, inner)
                        # Mark as removed
                        removed.add(end.get_seed())
                        #print(end.get_name())
                        #print(start.get_name())
                        for element in inner:
                            #print(element.get_name())
                            removed.add(element.get_seed())

        #self.merge_stats.after_dominance_merge = len(self.system_graph.abbs)
    

    def run(self, g: graph.PyGraph):
        
                    
        function_list = g.get_type_vertices("Function")
        initial_abb_list = g.get_type_vertices("ABB")
        
        
        #iterate about the functions
        for function in function_list:
            if function.get_has_syscall() == False:
                #iterate about the abbs of the function
                already_visited = []
                function_list = []
                

                #DFS for function
                function_list.append(function)
                
                while len(function_list) > 0:
                    tmp_function = function_list[-1]
                    del function_list[-1]
                    success = False
                    if not tmp_function.get_seed() in already_visited:
                        already_visited.append(tmp_function.get_seed())
                        
                        abb_list = tmp_function.get_atomic_basic_blocks()
                        
                        for abb in abb_list:
                            
                            if abb.get_call_type() == graph.call_definition_type.func_call:
                                called_functions = abb.get_called_functions()
                                for called_function in called_functions:
                                    function_list.append(called_function)
                                
                            elif abb.get_call_type() == graph.call_definition_type.sys_call:
                                function.set_has_syscall(True)
                                success = True
                                break
                            
                    if success == True:
                        break
                
        printer = DotFileParser(g)
        
        printer.print_functions(g,"before_merge")
        
        current_size = None
        
        initial_abb_count = len(initial_abb_list)
        
        #merge dominance regions
        self.merge_dominance(g)
        
        initial_abb_list = g.get_type_vertices("ABB")
        
        initial_abb_count = len(initial_abb_list)
   
        while current_size != initial_abb_count:
            
            tmp_abb_list = g.get_type_vertices("ABB")
            initial_abb_count = len(tmp_abb_list)
            
            # linear merging:
            self.merge_linear_abbs(g)
            
            # try to merge if-else branches
            self.merge_branches(g)

            # merge loop regions
            self.merge_loops(g)

            tmp_abb_list = g.get_type_vertices("ABB")
            current_size = len(tmp_abb_list)
        
        printer.print_functions(g,"after_merge")


        
        
