pybgl_includes = files('bgl.pxd', 'move.pxd', 'bgl_wrapper.pxd', 'bgl_bridge.pxd')

bgl_pyx_cpp = custom_target('bgl_pyx',
    output : 'bgl_pyx.cpp',
    input : ['bgl.pyx', pybgl_includes, common_cython_files],
    command : [cython, '-I', common_cython_inc, '@INPUT0@', '-o', '@OUTPUT@'] + cython_flags
)

bgl = py3_inst.extension_module('bgl',
    bgl_pyx_cpp,
    dependencies : [py3_inst.dependency(), boost_dep, common_dep]
)

bgl_inc = include_directories('.')
bgl_dep = declare_dependency(link_with : bgl,
                             include_directories : bgl_inc)

bgl_dir = meson.current_build_dir()
bgl_cython_inc = meson.current_source_dir()
