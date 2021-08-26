#include <output.h>
#include <time_markers.h>

extern __time_marker_t __start_time_markers;
extern __time_marker_t __end_time_markers;

// fix compilation with -fstack-check without extra linking
extern "C" __attribute__((weak)) void __stack_chk_fail(void){};
extern "C" __attribute__((weak)) void __stack_chk_guard(void){};

extern "C" void print_startup_statistics(void) {
  __time_marker_t * start = &__start_time_markers;
  kout.init();
  kout << endl;
  kout << "###" << dec << endl;
  while (start != &__end_time_markers) {
    kout << start->name << ": " << start->time << endl;
    start++;
  }
  kout << "$$$" << endl;
}
