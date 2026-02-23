# list of applications
baremetal_targets = []
baremetal_apps = [
  {'path': '../Xen/min-baremetal/BareMetal-A', 'name': 'a'},
  {'path': '../Xen/min-baremetal/BareMetal-B', 'name': 'b'},
  {'path': '../Xen/min-zb/BareMetal-B', 'name': 'b'},
  {'path': '../Xen/min-ba/BareMetal-A', 'name': 'a'},
  {'path': '../Xen/hc-baremetal/BareMetal-A', 'name': 'a'},
  {'path': '../Xen/hc-baremetal/BareMetal-B', 'name': 'b'},
  {'path': '../Xen/hc-baremetal2/BareMetal-A', 'name': 'a'},
  {'path': '../Xen/hc-baremetal2/BareMetal-B', 'name': 'b'},
  {'path': '../Xen/hc-z-b1/BareMetal-B', 'name': 'b'},
  {'path': '../Xen/hc-b-a1/BareMetal-A', 'name': 'a'},
  {'path': '../Xen/hc-z-b2/BareMetal-B', 'name': 'b'},
  {'path': '../Xen/hc-b-a2/BareMetal-A', 'name': 'a'},
  {'path': '../Xen/hc-baremetal-notiming/BareMetal-A', 'name': 'a'},
  {'path': '../Xen/hc-baremetal-notiming/BareMetal-B', 'name': 'b'},
  {'path': '../Xen/hardware/BareMetal-A', 'name': 'hardware'},
  {'path': '../Xen/braking/BareMetal-C', 'name': 'c_baremetal'},
]

foreach app : baremetal_apps
    # message('Found app:' + app['name'])

    sys = app['path'] / app['name']
    fullname = sys.underscorify()

    # compile into LLVM IR, flags copied from AUTSOSAR's meson.build
    # call with: ninja subprojects/ara/appl/Xen/bareMetal/BareMetal_A_main.pi4.ll
    app_ll_pi4 = custom_target(fullname + '_ll_pi4',
        input : sys + '.cc',
        output : fullname + '.pi4.ll',
        depfile : fullname + '.pi4.ll.dep',
        command : clang_cpp +
                arm_autosar_includes +
                autosar_includes +
                clang_flags +
                autosar_pi4_clang_flags +
                '-O0' + # dont optimize before IR
                ir_flags)

    app += {'ll_pi4': app_ll_pi4}
    baremetal_targets += [app]
endforeach