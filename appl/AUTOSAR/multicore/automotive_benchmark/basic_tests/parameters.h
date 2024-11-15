/**
 * Config file for testsuit benchmarks, defines different values for used paramaters that describe the size and the properties of the system.
 * Only one variant is active at the same time.
 * TODO
 */

// Lower border from paper
#ifdef VARIANT_SMALL
const unsigned RUNS = 1000;
const unsigned NUMBER_OF_RUNNABLES = 1000;
const unsigned NUMBER_OF_LABELS = 10000;

#endif

// Upper border from paper
#ifdef VARIANT_LARGE
const unsigned RUNS = 1000;
const unsigned NUMBER_OF_RUNNABLES = 1500;
const unsigned NUMBER_OF_LABELS = 25000;
#endif

// Medium case, but with longer runtime
#ifdef VARIANT_LONG
const unsigned RUNS = 5000;
const unsigned NUMBER_OF_RUNNABLES = 1000;
const unsigned NUMBER_OF_LABELS = 10000;
#endif

