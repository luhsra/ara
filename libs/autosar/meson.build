libs_includes += ['-I', meson.current_source_dir()]
autosar_includes = ['-I', meson.current_source_dir()]
autosar_includes += ['-I', meson.current_source_dir() / '..'] # for autosar/os.h and xen/events.h
autosar_includes += ['-I', meson.current_source_dir() / 'os']
autosar_includes += ['-I', meson.current_source_dir() / 'os' / 'util']

# Define AUTOSAR-specific build flags

libplatforms_proj = subproject('ara-libplatforms')
ar_cmd = [toolchains.get_variable('llvm_ar'), ['rcs', '@OUTPUT@', '@INPUT@']]
llvm_objcopy = toolchains.get_variable('llvm_objcopy')
tftp_deploy = libplatforms_proj.get_variable('tftp_deploy')

if arm_enabled

  autosar_pi4_clang_flags = [
    libplatform_proj.get_variable('arm_clang_flags'),
    libplatform_proj.get_variable('pi4_clang_flags'),
    #'-DDEBUG',
    '-O3',
    '-ffixed-r9', # cpuid
  ]

  is_qemu = '-DQEMU'
  if get_option('no_qemu')
    is_qemu = ''
  endif

  # For QEMU: pi4 is cortex-a72, but this makes it work in QEMU
  autosar_pi4_clang_flags += [
    '-mcpu=cortex-a7',
    # for qemu include this flag, for running on pi remove this flag
      is_qemu
    ]

  autosar_pi4_ld_flags = [
    libplatform_proj.get_variable('arm_ld_flags')
  ]

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


# RISC-V
if riscv_enabled
  autosar_riscv_clang_flags = [
    '--target=riscv64-unknown-elf', # 64 bit Architektur
    '-march=rv64imac',              # Spezifikation der genauen Architektur
    '-O3',                          # Optimierungsstufe
    '-mcmodel=medany',
    '-Wall',
    '-Wextra',
    #'-DDEBUG',                     # Debugging
  ]
  if get_option('no_qemu')
    autosar_riscv_clang_flags += libplatform_proj.get_variable('beaglev_clang_flags')
  endif
  autosar_riscv_ld_flags = [        # Linken der Bibliotheken
    '-Wl,-Map,@OUTPUT0@.map',
    '-Wl,--cref',
    '-nostdlib',
    '-nodefaultlibs',
  ]
endif

subdir('arch')
subdir('os')
subdir('test')
