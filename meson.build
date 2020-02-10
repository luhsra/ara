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

pyllco_dep = dependency('pyllco-py' + py3_inst.language_version(), required : false)

if pyllco_dep.found()
    pyllco_cython_inc = pyllco_dep.get_variable(pkgconfig: 'Cython.include')
    pyllco_dir = ''
else
    pyllco_proj = subproject('pyllco')
    pyllco_dep = pyllco_proj.get_variable('pyllco_dep')
    pyllco_cython_inc = pyllco_proj.get_variable('pyllco_cython_inc')
    pyllco_dir = pyllco_proj.get_variable('pyllco_dir')
endif


cython_flags = ['-Wextra', '--cplus', '-3']

build_dir = meson.current_build_dir()
source_dir = meson.source_root()

subdir('common')
subdir('graph')
subdir('steps')

python_path = 'PYTHONPATH=' + ':'.join([source_dir, step_dir, pyllco_dir, llvm_data_dir])


dump_cmds = files('utils/dump_cmds.py')
ara = files('ara.py')

sh = custom_target('ara-sh',
    input: ara,
    output: 'ara.sh',
	depends: [plib, libgraph, llvm_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', '#!/bin/sh\n' + python_path + ' ' + (source_dir / 'ara.py') + ' $@\n'],
    build_by_default: true
)

subdir('settings')
subdir('libs')
subdir('appl')
subdir('test')

extra_settings = files('test/extra_settings.json')

# TODO convert this into a proper test
test('ara_tester',
   py3_inst,
   args: [files('ara.py'), freertos_sse,
          '--log-level', 'debug', '--dump',
          '--step-settings', extra_settings],
   env : [python_path]
)

generator_settings = files('test/generator_settings.json')

test('generator_tester',
   py3_inst,
   args: [files('ara.py'), gpslogger_targets,
          '--log-level', 'debug', '--dump',
          '--step-settings', generator_settings],
   env : [python_path]
)

test('gpslogger',
   py3_inst,
   args: [files('ara.py'), gpslogger_targets, '--log-level', 'debug', '--step', 'SSE'],
   env : [python_path]
)

test('smartplug',
   py3_inst,
   args: [files('ara.py'), smartplug_targets, '--log-level', 'debug', '--step', 'SSE'],
   env : [python_path]
)

test('copter-without-alarms',
   py3_inst,
   args: [files('ara.py'), osek_copter_without_alarms[0], '--oilfile', osek_copter_without_alarms[1], '--log-level', 'debug', '--step', 'SSE'],
   env : [python_path]
)

test('copter',
   py3_inst,
   args: [files('ara.py'), osek_coptermok[0], '--oilfile', osek_coptermok[1], '--log-level', 'debug', '--step', 'SSE'],
   env : [python_path]
)


test('ospert',
   py3_inst,
   args: [files('ara.py'), freertos_ospert, '--log-level', 'debug', '--step', 'SSE'],
   env : [python_path]
)
