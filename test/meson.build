test('dependency_resolving',
        py3_inst,
        args : files('dependency_resolving.py'),
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

subdir('native_step_test')
