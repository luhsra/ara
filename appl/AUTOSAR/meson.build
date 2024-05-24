autosar_includes += ['-I', meson.current_source_dir() / 'source' / 'os']

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
  {'core': 'singlecore', 'path': 'bcc1' / 'hoffmann',  'name': 'a',                     'oil': 'system.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'a',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'b',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'c',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'd',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'isr2',      'name': 'e',                     'oil': 'system.json'},
  {'core': 'singlecore', 'path': 'bcc1' / 'lukas',     'name': 'alarmstress',           'oil': 'alarmstress.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'singlecore', 'path': 'bcc1' / 'lukas',     'name': 'dispatch',              'oil': 'dispatch.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'singlecore', 'path': 'bcc1' / 'lukas',     'name': 'isr2',                  'oil': 'isr2.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'singlecore', 'path': 'pairwise',           'name': 'pairwise',              'oil': 'system.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'singlecore', 'path': 'pairwise',           'name': 'pairwise-fail',              'oil': 'system.json', 'synthesis_disabled': ['posix', 'pi4']},
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
  {'core': 'singlecore', 'path': 'complex',            'name': 'copter-without-alarms', 'oil': 'system-without-alarms.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'singlecore', 'path': 'complex',            'name': 'isorc',                 'oil': 'isorc.json', 'synthesis_disabled': ['posix', 'pi4']},
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
  {'core': 'multicore',  'path': '',                   'name': 'minexample',            'oil': 'minexample.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'interrupts',        'name': 'a',                     'oil': 'a_system.json', 'mtrace': 'a_trace.json', 'timing': 'a_timings.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'interrupts',        'name': 'cross_alarms',          'oil': 'cross_alarms_system.json', 'mtrace': 'cross_alarms_trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'a',                     'oil': 'system.json', 'mtrace': 'a.trace.json', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'a_start1',              'oil': 'EXTRACT', 'mtrace': 'a_start1.trace.json', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'b',                     'oil': 'system.json', 'mtrace': 'b.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'c',                     'oil': 'system.json', 'mtrace': 'c.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '2cores',  'name': 'd',                     'oil': 'system.json', 'mtrace': 'd.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'a',                     'oil': 'a.system.json', 'mtrace': 'a.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'b',                     'oil': 'b.system.json', 'mtrace': 'b.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'c',                     'oil': 'c.system.json', 'mtrace': 'c.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'd',                     'oil': 'd.system.json', 'mtrace': 'd.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'e',                     'oil': 'e.system.json', 'mtrace': 'e.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'f',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'g',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'h',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'i',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'j',                     'oil': 'system.json', 'mtrace': 'j.trace.json', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'k',                     'oil': 'system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'l',                     'oil': 'system.json', 'mtrace': 'l.trace.json', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'm',                     'oil': 'system_m.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '3cores',  'name': 'n',                     'oil': 'system_m.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-a',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'timing': 'BB', 'ttrace': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-a-chain',   'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-a-start5',  'oil': 'EXTRACT',              'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'timing': 'BB', 'ttrace': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-b',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-c',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-d',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'identity-e',         'oil': 'identity-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-a',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-a-start5',    'oil': 'EXTRACT',            'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-b',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-c',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'locks' / '6cores',  'name': 'triple-d',           'oil': 'triple-system.json', 'mtrace': 'EXTRACT', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'loops',              'name': 'a',                     'oil': 'system_a.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'loops',              'name': 'b',                     'oil': 'system_b.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'loops',              'name': 'c',                     'oil': 'system_b.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'timing',             'name': 'a',                     'oil': 'system_a.json', 'timing': 'a_timing.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'timing',             'name': 'b',                     'oil': 'system_b.json', 'timing': 'b_timing.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'timing',             'name': 'c',                     'oil': 'system_c.json', 'timing': 'c_timing.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'running',               'oil': 'system_running.json', 'mtrace': 'running.trace.json', 'locks': 'EXTRACT', 'timing': 'BB', 'ttrace': 'running.timing.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'running_pmu',           'oil': 'system_running.json', 'mtrace': 'running.trace.json', 'locks': 'EXTRACT', 'timing': 'BB', 'ttrace': 'running.timing.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'running_long11',        'oil': 'system_running.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'deadlock',              'oil': 'system_running.json', 'locks': 'EXTRACT', 'timing': 'BB', 'mtrace': 'deadlock.trace.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'minimal',               'oil': 'system_minimal.json', 'locks': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'event',                 'oil': 'system_event.json', 'locks': 'EXTRACT', 'mtrace': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'timing',                'oil': 'system_timing.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'interrupt_as_tasks',    'oil': 'system_interrupt_as_tasks.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'interrupt_as_tasks2',   'oil': 'system_interrupt_as_tasks.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'interrupt_as_tasks3',   'oil': 'system_interrupt_as_tasks.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'timing-semiordered',    'oil': 'system_timing.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'paper',              'name': 'timing-ordered',        'oil': 'system_timing.json', 'locks': 'EXTRACT', 'timing': 'BB', 'mtrace': 'EXTRACT', 'ttrace': 'EXTRACT', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-without-alarms', 'oil': 'copter-without-alarms_system.json', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-with-alarms',    'oil': 'copter-with-alarms_system.json', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-single-alarm',   'oil': 'copter-single-alarm_system.json', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-autostart',      'oil': 'copter-autostart_system.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'complex',            'name': 'copter-autostart_pmu',  'oil': 'copter-autostart_system.json', 'locks': 'EXTRACT', 'timing': 'BB', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi',     'name': 'a',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi',     'name': 'b',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi',     'name': 'c',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi',     'name': 'd',                     'oil': 'system.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi',     'name': 'e',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi',     'name': 'f',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi',     'name': 'g',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi2',    'name': 'a',                     'oil': 'system_a.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi2',    'name': 'b',                     'oil': 'system_b.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi2',    'name': 'c',                     'oil': 'system_c.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi2',    'name': 'd',                     'oil': 'system_d.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi2',    'name': 'e',                     'oil': 'system_e.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi2',    'name': 'f',                     'oil': 'system_f.json', 'synthesis_disabled': ['pi4']},
  {'core': 'multicore',  'path': 'andreas'/ 'ipi2',    'name': 'g',                     'oil': 'system_f.json', 'synthesis_disabled': ['pi4']},
  {'core': 'multicore',  'path': 'andreas'/ 'spinlock','name': 'a',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'spinlock','name': 'b',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'spinlock','name': 'c',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'spinlock','name': 'd',                     'oil': 'system_d.json', 'synthesis_disabled': ['posix', 'pi4']},
  {'core': 'multicore',  'path': 'andreas'/ 'spinlock','name': 'e',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'spinlock','name': 'f',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'cores',   'name': '4',                     'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'cores',   'name': '12',                    'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'cores',   'name': '16',                    'oil': 'system.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'pmu',    'name': 'minimal',                'oil': 'system_spinlock.json', 'synthesis_disabled': ['posix']},
  {'core': 'multicore',  'path': 'andreas'/ 'pmu',    'name': 'ipi_send',               'oil': 'system_ipi_send.json', 'synthesis_disabled': ['posix']},
  {'core': 'multicore',  'path': 'andreas'/ 'pmu',    'name': 'ipi_recv',               'oil': 'system_ipi_recv.json', 'synthesis_disabled': ['posix']},
  {'core': 'multicore',  'path': 'andreas'/ 'pmu',    'name': 'ipi_recv_cache',         'oil': 'system_ipi_recv.json', 'synthesis_disabled': ['posix']},
  {'core': 'multicore',  'path': 'andreas'/ 'pmu',    'name': 'ipi_max',                'oil': 'system_ipi_max.json', 'synthesis_disabled': ['posix']},
  {'core': 'multicore',  'path': 'andreas'/ 'pmu',    'name': 'get_spinlock',           'oil': 'system_spinlock.json', 'synthesis_disabled': ['posix']},
  {'core': 'multicore',  'path': 'andreas'/ 'arved',   'name': 'a',                     'oil': 'system_a.json'},
  {'core': 'multicore',  'path': 'andreas'/ 'arved',   'name': 'b',                     'oil': 'system_b.json'},
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
    oil = files(app['core'] / app['path'] / app['oil'])[0]
  endif
  app += {'oil': oil}

  # compile the application
  if posix_enabled
    app_ll_posix = custom_target(full_name + '_ll_posix',
                          input : sys + '.cc',
                          output : full_name + '.posix.ll',
                          depfile : full_name + '.posix.ll.dep',
                          command : clang_cpp +
                                    posix_autosar_includes +
                                    autosar_includes +
                                    clang_flags +
                                    autosar_posix_clang_flags +
                                    '-O0' + # dont optimize before IR
                                    ir_flags)
  else
    app_ll_posix = disabler()
  endif
  app += {'ll': app_ll_posix} # store in ll to not break dependencies

  if arm_enabled
    app_ll_pi4 = custom_target(full_name + '_ll_pi4',
                          input : sys + '.cc',
                          output : full_name + '.pi4.ll',
                          depfile : full_name + '.pi4.ll.dep',
                          command : clang_cpp +
                                    arm_autosar_includes +
                                    autosar_includes +
                                    clang_flags +
                                    autosar_pi4_clang_flags +
                                    '-O0' + # dont optimize before IR
                                    ir_flags)
  else
    app_ll_pi4 = disabler()
  endif
  app += {'ll_pi4': app_ll_pi4}

  if true
    app_ll_riscv = custom_target(full_name + '_ll_riscv',
                          input : sys + '.cc',
                          output : full_name + '.riscv.ll',
                          depfile : full_name + '.riscv.ll.dep',
                          command : clang_cpp +
                                    riscv_autosar_includes +
                                    autosar_includes +
                                    clang_flags +
                                    autosar_riscv_clang_flags +
                                    '-O0' + # dont optimize before IR
                                    ir_flags)
  else
    app_ll_riscv = disabler()
  endif
    app += {'ll_riscv': app_ll_riscv}

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

autosar_generated_targets_posix = []
autosar_generated_targets_pi4 = []
autosar_generated_targets_riscv = []

foreach app: autosar_targets
  full_name = app['full_name']
  generate_timing_settings = custom_target(
    output: full_name  + '.generate_timing_settings.json',
    capture: true,
    command: ['echo', '{"steps": ["ApplyTimings", "LoadOIL", "DumpCFG"], "ApplyTimings": {"create_timings": "' +  app['full_name'] +'.empty_timing.json"}}'],
  )


  run_target('run_lock_elision_no_timings_' + full_name,
             command: [py3_inst, ara_py, app['ll'], '--os', 'AUTOSAR', '--oilfile', app['oil'], '-s', 'LockElision', '-s', 'IPIAvoidance'])
  run_target('run_lock_elision_generate_timings_' + full_name,
             command: [py3_inst, ara_py, app['ll'], '--os', 'AUTOSAR', '--oilfile', app['oil'], '--step-settings', generate_timing_settings])
  run_target('run_lock_elision_with_timings_' + full_name,
             command: [py3_inst, ara_py, app['ll'], '--os', 'AUTOSAR', '--oilfile', app['oil'], '--step-settings', with_timing_settings, '--timings', app['sys_timings'], '--step-data'])

  step_data = custom_target(full_name + '.multisse.no_timing.stepdata.json',
                            input: [ara_py, app['ll'], app['oil']],
                            output: full_name + '.multisse.no_timing.stepdata.json',
                            depfile: full_name + '.dep',
                            command: [py3_inst, ara_py, app['ll'], '--os', 'AUTOSAR',
                                      '--dependency_file', '@DEPFILE@',
                                      '--oilfile', app['oil'],
                                      '-s', 'LockElision', '-s', 'IPIAvoidance',
                                      '--step-data', '@OUTPUT@'],
                           )

  step_data = custom_target(full_name + '.multisse.with_timing.stepdata.json',
                            input: [ara_py, app['ll'], app['oil']],
                            output: full_name + '.multisse.with_timing.stepdata.json',
                            depfile: full_name + '.dep',
                            command: [py3_inst, ara_py, app['ll'], '--os', 'AUTOSAR',
                                      '--dependency_file', '@DEPFILE@',
                                      '--oilfile', app['oil'],
                                      '--step-settings', with_timing_settings,
                                      '--timings', app['sys_timings'],
                                      '--step-data', '@OUTPUT@'],
                           )


  if posix_enabled and not (app.has_key('synthesis_disabled') and 'posix' in app['synthesis_disabled'])
    if get_option('execute_ara')
      out = custom_target(
        full_name + '_mod_posix',
        input : app['ll'],
        output : [
          full_name + '_mod.posix.ll',
          full_name+'_autosar.posix.cc'
        ],
        depfile : full_name + '_mod.posix.ll.dep',
        command : [
          py3_inst, ara_py, app['ll'],
          '--os', 'AUTOSAR',
          '--oilfile', app['oil'],
          '--ir_output', '@OUTPUT0@',
          '--step-settings', files('../../settings/autosar_generator_posix.json'),
          '--generator_output', '@OUTPUT1@',
        ]
      )
    else
      out = disabler()
    endif
    app_ll_mod = out[0]
    autosar = out[1]
    app += {'ll_posix_mod': app_ll_mod}
    app += {'autosar_posix': autosar}

    app_image_posix = custom_target(full_name + '_image_posix',
                            input: [
                              app_ll_mod,
                              autosar,
                              libautosar_test_posix,
                              libautosar_os_posix,
                              libautosar_arch_posix,
                              libautosar_generic_posix
                            ],
                            output : full_name + '_posix',
                            depfile : full_name + '.posix.dep',
                            command : clang_cpp +
                                      posix_autosar_includes +
                                      autosar_includes +
                                      ld_flags +
                                      autosar_posix_clang_flags +
                                      clang_flags
                                      )

    app += {'app_image_posix': app_image_posix}

    run_cmd = [app_image_posix]
    app += {'run_cmd_posix': run_cmd}
    run_target('run_' + full_name + '_posix', command: run_cmd)

    autosar_generated_targets_posix += app
  endif


  if arm_enabled and not (app.has_key('synthesis_disabled') and 'pi4' in app['synthesis_disabled'])
    if get_option('execute_ara')
      out = custom_target(
        full_name + '_mod_pi4',
        input : app['ll_pi4'],
        output : [
          full_name + '_mod.pi4.ll',
          full_name+'_autosar.pi4.cc',
          full_name+'_autosar.pi4.ld'
        ],
        depfile : full_name + '_mod.pi4.ll.dep',
        command : [
          py3_inst, ara_py, app['ll_pi4'],
          '--os', 'AUTOSAR',
          '--oilfile', app['oil'],
          '--ir_output', '@OUTPUT0@',
          '--step-settings', files('../../settings/autosar_generator_arm.json'),
          '--generator_output', '@OUTPUT1@',
          #'--timings', app['sys_timings']
        ]
      )
    else
      out = disabler()
    endif
    app_ll_mod = out[0]
    autosar = out[1]
    linker_script = out[2]
    app += {'ll_pi4_mod': app_ll_mod}
    app += {'autosar_pi4': autosar}
    app += {'linker_script_pi4': linker_script}

    app_image_pi4 = custom_target(full_name + '_image_pi4',
                            input: [
                              app_ll_mod,
                              autosar,
                              libautosar_test_pi4,
                              libautosar_os_pi4,
                              libautosar_arch_pi4,
                              libautosar_generic_pi4
                            ],
                            output : full_name + '_pi4',
                            depfile : full_name + '.pi4.dep',
                            command : clang_cpp +
                                      ['-T', linker_script] +
                                      arm_autosar_includes +
                                      autosar_includes +
                                      ld_flags +
                                      autosar_pi4_ld_flags +
                                      clang_flags +
                                      autosar_pi4_clang_flags)

    app += {'app_image_pi4': app_image_pi4}
    run_cmd = libplatforms_proj.get_variable('qemu_rpi4_32bit_cmd') + app_image_pi4
    app += {'run_cmd_pi4': run_cmd}
    run_target('run_' + full_name + '_pi4', command: run_cmd)


    pi4_bin = custom_target(full_name + '_pi4_bin',
                        input: [
                          app_image_pi4,
                        ],
                        output : full_name + '_pi4.bin',
                        depfile : full_name + '.pi4.bin.dep',
                        command : [ llvm_objcopy,
                                  '-O', 'binary',
                                  '@INPUT@',
                                  '@OUTPUT@'])

    pi4_bin_pxe = run_target('tftp_' + full_name + '_pi4',
                        depends : [pi4_bin],
                        command : [rpi4_tftp_deploy,
                                  pi4_bin.full_path()])


    autosar_generated_targets_pi4 += app
  endif

  
  if true and not (app.has_key('synthesis_disabled') and 'riscv' in app['synthesis_disabled'])
    if get_option('execute_ara')
      out = custom_target(
        full_name + '_mod_riscv',
        input : app['ll_riscv'],
        output : [
          full_name + '_mod.riscv.ll',
          full_name +'_autosar.riscv.cc',
        ],
        depfile : full_name + '_mod.riscv.ll.dep',
        command : [
          py3_inst, ara_py, '@INPUT@',
          '--os', 'AUTOSAR',
          '--oilfile', app['oil'],
          '--ir_output', '@OUTPUT0@',
          '--step-settings', files('../../settings/autosar_generator_riscv.json'),
          '--generator_output', '@OUTPUT1@',
          #'--timings', app['sys_timings']
        ]
      )
    else
      out = disabler()
    endif
    app_ll_mod = out[0]
    autosar = out[1]
    app += {'ll_riscv_mod': app_ll_mod}
    app += {'autosar_riscv': autosar}

    app_image_riscv = custom_target(full_name + '_image_riscv',
                            input: [
                              app_ll_mod,
                              autosar,
                              libautosar_test_riscv,
                              libautosar_os_riscv,
                              libautosar_arch_riscv,
                              libautosar_generic_riscv
                            ],
                            output : full_name + '_riscv',
                            depfile : full_name + '.riscv.dep',
                            command : clang_cpp +
                                      ['-T', 'libs/autosar/arch/riscv/linker.ld'] +
                                      riscv_autosar_includes +
                                      autosar_includes +
                                      ld_flags +
                                      autosar_riscv_ld_flags +
                                      clang_flags +
                                      autosar_riscv_clang_flags)

    app += {'app_image_riscv': app_image_riscv}

    #run_cmd = libplatforms_proj.get_variable('qemu_riscv_cmd') + app_image_riscv
    run_cmd = [app_image_riscv]
    app += {'run_cmd_riscv': run_cmd}
    run_target('run_' + full_name + '_riscv', command: run_cmd)

    #riscv_bin = custom_target(full_name + '_riscv_bin',
    #                    input: [
    #                      app_image_riscv,
    #                    ],
    #                    output : full_name + '_riscv.bin',
    #                    depfile : full_name + '.riscv.bin.dep',
    #                    command : [ llvm_objcopy,
    #                              '-O', 'binary',
    #                              '@INPUT@',
    #                              '@OUTPUT@'])

    #pi4_bin_pxe = run_target('tftp_' + full_name + '_riscv',
    #                    depends : [riscv_bin],
    #                    command : [riscv_tftp_deploy,
    #                              riscv_bin.full_path()])


    autosar_generated_targets_riscv += app
  endif

endforeach


subdir('multicore/dynamic')
