# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from .SourceElement import CPPStatement, Comment

class Include:
    def __init__(self, filename, system_include=False, comment = None, overwrites=None):
        self.filename = filename
        self.system_include = system_include
        self.comment = comment
        self.overwrites = overwrites or []

    def source_elements(self):
        sep = '""'
        if self.system_include:
            sep = "<>"
        arg = sep[0] + self.filename + sep[1]
        ret = []
        if self.comment:
            ret.append(Comment(self.comment))
        ret.append(CPPStatement("include", arg))
        for overwrite in self.overwrites:
            ret.append(overwrite)
        return ret
    def add_overwrite(self, overwrite):
        self.overwrites.append(overwrite)

class IncludeManager:
    def __init__(self, _log):
        self.included_files = []
        self._log = _log.getChild(self.__class__.__name__)

    def add(self, include, position=None):
        # Filter out duplicate includes
        for idx, inc in enumerate(self.included_files):
            if (inc.filename == include.filename and
                inc.system_include == include.system_include):
                if position is None:
                    return
                if idx != position:
                    self.included_files.remove(inc)
                    self.included_files.insert(position, include)
                    include.overwrites.extend(inc.overwrites)
                return
        if position is not None:
            self.included_files.insert(position, include)
        else:
            self.included_files.append(include)

    def source_elements(self):
        ret = []
        # Sort by local and global includes
        for include in self.included_files:
            ret.append(include.source_elements())
        return ret

