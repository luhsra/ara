# MACAW

The MACAW (Multicore AUTOSAR Compatible Application-specific Whole-system-optimized) RTOS ist based upon [dOSEK](https://www4.cs.fau.de/Research/dOSEK/).
It requires ARA for system analysis and can leverage MultiSSE results for system call specialization.
Currently, MACAW only supports the POSIX platform on x86.

## Components

- Kernel libraries in `libs/autosar`
- AUTOSAR generator in `ara/generator/coder/autosar`
- IR modification step in `ara/steps/native/autosar_generator_ir.cpp`

## Usage

```bash
# configure meson for posix architecture
meson build -Darch=posix -Denable_toplevel_tests=false
cd build

# build and run single application
ninja run autosar_multicore_andreas_ipi_a

# run all tests
meson test --suite autosar_generator
```

## Specialization

By default, images are generated using the settings defined in `ara/settings/autosar_generator.json` and the options `lock_elision` and `ipi_avoidance` are enabled.

## Debug

When the meson `debug` configuration is set (default true), the binaries are build with debug output (`-DDEBUG`).
Debug information is written to STDERR, while the execution test results are in STDOUT.
