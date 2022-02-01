#!/usr/bin/env python3
import os
import sys
import logging
import random
import pprint
import itertools
from collections import defaultdict
from jinja2 import Template
import json
from json import JSONEncoder

class SimpleNamespace:
    print_long = False
    def __init__(self, type, dict):
        self.__dict__.update(dict)
        self.__type__ = type

    def __repr__(self):
        if SimpleNamespace.print_long:
            keys = sorted(self.__dict__)
            items = ("{}={!r}".format(k, self.__dict__[k]) for k in keys if k != '__type__')
            return "<{}({})>".format(self.__type__, ", ".join(items))
        else:
            return str(self)

    def __str__(self):
        return "<%s@%s>" % (getattr(self, "name", "<anon>"), self.__type__)

    def __hash__(self):
        return hash(self.name)

    def __lt__(self, other):
        return self.name < other.name

    def __iter__(self):
        return iter(self.__dict__.items())

    def dump(self, out=sys.stdout, depth = 0, visited=None):
        if visited is None:
            visited = set()


        def dump_object(obj, depth):
            if 'dump' in dir(obj):
                if obj in visited:
                    out.write(str(obj)+"\n")
                    out.write(" " * (depth))
                    return
                visited.add(obj)
                obj.dump(out, depth+1, visited)
            elif isinstance(obj, list):
                out.write("[\n")
                out.write(" " * (depth+2))
                for a in obj:
                    dump_object(a, depth+1)
                out.write("]\n")
                out.write(" " * depth)
            else:
                out.write(repr(v))
                out.write("\n")
                out.write(" " * depth)

        out.write("{{{}\n".format(str(self)))
        out.write(" " * (depth+1))

        for k,v in self.__dict__.items():
            if '__type__' == k:
                continue
            out.write("{} = ".format(k))
            dump_object(v, depth+1)


        out.write("}}\n".format(str(self)))
        out.write(" " * depth)





################################################################
# Generate DAGS
################################################################
def is_cyclic(graph):
    def helper(start, visited):
        """Returns True on cyclic"""
        if start in visited and visited[start]:
            return True
        if start in visited:
            return False
        visited[start] = True
        for children in graph[start]:
            x = helper(children, visited)
            if x is True:
                return True
        visited[start] = False

    visited = dict()
    for obj in graph:
        x = helper(obj, visited)
        if x is True:
            return True
    return False

assert is_cyclic({'a': ['b'], 'b':['c'], 'c':['a']})
assert not is_cyclic({'a': ['b'], 'b':['d'], 'c':['d'], 'd': []})

def find_roots(graph):
    roots = set(graph.keys())
    for childs in graph.values():
        roots -= set(childs)
    return roots


def create_dag_add_edge(rng, graph, is_valid = None):
    """Adds an edge to an already acyclic graph. Edges are only added, if is_valid
       returns True."""
    assert not is_cyclic(graph)
    while True:
        objects = list(sorted(graph.keys()))
        src = rng.choice(objects)
        dst = rng.choice(objects)

        if src == dst:
            continue
        if dst in graph[src]:
            continue
        graph[src].append(dst)
        if is_cyclic(graph):
            del graph[src][-1]
            continue
        if is_valid and not is_valid(graph, src, dst):
            del graph[src][-1]
            continue
        break
    return (src, dst)

def create_tree(rng, objects, max_children, root = None, graph = None):
    assert type(objects) == list
    objects = list(objects)
    rng.shuffle(objects)
    if graph is None:
        ret = {obj: [] for obj in objects}
    else:
        ret = graph

    def add_children(root, objects):
        return
        if not objects:
            return
        children_count = rng.randint(1, min(max_children, len(objects)))
        children = objects[:children_count]; del objects[:children_count]
        for child_id, child in enumerate(children):
            ret[root].append(child)
            add_children(child, objects[child_id::children_count])
        assert len(children) == children_count, (len(children), children_count)
    if root is None:
        root = objects[0]; del objects[0]
    else:
        objects.remove(root)
    add_children(root, objects)
    return ret

def create_tree(rng, objects, max_children, root=None, graph=None):
    logging.debug("------------------------create tree------------------------")
    assert type(objects) == list
    to_distribute = list(objects)
    rng.shuffle(to_distribute)
    if graph is None:
        ret = {obj: [] for obj in objects}
    else:
        ret = graph

    if root is None:
        root = to_distribute.pop()
    else:
        to_distribute.remove(root)
    free_parents = [root]
    while len(to_distribute):
        logging.debug("to distribute: %s", to_distribute)
        logging.debug("free parents:  %s", free_parents)
        parent = rng.choice(free_parents)
        logging.debug("chose parent:  %s", parent)
        free_parents.remove(parent)
        num_children = rng.randint(1,
                                   min(max_children,
                                       max_children-len(ret[parent]),
                                       len(to_distribute)))
        for _ in range(num_children):
            child = to_distribute.pop()
            ret[parent].append(child)
            free_parents.append(child)
            logging.debug("add child: %s", child)

    return ret

def get_parents(graph):
    """Invert the graph. Equals to a mapping from child -> parent"""
    ret = {obj: [] for obj in graph}
    for src, dsts in sorted(graph.items()):
        for dst in dsts:
            ret[dst].append(src)

    return ret


def pick_subtasks(rng, subtasks, n):
    assert False
    members = list(sorted(subtasks))
    rng.shuffle(members)
    return members[:n]

def pick_subtasks_cond(rng, subtasks, n, condition):
    candidates = list(sorted(subtasks)) # makes copy
    rng.shuffle(candidates)
    result = []
    while len(result) < n:
        new = candidates.pop()
        if condition(result, new):
            result.append(new)
    return result

def generate_system(config):
    rng = random.Random(config.seed)

    system = SimpleNamespace("System", {
        "rng": rng,
        'min_irq_id': 35,
        "tasks": [],
        "subtasks": [],
        'events': [],
        'resources': [],
        'cpus': [],
        'spinlocks': [],
    })
    # distribute tasks to cpus
    # each cpu gets at least one task
    cpu_membership = list(range(config.nCpus))
    # fill up the rest
    while len(cpu_membership) < config.nTasks:
        cpu_membership.append(rng.randint(0, config.nCpus-1))
    rng.shuffle(cpu_membership)
    logging.debug("cpu_membership (%s): %s", len(cpu_membership), cpu_membership)

    task_membership = list(range(0, config.nTasks)) # Every task gets at least one thread
    while len(task_membership) < config.nSubtasks:
        task = rng.randint(0, config.nTasks-1)
        task_membership.append(task)
    rng.shuffle(task_membership)
    logging.debug("task_membership (%s): %s", len(task_membership), task_membership)

    # Get some random priorities
    priorities = list(range(0, len(task_membership)))
    ret = rng.shuffle(priorities)
    logging.debug("prios (%s): %s", len(priorities), priorities)


    logging.info("------------------------------ make system object ----------")
    for cpu_id in range(0, config.nCpus):
        cpu = SimpleNamespace("CPU", {
            "name": f"CPU{cpu_id}",
            "id": cpu_id,
            "tasks": [],
            "subtasks": [],
            })
        system.cpus.append(cpu)
        logging.debug("create CPU: %s", cpu)

        for task_id in range(0, config.nTasks):
            if cpu_membership[task_id] != cpu_id:
                continue
            task = SimpleNamespace("Task", {
                "name": "Cpu{}Task{}".format(cpu_id, task_id),
                "id": f"C{cpu_id}T{task_id}",
                "cpu": cpu,
            })
            logging.debug("create Task: %s", task)
            system.tasks.append(task)
            cpu.tasks.append(task)

            task.subtasks = []
            for subtask_id in range(config.nSubtasks):
                if task_membership[subtask_id] != task_id:
                    continue
                logging.debug(subtask_id)
                subtask = SimpleNamespace("Subtask", {
                    "name": "CPU{}Task{}Subtask{}".format(cpu_id, task_id, subtask_id),
                    "task": task,
                    "static_priority": priorities.pop(),
                    "resources": [],
                    "events": [],
                    "operations": [],
                    "cpu": cpu,
                    "spinlocks": [],
                    "autostart": False,
                })
                system.subtasks.append(subtask)
                task.subtasks.append(subtask)
                cpu.subtasks.append(subtask)



    directed_dependencies = {}
    logging.info("---------------- make activation tree ----------------------")
    for task in system.tasks:
        # 1. Create a Tree form the subtasks
        logging.debug("create task tree for %s", task)
        dag = create_tree(rng, task.subtasks, config.depsMaxChildren)
        directed_dependencies.update(dag)
        # One of the subtask is the root of this task
        x = find_roots(dag)
        assert len(x) == 1
        task.entry_subtask = x.pop()


    # # Non Preemptability
    # nonPreempt = pick_subtasks(rng, system.subtasks, config.nNonPreemptTasks)
    # for subtask in system.subtasks:
    #     if subtask in nonPreempt:
    #         subtask.preemptable = False
    #     else:
    #         subtask.preemptable = True



    # 3. Add N extra dependencies
    waitingSubtasks = set()
    for i in range(0, config.nEvents):
        event = f"EVENT{i}"
        def is_valid(g, src, dst):
            if dst == dst.task.entry_subtask:
                return False # Task entries cannot wait
            if dst in waitingSubtasks:
                return False # Can only wait for one event

            return True
        (src, dst) = create_dag_add_edge(rng, directed_dependencies,
                                         is_valid)
        waitingSubtasks.add(dst)
        logging.info("waiting: %s -> %s", src, dst)
        src.operations.append(("SetEvent", dst, event))
        dst.operations.append(("WaitEvent", event))
        system.events.append(event)



    # # 5. Resources
    # for resource in range(0, config.nResourceGroups):
    #     resource = "RES{}".format(resource)
    #     member_count = int(2+rng.expovariate(1))
    #     members = pick_subtasks(rng, system.subtasks, member_count)
    #     for member in members:
    #         member.resources.append(resource)
    #         member.operations.append(("GetResource", resource))
    #         if resource not in system.resources:
    #                 system.resources.append(resource)
    # 5. SpinLocks
    logging.info("------------ generating %s locks --------", config.nLocks)
    for lock in range(0, config.nLocks):
        lock = f"LOCK{lock}"
        member_count = rng.randint(2, min(config.nCpus, int(config.nLockUsers)))
        def allowed(members, new):
            for member in members:
                if member.cpu == new.cpu:
                    return False
            return True
        members = pick_subtasks_cond(rng, system.subtasks, member_count, allowed)
        logging.debug("lock %s members: %s", lock, members)
        for member in members:
            member.spinlocks.append(lock)
            member.operations.append(("GetSpinlock", lock))
            if lock not in system.spinlocks:
                    system.spinlocks.append(lock)

    # # 6. IRQ Disable
    # irq_disable = pick_subtasks(rng, system.subtasks, config.nIRQBlockTasks)
    # for member in irq_disable:
    #     member.resources.append(resource)
    #     member.operations.append(("DisableInterrupts", ))

    # Find Subtask Entry
    for task in system.tasks:
        directed_dependencies.update(dag)


    # # 4. Who activates the tasks
    num_subtasks = len(system.subtasks)

    # 4. Who activates the subtasks
    inverse_graph = get_parents(directed_dependencies)
    for subtask, parents in sorted(inverse_graph.items()):
        parents = sorted(parents)
        rand = rng.uniform(0, 1)
        logging.debug("rand: %s", rand)
        if rand > config.R_AT_local: # cross core activation
            activator = rng.choice([st for st in  system.subtasks if st.cpu != subtask.cpu])
        else:
            if not parents:
                subtask.autostart = True
                continue
            activator = rng.choice(parents)
        activator.operations.append(("ActivateTask", subtask))
    #         else:
    #             event = "EVENT{}".format(idx)
    #             parent.operations.append(("SetEvent", subtask, event))
    #             subtask.operations.append(("WaitEvent", event))
    #             subtask.events.append(event)
    #             if event not in system.events:
    #                 system.events.append(event)

    dump_dot(directed_dependencies, "dependencies.dot",
             lambda n: n.name,
             lambda src, dst: ",".join([op[0] for op in src.operations if dst.name in str(op)])
    )

    return system


def dump_oil(system, fn):
    oil = {}
    oil['cpus'] = []
    oil['spinlocks'] = []
    for cpu in system.cpus:
        c = {}
        oil['cpus'].append(c)
        c['id'] = cpu.id
        c['task_groups'] = {}
        c['events'] = {}
        c['counters'] = {}
        c['resources'] = {}
        c['alarms'] = {}
        for task in cpu.tasks:
            tg = {}
            c['task_groups'][task.name] = tg
            tg['tasks'] = {}
            tg['name'] = task.name
            tg['promises'] = {'serialized': True}
            for subtask in task.subtasks:
                st = {}
                tg['tasks'][subtask.name] = st
                st['activation'] = 1
                st['autostart'] = subtask.autostart
                st['priority'] = subtask.static_priority
                st['schedule'] = True
                st['resources'] = subtask.resources
                for res in subtask.resources:
                    c['resources'][res] = {}
                st['spinlocks'] = subtask.spinlocks
                for spinlock in subtask.spinlocks:
                    if [spinlock] not in oil['spinlocks']:
                        oil['spinlocks'].append([spinlock])
                st['events'] = subtask.events
                for e in subtask.events:
                    c['events'][e] = {}


    with open(fn, "w+") as fd:
        json.dump(oil, fd)

def dump_dot(graph, fn, node_label, edge_label):
    with open(fn, "w+") as fd:
        fd.write("digraph G {\n")
        for node in graph.keys():
            fd.write("{} [label=\"{}\"];\n".format(node, node_label(node)))
        for src, dsts in graph.items():
            for dst in dsts:
                fd.write("{} -> {} [label=\"{}\"];\n".format(src, dst, edge_label(src, dst)))
        fd.write("}")

class InsertionPoint:
    def __init__(self, function, rng, config, syscall_allowed = True,
                 inside_critical=False):
        self.function = function
        self.rng = rng
        self.config = config
        self.syscall_allowed = syscall_allowed
        self.body = []
        self.called = None
        self.inside_critical = inside_critical

    def clone(self, syscall_allowed=None):
        ret = InsertionPoint(self.function, self.rng, self.config,
                             syscall_allowed=self.syscall_allowed,
                             inside_critical=self.inside_critical)
        if syscall_allowed is not None:
            ret.syscall_allowed = syscall_allowed

        # Record all inserts for this function
        self.function.inserts.append(ret)

        return ret

    def expand(self, insertion_points):
        ret = []
        for i in range(0, insertion_points):
            ret.append(self.clone())
            self.body.append(ret[-1])
        return ret

    def call_function(self, call_graph, other):
        call_graph[self.function].append(other)
        inverse_call_graph = get_parents(call_graph)

        if other.has_syscall:
            assert self.syscall_allowed

        class Call:
            def __init__(self, insert, func):
                self.insert = insert
                self.func = func
                self.had_syscall = func.has_syscall
            def dump(self, indent=2):
                if not self.insert.syscall_allowed:
                    pass
                    # assert self.func.has_syscall is False
                return "{}{}(); // has_syscall={}\n".format(
                    " " * indent,
                    self.func.name,
                    self.func.has_syscall
                )
        self.body = [Call(self, other)]
        self.called = other

        update_callgraph_information(call_graph)

        return []

    def call_system(self, syscall):
        assert self.syscall_allowed
        self.function.has_syscall = True

        if syscall[0] == 'GetResource':
            between = self.clone(False)
            between.inside_critical = True
            self.body = ["GetResource({});".format(syscall[1]),
                         between,
                         "ReleaseResource({});".format(syscall[1])]
            return [between]
        if syscall[0] == 'GetSpinlock':
            between = self.clone(False)
            between.inside_critical = True
            self.body = ["GetSpinlock({});".format(syscall[1]),
                         between,
                         "ReleaseSpinlock({});".format(syscall[1])]
            return [between]
        elif syscall[0] == "DisableInterrupts":
            between = self.clone(False)
            between.inside_critical = True
            self.body = ["SuspendAllInterrupts();",
                         between,
                         "ResumeAllInterrupts();"]
            return [between]
        elif syscall[0] == 'ActivateTask':
            self.body = ["ActivateTask({});".format(syscall[1].name)]
        elif syscall[0] == 'SetEvent':
            self.body = ["SetEvent({},{});".format(syscall[1].name, syscall[2])]
        elif syscall[0] == 'WaitEvent':
            self.body = ["WaitEvent({});".format(syscall[1])]
        elif syscall[0] == 'TerminateTask':
            self.body = ['TerminateTask();']
        else:
            assert False, ("Unknown Syscall", str(syscall))
        return []

    def assign_times(self):
        if self.inside_critical:
            bcet_bound = self.config.bcet_critical
            wcet_bound = self.config.wcet_critical
        else:
            bcet_bound = self.config.bcet_normal
            wcet_bound = self.config.wcet_normal
        self.bcet = self.rng.randint(1, bcet_bound)
        self.wcet = self.rng.randint(self.bcet, wcet_bound)


    def dump(self, indent = 2):
        self.assign_times()
        ret = ""
        for x in self.body:
            if hasattr(x, "dump"):
                ret += x.dump(indent)
            else:
                ret += " " * indent + x + "\n"
        if True or ret != "":
            rret = " " * indent + "/* %s x*/\n" %(repr(self))
            rret += " " * indent + f'ara_timing_info({self.bcet}, {self.wcet}); // {int(self.inside_critical)}\n'
            ret = rret + ret
        return ret

    def __repr__(self):
        return "<InsertionPoint %s.%d sys_allowed=%s inside_critical=%s>"%(
            self.function.name,
            self.function.inserts.index(self),
            self.syscall_allowed,
            self.inside_critical)

def update_callgraph_information(call_graph):
    inverse_call_graph = get_parents(call_graph)
    # Maximal Stack Ptr
    changed = True
    while changed:
        changed = False
        for child, parents in inverse_call_graph.items():
            max_stackptr = 0

            if child.has_syscall:
                for parent in parents:
                    if not parent.has_syscall:
                        parent.has_syscall = True
                        changed = True

    # Syscall Information
    changed = True
    while changed:
        changed = False
        # If a insert does not allow syscalls, all reachable syscalls do not
        # allow syscalls either
        for parent in call_graph:
            for call_insert in [x for x in parent.inserts
                                if x.called and x.syscall_allowed is False]:
                for called_insert in call_insert.called.inserts:
                    if called_insert.syscall_allowed is True:
                        changed = True
                        called_insert.syscall_allowed = False

def generate_callgraph(config, system):
    rng = system.rng

    call_graph = {}

    system_inserts = []
    for subtask in sorted(system.subtasks):
        entry = SimpleNamespace("Function", {
            "name": 'AUTOSAR_TASK_FUNC_{}'.format(subtask.name),
            'has_syscall': False,
            'is_entry': True,
            'inserts': [],
        })

        entry.body = InsertionPoint(entry, rng, config)
        entry.inserts.append(entry.body)
        subtask.entry_function = entry
        call_graph[entry] = []

        # Add all of our systemcalls
        entry_inserts = entry.body.expand(len(subtask.operations)+1)
        subtask_inserts = entry_inserts

        for op in subtask.operations:
            insert = rng.choice(subtask_inserts)
            if not insert.syscall_allowed:
                continue
            subtask_inserts.remove(insert)
            subtask_inserts.extend(
                insert.call_system(op)
            )
            update_callgraph_information(call_graph)

        system_inserts += subtask_inserts




    system.functions = sorted(call_graph.keys())
    for subtask in system.subtasks:
        exit_block = subtask.entry_function.body.expand(1)[0]
        exit_block.call_system(('TerminateTask',))


def dump_source(system, fn):
    p = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(p, "benchmark_gen_system.jinja")) as fd:
        t = Template(fd.read())
    with open(fn, "w+") as fd:
        fd.write(t.render(system=system, len=len))


config = SimpleNamespace("Config", {
    "R_AT_local": 0.9,
    "nCpus": 2,
    "nEvents": 0,
    "R_SE_local": 0.9,
    "nTasks": 6,
    "nLocks": 1,
    "nLockUsers": 2,
    "nSubtasks": 15,
    "depsMaxChildren": 3,
    "bcet_normal": 20,
    "wcet_normal": 200,
    "bcet_critical": 10,
    "wcet_critical": 30,

    "seed": 4711,
})


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Generate Stack Consuming Systems.')
    parser.add_argument('--oil', default="synthetic.oil",
                        help='where to store the oil file')
    parser.add_argument('--system', default="synthetic.cc",
                        help='where to store the source code')

    # System configuration
    parser.add_argument('--subtasks', metavar='N', type=int, default = 15,
                        help='Number of Subtasks')
    parser.add_argument('--cores', metavar='N', type=int, default = 2,
                        help='Number of cores')
    parser.add_argument('--locks', metavar='N', type=int, default = 1,
                        help='Number of spinlocks')
    parser.add_argument('--lock-users', metavar='N', type=int, default = 2,
                        help='Number of users per lock')
    parser.add_argument('--at-local', metavar='P', type=int, default = 90,
                        help='Percentage of AT-calls which are core local')
    parser.add_argument('--se-local', metavar='P', type=int, default = 90,
                        help='Percentage of SE-calls which are core local')
    parser.add_argument('--events', metavar='N', type=int, default = 0,
                        help='Number of events')



    parser.add_argument('--seed', metavar='N', default=1,
                        help='Seed used for random numbers')

    parser.add_argument('--verbose', '-v', action='store_true')

    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    config.seed = args.seed

    config.R_AT_local = args.at_local/100
    config.nCpus = args.cores
    config.nEvents = args.events
    config.R_SE_local = args.se_local/100
    config.nLocks = args.locks
    config.nLockUsers = args.lock_users
    config.nSubtasks = args.subtasks



    system = generate_system(config)
    dump_oil(system, args.oil)
    logging.error("oilfile: %s, %s", os.getcwd(), args.oil)

    generate_callgraph(config, system)
    dump_source(system, args.system)
