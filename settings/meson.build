settings_dir = meson.current_source_dir()

# common flags for clang
clang_flags = ['-g',  # generate debug information
               '-O0',
               '-Xclang', '-disable-O0-optnone',  # don't set the noopt attribute (prevent optimization needed by ARA)
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

# posix
if posix_enabled
  posix_clang_flags = [
    '-m32',
    '-gdwarf-4' # for valgrind
  ]
  if get_option('debug') == true
    posix_clang_flags += '-DDEBUG'
  endif
  posix_ld_flags = [
    '-lpthread',
    '-lrt',
  ]
  posix_ar = toolchains.get_variable('posix_ar')
endif

if arm_enabled
  arm_triple = toolchains.get_variable('arm_triple')
  arm_clang_flags = [
    '--target=' + arm_triple,
    '-mthumb',
    '-mcpu=cortex-m3',
    '-march=armv7-m',
    '-mfloat-abi=soft',
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
  arm_include_path = toolchains.get_variable('arm_include_path')
  arm_link_path = toolchains.get_variable('arm_link_path')

  llvm_ld = toolchains.get_variable('llvm_ld')
  arm_ld_flags = [
    '-Wl,-Map,@OUTPUT0@.map',
    '-Wl,--cref',
    '-fuse-ld=' + llvm_ld.path(),
    '-nostdlib',
    '-nodefaultlibs',
    '-lc',
  ]

  # tools
  arm_gcc = toolchains.get_variable('arm_gcc')
  arm_ar = toolchains.get_variable('arm_ar')
  arm_objcopy = toolchains.get_variable('arm_objcopy')
  arm_size = toolchains.get_variable('arm_size')
  arm_nm = toolchains.get_variable('arm_nm')

  libgcc_dir = toolchains.get_variable('libgcc_dir')
  arm_ld_flags += ['-Wl,-L,' + (libgcc_dir)]

  arm_llc_flags = ['--frame-pointer=none']
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
ar_args = ['qcs', '@OUTPUT@', '@INPUT@']
llc_cmd = [llc, '-filetype=obj', '-o', '@OUTPUT@', '@INPUT@', ] + llc_flags
objcopy_args = ['-Obinary', '@INPUT@', '@OUTPUT@']
llvm_link_cmd = [ara_link, '-S', '-o', '@OUTPUT@', '@INPUT@',]
llvm_opt_cmd = [llvm_opt, '-S', '-o', '@OUTPUT@', '@INPUT@'] + llvm_opt_flags

ara_gen_cmd = [py3_inst, ara_py,
               '@INPUT@',
               '--generator_output', '@OUTPUT0@',
               '--ir_output', '@OUTPUT2@',
               '--dependency_file', '@DEPFILE@',
              ]


ara_gen_freertos_targets = ['passthrough',
                            'vanilla',
                            'instances_full_static',
                            'instances_full_initialized',
                            #'interactions',
                           ]

ara_gen_freertos_cmds = {}

foreach target : ara_gen_freertos_targets
  set_variable('ara_gen_cmd_'+target, ara_gen_cmd +
                             [ '--os', 'FreeRTOS', '--step-settings',
                               files(join_paths(settings_dir, 'freertos_'+target+'.json')),
                             ]
              )
  ara_gen_freertos_cmds += {target: get_variable('ara_gen_cmd_'+target)}
endforeach
llvm_lto_cmd_none = ['cp', '@INPUT@', '@OUTPUT@']
llvm_lto_cmd_standard = llvm_opt_cmd
llvm_lto_cmd_rle2 = llvm_opt_cmd + ['-load', sparse_rle2.full_path(), '-SparseRLE2', '-enable-new-pm=0']

#install_subdir(settings_dir,
#               exclude_files: ['meson.build'],
#               install_dir: get_option('datadir') / 'ara')
