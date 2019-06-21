#include <stdint.h>

volatile int always_false = 0;

extern int do_stuff();
extern int init_a();

extern __attribute__((noreturn)) int start_scheduler();
extern __attribute__((noreturn)) int Terminate();
extern int config_option;

int main( void ){
// 	if (always_false) {
// 	  __builtin_unreachable();
// 	  always_false = 0xff;
// 	  return 4234324;
// 	} else {
// 	  return always_false;
// 	}

  do_stuff();
  if (config_option) {
	Terminate();
  } else {
	init_a();
  }
	start_scheduler();

}
