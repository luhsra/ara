
# Not all apps are compatible with the nucleo_f103rb
zephyr_apps = [
'blinky',
#'blinky_pwm',
'button',
'cpp_synchronization',
'dynamic_synchronization',
#'fade_led',
'minimal',
'mutex',
#'rgb_led',
#'servo_motor',
#'shared_mem',
'sthread',
'synchronization',
#'threads'
]

#zephyr_apps = ['dynamic_synchronization']
#zephyr_apps = ['mutex']

# Currently only two boards are supported:
# Arm: The nucleo f103rb
# i386: The native posix target
# TODO: Find at least one arm board that supports user mode.
if get_option('arch') == 'i386'
    l_gcc = ''
    board = 'native_posix'
elif get_option('arch') == 'arm'
    l_gcc = libgcc_dir
    board = 'nucleo_f103rb'
endif

zephyr_targets = []
zephyr_root = get_option('zephyr_dir')


# Add all available zephyr apps to zephyr_apps.
# The build process looks like this:
# 1) All apps are build using a custom target which invokes the compile_zephyr.py script.
# 2) The build script checks if the board has changed since last build and might clear all artifacts
# 3) CMake is configured and the ninja backend is executed
# 4) The zephyr build process runs as it normally would, but the app is compiled to llvm ir and in a
#       second step compiled with llc. At this point linking finishes normally and a flashable
#       image as well as *app*.ll is produced.
# This process is not ideal, but the other options are even worse:
# CMake module: While meson explicitly states that it does not support mixing build systems, it
#   provides a cmake module. There are multiple reasons why this is not feasable:
#   * All cmake projects have to be located in /subprojects
#   * Most compiler and linker flags are inferred from the meson project (ARA) which is a pain when
#       crosscompiling/changing boards.
#   * When changing boards the entire cmake project has to be purged to avoid caching issues. This
#       can not be automated.
# run_command(): This does not create a top level target.
# run_target(): Meson expects this to have no output.
foreach app : zephyr_apps
    zephyr_targets += custom_target(app,
        command: [py3_inst,
        join_paths(meson.current_source_dir(), 'compile_zephyr.py'), 
        app,
        '--source_dir=' + join_paths(meson.current_source_dir(), app),
        '--build_dir=' + join_paths(meson.current_build_dir(), app),
        '--ld=' + ld.full_path(),
        '--objcopy=' + objcopy.full_path(),
        '--objdump=' + objdump.full_path(),
        '--nm=' + nm.full_path(),
        '--ar=' + ar.full_path(),
        '--board=' + board,
        '--libgcc=' + l_gcc],
        output: app + '.ll',
        build_always_stale: true)
endforeach




# Message: libgcc directory: /usr/lib/gcc/arm-none-eabi/9.2.1/thumb/v7-m/nofp/

