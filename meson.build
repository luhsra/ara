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
# TODO add version argument to find_installation: see https://github.com/mesonbuild/meson/issues/7078
py3_inst = py3_mod.find_installation('python3', modules: ['pydot', 'graph_tool'])

## llvm dependencies
llvm_version = ['>=9', '<11']
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
svf_proj = cmake.subproject('svf', cmake_options: ['-DLLVM_DIR=' + llvm_dep.get_variable(configtool: 'prefix'),
                                                   '-DBUILD_SHARED_LIBS=on'])
svf_dep = svf_proj.dependency('Svf')
cudd_dep = svf_proj.dependency('Cudd')

## sparsedata
sparsedata = subproject('sparsedata')
sparse_rle = sparsedata.get_variable('libsparserle')
sparse_rle2 = sparsedata.get_variable('libsparserle2')

## ara-link
ara_link = find_program('ara-link', version: llvm_version, required: false)
if not ara_link.found()
    ara_link_proj = subproject('ara-link')
    ara_link = ara_link_proj.get_variable('ara_link')
    message('Using ara-link from subproject.')
endif

## tools
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

# convenience script to call ara without installing
ara_py_content = '''#!@0@
"""Automatic Real-time System Analyzer"""
import importlib
import sys
import graph_tool

def load(what, where):
    module = importlib.import_module(what)
    sys.modules[where] = module

sys.path = [@1@] + sys.path

load("graph_data", "ara.graph.graph_data")
load("py_logging", "ara.steps.py_logging")
load("step", "ara.steps.step")

import ara.ara as _ara
sys.exit(_ara.main())'''

python_dirs = [source_dir, pyllco_dir, step_dir, graph_data_dir]
python_path = 'PYTHONPATH=' + ':'.join(python_dirs)

ara_py = custom_target('ara-py',
    input: [],
    output: 'ara.py',
    depends: [step_mod, graph_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_py_content.format(py3_inst.path(), '"' + '", "'.join(python_dirs) + '"')],
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
if get_option('enable_toplevel_tests')
    extra_settings = files('test' / 'extra_settings.json')
    test('ara_tester',
       py3_inst,
       args: [ara_py, librepilot_application,
              '--log-level', 'warn', '--runtime-stats', '--runtime-stats-file', 'dump', '--runtime-stats-format', 'json',
              '--step-settings', extra_settings,
              '--manual-corrections', instance_corrections],
       suite: 'toplevel'
    )

    rtas_settings = files('test' / 'rtas_settings.json')
    test('rtas20',
       py3_inst,
       args: [ara_py, freertos_rtas20_example,
              '--log-level', 'debug', '--runtime-stats', '--runtime-stats-file', 'dump', '--runtime-stats-format', 'json',
              '--dump',
              '--step-settings', rtas_settings],
       suite: 'toplevel'
    )

    generator_settings = files('test/generator_settings.json')
    test('generator_tester',
       py3_inst,
       args: [ara_py, freertos_simple_print,
              '--log-level', 'debug', '--dump',
              '--generator_output', 'generator_tester-os.cc',
              '--step-settings', generator_settings],
       suite: 'toplevel'
    )

    autosar_minexample_settings = files('test' / 'autosar_minexample_settings.json')
    test('multisse',
       py3_inst,
       args: [ara_py, autosar_minexample[0],
              '--oilfile', autosar_minexample[1],
              '--log-level', 'info',
              '--dump',
              '--step-settings', autosar_minexample_settings],
       suite: 'toplevel',
       timeout: 30
    )
endif
