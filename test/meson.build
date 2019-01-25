test('dependency_resolving',
        py3_inst,
        args : files('dependency_resolving.py'),
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

test('priority_inversion',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('priority_inversion.json'), freertos_targets[13]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

subdir('native_step_test')
