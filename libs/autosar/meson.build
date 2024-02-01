libs_includes += ['-I', meson.current_source_dir()]
autosar_includes = ['-I', meson.current_source_dir()]
autosar_includes += ['-I', meson.current_source_dir() / '..'] # for autosar/os.h
autosar_includes += ['-I', meson.current_source_dir() / 'os']
autosar_includes += ['-I', meson.current_source_dir() / 'os' / 'util']

# Define AUTOSAR-specific build flags

libplatforms_proj = subproject('ara-libplatforms')

if arm_enabled
  autosar_pi4_gcc_flags = [
    '-mcpu=cortex-a7',
    '-mfloat-abi=soft',
    '-mthumb',
    '-DQEMU', #QEMU
  ]

  autosar_pi4_clang_flags = [
    libplatform_proj.get_variable('arm_clang_flags'),
    libplatform_proj.get_variable('pi4_clang_flags'),
    #'-DDEBUG',
    '-O3',
    '-ffixed-r9', # cpuid
  ]
  autosar_pi4_ld_flags = [
    libplatform_proj.get_variable('arm_ld_flags')
  ]

  arm_ar_cmd = libplatforms_proj.get_variable('ar_cmd')
endif

if posix_enabled
  autosar_posix_clang_flags = [
    '--target=i386-pc-linux-gnu',
    '-m32',
    '-O3',
    #'-DDEBUG',
    '-DCONFIG_ARCH_POSIX', # for alarm3
  ]
  autosar_posix_ld_flags = [
    '-lpthread',
    '-lrt',
  ]
  posix_ar_cmd = [toolchains.get_variable('llvm_ar'), ['rcs', '@OUTPUT@', '@INPUT@']]
endif

subdir('arch')
subdir('os')
subdir('test')
