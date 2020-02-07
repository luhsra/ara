settings_dir = meson.current_source_dir()
clang = find_program('clang', version: llvm_version)
# llc = find_program('llc', version: llvm_version)
nop = find_program('true')

# compiler flags to generate annotated IR
clang_flags = ['-g',
               '-ffunction-sections',
               '-fdata-sections',
               '-fno-rtti',
               '-fno-discard-value-names', '-fno-exceptions']
ld_flags = ['-Wl,--gc-sections',
            '-Wl,--warn-common',
            '-Wl,--warn-section-align',
            '-Wl,--cref',
            '-Wl,-Map,@OUTPUT0@.map'
           ]
ir_flags = ['-S', '-emit-llvm',]
obj_flags = ['-c']

if get_option('arch') == 'i386'
  clang_flags += '--target=i386-pc-linux-gnu'
  ar = find_program('ar')
  objcopy = find_program('objcopy')
elif get_option('arch') == 'arm'
  clang_flags += ['--target=arm-none-eabi',
                  '-mthumb',
                  '-mcpu=cortex-m3',
                  '-march=armv7-m',
                  '-mabi=aapcs',
                  '-DF_CPU=72000000L',
                  '-DMCU_STM32F103RB',
                  '-DSTM32F1',
                  '-DSTM32F103RB',
                  '-DSTM32F103xB',
                  '-fomit-frame-pointer',
                  '-fno-builtin',
                  '-fno-threadsafe-statics',
                  '-fshort-enums',
                  '--rtlib=libgcc',
                  '-I','/usr/arm-none-eabi/include/',
                  '-I','/usr/lib/arm-none-eabi/include/',
                 ]
  ld_flags += ['-Wl,-Map,GPSLogger.map',
               '-fuse-ld=/usr/bin/arm-none-eabi-ld',
               '-Wl,-L,/usr/arm-none-eabi/lib/thumb',
               '-Wl,-L,/usr/lib/arm-none-eabi/newlib/thumb',
               '-Wl,-L,/usr/lib/gcc/arm-none-eabi/7.3.1/thumb/',
               '-nostdlib',
               '-nodefaultlibs',
               '-lc',
              ]
  ar = find_program('arm-none-eabi-ar')
  objcopy = find_program('arm-none-eabi-objcopy')
else
  assert(false, 'unknown arch ' + get_option('arch'))
endif

clang_flags += '-Wno-everything'
c_std = '-std=c11'
cxx_std = '-std=c++11'
clang_x = [clang,
           '-o', '@OUTPUT0@',
           '@INPUT@',
           '-MD', '-MF', '@DEPFILE@',
          ]
clang_c = clang_x + [c_std]
clang_cpp = clang_x + [cxx_std]
ar_cmd = [ar, 'qcs', '@OUTPUT@', '@INPUT@']
llc_cmd = ['llc', '-filetype=obj', '-o', '@OUTPUT@', '@INPUT@', ]
objcopy_cmd = [objcopy, '-Obinary', '@INPUT@', '@OUTPUT@']

ara_gen_cmd = [sh.full_path(),
               '@INPUT@',
               '--output_file', '@OUTPUT0@',
              ]


ara_gen_freertos_targets = ['vanilla',
                            'instances_full_static',
                           ]

foreach t : ara_gen_freertos_targets
  set_variable('ara_gen_'+t, ara_gen_cmd +
                             [ '--step-settings',
                               files(join_paths(settings_dir, 'freertos_'+t+'.json')),
                             ]
              )
endforeach
