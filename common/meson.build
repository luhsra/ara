libcommon = static_library('libcommon',
	'llvm_common.cpp',
	dependencies: llvm_dep
)

common_inc = include_directories('.')
common_dep = declare_dependency(link_with: libcommon,
                                include_directories: common_inc)

commondir = meson.current_build_dir()
