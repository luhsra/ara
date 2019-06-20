#include <stdint.h>

volatile int always_false = 0;

extern int do_stuff();

extern __attribute__((noreturn)) int start_scheduler();

int main( void ){
// 	if (always_false) {
// 	  __builtin_unreachable();
// 	  always_false = 0xff;
// 	  return 4234324;
// 	} else {
// 	  return always_false;
// 	}

  do_stuff();
  start_scheduler();
}
