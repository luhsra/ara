project('ara', 'cpp',
    default_options : ['warning_level=3',
                       'cpp_std=c++17',
                       'buildtype=debugoptimized'])

add_project_arguments('-Werror=return-type', language: ['c', 'cpp'])
# c-linkage is not correct, see https://github.com/cython/cython/issues/1839
compiler = meson.get_compiler('cpp')
if compiler.has_argument('-Wno-error=return-type-c-linkage')
    add_project_arguments('-Wno-error=return-type-c-linkage', language: ['c', 'cpp'])
endif

fs = import('fs')

# check all dependencies first

cython = find_program('cython', version: '>=0.29.14')
cython_flags = ['-Wextra', '--cplus', '-3']

py3_mod = import('python')
# TODO add version argument to find_installation: see https://github.com/mesonbuild/meson/issues/7078
py3_inst = py3_mod.find_installation('python3', modules: ['pydot', 'graph_tool', 'PySide6', 'scipy'])
if py3_inst.language_version().version_compare('<3.9')
    error('At least Python 3.9 is required.')
endif

## llvm dependencies
llvm_version = ['>=10', '<13']
llvm_dep = dependency('llvm', method: 'config-tool', version: llvm_version, include_type: 'system')

llvm_bindir = llvm_dep.get_variable(configtool: 'bindir')
clang = find_program(llvm_bindir / 'clang', version: llvm_version)
llc = find_program(llvm_bindir / 'llc', version: llvm_version)
llvm_dis = find_program(llvm_bindir / 'llvm-dis', version: llvm_version)
llvm_link = find_program(llvm_bindir / 'llvm-link', version: llvm_version)
llvm_opt = find_program(llvm_bindir / 'opt', version: llvm_version)

boost_dep = dependency('boost', modules: ['graph', 'python' + py3_inst.language_version().replace('.', '')])
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
svf_opts = cmake.subproject_options()
svf_opts.append_compile_args('cpp', '-Wno-unused-parameter')
svf_opts.append_compile_args('cpp', '-Wno-unused-variable')
svf_opts.append_compile_args('cpp', '-Wno-unused-function')
svf_opts.append_compile_args('cpp', '-Wno-maybe-uninitialized')
svf_opts.add_cmake_defines({'LLVM_DIR': llvm_dep.get_variable(configtool: 'prefix'),
                            'BUILD_SHARED_LIBS': 'on'})
svf_proj = cmake.subproject('svf', options: svf_opts)
svf_dep = svf_proj.dependency('Svf')
cudd_dep = svf_proj.dependency('Cudd')

## sparsedata
sparsedata = subproject('sparsedata')
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
st_flash = find_program('st-flash', required: false, disabler: true)
sed = find_program('sed')

## POSIX
wllvm = find_program('wllvm')
extract_bc = find_program('extract-bc') # provided by wllvm
realpath = find_program('realpath')

# Note: libmicrohttpd needs this tools available via PATH:
autoconf = find_program('autoconf')
automake = find_program('automake')

## arch specific build tools
if get_option('arch') == 'i386'
    target_triple='x86_64-linux-gnu'
elif get_option('arch') == 'arm'
    target_triple = 'arm-none-eabi'
else
    error('unknown arch ' + get_option('arch'))
endif

if not get_option('execute_ara') and get_option('enable_generator_tests')
  error('execute_ara has to be true to set enable_generator_tests')
endif

arch_error = 'Do you have an @0@ toolchain? Otherwise consider to switch to another architecture. See the "arch" config option for that.'

foreach prog_name : ['ar', 'objcopy', 'size', 'nm', 'ld', 'objdump']
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
import os
import graph_tool

def load(what, where):
    module = importlib.import_module(what)
    sys.modules[where] = module

sys.path = [@1@] + sys.path
sys.setdlopenflags(sys.getdlopenflags() | os.RTLD_GLOBAL)

import pyllco

load("graph_data", "ara.graph.graph_data")
load("py_logging", "ara.steps.py_logging")
load("step", "ara.steps.step")

sys.setdlopenflags(sys.getdlopenflags() & ~os.RTLD_GLOBAL)

import ara.ara as _ara
sys.exit(_ara.main())'''

gui_py_content = '''#!@0@
"""Automatic Real-time System Analyzer GUI"""
import importlib
import sys
import os
import graph_tool

def load(what, where):
    module = importlib.import_module(what)
    sys.modules[where] = module

sys.path = [@1@] + sys.path
sys.setdlopenflags(sys.getdlopenflags() | os.RTLD_GLOBAL)

import pyllco

load("graph_data", "ara.graph.graph_data")
load("py_logging", "ara.steps.py_logging")
load("step", "ara.steps.step")

import ara.ara as _ara
from ara.visualization.util import RESOURCE_PATH
RESOURCE_PATH.set('@2@')
import ara.visualization.main
sys.exit()'''

subdir('resources')

python_dirs = [source_dir, pyllco_dir, step_dir, graph_data_dir]
python_path = 'PYTHONPATH=' + ':'.join(python_dirs)

ara_py = custom_target('ara-py',
    input: [],
    output: 'ara.py',
    depends: [step_mod, graph_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_py_content.format(py3_inst.path(), '"' + '", "'.join(python_dirs) + '"')],
    build_by_default: true
)

gui_py = custom_target('gui-py',
    input: [],
    output: 'gui.py',
    depends: [step_mod, graph_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', gui_py_content.format(py3_inst.path(), '"' + '", "'.join(python_dirs) + '"', resources_dir + '/')],
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
    settings = 'settings'
    app = autosar_singlecore_bcc1_task1_a
    app = autosar_multicore_paper_running
    test('ara_tester',
       py3_inst,
       args: [ara_py, app['ll'],
              '--log-level', 'warn', '--runtime-stats', '--runtime-stats-file', 'dump', '--runtime-stats-format', 'json',
              '--oilfile', app['oil'],
              '--timings', app['sys_timings'],
              '--step-settings', files(settings / 'extra_settings.json')],
              # '--manual-corrections', instance_corrections],
       suite: 'toplevel'
    )

    test('rtas20',
       py3_inst,
       args: [ara_py, freertos_rtas20_example,
              '--log-level', 'debug', '--runtime-stats', '--runtime-stats-file', 'dump', '--runtime-stats-format', 'json',
              '--dump',
              '--step-settings', files(settings / 'rtas_settings.json')],
       suite: 'toplevel'
    )

    test('generator_tester',
       py3_inst,
       args: [ara_py, freertos_simple_print,
              '--log-level', 'debug', '--dump',
              '--generator_output', 'generator_tester-os.cc',
              '--step-settings', files(settings / 'generator_settings.json')],
       suite: 'toplevel'
    )

    test('multisse',
      py3_inst,
      args: [ara_py, autosar_multicore_minexample['ll'],
             '--oilfile', autosar_multicore_minexample['oil'],
             '--dump',
             '--log-level', 'info',
             '--step-settings', files(settings / 'autosar_minexample_settings.json')],
      suite: 'toplevel',
      timeout: 30
    )

    # OSPERT tests
    posix_settings = files('settings' / 'posix_instance_graph.json')
    test('posix_ospert',
        py3_inst,
        args: [ara_py, posix_ospert_2022_example,
                '--os', 'POSIX',
                '-v',
                '--step-settings', posix_settings],
        suite: 'toplevel',
        timeout: 90
    )

    if get_option('enable_posix_toplevel_tests')
        test('microhttpd_fileserver_dirs',
            py3_inst,
            args: [ara_py, posix_microhttpd_fileserver_dirs_musl,
                    '--os', 'POSIX',
                    '-v',
                    '--step-settings', posix_settings],
            suite: 'toplevel',
            timeout: 14400
        )
    endif

    test('cfg_pic',
       py3_inst,
       args: [ara_py, freertos_cfg_pic,
              '--dump',
              '--log-level', 'info',
              '--step', 'SIA'],
       suite: 'toplevel',
       timeout: 30
    )

    test('cfg_pic',
       py3_inst,
       args: [ara_py, freertos_visualization_thesis_example,
              '--dump',
              '--log-level', 'info',
              '--step', 'SIA'],
       suite: 'toplevel',
       timeout: 30
    )

    test('sse-i4copter',
      py3_inst,
      args: [ara_py, autosar_singlecore_complex_isorc['ll'],
             '--oilfile', autosar_singlecore_complex_isorc['oil'],
             '--log-level', 'info',
             '--step-settings', files(settings / 'sse_i4copter.json')],
      suite: 'toplevel',
      timeout: 0,
    )

    test('ina-i4copter',
      py3_inst,
      args: [ara_py, autosar_singlecore_complex_isorc['ll'],
             '--oilfile', autosar_singlecore_complex_isorc['oil'],
             '--log-level', 'info',
             '--step-settings', files(settings / 'ina_i4copter.json')],
      suite: 'toplevel',
      timeout: 30
    )

    librepilot_instance_graph_settings = files(settings / 'ina_librepilot.json')
    librepilot_manual_corrections = files('appl' / 'FreeRTOS' / 'Librepilot' / 'instance_corrections.json')
    test('ina-librepilot',
       py3_inst,
       args: [ara_py, librepilot_application,
              '--os', 'FreeRTOS',
              '--log-level', 'info',
              '--step-settings', librepilot_instance_graph_settings,
              '--manual-corrections', librepilot_manual_corrections],
       suite: 'toplevel',
       timeout: 0
    )

    test('ina-gpslogger',
       py3_inst,
       args: [ara_py, gpslogger_application,
              '--log-level', 'info',
              '--step-settings', files(settings /'ina_gpslogger.json')],
       suite: 'toplevel',
       timeout: 0
    )
endif
