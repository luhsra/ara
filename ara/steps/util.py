# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Helper functions that are needed in multiple places."""
import os

from contextlib import contextmanager


def raise_and_error(logger, message, exception=RuntimeError):
    """Error log message and raise it as exception."""
    logger.error(message)
    raise exception(message)

@contextmanager
def open_with_dirs(path, flags="w"):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, flags) as g:
        yield g


class Wrapper:
    def set_wrappee(self, wrappee):
        self.__wrappee = wrappee

    def __getattr__(self, attr):
        return getattr(self.__wrappee, attr)
current_step = Wrapper()
