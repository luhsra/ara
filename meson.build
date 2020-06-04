project('ara', 'cpp',
    default_options : ['warning_level=3',
                       'cpp_std=c++17',
                       'buildtype=debugoptimized'])

add_project_arguments('-Werror=return-type', language: ['c', 'cpp'])

fs = import('fs')

# check all dependencies first

cython = find_program('cython', version: '>=0.29.14')
cython_flags = ['-Wextra', '--cplus', '-3']

py3_mod = import('python')
py3_inst = py3_mod.find_installation('python3', modules: ['pydot', 'graph_tool'])

## llvm dependencies
llvm_version = ['>=9', '<10']
llvm_dep = dependency('llvm', version: llvm_version, include_type: 'system')

llvm_bindir = llvm_dep.get_variable(configtool: 'bindir')
clang = find_program(llvm_bindir / 'clang', version: llvm_version)
llc = find_program(llvm_bindir / 'llc', version: llvm_version)
llvm_link = find_program(llvm_bindir / 'llvm-link', version: llvm_version)
llvm_opt = find_program(llvm_bindir / 'opt', version: llvm_version)

boost_dep = dependency('boost', modules: ['graph', 'python3'])
graph_tool_dep = dependency('graph-tool-py' + py3_inst.language_version(), include_type: 'system')

## pyllco
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

## svf
cmake = import('cmake')
svf_proj = cmake.subproject('svf', cmake_options: '-DLLVM_DIR=' + llvm_dep.get_variable(configtool: 'prefix'))
svf_dep = svf_proj.dependency('Svf')
cudd_dep = svf_proj.dependency('Cudd')

## tools
bash = find_program('bash')
nop = find_program('true')

## arch specific build tools
if get_option('arch') == 'i386'
    target_triple='x86_64-linux-gnu'
elif get_option('arch') == 'arm'
    target_triple = 'arm-none-eabi'
else
    error('unknown arch ' + get_option('arch'))
endif

arch_error = 'Do you have an @0@ toolchain? Otherwise consider to switch to another architecture. See the "arch" config option for that.'

foreach prog_name : ['ar', 'objcopy', 'size', 'nm', 'ld']
    full_prog_name = target_triple + '-' + prog_name
    prog = find_program(full_prog_name, required: false)
    if not prog.found()
        error(arch_error.format(get_option('arch').to_upper()))
    endif
    set_variable(prog_name, prog)
endforeach

# all dependencies found, build the actual program

build_dir = meson.current_build_dir()
source_dir = meson.source_root()

# build ARA itself
subdir('ara')

# tools for deploying
subdir('tools')

python_path = 'PYTHONPATH=' + ':'.join([source_dir, step_dir, pyllco_dir, llvm_data_dir])
ara = files('ara.py')

# convenience script to call ara with correct environment
ara_sh = custom_target('ara-sh',
    input: ara,
    output: 'ara.sh',
    depends: [plib, libgraph, llvm_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', '#!/bin/sh\n' + python_path + ' ' + py3_inst.path() + ' ' + (source_dir / 'ara.py') + ' $@\n'],
    build_by_default: true
)

# build test applications with help of ARA
# Attention: The include order is important here.
subdir('settings') # generic settings
subdir('libs') # build libs such as osek/freertos/stm32-init
subdir('appl')
subdir('test')

# application tests
# tests that aren't actually tests, but a way to store ara invocations with a given set of arguments
if not get_option('disable_toplevel_tests')
    extra_settings = files('test/extra_settings.json')
    test('ara_tester',
       py3_inst,
       args: [ara, gpslogger_application,
              '--log-level', 'debug',
              '--step-settings', extra_settings],
       env: [python_path],
       suite: 'toplevel'
    )

    generator_settings = files('test/generator_settings.json')
    test('generator_tester',
       py3_inst,
       args: [ara, freertos_simple_print,
              '--log-level', 'debug', '--dump',
              '--generator_output', 'generator_tester-os.cc',
              '--step-settings', generator_settings],
       env : [python_path],
       suite: 'toplevel'
    )

    test('gpslogger',
       py3_inst,
       args: [ara, gpslogger_application, '--log-level', 'debug', '--step', 'InstanceGraph'],
       env : [python_path],
       suite: 'toplevel'
    )

    test('smartplug',
       py3_inst,
       args: [ara, smartplug_application, '--log-level', 'debug', '--step', 'InstanceGraph'],
       env : [python_path],
       suite: 'toplevel'
    )

    test('copter-without-alarms',
       py3_inst,
       args: [ara, osek_copter_without_alarms[0], '--oilfile', osek_copter_without_alarms[1], '--log-level', 'debug', '--step', 'InstanceGraph'],
       env : [python_path],
       suite: 'toplevel'
    )

    test('copter',
       py3_inst,
       args: [ara, osek_coptermok[0], '--oilfile', osek_coptermok[1], '--log-level', 'debug', '--step', 'InstanceGraph'],
       env : [python_path],
       suite: 'toplevel'
    )

    test('ospert',
       py3_inst,
       args: [ara, freertos_ospert, '--log-level', 'debug', '--step', 'InstanceGraph'],
       env : [python_path],
       suite: 'toplevel'
    )
endif
