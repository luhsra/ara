# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

libsra_objs += custom_target('libsra-output.o',
                             input: 'output.cc',
                             output: 'output.cc.o',
                             depfile: 'output.cc.dep',
                             command: clang_cpp +
                                      libs_includes +
                                      obj_flags +
                                      clang_flags)
subdir('platforms/stm32f103rb')
