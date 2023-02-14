ir_files = []
no_jsons = []
with_jsons = []
all_jsons = []


synthetic_03C_01L_2U_15T_90A_90S_05E__0039_cc = files('synthetic_03C_01L_2U_15T_90A_90S_05E__0039.cc', 'synthetic_03C_01L_2U_15T_90A_90S_05E__0039.oil.json')

synthetic_03C_01L_2U_15T_90A_90S_05E__0039_ll = custom_target('synthetic_03C_01L_2U_15T_90A_90S_05E__0039_ll',
  input: synthetic_03C_01L_2U_15T_90A_90S_05E__0039_cc[0],
  depfile: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0039.cc.dep',
  output: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0039.cc.ll',
  command: clang_cpp + libs_includes + ir_flags + clang_flags)
ir_files += synthetic_03C_01L_2U_15T_90A_90S_05E__0039_ll

synthetic_03C_01L_2U_15T_90A_90S_05E__0039_no_stepdata = custom_target('synthetic_03C_01L_2U_15T_90A_90S_05E__0039_no_stepdata',
  input: [ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0039_ll],
  output: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0039.multisse.no_timing.stepdata.json',
  command: [py3_inst, ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0039_ll,
  '--oilfile', synthetic_03C_01L_2U_15T_90A_90S_05E__0039_cc[1],
  '--step-settings', no_timing_settings,
  '--timings', 'BB',
  '--os', 'AUTOSAR',
  '--step-data', '@OUTPUT0@'],
)

no_jsons +=synthetic_03C_01L_2U_15T_90A_90S_05E__0039_no_stepdata
all_jsons += synthetic_03C_01L_2U_15T_90A_90S_05E__0039_no_stepdata

synthetic_03C_01L_2U_15T_90A_90S_05E__0039_with_stepdata = custom_target('synthetic_03C_01L_2U_15T_90A_90S_05E__0039_with_stepdata',
  input: [ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0039_ll],
  output: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0039.multisse.with_timing.stepdata.json',
  command: [py3_inst, ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0039_ll,
  '--oilfile', synthetic_03C_01L_2U_15T_90A_90S_05E__0039_cc[1],
  '--step-settings', with_timing_settings,
  '--timings', 'BB',
  '--os', 'AUTOSAR',
  '--step-data', '@OUTPUT0@'],
)

with_jsons +=synthetic_03C_01L_2U_15T_90A_90S_05E__0039_with_stepdata
all_jsons += synthetic_03C_01L_2U_15T_90A_90S_05E__0039_with_stepdata

synthetic_03C_01L_2U_15T_90A_90S_05E__0030_cc = files('synthetic_03C_01L_2U_15T_90A_90S_05E__0030.cc', 'synthetic_03C_01L_2U_15T_90A_90S_05E__0030.oil.json')

synthetic_03C_01L_2U_15T_90A_90S_05E__0030_ll = custom_target('synthetic_03C_01L_2U_15T_90A_90S_05E__0030_ll',
  input: synthetic_03C_01L_2U_15T_90A_90S_05E__0030_cc[0],
  depfile: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0030.cc.dep',
  output: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0030.cc.ll',
  command: clang_cpp + libs_includes + ir_flags + clang_flags)
ir_files += synthetic_03C_01L_2U_15T_90A_90S_05E__0030_ll

synthetic_03C_01L_2U_15T_90A_90S_05E__0030_no_stepdata = custom_target('synthetic_03C_01L_2U_15T_90A_90S_05E__0030_no_stepdata',
  input: [ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0030_ll],
  output: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0030.multisse.no_timing.stepdata.json',
  command: [py3_inst, ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0030_ll,
  '--oilfile', synthetic_03C_01L_2U_15T_90A_90S_05E__0030_cc[1],
  '--step-settings', no_timing_settings,
  '--timings', 'BB',
  '--os', 'AUTOSAR',
  '--step-data', '@OUTPUT0@'],
)

no_jsons +=synthetic_03C_01L_2U_15T_90A_90S_05E__0030_no_stepdata
all_jsons += synthetic_03C_01L_2U_15T_90A_90S_05E__0030_no_stepdata

synthetic_03C_01L_2U_15T_90A_90S_05E__0030_with_stepdata = custom_target('synthetic_03C_01L_2U_15T_90A_90S_05E__0030_with_stepdata',
  input: [ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0030_ll],
  output: 'synthetic_03C_01L_2U_15T_90A_90S_05E__0030.multisse.with_timing.stepdata.json',
  command: [py3_inst, ara_py, synthetic_03C_01L_2U_15T_90A_90S_05E__0030_ll,
  '--oilfile', synthetic_03C_01L_2U_15T_90A_90S_05E__0030_cc[1],
  '--step-settings', with_timing_settings,
  '--timings', 'BB',
  '--os', 'AUTOSAR',
  '--step-data', '@OUTPUT0@'],
)

with_jsons +=synthetic_03C_01L_2U_15T_90A_90S_05E__0030_with_stepdata
all_jsons += synthetic_03C_01L_2U_15T_90A_90S_05E__0030_with_stepdata

synthetic_02C_01L_2U_15T_90A_90S_00E__0017_cc = files('synthetic_02C_01L_2U_15T_90A_90S_00E__0017.cc', 'synthetic_02C_01L_2U_15T_90A_90S_00E__0017.oil.json')

synthetic_02C_01L_2U_15T_90A_90S_00E__0017_ll = custom_target('synthetic_02C_01L_2U_15T_90A_90S_00E__0017_ll',
  input: synthetic_02C_01L_2U_15T_90A_90S_00E__0017_cc[0],
  depfile: 'synthetic_02C_01L_2U_15T_90A_90S_00E__0017.cc.dep',
  output: 'synthetic_02C_01L_2U_15T_90A_90S_00E__0017.cc.ll',
  command: clang_cpp + libs_includes + ir_flags + clang_flags)
ir_files += synthetic_02C_01L_2U_15T_90A_90S_00E__0017_ll

synthetic_02C_01L_2U_15T_90A_90S_00E__0017_no_stepdata = custom_target('synthetic_02C_01L_2U_15T_90A_90S_00E__0017_no_stepdata',
  input: [ara_py, synthetic_02C_01L_2U_15T_90A_90S_00E__0017_ll],
  output: 'synthetic_02C_01L_2U_15T_90A_90S_00E__0017.multisse.no_timing.stepdata.json',
  command: [py3_inst, ara_py, synthetic_02C_01L_2U_15T_90A_90S_00E__0017_ll,
  '--oilfile', synthetic_02C_01L_2U_15T_90A_90S_00E__0017_cc[1],
  '--step-settings', no_timing_settings,
  '--timings', 'BB',
  '--os', 'AUTOSAR',
  '--step-data', '@OUTPUT0@'],
)

no_jsons +=synthetic_02C_01L_2U_15T_90A_90S_00E__0017_no_stepdata
all_jsons += synthetic_02C_01L_2U_15T_90A_90S_00E__0017_no_stepdata

synthetic_02C_01L_2U_15T_90A_90S_00E__0017_with_stepdata = custom_target('synthetic_02C_01L_2U_15T_90A_90S_00E__0017_with_stepdata',
  input: [ara_py, synthetic_02C_01L_2U_15T_90A_90S_00E__0017_ll],
  output: 'synthetic_02C_01L_2U_15T_90A_90S_00E__0017.multisse.with_timing.stepdata.json',
  command: [py3_inst, ara_py, synthetic_02C_01L_2U_15T_90A_90S_00E__0017_ll,
  '--oilfile', synthetic_02C_01L_2U_15T_90A_90S_00E__0017_cc[1],
  '--step-settings', with_timing_settings,
  '--timings', 'BB',
  '--os', 'AUTOSAR',
  '--step-data', '@OUTPUT0@'],
)

with_jsons +=synthetic_02C_01L_2U_15T_90A_90S_00E__0017_with_stepdata
all_jsons += synthetic_02C_01L_2U_15T_90A_90S_00E__0017_with_stepdata





run_target('run_multisse_dynamic_bestof_experiment_all', command: ['ls'], depends: all_jsons)
run_target('run_multisse_dynamic_bestof_experiment_generator', command: ['echo', 'generator finished'], depends: ir_files)
run_target('run_multisse_dynamic_bestof_experiment_no_timing', command: ['ls'], depends: no_jsons)
run_target('run_multisse_dynamic_bestof_experiment_with_timing', command: ['ls'], depends: with_jsons)
