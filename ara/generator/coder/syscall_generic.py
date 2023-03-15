# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from .base import BaseCoder
from .elements import Function, FunctionCall, FunctionDeclaration, Statement

class GenericSystemCalls(BaseCoder):
    def __init__(self):
        self._init = Function('_init', 'void', [], extern_c=True,
                              attributes=['__attribute__((weak))'])


