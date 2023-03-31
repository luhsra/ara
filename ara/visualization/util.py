# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

class RESOURCES:
    """Allows to get paths to GUI resources files"""
    res_path = "../"

    def get(filename: str):
        import os
        return os.path.join(RESOURCES.res_path, filename)

    def set_res_path(path: str):
        RESOURCES.res_path = path

class __USING_ARA_GUI:
    """True if ara-gui.py was started"""
    def __init__(self):
        self.ara_gui = False

    def set(self, ara_gui: bool):
        self.ara_gui = ara_gui

    def __bool__(self):
        return bool(self.ara_gui)

USING_ARA_GUI = __USING_ARA_GUI()

class StepMode:
    DEFAULT = 1
    TRACE = 2

SMALL_WIDGET_HEIGHT = 400
SMALL_WIDGET_WIDTH = 200

BIG_WIDGET_HEIGHT = 400
BIG_WIDGET_WIDTH = 400
