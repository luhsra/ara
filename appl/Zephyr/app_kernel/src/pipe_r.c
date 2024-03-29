/* pipe_r.c */

/*
 * Copyright (c) 1997-2010, 2013-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "receiver.h"
#include "master.h"

#ifdef PIPE_BENCH


/*
 * Function prototypes.
 */
int pipeget(struct k_pipe *pipe, enum pipe_options option,
			int size, int count, unsigned int *time);

/*
 * Function declarations.
 */

/* pipes transfer speed test */

/**
 *
 * @brief Receive task
 *
 * @return N/A
 */
void piperecvtask(void)
{
	int getsize;
	unsigned int gettime;
	int getcount;
	int pipe;
	int prio;
	struct getinfo getinfo;

	/* matching (ALL_N) */

	for (getsize = 8; getsize <= MESSAGE_SIZE_PIPE; getsize <<= 1) {
#if 1
		for (pipe = 0; pipe < 3; pipe++) {
			getcount = NR_OF_PIPE_RUNS;
			pipeget(test_pipes[pipe], _ALL_N, getsize,
				getcount, &gettime);
			getinfo.time = gettime;
			getinfo.size = getsize;
			getinfo.count = getcount;
			/* acknowledge to master */
			k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);
		}
#else
        getcount = NR_OF_PIPE_RUNS;
        pipeget(&PIPE_NOBUFF, _ALL_N, getsize,
            getcount, &gettime);
        getinfo.time = gettime;
        getinfo.size = getsize;
        getinfo.count = getcount;
        /* acknowledge to master */
        k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);

        getcount = NR_OF_PIPE_RUNS;
        pipeget(&PIPE_SMALLBUFF, _ALL_N, getsize,
            getcount, &gettime);
        getinfo.time = gettime;
        getinfo.size = getsize;
        getinfo.count = getcount;
        /* acknowledge to master */
        k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);

        getcount = NR_OF_PIPE_RUNS;
        pipeget(&PIPE_BIGBUFF, _ALL_N, getsize,
            getcount, &gettime);
        getinfo.time = gettime;
        getinfo.size = getsize;
        getinfo.count = getcount;
        /* acknowledge to master */
        k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);
#endif
	}

	for (prio = 0; prio < 2; prio++) {
		/* non-matching (1_TO_N) */
	for (getsize = (MESSAGE_SIZE_PIPE); getsize >= 8; getsize >>= 1) {
		getcount = MESSAGE_SIZE_PIPE / getsize;
#if USE_ARRAY
		for (pipe = 0; pipe < 3; pipe++) {
			/* size*count == MESSAGE_SIZE_PIPE */
			pipeget(test_pipes[pipe], _1_TO_N,
					getsize, getcount, &gettime);
			getinfo.time = gettime;
			getinfo.size = getsize;
			getinfo.count = getcount;
			/* acknowledge to master */
			k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);
		}
#else
        /* size*count == MESSAGE_SIZE_PIPE */
        pipeget(&PIPE_NOBUFF, _1_TO_N,
                getsize, getcount, &gettime);
        getinfo.time = gettime;
        getinfo.size = getsize;
        getinfo.count = getcount;
        /* acknowledge to master */
        k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);

        /* size*count == MESSAGE_SIZE_PIPE */
        pipeget(&PIPE_SMALLBUFF, _1_TO_N,
                getsize, getcount, &gettime);
        getinfo.time = gettime;
        getinfo.size = getsize;
        getinfo.count = getcount;
        /* acknowledge to master */
        k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);

        /* size*count == MESSAGE_SIZE_PIPE */
        pipeget(&PIPE_BIGBUFF, _1_TO_N,
                getsize, getcount, &gettime);
        getinfo.time = gettime;
        getinfo.size = getsize;
        getinfo.count = getcount;
        /* acknowledge to master */
        k_msgq_put(&CH_COMM, &getinfo, K_FOREVER);
#endif
	}
	}

}


/**
 *
 * @brief Read a data portion from the pipe and measure time
 *
 * @return 0 on success, 1 on error
 *
 * @param pipe     Pipe to read data from.
 * @param option   _ALL_TO_N or _1_TO_N.
 * @param size     Data chunk size.
 * @param count    Number of data chunks.
 * @param time     Total write time.
 */
int pipeget(struct k_pipe *pipe, enum pipe_options option, int size, int count,
			unsigned int *time)
{
	int i;
	unsigned int t;
	size_t sizexferd_total = 0;
	size_t size2xfer_total = size * count;

	/* sync with the sender */
	k_sem_take(&SEM0, K_FOREVER);
	t = BENCH_START();
	for (i = 0; option == _1_TO_N || (i < count); i++) {
		size_t sizexferd = 0;
		size_t size2xfer = MIN(size, size2xfer_total - sizexferd_total);
		int ret;

		ret = k_pipe_get(pipe, data_recv, size2xfer,
				 &sizexferd, option, K_FOREVER);

		if (ret != 0) {
			return 1;
		}

		if (option == _ALL_N  && sizexferd != size2xfer) {
			return 1;
		}

		sizexferd_total += sizexferd;
		if (size2xfer_total == sizexferd_total) {
			break;
		}

		if (size2xfer_total < sizexferd_total) {
			return 1;
		}
	}

	t = TIME_STAMP_DELTA_GET(t);
	*time = SYS_CLOCK_HW_CYCLES_TO_NS_AVG(t, count);
	if (bench_test_end() < 0) {
		if (high_timer_overflow()) {
			PRINT_STRING("| Timer overflow. "
			"Results are invalid            ",
						 output_file);
		} else {
			PRINT_STRING("| Tick occurred. "
			"Results may be inaccurate       ",
						 output_file);
		}
		PRINT_STRING("                             |\n",
					 output_file);
	}
	return 0;
}

#endif /* PIPE_BENCH */
