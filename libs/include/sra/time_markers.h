#pragma once
#ifdef __cplusplus
extern "C" {
#endif


#define DWT_CYCCNT      ((volatile uint32_t *)0xE0001004)

#ifndef STORE_TIME_MARKER
// extern __time_marker_t ##NAME;
#define _STRINGIFY_(x) #x
#define STRINGIFY(x) _STRINGIFY_(x)
#define _CONCAT_(a, b) a ## b
#define CONCAT(a, b) _CONCAT_(a,b)
#define TIME_SECTION __attribute((section(".data.__time_markers")))
#define STORE_INLINE_TIME_MARKER(NAME) TIME_SECTION static __time_marker_t CONCAT(__time_ , CONCAT(NAME ## _ , __LINE__)) = {.name = #NAME "$" STRINGIFY(__LINE__)}; CONCAT(__time_ , CONCAT(NAME ## _ , __LINE__)) .time = *DWT_CYCCNT;
#define STORE_TIME_MARKER(NAME)  __time_ ## NAME .time = *DWT_CYCCNT

typedef struct __time_marker {
  unsigned int time;
  char * name;
} __time_marker_t;

#define TIME_MARKER(NAME) TIME_SECTION __time_marker_t __time_##NAME = {.name=#NAME};

#endif //STORE_TIME_MARKER

void print_startup_statistics();

#ifdef __cplusplus
}
#endif
