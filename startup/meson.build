# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

## Code required to start installed version of ARA ##

ara_startup = '''
"""Automatic Real-time System Analyzer"""
import importlib
import sys
import os
import graph_tool

sys.setdlopenflags(sys.getdlopenflags() | os.RTLD_GLOBAL)

import pyllco
@0@
import ara.graph.graph_data
import ara.steps.py_logging
import ara.steps.step

sys.setdlopenflags(sys.getdlopenflags() & ~os.RTLD_GLOBAL)
'''

ara_py_installed = custom_target('ara-py-installed',
    input: [],
    output: 'ara',
    depends: [step_mod, graph_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_py_content.format(py3_inst.path()+python_opt_arg, ara_startup.format(''))],
    install: true,
    install_dir: get_option('bindir')
)

installed_resources_dir = 'os.path.join(os.environ["ARA_DATA_DIR"], "resources") if "ARA_DATA_DIR" in os.environ else "' + \
                          get_option('prefix') / get_option('datadir') / 'ara' / 'resources' + '"'

ara_startup_formatted = ara_startup.format(ara_gui_py_before_import.format(installed_resources_dir))

ara_gui_py_installed = custom_target('ara-gui-py-installed',
    input: [],
    output: 'ara-gui',
    depends: [step_mod, graph_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_gui_py_content.format(py3_inst.path()+python_opt_arg, ara_startup_formatted)],
    install: true,
    install_dir: get_option('bindir')
)

# Create ara-wrapper and ara-gui-wrapper
#
# These wrappers can be used to execute ARA without installing it properly.
# Receiving a zip file and executing ara-wrapper is enough to run ARA.
ara_wrapper_content = '''#!/bin/sh

# Set environment variables for ARA.
# This script allows to run ARA without installation in the system.

SVF_EXT_API_JSON="@0@"
export SVF_EXT_API_JSON
PYTHONPATH="${PYTHONPATH}:@1@" LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:@2@" @3@ "@4@" "$@"
'''

ara_wrapper_formatted = ara_wrapper_content.format(get_option('prefix') / get_option('datadir') / 'svf' / 'ExtAPI.json',
                                                   py3_inst.get_install_dir(), 
                                                   get_option('prefix') / get_option('libdir'),
                                                   py3_inst.path()+python_opt_arg,
                                                   get_option('prefix') / get_option('bindir') / '@0@')

ara_wrapper = custom_target('ara-wrapper',
    input: [],
    output: 'ara-wrapper',
    depends: [ara_py_installed],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_wrapper_formatted.format('ara')],
    install: true,
    install_dir: get_option('bindir')
)
ara_gui_wrapper = custom_target('ara-gui-wrapper',
    input: [],
    output: 'ara-gui-wrapper',
    depends: [ara_gui_py_installed],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_wrapper_formatted.format('ara-gui')],
    install: true,
    install_dir: get_option('bindir')
)
