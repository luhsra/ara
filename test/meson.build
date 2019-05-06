test('dependency_resolving',
        py3_inst,
        args : files('dependency_resolving.py'),
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('priority_inversion',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('priority_inversion.json'), freertos_priority_inversion],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('invalid_mutex',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('invalid_mutex.json'), freertos_invalid_mutex],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('start_scheduler_relation',
        py3_inst,
        args : [files('start_scheduler_relation.py'), 'freertos', files('start_scheduler_relation.json'), freertos_start_scheduler_relation],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('topological_sort',
        py3_inst,
        args : [files('topological_sort.py'), 'freertos', files('topological_sort.json'), freertos_topological_sort],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('deadlock',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('deadlock.json'), freertos_deadlock],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('invalid_semaphore',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('invalid_semaphore.json'), freertos_invalid_semaphore],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('eventlist_warning',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('eventgroup.json'), freertos_eventgroup],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('critical_region_detection',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('critical_region_detection.json'), freertos_critical_region_detection],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
        # TODO Test auf ABB3 nicht im kritischen Bereich
)

test('invalid_isr_syscall',
        py3_inst,
        args : [files('validation.py'), 'freertos', files('invalid_isr_syscall.json'), freertos_invalid_isr_syscall],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)
test('loop_detection',
        py3_inst,
        args : [files('loop_detection.py'), 'freertos', files('loop_detection.json'), freertos_loop_detection],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('oil-parsing',
  py3_inst,
  args : files('oil/oil.py', 'oil/1.oil'),
  env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)


subdir('native_step_test')
