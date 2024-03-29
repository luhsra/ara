# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from ..os_util import syscall


class SyscallStubAliases:
    """You can provide a do_not_interpret implementation in this class for
    syscall stubs with custom aliases.
    """

    @syscall(aliases={"default_malloc", "__libc_malloc_impl",
                      "__libc_malloc", "__simple_malloc"},
             is_stub=True)
    def malloc(graph, state, cpu_id, args, va):
        return state
