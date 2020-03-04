#pragma once

#define DWT_CYCCNT      ((volatile uint32_t *)0xE0001004)

#ifndef STORE_TIME_MARKER
// extern __time_marker_t ##NAME;
#define STORE_TIME_MARKER(NAME)  __time_ ## NAME .time = *DWT_CYCCNT

typedef struct __time_marker {
  unsigned int time;
  char * name;
} __time_marker_t;

#define TIME_MARKER(NAME) __attribute((section(".data.__time_markers"))) __time_marker_t __time_##NAME = {.name=#NAME};

#endif //STORE_TIME_MARKER
