#!/usr/bin/python3 
"""Automatic Real-time System Analyzer"""
import importlib
import sys
import graph_tool


def load(what, where):
    module = importlib.import_module(what)
    sys.modules[where] = module


sys.path = ["/mnt/c/Users/Sebastian/Documents/Studium/Bachelor/BA/Git/ara",
            "/mnt/c/Users/Sebastian/Documents/Studium/Bachelor/BA/Git/ara/buildProject/subprojects/pyllco",
            "/mnt/c/Users/Sebastian/Documents/Studium/Bachelor/BA/Git/ara/buildProject/ara/steps/native",
            "/mnt/c/Users/Sebastian/Documents/Studium/Bachelor/BA/Git/ara/buildProject/ara/graph/cgraph"] + sys.path

load("graph_data", "ara.graph.graph_data")
load("py_logging", "ara.steps.py_logging")
load("step", "ara.steps.step")
#load("graphics_graph_view", "ara.visualization.graphics_graph_view")

import ara.ara as _ara
import ara.visualization.gui_manager
sys.exit()
