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

test('invalid_mutex',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('invalid_mutex.json'), freertos_targets[12]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

test('start_scheduler_relation',
        py3_inst,
        args : [files('start_scheduler_relation.py'), 'freertos', files('start_scheduler_relation.json'), freertos_targets[8]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

test('topological_sort',
        py3_inst,
        args : [files('topological_sort.py'), 'freertos', files('topological_sort.json'), freertos_targets[4]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

subdir('native_step_test')
