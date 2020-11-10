#!/bin/bash

kill $(ps aux | grep ara.py | grep -v grep | sed 's, \+, ,g' | cut -d ' ' -f 2)
