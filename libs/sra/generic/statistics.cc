#include <output.h>
#include <time_markers.h>

extern __time_marker_t __start_time_markers;
extern __time_marker_t __end_time_markers;

extern "C" void vPortExitCritical();
extern "C" void vPortEnterCritical();

extern "C" void print_startup_statistics(void) {
  __time_marker_t * start = &__start_time_markers;
  vPortEnterCritical();
  kout.init();
  kout << endl;
  kout << "###" << dec << endl;
  while (start != &__end_time_markers) {
    kout << start->name << ": " << start->time << endl;
    start++;
  }
  kout << "$$$" << endl;
  vPortExitCritical();
}
