#include <output.h>

void vPrintString(const char *string) {
  kout << string << endl;
}
void vPrintStringAndNumber(const char *string, int number) {
  kout << string << ' ' << number << endl;
}
