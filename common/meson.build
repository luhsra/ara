libcommon = static_library('libcommon',
	'llvm_common.cpp',
	dependencies: llvm_dep
)

common_inc = include_directories('.')
common_cython_inc = meson.current_source_dir()
common_cython_files = files('common/__init__.pxd',
                            'common/backported_memory.pxd',
                            'common/cy_helper.pxd',
                            'common/move.pxd')

common_dep = declare_dependency(link_with: libcommon,
                                include_directories: common_inc)

commondir = meson.current_build_dir()
