project('ara', 'cpp',
    default_options : ['warning_level=3',
                       'cpp_std=c++17',
                       'buildtype=debugoptimized'])

add_project_arguments('-Werror=return-type', language: ['c', 'cpp'])

cython = find_program('cython')
py3_mod = import('python')
py3_inst = py3_mod.find_installation('python3', modules: ['pydot', 'graph_tool'])

llvm_version = ['>=9', '<10']

llvm_dep = dependency('llvm', version: llvm_version, include_type: 'system')
boost_dep = dependency('boost', modules: ['graph', 'python3'], include_type: 'system')
graph_tool_dep = dependency('graph-tool-py' + py3_inst.language_version(), include_type: 'system')

cython_flags = ['-Wextra', '--cplus', '-3']

build_dir = meson.current_build_dir()
source_dir = meson.source_root()

subdir('common')
subdir('graph')
subdir('steps')
subdir('appl')

python_path = 'PYTHONPATH=' + ':'.join([source_dir, stepdir, llvm_wrapper_dir])

subdir('test')

dump_cmds = files('utils/dump_cmds.py')
ara = files('ara.py')

sh = custom_target('ara-sh',
    input: ara,
    output: 'ara.sh',
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', '#!/bin/sh\n' + python_path + ' ' + (source_dir / 'ara.py') + ' $@\n'],
    build_by_default: true
)

extra_settings = files('test/extra_settings.json')

# TODO convert this into a proper test
test('const_prop',
   py3_inst,
   args: [files('ara.py'), const_prop, '--os', 'FreeRTOS',
          '--log-level', 'debug',
          '--step', 'ConstProp'],
   env : [python_path]
)

test('dead_code',
   py3_inst,
   args: [files('ara.py'), dead_code, '--os', 'FreeRTOS',
          '--log-level', 'debug',
          '--step', 'DeadCodeElimination'],
   env : [python_path]
)

test('gpslogger',
   py3_inst,
   args: [files('ara.py'), gpslogger_targets, '--os', 'FreeRTOS', '--log-level', 'debug'],
   env : [python_path]
)

test('smartplug',
   py3_inst,
   args: [files('ara.py'), smartplug_targets, '--os', 'FreeRTOS', '--log-level', 'debug'],
   env : [python_path]
)

test('copter-without-alarms',
   py3_inst,
   args: [files('ara.py'), osek_copter_without_alarms[0], '--os', 'OSEK', '--oilfile', osek_copter_without_alarms[1], '--log-level', 'debug'],
   env : [python_path]
)

test('copter',
   py3_inst,
   args: [files('ara.py'), osek_coptermok[0], '--os', 'OSEK', '--oilfile', osek_coptermok[1], '--log-level', 'debug'],
   env : [python_path]
)


test('ospert',
   py3_inst,
   args: [files('ara.py'), freertos_ospert, '--os', 'FreeRTOS', '--log-level', 'debug'],
   env : [python_path]
)
