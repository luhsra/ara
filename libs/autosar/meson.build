libs_includes += ['-I', meson.current_source_dir()]
autosar_includes = ['-I', meson.current_source_dir()]
autosar_includes += ['-I', meson.current_source_dir() / '..'] # for autosar/os.h
autosar_includes += ['-I', meson.current_source_dir() / 'os']
autosar_includes += ['-I', meson.current_source_dir() / 'os' / 'util']

# Define AUTOSAR-specific build flags

libplatforms_proj = subproject('ara-libplatforms')
ar_cmd = [toolchains.get_variable('llvm_ar'), ['rcs', '@OUTPUT@', '@INPUT@']]

if arm_enabled

  autosar_pi4_clang_flags = [
    libplatform_proj.get_variable('arm_clang_flags'),
    libplatform_proj.get_variable('pi4_clang_flags'),
    #'-DDEBUG',
    '-O3',
    '-ffixed-r9', # cpuid
  ]

# For QEMU: pi4 is cortex-a72, but this makes it work in QEMU
autosar_pi4_clang_flags += [
    '-mcpu=cortex-a7',
    '-DQEMU', #QEMU
]

  autosar_pi4_ld_flags = [
    libplatform_proj.get_variable('arm_ld_flags')
  ]

  llvm_objcopy = toolchains.get_variable('llvm_objcopy')
  rpi4_tftp_deploy = libplatforms_proj.get_variable('rpi4_tftp_deploy')
endif

if posix_enabled
  autosar_posix_clang_flags = [
    '--target=i386-pc-linux-gnu',
    '-m32',
    '-O3',
    #'-DDEBUG',
  ]
  autosar_posix_ld_flags = [
    '-lpthread',
    '-lrt',
  ]
endif

subdir('arch')
subdir('os')
subdir('test')
