extern "C" int __attribute__((weak)) arch_timing_get() {
    static int time;
    return ++time;
}
