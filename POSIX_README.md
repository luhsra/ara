POSIX Support for ARA
=====================

POSIX build system
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

build directories:
- build/appl/POSIX/
    Contains all LLVM IR files with musl libc. (Recommended)
- build/appl/POSIX/objs
    Contains all LLVM IR files without musl libc.
- build/appl/POSIX/bin
    Contains all binary files.

NOTE: build/ is the path to Meson's build root directory.

If you want to add new POSIX applications to analyze, see the documentation in appl/POSIX/Makefile

POSIX test suite
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
