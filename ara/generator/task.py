# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

class TaskBase(Object):

    def __init__(self, name, function=None, stack_size=None):
        self._name = name
        self._function = function
        self._stack_size = None




class DynamicTask(TaskBase):

    def 
