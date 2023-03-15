// SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "output.h"

#if DEBUG

Serial kout;
Serial debug;

#else
Serial kout;
Null_Stream debug;

#endif
