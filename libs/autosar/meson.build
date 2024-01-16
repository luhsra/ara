libs_includes += ['-I', meson.current_source_dir()]
autosar_includes = ['-I', meson.current_source_dir()]
autosar_includes += ['-I', meson.current_source_dir() / '..'] # for autosar/os.h
autosar_includes += ['-I', meson.current_source_dir() / 'os']
autosar_includes += ['-I', meson.current_source_dir() / 'os' / 'util']

# Define AUTOSAR-specific build flags

if arm_enabled
  autosar_pi4_gcc_flags = [
    '-mcpu=cortex-a7',
    '-mfloat-abi=soft',
    '-mthumb',
    #'-DPMU_TRACE_A', # PMU tracing (syscall)
    #'-DPMU_TRACE_B', # PMU tracing (IRQ)
    #'-DPMU_TRACE_C', # only user
    #'-DDEBUG'
    '-DQEMU', #QEMU
  ]

  autosar_pi4_clang_flags = [
    autosar_pi4_gcc_flags,
    '-g', # debug info
    '--target=armv7a-none-elf',
    '-ffixed-r9',
    #'-no-integrated-as',
    #'--prefix=/usr/arm-none-eabi/bin',
    '-Wno-error=void-ptr-dereference',
    '-fno-exceptions',
    '-std=c++11',
    '-ccc-gcc-name',
    'arm-none-eabi-gcc',
    '-O2', # required for GIC/machine assembly
  ]
  autosar_pi4_ld_flags = [
    '-nostartfiles',
    '-nostdlib'
  ]
  ir_flags += [
    '-O0' # required for IR ABB analysis
  ]
endif

if posix_enabled
  autosar_posix_clang_flags = [
    '--target=i386-pc-linux-gnu',
    '-m32',
  ]
  autosar_posix_ld_flags = [
    '-lpthread',
    '-lrt',
  ]
  libplatforms_proj = subproject('ara-libplatforms')
  ar_args = libplatforms_proj.get_variable('ar_args')
  arm_ar_cmd = libplatforms_proj.get_variable('ar_cmd')
  posix_ar_cmd = [toolchains.get_variable('llvm_ar'), ar_args]
endif

subdir('arch')
subdir('os')
subdir('test')
