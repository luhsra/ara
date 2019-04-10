project('ara', 'cpp',
	default_options : ['warning_level=3',
	                   'cpp_std=c++17',
	                   'buildtype=debugoptimized'])

cython = find_program('cython')
py3_mod = import('python')
py3_inst = py3_mod.find_installation('python3')

llvm_dep = dependency('llvm', version : '>=7.0')

cython_flags = ['-Wextra', '--cplus', '-3']

build_dir = meson.current_build_dir()
source_dir = meson.source_root()

subdir('libgraph')
subdir('steps')
subdir('appl')
subdir('test')

dump_cmds = files('utils/dump_cmds.py')
ara = files('ara.py')

sh = custom_target('ara-sh',
	input: ara,
	output: 'ara.sh',
	command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', '#!/bin/sh\nPYTHONPATH=' + graphdir + ':' + stepdir + ' ' + (source_dir / 'ara.py') + ' $@\n'],
	build_by_default: true
)

# TODO convert this into a proper test
test('ara_tester',
   py3_inst,
   args: [files('ara.py'), freertos_thesis_print, '--os', 'freertos', '--log-level', 'debug'],
#   #args: [files('ara.py', 'Smartplug/main.ll','Smartplug/cloud.ll','Smartplug/http_server.ll','Smartplug/plc.ll','Smartplug/power_meter.ll','Smartplug/system.ll'), '--os', 'freertos'],
#   
#   #args : [files('ara.py'), '--os', 'freertos', freertos_targets[1]],
#   #args : [files('ara.py'), '--os', 'freertos', freertos_targets[16]],
# 
#   #args : [files('ara.py'), '--os', 'osek', osek_targets[4]],
# 
#   #args : [files('ara.py'), '--os', 'osek', '--log-level', 'debug','--oilfile' , 'system-without-alarms.oil',  osek_targets[4]],
# 
   env : ['PYTHONPATH=' + stepdir + ':' + graphdir]
)

test('gps_logger',
   py3_inst,
   args: [files('ara.py'), gpslogger_targets, '--os', 'freertos', '--log-level', 'debug'],
   env : ['PYTHONPATH=' + stepdir + ':' + graphdir]
)

test('ospert',
   py3_inst,
   args: [files('ara.py'), freertos_ospert, '--os', 'freertos', '--log-level', 'debug'],
   env : ['PYTHONPATH=' + stepdir + ':' + graphdir]
)
