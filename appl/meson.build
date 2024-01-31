# experiment scripts
GenericTimingExperiment = files('experiments' / 'GenericTimingExperiment.py')
ShowGenericTimingExperiment = files('experiments' / 'make_figures.py')
InstanceGraphExperiment = files('experiments' / 'instance_graph_experiment.py')

if arm_enabled
  # TODO make it possible to run the analysis tests without ARM toolchain
  subdir('FreeRTOS')
endif

# AUTOSAR examples
# it is POSIX only currently
if posix_enabled
  subdir('AUTOSAR')
  i4copter = autosar_singlecore_complex_isorc
  run_target('i4copter_instance_exp',
      command: [py3_inst, InstanceGraphExperiment, '--title=ARA_Instance_Graph_Experiment', '-v',
                '--llvm_ir', i4copter['ll'],
                '--oil', i4copter['oil'],
                '--os=AUTOSAR'],
      env: [python_path],
      depends: ara_py
  )

  run_target('i4copter_sse_exp',
      command: [py3_inst, InstanceGraphExperiment, '--title=ARA_SSE_Experiment', '-v',
                '--llvm_ir', i4copter['ll'],
                '--oil', i4copter['oil'],
                '--is_ina=False',
                '--os=AUTOSAR'],
      env: [python_path],
      depends: ara_py
  )
endif
