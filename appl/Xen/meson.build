# Xen testcases build file

# Testcases
xen_testcases = [
  # {'name': 'hypercall', 'do_timings': true, 'guests': ['Autosar', 'subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_a.pi4.ll',
	# 			'../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercall/a.json', 'Autosar', 'subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_b.pi4.ll', 
  #       '../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercall/b.json']},
  {'name': 'hypercall', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-B/b.json'},
]

# Autosar specific build configs
xen_autosar_apps = [
  {'core': '../Xen',  'path': 'hypercall'/ 'Autosar-A','name': 'a', 'oil': 'a.json', 'timing': 'BB'},
  {'core': '../Xen',  'path': 'hypercall'/ 'Autosar-B','name': 'b', 'oil': 'b.json', 'timing': 'BB'},
]

foreach case: xen_testcases
  conf_data = configuration_data()
  conf_data.set('name', case['name'])
  conf_data.set('do_timings', case['do_timings'])
  conf_data.set('guests', case['guests'])

  name = case['name']
  settings = configure_file(input : files(f'hypersse.json.in'), output : f'hypersse-@name@.json',
              configuration : conf_data)

  run_target('xen-ara-' + case['name'], command: [py3_inst, ara_py, 'ignored', '--os', 'XEN', '--log-level', 'warn',
                '--step-settings', settings]

  # ninja subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_A_a.pi4.ll
  )
endforeach