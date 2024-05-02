# this variables are filled in the subdirs
libs_includes = []
libs_targets = []

libplatform_proj = subproject('ara-libplatforms')

clang_c = toolchains.get_variable('clang_c_cmd')
clang_cpp = toolchains.get_variable('clang_cpp_cmd')
obj_flags = libplatform_proj.get_variable('obj_flags')
clang_flags = libplatform_proj.get_variable('clang_flags')
ld_flags = libplatform_proj.get_variable('ld_flags')
ir_flags = toolchains.get_variable('ir_flags')

if arm_enabled
  # TODO: arm_clang_flags -> freertos_stm32_clang_flags
  arm_clang_flags = libplatform_proj.get_variable('arm_clang_flags')
  ar_args = libplatform_proj.get_variable('ar_args')
  arm_ar = toolchains.get_variable('arm_ar')

  libplatform_linkerscript = libplatform_proj.get_variable('libplatform_linkerscript')
endif

if posix_enabled
  posix_ar = toolchains.get_variable('posix_ar')
endif

if true
  #riscv_ar = toolchains.get_variable('riscv_ar')
endif


# subdir('include')
# subdir('freertos')
# subdir('osek')
subdir('autosar')

