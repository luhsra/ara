# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from .syscall_generic import GenericSystemCalls

class VanillaSystemCalls(GenericSystemCalls):
    def generate_data_objects(self):
        pass
    def generate_system_code(self):
        pass
    pass
