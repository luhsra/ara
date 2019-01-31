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

test('deadlock',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('deadlock.json'), freertos_targets[9]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

test('invalid_semaphore',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('invalid_semaphore.json'), freertos_targets[15]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

test('eventlist_warning',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('eventgroup.json'), freertos_targets[11]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

test('critical_region_detection',
        py3_inst,
        args : [files('critical_region_detection.py'), 'freertos', files('critical_region_detection.json'), freertos_targets[14]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)

test('invalid_isr_syscall',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('invalid_isr_syscall.json'), freertos_targets[1]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)
test('loop_detection',
        py3_inst,
        args : [files('loop_detection.py'), 'freertos', files('loop_detection.json'), freertos_targets[3]],
        env : ['PYTHONPATH=' + ':'.join([source_dir, passdir, 'subprojects/libgraph'])]
)




subdir('native_step_test')
