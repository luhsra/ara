project('arsa', 'cpp',
  default_options : ['warning_level=3', 'cpp_std=c++17'])

cython = find_program('cython')
py3_mod = import('python')
py3_inst = py3_mod.find_installation('python3')

libgraph = dependency('libgraph', fallback : ['libgraph', 'graph_dep'])
libpass = dependency('libpass', fallback : ['libpass', 'pass_dep'])

build_dir = meson.current_build_dir()

test('ara tester',
	py3_inst,
	args : files('arsa.py', 'test/osek.ll'),
	env : ['PYTHONPATH=' + 'subprojects/libpass/' + ':' + 'subprojects/libgraph']
)
