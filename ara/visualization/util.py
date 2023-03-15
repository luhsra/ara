# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

class RESOURCE_PATH:
    """Contains path to resource directory"""
    res_path = "../"

    def get():
        return RESOURCE_PATH.res_path

    def set(path: str):
        RESOURCE_PATH.res_path = path

class __SUPPORT_FOR_GUI:
    """True if Meson option enable_gui is set"""
    def __init__(self):
        self.support = False

    def set(self, support: bool):
        self.support = support

    def __bool__(self):
        return bool(self.support)

SUPPORT_FOR_GUI = __SUPPORT_FOR_GUI()

class StepMode:
    DEFAULT = 1
    TRACE = 2
