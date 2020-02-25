settings_dir = meson.current_source_dir()
clang = find_program('clang', version: llvm_version)
#FIXME: enable find_program if it correctly detects llc version
llc = 'llc'
#llc = find_program('llc', version: llvm_version)
llvm_link = 'llvm-link'
#llvm_link = find_program('llvm-link', llvm_version)
llvm_opt = 'opt'
#llmvm_opt = find_program('opt', llvm_version)
bash = find_program('bash')
nop = find_program('true')

# compiler flags to generate annotated IR
clang_flags = ['-g',
               # '-Og',
               '-O2',
               '-ffunction-sections',
               '-fdata-sections',
               '-fno-rtti',
               '-fno-discard-value-names', '-fno-exceptions']
llvm_opt_flags = [
  # '-time-passes',
  # '-Og',
  '-O2',
]

llc_flags = ['--function-sections',
             '--data-sections',
            ]
ld_flags = ['-Wl,--gc-sections',
            '-Wl,--warn-common',
            '-Wl,--warn-section-align',
            '-Wl,--cref',
            '-Wl,-Map,@OUTPUT0@.map'
           ]
ir_flags = ['-S', '-emit-llvm',]
obj_flags = ['-c']

if get_option('arch') == 'i386'
  target_triple='x86_64-linux-gnu'
  clang_flags += '--target=i386-pc-linux-gnu'
elif get_option('arch') == 'arm'
  target_triple = 'arm-none-eabi'
  clang_flags += ['--target='+target_triple,
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
  llc_flags += ['--frame-pointer=none',
                ]

else
  assert(false, 'unknown arch ' + get_option('arch'))
endif

arch_error = 'Do you have an @0@ toolchain? Otherwise consider to switch to another architecture. See the "arch" config option for that.'

foreach prog_name : ['ar', 'objcopy', 'size', 'nm']
    full_prog_name = target_triple + '-' + prog_name
    prog = find_program(full_prog_name, required: false)
    if not prog.found()
        error(arch_error.format(get_option('arch').to_upper()))
    endif
    set_variable(prog_name, prog)
endforeach

compare_nm += nm.path()

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
llc_cmd = [llc, '-filetype=obj', '-o', '@OUTPUT@', '@INPUT@', ] + llc_flags
objcopy_cmd = [objcopy, '-Obinary', '@INPUT@', '@OUTPUT@']
llvm_link_cmd = [llvm_link, '-S', '-o', '@OUTPUT@', '@INPUT@',]
llvm_opt_cmd = [llvm_opt, '-S', '-o', '@OUTPUT@', '@INPUT@'] + llvm_opt_flags

ara_gen_cmd = [bash, sh,
               '@INPUT@',
               '--output_file', '@OUTPUT0@',
               '--dependency_file', '@DEPFILE@',
              ]


ara_gen_freertos_targets = ['vanilla',
                            'instances_full_static',
                            'instances_full_initialized',
                           ]

foreach t : ara_gen_freertos_targets
  set_variable('ara_gen_'+t, ara_gen_cmd +
                             [ '--step-settings',
                               files(join_paths(settings_dir, 'freertos_'+t+'.json')),
                             ]
              )
endforeach
