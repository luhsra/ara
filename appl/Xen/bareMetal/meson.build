# list of applications
baremetal_targets = []
baremetal_apps = [
  {'path': 'BareMetal-A', 'name': 'main'},
  {'path': 'BareMetal-A', 'name': 'other'},
#   {'path': 'BareMetal-A', 'name': 'main.c', 'timing': 'BB'},
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
                clang_flags +
                autosar_pi4_clang_flags +
                '-O0' + # dont optimize before IR
                ir_flags)

    app += {'ll_pi4': app_ll_pi4}
    baremetal_targets += [app]
endforeach