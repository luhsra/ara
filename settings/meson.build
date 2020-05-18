settings_dir = meson.current_source_dir()

# common flags for clang
clang_flags = ['-g',  # generate debug information
               '-disable-O0-optnone',  # don't set the noopt attribute (prevent optimization needed by ARA)
               '-ffunction-sections',
               '-fdata-sections',
               '-fno-rtti',
               '-Wno-everything',
               '-fno-discard-value-names',  # use the C/C++ variable names for the pendent in the LLVM IR when possible
               '-fno-exceptions']

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

# compiler flags to generate IR
ir_flags = ['-S', '-emit-llvm',]

obj_flags = ['-c']

if get_option('arch') == 'i386'
  clang_flags += '--target=i386-pc-linux-gnu'
elif get_option('arch') == 'arm'
  clang_flags += ['--target=' + target_triple,
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
                 ]
  path_error = '@0@ "@1@" does not exist or is not absolute'
  foreach include_dir : get_option('arm_include_dirs')
    # requires meson 0.54
    # assert(fs.exists(include_dir) and fs.is_absolute(include_dir), path_error.format('arm_include_dir', include_dir))
    assert(fs.exists(include_dir), path_error.format('arm_include_dir', include_dir))
    clang_flags += ['-I', include_dir]
  endforeach

  ld_flags += ['-Wl,-Map,@OUTPUT0@.map',
               '-Wl,--cref',
               '-fuse-ld=' + ld.path(),
               '-nostdlib',
               '-nodefaultlibs',
               '-lc',
              ]
  # external arm dirs
  foreach link_dir : get_option('arm_link_dirs')
    # requires meson 0.54
    # assert(fs.exists(link_dir) and fs.is_absolute(link_dir), path_error.format('arm_link_dir', link_dir))
    assert(fs.exists(link_dir), path_error.format('arm_link_dir', link_dir))
    ld_flags += ['-Wl,-L,' + link_dir]
  endforeach
  # external gcc dir
  if get_option('arm_gcc_version') == 'default'
    system_gcc = find_program('gcc')
    r = run_command(py3_inst, gcc_version, system_gcc.path())
    if r.returncode() != 0
      error('Cannot extract default GCC option. Consider setting "arm_gcc_version".')
    endif
    gcc_arm_version = r.stdout().strip()
  else
    gcc_arm_version = get_option('arm_gcc_version')
  endif
  libgcc_dir = get_option('arm_gcc_dir').format(gcc_arm_version)
  # requires meson 0.54
  # assert(fs.exists(libgcc_dir) and fs.is_absolute(libgcc_dir), path_error.format('arm_gcc_dir', libgcc_dir))
  assert(fs.exists(libgcc_dir), path_error.format('arm_gcc_dir', libgcc_dir))
  assert(fs.exists(libgcc_dir / 'thumb'), 'Thumb library inside GCC ARM is missing.')
  message('libgcc directory: @0@'.format(libgcc_dir))
  ld_flags += ['-Wl,-L,' + (libgcc_dir / 'thumb')]


  llc_flags += ['--frame-pointer=none']
else
  error('unknown arch ' + get_option('arch'))
endif

# standard invocations for clang with c and cpp
c_std = '-std=c11'
cxx_std = '-std=c++11'
clang_base = [
           '-o', '@OUTPUT0@',
           '@INPUT@',
           '-MD', '-MF', '@DEPFILE@',
]
clang_c = [clang, clang_base, c_std]
clang_cpp = [clang, clang_base, cxx_std]

# standard invocations for rest of the toolchain
ar_cmd = [ar, 'qcs', '@OUTPUT@', '@INPUT@']
llc_cmd = [llc, '-filetype=obj', '-o', '@OUTPUT@', '@INPUT@', ] + llc_flags
objcopy_cmd = [objcopy, '-Obinary', '@INPUT@', '@OUTPUT@']
llvm_link_cmd = [llvm_link, '-S', '-o', '@OUTPUT@', '@INPUT@',]
llvm_opt_cmd = [llvm_opt, '-S', '-o', '@OUTPUT@', '@INPUT@'] + llvm_opt_flags

ara_gen_cmd = [bash, ara_sh,
               '@INPUT@',
               '--generator_output', '@OUTPUT0@',
               '--ir_output', '@OUTPUT2@',
               '--dependency_file', '@DEPFILE@',
              ]


ara_gen_freertos_targets = ['vanilla',
                            'instances_full_static',
                            'instances_full_initialized',
                            'passthrough'
                           ]

foreach target : ara_gen_freertos_targets
  set_variable('ara_gen_cmd_'+target, ara_gen_cmd +
                             [ '--step-settings',
                               files(join_paths(settings_dir, 'freertos_'+target+'.json')),
                             ]
              )
endforeach
