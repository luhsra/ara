<!--
SPDX-FileCopyrightText: 2021 Jan Neugebauer

SPDX-License-Identifier: GPL-3.0-or-later
-->

POSIX Support for ARA
=====================

Installation
------------

Type the following commands:
```
./init
meson build -Denable_gpslogger_tests=false -Denable_librepilot_tests=false -Denable_qemu_tests=false
cd build
ninja
```

If you have already a build root directory (./build) make sure to deactivate qemu, gpslogger and librepilot tests:
```
meson --reconfigure -Denable_gpslogger_tests=false -Denable_librepilot_tests=false -Denable_qemu_tests=false
```


POSIX Build System
------------------

To build all POSIX applications, just type from the build root directory:
```
ninja
```

if you want to invoke the POSIX build system directly use:
```
ninja posix
```

To remove all build files of the POSIX build system use:
```
ninja posix-clean
```

Build directories:
- build/appl/POSIX/
    Contains all LLVM IR files with musl libc. (Recommended)
- build/appl/POSIX/objs
    Contains all LLVM IR files without musl libc.
- build/appl/POSIX/bin
    Contains all binary files.

NOTE: build/ is the path to Meson's build root directory.

If you want to add new POSIX applications to analyze, see the documentation in appl/POSIX/Makefile


POSIX Test Suite
----------------

To run the test suite, type from the build root directory:
```
meson test --suite posix
```


Generation of instance graphs
-----------------------------

To generate an instance graph, you can use the step settings:
- settings/posix_instance_graph.json [instance graph with POSIX profile]
- settings/linux_instance_graph.json [instance graph with Linux profile]

Example invocation:
```
./ara.py --step-settings ../settings/linux_instance_graph.json appl/POSIX/<your_application>.ll -v
```
