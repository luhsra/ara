autosar_includes += ['-I', meson.current_source_dir() / 'generic']

if get_option('arch') == 'arm'

  if  get_option('platform') == 'zedboard'
    arm_gcc_flags = [
      '-mcpu=cortex-a9',
      '-mfloat-abi=soft',
      '-mthumb'
    ]
  elif get_option('platform') == 'raspi_32'
    arm_gcc_flags = [
      '-mcpu=cortex-a72',
      '-mfloat-abi=soft',
      '-mthumb',
      #'-DPMU_TRACE_A', # PMU tracing (syscall)
      #'-DPMU_TRACE_B', # PMU tracing (IRQ)
      '-DPMU_TRACE_C', # only user
      #'-DDEBUG'
    ]
    # QEMU:
      arm_gcc_flags += [
      '-DQEMU',
      #'-DDEBUG', # runtime debug output
      '-mcpu=cortex-a7'
    ]
  endif

  clang_flags += [
    '-g', # debug info
    '--target=armv7a-none-elf',
    arm_gcc_flags,
    '-ffixed-r9',
    #'-no-integrated-as',
    #'--prefix=/usr/arm-none-eabi/bin',
    '-Wno-error=void-ptr-dereference',
    '-fno-exceptions',
    '-std=c++11',
    '-ccc-gcc-name',
    'arm-none-eabi-gcc',
    '-O1', # required for GIC/machine assembly
  ]
  ld_flags += [
    '-nostartfiles',
    '-nostdlib'
  ]
  ir_flags += [
    '-O0' # required for IR ABB analysis
  ]
  subdir('arm')
  subdir('generic')

elif get_option('arch') == 'posix'
  clang_flags += [
    '--target=i386-pc-linux-gnu',
    '-m32',
    '-gdwarf-4', # for valgrind'
    '-O0',
    '-ffunction-sections',
    '-fdata-sections',
    '-fno-rtti',
    '-Wno-everything',
    '-fno-discard-value-names',  # use the C/C++ variable names for the pendent in the LLVM IR when possible
    '-fno-exceptions'
  ]
  ld_flags += [
    '-lpthread',
    '-lrt',
  ]
  subdir('posix')
  subdir('generic')
else
  warning('unknown arch/platform')

endif
