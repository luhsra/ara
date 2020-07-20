libsra_objs += custom_target('libsra-serial.o',
                             input: 'serial.cc',
                             output: 'serial.cc.o',
                             depfile: 'serial.cc.dep',
                             command: clang_cpp +
                                      libs_includes +
                                      obj_flags +
                                      ['-O0'] +
                                      clang_flags)
libsra_objs += custom_target('libsra-debug.o',
                             input: 'debug.cc',
                             output: 'debuf.cc.o',
                             depfile: 'debug.cc.dep',
                             command: clang_cpp +
                                      libs_includes +
                                      obj_flags +
                                      ['-O0'] +
                                      clang_flags)
