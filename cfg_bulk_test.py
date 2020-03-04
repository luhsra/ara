#!/usr/bin/env python3
# This is a script to perform multiple cfg_stats meson tests
# It needs to be placed inside ara/build
# For execution specifiy a list of passBuilder Strings inside a json file called pass_lists.json 

import json
import subprocess
import re

# load pass lists from file
with open("pass_lists.json", "r") as read_file:
    pass_lists = json.load(read_file)

def replace_pass_list(pass_list): 
    cfg_json = {}
    icfg_json = {}
    with open('../test/cfg_stats.json', 'r') as f:
        cfg_json = json.load(f)
        cfg_json['steps'][0]['pass_list'] = pass_list
    with open('../test/cfg_stats.json', 'w') as f:
        json.dump(cfg_json, f, indent=4)
    with open('../test/icfg_stats.json', 'r') as f:
        icfg_json = json.load(f)
        icfg_json['steps'][0]['pass_list'] = pass_list
    with open('../test/icfg_stats.json', 'w') as f:
        json.dump(icfg_json, f, indent=4)

with open('gps_stats.txt', 'w') as gps_stats, open('gps_ipstats.txt', 'w') as gps_ipstats, open('smart_stats.txt', 'w') as smart_stats, open('smart_ipstats.txt', 'w') as smart_ipstats:
        for pass_list in pass_lists :
            replace_pass_list(pass_list)
            gps_test = subprocess.Popen(['meson', 'test', 'gps_stats', '-v'], stdout=subprocess.PIPE)
            gps_stats.write(pass_list + " " + gps_test.communicate()[0].decode('utf-8'))
            gps_iptest = subprocess.Popen(['meson', 'test', 'gps_ipstats', '-v'], stdout=subprocess.PIPE)
            gps_ipstats.write(pass_list + " " + gps_iptest.communicate()[0].decode('utf-8'))
            smart_test = subprocess.Popen(['meson', 'test', 'smart_stats', '-v'], stdout=subprocess.PIPE)
            smart_stats.write(pass_list + " " + smart_test.communicate()[0].decode('utf-8'))
            smart_iptest = subprocess.Popen(['meson', 'test', 'smart_ipstats', '-v'], stdout=subprocess.PIPE)
            smart_ipstats.write(pass_list + " " + smart_iptest.communicate()[0].decode('utf-8'))

# clean stat files using sed
subprocess.Popen(['sed', '-i', '/module.*/{N;s/\\n/ /;};s/\(module(.*)\).*/\\1/g;/module.*/{N;s/\\n/ /;};/Ok/d;/Fail/d;/Timeout/d;/1\\/1/d;/Unexpected/d;/Skipped/d;/^$/d', 'gps_stats.txt', 'gps_ipstats.txt', 'smart_stats.txt', 'smart_ipstats.txt'])

