#!/usr/bin/env python3.6

import logging
import sys

import stepmanager
import graph

from native_step import Step

def main():
    logging.basicConfig(level=logging.DEBUG)
    g = graph.PyGraph()
    config = {'oil': sys.argv[1], 'os': 'osek'}
    p_manager = stepmanager.StepManager(g, config)

    p_manager.execute(['OilStep'])

    print(g)


if __name__ == '__main__':
    main()
