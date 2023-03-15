# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

src_files = [
  'statistics',
  'print_functions',
]
foreach src: src_files
  libsra_objs += custom_target(src,
                               input: src+'.cc',
                               output: src+'.cc.o',
                               depfile: src+'.cc.dep',
                               command: clang_cpp+
                                        libs_includes +
                                        obj_flags +
                                        clang_flags)
endforeach
