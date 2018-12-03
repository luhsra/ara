#!/usr/bin/env python3
# vim: set et ts=4 sw=4:

"""Automated Realtime System Analysis"""


import subprocess
import logging

import graph
#import pass1
import argparse
import sys
import stepmanager


from steps import OilStep


def execute_shellcommands(commands, shell_flag):
	"""execute_shellcommands is used to  generate the makefile, build the pass
	and run the pass on the application code
	"""
	try:
		proc = subprocess.Popen(commands, shell=shell_flag,
								stdout=subprocess.PIPE,
								stderr=subprocess.PIPE)
		stdout, stderr = proc.communicate()
		print(stdout)

		if proc.returncode != 0:

			logging.error('Call of: ' + " ".join(str(x) for x in commands) +
						'\nfailed with:')
			stderr = stderr.decode('utf8').strip('\n')
			for line in stderr.split('\n'):
				logging.error(line)

	except subprocess.CalledProcessError:
		raise RuntimeError("command '{}' return with error (code {}): {}".format(e.cmd, e.returncode, e.output))
	return



def main():
	"""Entry point for ARSA."""

	parser = argparse.ArgumentParser(prog=sys.argv[0],
									description=sys.modules[__name__].__doc__)
	parser.add_argument('--verbose', '-v', help="be verbose",
						action="store_true", default=False)
	parser.add_argument('--os', '-O', help="specify the operation system",
						choices=['freertos', 'osek'], default='osek')
	parser.add_argument('input_files', help="all LLVM-IR input files",
						nargs='+')

	parser.add_argument('--application_file',
						help="application file which shall be transformed in .ll",
						nargs='+')

	args = parser.parse_args()
	# generate IR (.ll file) of application in dependency
	# of the transmitted argument
	if args.os == "freertos":
		folder = "FreeRTOS"
	else:
		folder = "OSEK"

	print(args.application_file)

	commands = ["clang-6.0", "-S", "-emit-llvm", "../appl/" + folder + "/"+ args.application_file[0],
				"--std=c++11", "-o", "../test/data/appl.ll",
				"-target", "i386-pc-linux-gnu" ,"-discard-value-names" ,"-###"]
		
	commands = ["/usr/lib/llvm-6.0/bin/clang", "-cc1", "-triple", "i386-pc-linux-gnu", "-emit-llvm" ,"-disable-free" ,"-disable-llvm-verifier", "-main-file-name", "l.cc", "-mrelocation-model" ,"static" ,"-mthread-model" ,"posix", "-mdisable-fp-elim" ,"-fmath-errno", "-masm-verbose" ,"-mconstructor-aliases", "-fuse-init-array", "-target-cpu", "pentium4" ,"-dwarf-column-info", "-debugger-tuning=gdb", "-coverage-notes-file", "/srv/scratch/steinmeier/ma-ben-steinmeier/arsa/build/../test/data/appl.gcno", "-resource-dir", "/usr/lib/llvm-6.0/lib/clang/6.0.0", "-internal-isystem" ,"/usr/bin/../lib/gcc/x86_64-linux-gnu/7.3.0/../../../../include/c++/7.3.0", "-internal-isystem", "/usr/bin/../lib/gcc/x86_64-linux-gnu/7.3.0/../../../../include/x86_64-linux-gnu/c++/7.3.0/32", "-internal-isystem", "/usr/bin/../lib/gcc/x86_64-linux-gnu/7.3.0/../../../../include/i386-pc-linux-gnu/c++/7.3.0" ,"-internal-isystem", "/usr/bin/../lib/gcc/x86_64-linux-gnu/7.3.0/../../../../include/c++/7.3.0/backward", "-internal-isystem", "/usr/include/clang/6.0.0/include/", "-internal-isystem", "/usr/local/include", "-internal-isystem" ,"/usr/lib/llvm-6.0/lib/clang/6.0.0/include" ,"-internal-externc-isystem", "/include", "-internal-externc-isystem" ,"/usr/include", "--std=c++11", "-fdeprecated-macro" ,"-fdebug-compilation-dir", "/srv/scratch/steinmeier/ma-ben-steinmeier/arsa/build", "-ferror-limit", "19" ,"-fmessage-length" ,"272" ,"-fobjc-runtime=gcc" ,"-fcxx-exceptions" ,"-fexceptions" ,"-fdiagnostics-show-option" ,"-fcolor-diagnostics","-o" ,"../test/data/appl.ll" ,"-x", "c++", "../appl/"+folder+"/"+args.application_file[0]]

	execute_shellcommands(commands, False)

	g = graph.PyGraph()

	p_manager = stepmanager.StepManager(g, vars(args))

	p_manager.execute(['LLVMStep','OilStep','SyscallStep' ,'ABB_MergeStep','FreeRTOSInstancesStep','DetectInteractionsStep','DisplayResultsStep'])


if __name__ == '__main__':
	main()
