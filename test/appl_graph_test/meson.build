# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

# instance graph tests for common applications

graphs = meson.current_source_dir() / 'graphs'

test('gpslogger_instance_graph',
        py3_inst,
        args: [files('../interactions.py'), graphs / 'gpslogger_instance_graph.json', gpslogger_application],
        env: [python_path],
        suite: 'appl_graph',
        timeout: 300
)