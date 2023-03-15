// SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <output.h>

void vPrintString(const char *string) {
  kout << string << endl;
}
void vPrintStringAndNumber(const char *string, int number) {
  kout << string << ' ' << number << endl;
}
