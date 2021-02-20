# Different ARM toolchain dirs for arm-none-eabi tools from the official repository of manjaro (Arch Linux)
meson build \
    -Darm_include_dirs=/usr/arm-none-eabi/include/           \
    -Darm_link_dirs=/usr/arm-none-eabi/lib/thumb/v7-m/nofp/  \
    -Darm_gcc_dir=/usr/bin/arm-none-eabi-gcc                 \
    -Denable_gpslogger_tests=false                           \
    -Denable_librepilot_tests=false                          \
    -Denable_qemu_tests=false