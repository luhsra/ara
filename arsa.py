#!/usr/bin/env python3

"""Automated Realtime System Analysis"""


import subprocess
import logging

import graph
#import pass1
import argparse
import sys
import passagemanager

from passages import OilPassage

from passages import Test1Passage
from passages import Test2Passage
from passages import Test3Passage
from passages import Test4Passage


#select the operating system: 0 = OSEK; 1 = FreeRTOS
realtime_system = 1;
application_file = "g.cc"


def execute_shellcommands(commands,shell_flag):
    """execute_shellcommands is used to  generate the makefile, build the pass and run the pass on the application code
    """
    try:
        proc = subprocess.Popen(commands,shell=shell_flag,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        stdout, stderr = proc.communicate()
        print(stdout)

        if proc.returncode != 0:

            logging.error('Call of: '+  " ".join(str(x) for x in commands) + '\nfailed with:')
            stderr = stderr.decode('utf8').strip('\n')
            for line in stderr.split('\n'):
                logging.error(line)

    except subprocess.CalledProcessError as e:
        raise RuntimeError("command '{}' return with error (code {}): {}".format(e.cmd, e.returncode, e.output))
    return



def main():

    #generate IR (.ll file) of application
    if realtime_system == 0:
        folder = "OSEK"
    else:
        folder = "FreeRTOS"

    commands = ["clang-6.0", "-S", "-emit-llvm", "../appl/" + folder + "/" +application_file, "--std=c++11",  "-o", "../test/appl.ll", "-target", "i386-pc-linux-gnu"]

    execute_shellcommands(commands, False)



    parser = argparse.ArgumentParser(prog=sys.argv[0],
                                     description=sys.modules[__name__].__doc__)
    parser.add_argument('--verbose', '-v', help="be verbose",
                        action="store_true", default=False)
    parser.add_argument('--os', '-O', help="specify the operation system",
                        choices=['freertos', 'osek'], default='osek')
    parser.add_argument('input_files', help="all LLVM-IR input files",
                        nargs='+')
    args = parser.parse_args()

    print(args.os)

    g = graph.PyGraph()


    p_manager = passagemanager.PassageManager(g, vars(args))

    #p = pass1.PyPass()
    #a = [x.encode('utf-8') for x in args.input_files]

    #p.run(g, a)

    p_manager.execute(['Test4Passage'])


if __name__ == '__main__':
    main()
