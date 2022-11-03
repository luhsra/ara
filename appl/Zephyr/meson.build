
# Apps that run on virtually any board since there are no hw dependencies
z_easy_apps = [
    'app_kernel',
    'cpp_sems',
    'duplicate_syscalls',
    'dyn_heap',
    'dyn_msgq',
    'dyn_pipe',
    'dyn_queue',
    'dyn_stack',
    'dyn_sys_sems',
    'dyn_sems',
    'latency_measure',
    'minimal',
    'multi_init',
    'static_heap',
    'static_msgq',
    'static_pipe',
    'static_queue',
    'static_sems',
    'static_stack',
    'static_sys_sems',
    'static_threads',
    'sys_kernel',
    'OSPERT_2022'
]

# Apps that require boards that support userspace applications
z_userspace_apps = [
    'prod_consumer',
    'shared_mem'
]

# Apps that require hardware (gpio, interrupt controller) and therefore run on the nucleo_f103rb
z_hw_apps = [
    'blinky',
    'button',
    'dyn_isr',
    'static_isr'
]

zephyr_apps = z_easy_apps

# Currently only three targets are supported:
# Arm: The nucleo f103rb and nucleo_f303re
# i386: native_posix
# TODO: Find at least one arm board that supports user mode.
if get_option('arch') == 'i386'
    l_gcc = ''
    board = 'native_posix'
elif get_option('arch') == 'arm'
    l_gcc = libgcc_dir
    # The f303re has a bigger flash which is needed for a few bigger samples.
    #board = 'nucleo_f103rb'
    board = 'nucleo_f303re'
    zephyr_apps += z_hw_apps
endif

zephyr_targets = []
zephyr_root = join_paths(get_option('zephyr_dir'), 'zephyr')


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
    target = custom_target(app,
        env: [python_path],
        depends: ara_py,
        command: [py3_inst,
        join_paths(meson.current_source_dir(), 'compile_zephyr.py'),
        app,
        '--source_dir=' + join_paths(meson.current_source_dir(), app),
        '--build_dir=' + join_paths(meson.current_build_dir(), app),
        '--zephyr_root=' + zephyr_root,
        '--ld=' + ld.full_path(),
        '--objcopy=' + objcopy.full_path(),
        '--objdump=' + objdump.full_path(),
        '--nm=' + nm.full_path(),
        '--ar=' + ar.full_path(),
        '--board=' + board,
        '--libgcc=' + l_gcc,
        '--cc=' + clang.full_path(),
        '--llc=' + llc.full_path(),
        '--llvm_link=' + llvm_link.full_path()],
        output: app + '.ll',
        build_always_stale: true)
    zephyr_targets += target
    set_variable('zephyr_' + app, target)
endforeach

