autosar_includes = ['-I', meson.current_source_dir() / 'source' / 'os']

autosar_targets = []
autosar_apps = [
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm1',    'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm1',    'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm1',    'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm1',    'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm1',    'name': 'e',                     'oil': 'system.json', 'mtrace': 'e.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm1',    'name': 'f',                     'oil': 'system.json', 'mtrace': 'f.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm2',    'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm2',    'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm2',    'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm3',    'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm3',    'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm3',    'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm3',    'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'alarm3',    'name': 'e',                     'oil': 'system.json', 'mtrace': 'e.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'complex1',  'name': 'a',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'complex1',  'name': 'b',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'complex1',  'name': 'c',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'complex1',  'name': 'd',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'complex2',  'name': 'a',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'counter1',  'name': 'a',                     'oil': 'system.json'},
# {'core': 'singlecore', 'path': 'bcc1' / 'depsvc',    'name': 'depsvc',                'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'hoffmann',  'name': 'a',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'a',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'b',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'c',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'd',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'e',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'lukas',     'name': 'alarmstress',           'oil': 'alarmstress.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'lukas',     'name': 'dispatch',              'oil': 'dispatch.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'lukas',     'name': 'isr2',                  'oil': 'isr2.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'e',                     'oil': 'system.json', 'mtrace': 'e.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'f',                     'oil': 'system.json', 'mtrace': 'f.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'g',                     'oil': 'system.json', 'mtrace': 'g.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'h',                     'oil': 'system.json', 'mtrace': 'h.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'j',                     'oil': 'system.json', 'mtrace': 'j.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'k',                     'oil': 'system.json', 'mtrace': 'k.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource1', 'name': 'l',                     'oil': 'system.json', 'mtrace': 'l.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource2', 'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'resource2', 'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'sse1',      'name': 'a',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'sse1',      'name': 'b',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'sse1',      'name': 'c',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task1',     'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task1',     'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task1',     'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task1',     'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task1',     'name': 'e',                     'oil': 'system.json', 'mtrace': 'e.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task1',     'name': 'f',                     'oil': 'system.json', 'mtrace': 'f.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task1',     'name': 'g',                     'oil': 'system.json', 'mtrace': 'g.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task2',     'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task2',     'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'task2',     'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'complex',            'name': 'copter-without-alarms', 'oil': 'system-without-alarms.json'},
  {'core': 'singlecore', 'path': 'complex',            'name': 'isorc',                 'oil': 'isorc.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'e',                     'oil': 'system.json', 'mtrace': 'e.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'f',                     'oil': 'system.json', 'mtrace': 'f.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'g',                     'oil': 'system.json', 'mtrace': 'g.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'bt1',       'name': 'h',                     'oil': 'system.json', 'mtrace': 'h.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'event1',    'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'event1',    'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'event1',    'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'event1',    'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'event1',    'name': 'e',                     'oil': 'system.json', 'mtrace': 'e.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'event1',    'name': 'f',                     'oil': 'system.json', 'mtrace': 'f.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'event1',    'name': 'g',                     'oil': 'system.json', 'mtrace': 'g.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'eventisr1', 'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'eventisr1', 'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'eventisr1', 'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'eventisr1', 'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'eventisr1', 'name': 'e',                     'oil': 'system.json', 'mtrace': 'e.trace.json'},
  {'core': 'singlecore', 'path': 'ecc1' / 'eventisr1', 'name': 'f',                     'oil': 'system.json', 'mtrace': 'f.trace.json'},
  {'core': 'singlecore', 'path': 'sched' ,             'name': 'a',                     'oil': 'a.json', 'mtrace': 'a.trace.json'},
  {'core': 'multicore',  'path': '',                   'name': 'minexample',            'oil': 'minexample.json'},
  {'core': 'multicore',  'path': 'interrupts',        'name': 'a',                     'oil': 'a_system.json', 'mtrace': 'a_trace.json', 'timing': 'a_timings.json'},
  {'core': 'multicore',  'path': 'interrupts',        'name': 'cross_alarms',          'oil': 'cross_alarms_system.json', 'mtrace': 'cross_alarms_trace.json'},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'a_start1',              'oil': 'EXTRACT', 'mtrace': 'a_start1.trace.json', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'a',                     'oil': 'a.system.json', 'mtrace': 'a.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'b',                     'oil': 'b.system.json', 'mtrace': 'b.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'c',                     'oil': 'c.system.json', 'mtrace': 'c.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'd',                     'oil': 'd.system.json', 'mtrace': 'd.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'e',                     'oil': 'e.system.json', 'mtrace': 'e.trace.json'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'f',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'g',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'h',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'i',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'j',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'k',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'l',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'm',                     'oil': 'system_m.json'},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'n',                     'oil': 'system_m.json'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-a',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'timing': 'BB', 'ttrace': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-a-chain',   'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-a-start5',  'oil': 'EXTRACT',              'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'timing': 'BB', 'ttrace': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-b',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-c',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-d',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-e',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-a',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-a-start5',    'oil': 'EXTRACT',            'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-b',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-c',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-d',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'loops',              'name': 'a',                     'oil': 'system_a.json'},
  {'core': 'multicore',  'path': 'loops',              'name': 'b',                     'oil': 'system_b.json'},
  {'core': 'multicore',  'path': 'loops',              'name': 'c',                     'oil': 'system_b.json'},
  {'core': 'multicore',  'path': 'timing',             'name': 'a',                     'oil': 'system_a.json', 'timing': 'a_timing.json'},
  {'core': 'multicore',  'path': 'timing',             'name': 'b',                     'oil': 'system_b.json', 'timing': 'b_timing.json'},
  {'core': 'multicore',  'path': 'timing',             'name': 'c',                     'oil': 'system_c.json', 'timing': 'c_timing.json'},
  {'core': 'multicore',  'path': 'paper',              'name': 'running',               'oil': 'system_running.json', 'mtrace': 'running.trace.json', 'locks': 'EXTRACT', 'timing': 'BB', 'ttrace': 'running.timing.trace.json'},
  {'core': 'multicore',  'path': 'paper',              'name': 'running_long11',        'oil': 'system_running.json', 'locks': 'EXTRACT', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'paper',              'name': 'deadlock',              'oil': 'system_running.json', 'locks': 'EXTRACT', 'timing': 'BB', 'mtrace': 'deadlock.trace.json'},
  {'core': 'multicore',  'path': 'paper',              'name': 'minimal',               'oil': 'system_minimal.json', 'locks': 'EXTRACT'},
  {'core': 'multicore',  'path': 'paper',              'name': 'event',                 'oil': 'system_event.json', 'locks': 'EXTRACT', 'mtrace': 'EXTRACT'},
  {'core': 'multicore',  'path': 'paper',              'name': 'timing',                'oil': 'system_timing.json', 'locks': 'EXTRACT', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'paper',              'name': 'interrupt_as_tasks',    'oil': 'system_interrupt_as_tasks.json', 'locks': 'EXTRACT', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'paper',              'name': 'interrupt_as_tasks2',   'oil': 'system_interrupt_as_tasks.json', 'locks': 'EXTRACT', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'paper',              'name': 'interrupt_as_tasks3',   'oil': 'system_interrupt_as_tasks.json', 'locks': 'EXTRACT', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'paper',              'name': 'timing-semiordered',    'oil': 'system_timing.json', 'locks': 'EXTRACT', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'paper',              'name': 'timing-ordered',        'oil': 'system_timing.json', 'locks': 'EXTRACT', 'timing': 'BB', 'mtrace': 'EXTRACT', 'ttrace': 'EXTRACT'},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-without-alarms', 'oil': 'copter-without-alarms_system.json', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-with-alarms',    'oil': 'copter-with-alarms_system.json', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-single-alarm',   'oil': 'copter-single-alarm_system.json', 'timing': 'BB'},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-autostart',      'oil': 'copter-autostart_system.json', 'locks': 'EXTRACT', 'timing': 'BB'},
]
# conformance tests for trampoline
subdir('multicore' / 'trampoline')


no_timing_settings = custom_target(
  output: 'no_timing_settings.json',
  capture: true,
  command: ['echo', '{"steps": ["LockElision", "IPIAvoidance"], "MultiSSE": {"with_times": false}}'],
)
with_timing_settings = custom_target(
  output: 'with_timing_settings.json',
  capture: true,
  command: ['echo', '{"steps": ["ApplyTimings", "LockElision", "IPIAvoidance"], "MultiSSE": {"with_times": true}}'],
)


foreach app : autosar_apps
  # src file
  sys = app['core'] / app['path'] / app['name']
  full_name = 'autosar_' + sys.underscorify()
  app += {'src': files(sys + '.cc'), 'full_name': full_name}


  #oil file
  if app['oil'] == 'EXTRACT'
    oil = custom_target('autosar_' + sys.underscorify() + '.system.json',
                        input: sys + '.cc',
                        output : full_name + '.system.json',
                        capture: true,
                        command : [sed, '-n', '/if SYSTEM_JSON/,/SYSTEM_JSON/{/SYSTEM_JSON/d;p}', '@INPUT@'])
  else
    oil = files(app['core'] / app['path'] / app['oil'])
  endif
  app += {'oil': oil}

  # compile the application
  app_ll = custom_target(full_name,
                         input : sys + '.cc',
                         output : full_name + '.ll',
                         depfile : full_name + '.ll.dep',
                         command : clang_cpp +
                                   libs_includes +
                                   ir_flags +
                                   clang_flags)
  app += {'ll': app_ll}

  run_target('run_lock_elision_no_timings_' + full_name,
             command: [py3_inst, ara_py, app_ll, '--oilfile', oil, '-s', 'LockElision', '-s', 'IPIAvoidance'])


  # trace file for sse testing
  if not app.has_key('mtrace')
    sys_test =  disabler()
  elif app['mtrace'] == 'EXTRACT'
    sys_test = custom_target(full_name + '.trace.json',
                             input: sys + '.cc',
                             output : full_name + '.trace.json',
                             capture: true,
                             command : [sed, '-n', '/if TRACE_JSON/,/TRACE_JSON/{/TRACE_JSON/d;p}', '@INPUT@'])
  else
    sys_test = files(app['core'] / app['path'] / app['mtrace'])
  endif
  app += {'sys_test': sys_test}

  if not app.has_key('ttrace')
    time_test =  disabler()
  elif app['ttrace'] == 'EXTRACT'
    time_test = custom_target(full_name + '.ttrace.json',
                              input: sys + '.cc',
                              output : full_name + '.ttrace.json',
                              capture: true,
                              command : [sed, '-n', '/if TIMING_JSON/,/TIMING_JSON/{/TIMING_JSON/d;p}', '@INPUT@'])
  else
    time_test = files(app['core'] / app['path'] / app['ttrace'])
  endif
  app += {'time_test': time_test}

  # timings for multisse with lock elision
  if not app.has_key('timing')
    sys_timings = disabler()
  elif app['timing'] == 'BB'
    sys_timings = 'BB'
  else
    sys_timings = files(app['core'] / app['path'] / app['timing'])
  endif
  app += {'sys_timings': sys_timings}

  generate_timing_settings = custom_target(
    output: full_name  + '.generate_timing_settings.json',
    capture: true,
    command: ['echo', '{"steps": ["ApplyTimings", "LoadOIL", "DumpCFG"], "ApplyTimings": {"create_timings": "' +  app['full_name'] +'.empty_timing.json"}}'],
  )



  run_target('run_lock_elision_generate_timings_' + full_name,
             command: [py3_inst, ara_py, app['ll'], '--oilfile', app['oil'], '--step-settings', generate_timing_settings])
  run_target('run_lock_elision_with_timings_' + full_name,
             command: [py3_inst, ara_py, app['ll'], '--oilfile', app['oil'], '--step-settings', with_timing_settings, '--timings', app['sys_timings'], '--step-data'])

  step_data = custom_target(full_name + '.multisse.no_timing.stepdata.json',
                            input: [ara_py, app['ll'], app['oil']],
                            output: full_name + '.multisse.no_timing.stepdata.json',
                            depfile: full_name + '.dep',
                            command: [py3_inst, ara_py, app['ll'],
                                      '--dependency_file', '@DEPFILE@',
                                      '--oilfile', app['oil'],
                                      '-s', 'LockElision', '-s', 'IPIAvoidance',
                                      '--step-data', '@OUTPUT@'],
                           )

  step_data = custom_target(full_name + '.multisse.with_timing.stepdata.json',
                            input: [ara_py, app['ll'], app['oil']],
                            output: full_name + '.multisse.with_timing.stepdata.json',
                            depfile: full_name + '.dep',
                            command: [py3_inst, ara_py, app['ll'],
                                      '--dependency_file', '@DEPFILE@',
                                      '--oilfile', app['oil'],
                                      '--step-settings', with_timing_settings,
                                      '--timings', app['sys_timings'],
                                      '--step-data', '@OUTPUT@'],
                           )

  # lock elision test data
  if app.has_key('locks')
    if app['locks'] == 'EXTRACT'
      locks = custom_target(full_name + '.locks.json',
                            input: sys + '.cc',
                            output : full_name + '.locks.json',
                            capture: true,
                            command : [sed, '-n', '/if LOCKS_JSON/,/LOCKS_JSON/{/LOCKS_JSON/d;p}', '@INPUT@'])
    elif app.has_key('locks')
      locks = files(app['core'] / app['path'] / app['locks'])
    endif
    app += {'locks': locks}
  endif
  set_variable(full_name, app)
  autosar_targets += [app]
endforeach


subdir('multicore/dynamic')
