# Xen testcases build file
# To add a testcase create a folder in ara/appl/Xen, then create a subfolder for each guest system.
# The folder name must match the 'name', guests are listed by their OS and afterwards OS specific config
#   Autosar: needs .ll and .json, for .ll add to ../AUTOSAR/meson.build

# Testcases
xen_testcases = [
  {'name': 'hypercall', 'do_timings': 'true', 'guests':
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-B/b.json'},
  {'name': 'hypercallv6', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-B/b.json'},
]

# Compile ll files
ll_targets = []
foreach app: autosar_targets
  if app['core'].contains('Xen')
    ll_targets += app['ll_pi4']
  endif
endforeach
custom_target('xen-ara-prepll', 
            command: ['echo', 'done'],
            output: 'xen-ara-prepll',
            depends: ll_targets)

# Create ninja target, run with: ninja subprojects/ara/appl/Xen/HyperSSE.hypercallv2.hstg.dot
foreach case: xen_testcases
  conf_data = configuration_data()
  conf_data.set('name', case['name'])
  conf_data.set('do_timings', case['do_timings'])
  conf_data.set('guests', case['guests'])

  name = case['name']
  settings = configure_file(input : files(f'hypersse.json.in'), output : f'hypersse-@name@.json',
              configuration : conf_data)

  custom_target('xen-ara-' + case['name'], 
            command: [py3_inst, ara_py, 'ignored', '--os', 'XEN', '--log-level', 'warn',
                '--step-settings', settings],
            output: name,
            depends : ll_targets

  )
endforeach