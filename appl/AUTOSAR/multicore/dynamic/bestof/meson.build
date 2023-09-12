ir_files = []
no_jsons = []
with_jsons = []
all_jsons = []

complex_systems = [
  {'system': 'synthetic_02C_01L_2U_15T_90A_90S_00E__0017', 'with_timing': 'yes'},
  {'system': 'synthetic_02C_01L_2U_15T_90A_90S_05E__0006', 'with_timing': 'both'},
  {'system': 'synthetic_03C_01L_2U_15T_90A_90S_05E__0030', 'with_timing': 'no'},
  {'system': 'synthetic_03C_01L_2U_15T_90A_90S_05E__0039', 'with_timing': 'no'},
  {'system': 'synthetic_03C_02L_2U_15T_90A_90S_00E__0057', 'with_timing': 'no'},
]

foreach system_desc: complex_systems
  system = system_desc['system']
  timings = system_desc['with_timing']

  system_ll = custom_target(system + '_ll',
    input: system + '.cc',
    depfile: system + '.cc.dep',
    output: system + '.cc.ll',
    command: clang_cpp + autosar_includes + ir_flags + clang_flags
  )
  ir_files += system_ll

  if timings == 'both'
    t = [true, false]
  elif timings == 'yes'
    t = [true]
  elif timings == 'no'
    t = [false]
  endif

  foreach time: t
    if time
      t_desc = {'key': 'with_timing',
                'settings': with_timing_settings}
    else
      t_desc = {'key': 'no_timing',
                'settings': no_timing_settings}
    endif

    ara_run = custom_target(system + '_' + t_desc['key'] + '_ara',
      input: [ara_py, system_ll],
      output: system + '.multisse.' + t_desc['key'] + '.stepdata.json',
      command: [ctimeout, py3_inst, ara_py, system_ll,
      '--oilfile', files(system + '.oil.json'),
      '--step-settings', t_desc['settings'],
      '--timings', 'BB',
      '--os', 'AUTOSAR',
      '--step-data', '@OUTPUT0@'],
    )
    if time
      with_jsons += ara_run
    else
      no_jsons += ara_run
    endif
    all_jsons += ara_run
  endforeach
endforeach

run_target('run_multisse_dynamic_bestof_experiment_all', command: ['ls'], depends: all_jsons)
run_target('run_multisse_dynamic_bestof_experiment_generator', command: ['echo', 'generator finished'], depends: ir_files)
run_target('run_multisse_dynamic_bestof_experiment_no_timing', command: ['ls'], depends: no_jsons)
run_target('run_multisse_dynamic_bestof_experiment_with_timing', command: ['ls'], depends: with_jsons)

