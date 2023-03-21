# Code required to start installed version of ARA

python_dirs_installed = ['os.path.join(os.environ["ARA_INSTALL_DIR"], "python")',
                         'os.path.join(os.environ["ARA_INSTALL_DIR"], "lib")']
if pyllco_used_from_subproj
    python_dirs_installed += ['os.path.join(os.environ["ARA_INSTALL_DIR"], "usr' / 'lib' / ('python' + py3_inst.language_version()) / 'site-packages")']
endif

ara_py_installed = custom_target('ara-py-installed',
    input: [],
    output: 'ara',
    depends: [step_mod, graph_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_py_content.format('#!/usr/bin/env python3', ', '.join(python_dirs_installed))],
    install: true,
    install_dir: 'python' / 'startup'
)

ara_gui_py_installed = custom_target('ara-gui-py-installed',
    input: [],
    output: 'ara-gui',
    depends: [step_mod, graph_data_mod],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_gui_py_content.format('#!/usr/bin/env python3', ', '.join(python_dirs_installed), 'os.path.join(os.environ["ARA_INSTALL_DIR"], "resources")')],
    install: true,
    install_dir: 'python' / 'startup'
)

# Wrapper that is used if ARA is installed.
#
# This wrapper is required because setting LD_LIBRARY_PATH in ara.py does not have an effect.
# We need to set LD_LIBRARY_PATH beforehand.
#
# __ARA_DEFAULT_INSTALL_DIR__ will be set in the install script tools/post_meson_install.sh
# There is no way to get ${MESON_INSTALL_DESTDIR_PREFIX} here so we need to set it in the install script.
ara_wrapper_content = '''#!/bin/sh

if [ "x${ARA_INSTALL_DIR}" = "x" ] ; then
	ARA_INSTALL_DIR="__ARA_DEFAULT_INSTALL_DIR__"
fi

cd "${ARA_INSTALL_DIR}/python/startup"
ARA_INSTALL_DIR="${ARA_INSTALL_DIR}" SVF_DIR="${ARA_INSTALL_DIR}" LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${ARA_INSTALL_DIR}/lib" @0@ "@1@" "$@"
'''
ara_wrapper = custom_target('ara-wrapper',
    input: [],
    output: 'ara.sh',
    depends: [ara_py_installed],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_wrapper_content.format(py3_inst.path()+python_opt_arg, 'ara')],
    install: true,
    install_dir: 'bin'
)
ara_gui_wrapper = custom_target('ara-gui-wrapper',
    input: [],
    output: 'ara-gui.sh',
    depends: [ara_gui_py_installed],
    command: [py3_inst, dump_cmds, '@OUTPUT@', '0o755', ara_wrapper_content.format(py3_inst.path()+python_opt_arg, 'ara-gui')],
    install: true,
    install_dir: 'bin'
)
