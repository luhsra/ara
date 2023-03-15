# SPDX-FileCopyrightText: 2020 Kenny Albes
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from typing import List


_os_models: dict = None  # Dictionary with names -> OS-model-object


def _init_os_package():
    """Initializes this package.

    It is not required to call this function.
    All functions in this file will call this function automatically to
    ensure _os_models is initlialized. This function is a workaround to
    force Python not to load the OS models at program startup where some
    objects are not correctly initialized.
    """
    global _os_models
    if _os_models is None:
        # Register your new OS Model here:
        from .freertos import FreeRTOS
        from .autosar import AUTOSAR
        from .zephyr import ZEPHYR
        from .posix.posix import POSIX

        _os_models = {
            model.get_name(): model
            for model in [FreeRTOS, AUTOSAR, ZEPHYR, POSIX]
        }  # And here


def get_os_names() -> List[str]:
    """Return all supported OSes as string."""
    _init_os_package()
    return list(_os_models.keys())


def get_os(name: str):
    """Return the OS with name."""
    _init_os_package()
    return _os_models[name]
