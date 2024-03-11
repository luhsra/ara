<!--
SPDX-FileCopyrightText: 2023 Andreas Kässens

SPDX-License-Identifier: GPL-3.0-or-later
-->
# MACAW

MACAW (Multicore AUTOSAR Compatible Application-specific Whole-system-optimizer) is based upon [dOSEK](https://www4.cs.fau.de/Research/dOSEK/).
It requires ARA for system analysis and can leverage MultiSSE results for system call specialization.
MACAW supports the POSIX "platform" on x86-Linux and the Raspberry Pi 4B.

## Components

- Kernel libraries in `libs/autosar`
- AUTOSAR generator in `ara/generator/coder/autosar`
- IR modification step in `ara/steps/native/autosar_generator_ir.cpp`
- Test runner in `test/autosar_generator.py`

## Usage

```bash
# configure meson (for POSIX and ARM)
meson build --native-file native-lab.txt -D execute_ara=true -D toolchains:enable_arm=enabled -D toolchains:enable_riscv=disabled
cd build

# build and run single application
ninja run_autosar_multicore_andreas_ipi_a_posix
ninja run_autosar_multicore_andreas_ipi_a_pi4

# run all tests for posix
meson test --suite autosar_generator_multicore_posix
```

## Specialization

By default, images are generated using the ARA settings defined in `settings/autosar_generator_{posix|arm}.json`.

## Debugging

To get debug output, the binaries can be built with `-DDEBUG`.
