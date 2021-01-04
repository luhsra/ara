; ModuleID = './appl/Zephyr/app_kernel.ll'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-unknown-eabi"

%struct.k_mbox_msg = type { i32, i32, i32, i8*, i8*, %struct.k_mem_block, %struct.k_thread.30*, %struct.k_thread.30*, %struct.k_thread.30*, %struct.k_sem* }
%struct.k_mem_block = type { %union.anon.3 }
%union.anon.3 = type { %struct.k_mem_block_id }
%struct.k_mem_block_id = type { i8*, %struct.k_heap.31* }
%struct.k_heap.31 = type { %struct.sys_heap.32, %struct._wait_q_t, %struct.k_spinlock }
%struct.sys_heap.32 = type { %struct.z_heap.33*, i8*, i32 }
%struct.z_heap.33 = type opaque
%struct._wait_q_t = type { %struct._dnode }
%struct._dnode = type { %union.anon.0, %union.anon.0 }
%union.anon.0 = type { %struct._dnode* }
%struct.k_spinlock = type { i32 }
%struct.k_thread.30 = type { %struct._thread_base.34, %struct._callee_saved.35, i8*, void ()*, [32 x i8], i32, %struct.getinfo, %struct.k_mem_pool.37*, %struct._thread_arch.38 }
%struct._thread_base.34 = type { %struct._wait_q_t, %struct._wait_q_t*, i8, i8, %union.anon.2.40, i32, i8*, %struct._timeout.41, %struct._wait_q_t }
%union.anon.2.40 = type { i16 }
%struct._timeout.41 = type { %struct._dnode, void (%struct._timeout.41*)*, i64 }
%struct._callee_saved.35 = type { i32, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.getinfo = type { i32, i32, i32 }
%struct.k_mem_pool.37 = type { %struct.k_heap.31* }
%struct._thread_arch.38 = type { i32, i32 }
%struct.k_sem = type { %struct._wait_q_t, i32, i32 }
%struct.k_pipe = type { i8*, i32, i32, i32, i32, %struct.k_spinlock, %struct.anon.3, i8 }
%struct.anon.3 = type { %struct._wait_q_t, %struct._wait_q_t }
%struct.k_thread.82 = type { %struct._thread_base.83, %struct._callee_saved.35, i8*, void ()*, [32 x i8], i32, %struct.getinfo, %struct.k_mem_pool.86*, %struct._thread_arch.38 }
%struct._thread_base.83 = type { %struct._wait_q_t, %struct._wait_q_t*, i8, i8, %union.anon.2.40, i32, i8*, %struct._timeout.90, %struct._wait_q_t }
%struct._timeout.90 = type { %struct._dnode, void (%struct._timeout.90*)*, i64 }
%struct.k_mem_pool.86 = type { %struct.k_heap.91* }
%struct.k_heap.91 = type { %struct.sys_heap.92, %struct._wait_q_t, %struct.k_spinlock }
%struct.sys_heap.92 = type { %struct.z_heap.93*, i8*, i32 }
%struct.z_heap.93 = type opaque
%struct.z_thread_stack_element = type { i8 }
%struct._static_thread_data = type { %struct.k_thread.82*, %struct.z_thread_stack_element*, i32, void (i8*, i8*, i8*)*, i8*, i8*, i8*, i32, i32, i32, void ()*, i8* }
%struct.k_msgq = type { %struct._wait_q_t, %struct.k_spinlock, i32, i32, i8*, i8*, i8*, i8*, i32, i8 }
%struct.k_mem_slab = type { %struct._wait_q_t, i32, i32, i8*, i8*, i32 }
%struct.k_mbox = type { %struct._wait_q_t, %struct._wait_q_t, %struct.k_spinlock }
%struct.k_mutex = type { %struct._wait_q_t, %struct.k_thread.82*, i32, i32 }
%struct.k_timeout_t = type { i64 }
%struct.k_mem_block.152 = type { %union.anon.3.153 }
%union.anon.3.153 = type { %struct.k_mem_block_id.154 }
%struct.k_mem_block_id.154 = type { i8*, %struct.k_heap.91* }
%struct.k_thread.188 = type { %struct._thread_base.189, %struct._callee_saved.35, i8*, void ()*, [32 x i8], i32, %struct.getinfo, %struct.k_mem_pool.192*, %struct._thread_arch.38 }
%struct._thread_base.189 = type { %struct._wait_q_t, %struct._wait_q_t*, i8, i8, %union.anon.2.40, i32, i8*, %struct._timeout.196, %struct._wait_q_t }
%struct._timeout.196 = type { %struct._dnode, void (%struct._timeout.196*)*, i64 }
%struct.k_mem_pool.192 = type { %struct.k_heap.197* }
%struct.k_heap.197 = type { %struct.sys_heap.198, %struct._wait_q_t, %struct.k_spinlock }
%struct.sys_heap.198 = type { %struct.z_heap.199*, i8*, i32 }
%struct.z_heap.199 = type opaque

@.str = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.1 = private unnamed_addr constant [15 x i8] c"| %-65s|%10u|\0A\00", align 1
@.str.2 = private unnamed_addr constant [27 x i8] c"enqueue 1 byte msg in FIFO\00", align 1
@.str.3 = private unnamed_addr constant [27 x i8] c"dequeue 1 byte msg in FIFO\00", align 1
@.str.4 = private unnamed_addr constant [28 x i8] c"enqueue 4 bytes msg in FIFO\00", align 1
@.str.5 = private unnamed_addr constant [28 x i8] c"dequeue 4 bytes msg in FIFO\00", align 1
@.str.6 = private unnamed_addr constant [61 x i8] c"enqueue 1 byte msg in FIFO to a waiting higher priority task\00", align 1
@.str.7 = private unnamed_addr constant [58 x i8] c"enqueue 4 bytes in FIFO to a waiting higher priority task\00", align 1
@.str.8 = private unnamed_addr constant [77 x i8] c"/home/kenny/ara/appl/Zephyr/app_kernel/src/master.h:%d Error: tick occurred\0A\00", align 1
@timestamp_check = internal global i64 0, align 8, !dbg !0
@.str.9 = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.1.10 = private unnamed_addr constant [81 x i8] c"|                M A I L B O X   M E A S U R E M E N T S                      |\0A\00", align 1
@.str.2.11 = private unnamed_addr constant [81 x i8] c"| Send mailbox message to waiting high priority task and wait                 |\0A\00", align 1
@.str.3.12 = private unnamed_addr constant [80 x i8] c"| repeat for %4d times and take the average                                  |\0A\00", align 1
@.str.4.13 = private unnamed_addr constant [81 x i8] c"|   size(B) |       time/packet (nsec)       |          KB/sec                |\0A\00", align 1
@.str.5.16 = private unnamed_addr constant [18 x i8] c"|%11u|%32u|%32u|\0A\00", align 1
@.str.6.17 = private unnamed_addr constant [75 x i8] c"| message overhead:  %10u     nsec/packet                               |\0A\00", align 1
@.str.7.18 = private unnamed_addr constant [75 x i8] c"| raw transfer rate:     %10u KB/sec (without overhead)                 |\0A\00", align 1
@message = internal global %struct.k_mbox_msg zeroinitializer, align 4, !dbg !64
@.str.8.24 = private unnamed_addr constant [77 x i8] c"/home/kenny/ara/appl/Zephyr/app_kernel/src/master.h:%d Error: tick occurred\0A\00", align 1
@timestamp_check.25 = internal global i64 0, align 8, !dbg !72
@.str.41 = private unnamed_addr constant [80 x i8] c"/home/kenny/ara/appl/Zephyr/app_kernel/src/mailbox_r.c:%d Error: tick occurred\0A\00", align 1
@timestamp_check.42 = internal global i64 0, align 8, !dbg !239
@PIPE_NOBUFF = dso_local global %struct.k_pipe { i8* getelementptr inbounds ([0 x i8], [0 x i8]* @_k_pipe_buf_PIPE_NOBUFF, i32 0, i32 0), i32 0, i32 0, i32 0, i32 0, %struct.k_spinlock zeroinitializer, %struct.anon.3 { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_NOBUFF to i8*), i64 24) to %struct._dnode*) }, %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_NOBUFF to i8*), i64 24) to %struct._dnode*) } } }, %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_NOBUFF to i8*), i64 32) to %struct._dnode*) }, %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_NOBUFF to i8*), i64 32) to %struct._dnode*) } } } }, i8 0 }, section "._k_pipe.static.PIPE_NOBUFF", align 4, !dbg !244
@_k_pipe_buf_PIPE_NOBUFF = internal global [0 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.20", align 4, !dbg !536
@PIPE_SMALLBUFF = dso_local global %struct.k_pipe { i8* getelementptr inbounds ([256 x i8], [256 x i8]* @_k_pipe_buf_PIPE_SMALLBUFF, i32 0, i32 0), i32 256, i32 0, i32 0, i32 0, %struct.k_spinlock zeroinitializer, %struct.anon.3 { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_SMALLBUFF to i8*), i64 24) to %struct._dnode*) }, %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_SMALLBUFF to i8*), i64 24) to %struct._dnode*) } } }, %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_SMALLBUFF to i8*), i64 32) to %struct._dnode*) }, %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_SMALLBUFF to i8*), i64 32) to %struct._dnode*) } } } }, i8 0 }, section "._k_pipe.static.PIPE_SMALLBUFF", align 4, !dbg !483
@_k_pipe_buf_PIPE_SMALLBUFF = internal global [256 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.21", align 4, !dbg !541
@PIPE_BIGBUFF = dso_local global %struct.k_pipe { i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @_k_pipe_buf_PIPE_BIGBUFF, i32 0, i32 0), i32 4096, i32 0, i32 0, i32 0, %struct.k_spinlock zeroinitializer, %struct.anon.3 { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_BIGBUFF to i8*), i64 24) to %struct._dnode*) }, %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_BIGBUFF to i8*), i64 24) to %struct._dnode*) } } }, %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_BIGBUFF to i8*), i64 32) to %struct._dnode*) }, %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_pipe* @PIPE_BIGBUFF to i8*), i64 32) to %struct._dnode*) } } } }, i8 0 }, section "._k_pipe.static.PIPE_BIGBUFF", align 4, !dbg !485
@_k_pipe_buf_PIPE_BIGBUFF = internal global [4096 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.22", align 4, !dbg !544
@test_pipes = dso_local global [3 x %struct.k_pipe*] [%struct.k_pipe* @PIPE_NOBUFF, %struct.k_pipe* @PIPE_SMALLBUFF, %struct.k_pipe* @PIPE_BIGBUFF], align 4, !dbg !253
@newline = dso_local constant [2 x i8] c"\0A\00", align 1, !dbg !296
@_k_thread_obj_RECVTASK = dso_local global %struct.k_thread.82 zeroinitializer, align 8, !dbg !515
@_k_thread_stack_RECVTASK = dso_local global [1024 x %struct.z_thread_stack_element] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.2", align 8, !dbg !510
@_k_thread_data_RECVTASK = dso_local global %struct._static_thread_data { %struct.k_thread.82* @_k_thread_obj_RECVTASK, %struct.z_thread_stack_element* getelementptr inbounds ([1024 x %struct.z_thread_stack_element], [1024 x %struct.z_thread_stack_element]* @_k_thread_stack_RECVTASK, i32 0, i32 0), i32 1024, void (i8*, i8*, i8*)* @recvtask, i8* null, i8* null, i8* null, i32 5, i32 0, i32 0, void ()* null, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.53, i32 0, i32 0) }, section ".__static_thread_data.static._k_thread_data_RECVTASK", align 4, !dbg !300
@.str.53 = private unnamed_addr constant [9 x i8] c"RECVTASK\00", align 1
@RECVTASK = dso_local constant %struct.k_thread.82* @_k_thread_obj_RECVTASK, align 4, !dbg !416
@DEMOQX1 = dso_local global %struct.k_msgq { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @DEMOQX1, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @DEMOQX1, i32 0, i32 0, i32 0) } } }, %struct.k_spinlock zeroinitializer, i32 1, i32 500, i8* getelementptr inbounds ([500 x i8], [500 x i8]* @_k_fifo_buf_DEMOQX1, i32 0, i32 0), i8* getelementptr (i8, i8* getelementptr inbounds ([500 x i8], [500 x i8]* @_k_fifo_buf_DEMOQX1, i32 0, i32 0), i64 500), i8* getelementptr inbounds ([500 x i8], [500 x i8]* @_k_fifo_buf_DEMOQX1, i32 0, i32 0), i8* getelementptr inbounds ([500 x i8], [500 x i8]* @_k_fifo_buf_DEMOQX1, i32 0, i32 0), i32 0, i8 0 }, section "._k_msgq.static.DEMOQX1", align 4, !dbg !420
@_k_fifo_buf_DEMOQX1 = internal global [500 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.3", align 4, !dbg !517
@DEMOQX4 = dso_local global %struct.k_msgq { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @DEMOQX4, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @DEMOQX4, i32 0, i32 0, i32 0) } } }, %struct.k_spinlock zeroinitializer, i32 4, i32 500, i8* getelementptr inbounds ([2000 x i8], [2000 x i8]* @_k_fifo_buf_DEMOQX4, i32 0, i32 0), i8* getelementptr (i8, i8* getelementptr inbounds ([2000 x i8], [2000 x i8]* @_k_fifo_buf_DEMOQX4, i32 0, i32 0), i64 2000), i8* getelementptr inbounds ([2000 x i8], [2000 x i8]* @_k_fifo_buf_DEMOQX4, i32 0, i32 0), i8* getelementptr inbounds ([2000 x i8], [2000 x i8]* @_k_fifo_buf_DEMOQX4, i32 0, i32 0), i32 0, i8 0 }, section "._k_msgq.static.DEMOQX4", align 4, !dbg !435
@_k_fifo_buf_DEMOQX4 = internal global [2000 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.4", align 4, !dbg !522
@MB_COMM = dso_local global %struct.k_msgq { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @MB_COMM, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @MB_COMM, i32 0, i32 0, i32 0) } } }, %struct.k_spinlock zeroinitializer, i32 12, i32 1, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_MB_COMM, i32 0, i32 0), i8* getelementptr (i8, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_MB_COMM, i32 0, i32 0), i64 12), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_MB_COMM, i32 0, i32 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_MB_COMM, i32 0, i32 0), i32 0, i8 0 }, section "._k_msgq.static.MB_COMM", align 4, !dbg !437
@_k_fifo_buf_MB_COMM = internal global [12 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.5", align 4, !dbg !527
@CH_COMM = dso_local global %struct.k_msgq { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @CH_COMM, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_msgq, %struct.k_msgq* @CH_COMM, i32 0, i32 0, i32 0) } } }, %struct.k_spinlock zeroinitializer, i32 12, i32 1, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_CH_COMM, i32 0, i32 0), i8* getelementptr (i8, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_CH_COMM, i32 0, i32 0), i64 12), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_CH_COMM, i32 0, i32 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @_k_fifo_buf_CH_COMM, i32 0, i32 0), i32 0, i8 0 }, section "._k_msgq.static.CH_COMM", align 4, !dbg !439
@_k_fifo_buf_CH_COMM = internal global [12 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.6", align 4, !dbg !532
@MAP1 = dso_local global %struct.k_mem_slab { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mem_slab, %struct.k_mem_slab* @MAP1, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mem_slab, %struct.k_mem_slab* @MAP1, i32 0, i32 0, i32 0) } } }, i32 2, i32 16, i8* getelementptr inbounds ([32 x i8], [32 x i8]* @_k_mem_slab_buf_MAP1, i32 0, i32 0), i8* null, i32 0 }, section "._k_mem_slab.static.MAP1", align 4, !dbg !441
@_k_mem_slab_buf_MAP1 = dso_local global [32 x i8] zeroinitializer, section ".noinit.\22/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c\22.7", align 4, !dbg !534
@SEM0 = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM0, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM0, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.SEM0", align 4, !dbg !451
@SEM1 = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM1, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM1, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.SEM1", align 4, !dbg !458
@SEM2 = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM2, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM2, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.SEM2", align 4, !dbg !460
@SEM3 = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM3, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM3, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.SEM3", align 4, !dbg !462
@SEM4 = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM4, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @SEM4, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.SEM4", align 4, !dbg !464
@STARTRCV = dso_local global %struct.k_sem { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @STARTRCV, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_sem, %struct.k_sem* @STARTRCV, i32 0, i32 0, i32 0) } } }, i32 0, i32 1 }, section "._k_sem.static.STARTRCV", align 4, !dbg !466
@MAILB1 = dso_local global %struct.k_mbox { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mbox, %struct.k_mbox* @MAILB1, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mbox, %struct.k_mbox* @MAILB1, i32 0, i32 0, i32 0) } } }, %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_mbox* @MAILB1 to i8*), i64 8) to %struct._dnode*) }, %union.anon.0 { %struct._dnode* bitcast (i8* getelementptr (i8, i8* bitcast (%struct.k_mbox* @MAILB1 to i8*), i64 8) to %struct._dnode*) } } }, %struct.k_spinlock zeroinitializer }, section "._k_mbox.static.MAILB1", align 4, !dbg !468
@DEMO_MUTEX = dso_local global %struct.k_mutex { %struct._wait_q_t { %struct._dnode { %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mutex, %struct.k_mutex* @DEMO_MUTEX, i32 0, i32 0, i32 0) }, %union.anon.0 { %struct._dnode* getelementptr inbounds (%struct.k_mutex, %struct.k_mutex* @DEMO_MUTEX, i32 0, i32 0, i32 0) } } }, %struct.k_thread.82* null, i32 0, i32 15 }, section "._k_mutex.static.DEMO_MUTEX", align 4, !dbg !475
@kheap_poolheap_DEMOPOOL = dso_local global [84 x i8] zeroinitializer, align 4, !dbg !547
@poolheap_DEMOPOOL = dso_local global %struct.k_heap.91 { %struct.sys_heap.92 { %struct.z_heap.93* null, i8* getelementptr inbounds ([84 x i8], [84 x i8]* @kheap_poolheap_DEMOPOOL, i32 0, i32 0), i32 84 }, %struct._wait_q_t zeroinitializer, %struct.k_spinlock zeroinitializer }, section "._k_heap.static.poolheap_DEMOPOOL", align 4, !dbg !487
@DEMOPOOL = dso_local global %struct.k_mem_pool.86 { %struct.k_heap.91* @poolheap_DEMOPOOL }, align 4, !dbg !489
@output_file = dso_local global i32* null, align 4, !dbg !506
@msg = dso_local global [256 x i8] zeroinitializer, align 1, !dbg !491
@data_bench = dso_local global [4096 x i8] zeroinitializer, align 1, !dbg !496
@sline = dso_local global [257 x i8] zeroinitializer, align 1, !dbg !501
@tm_off = dso_local global i32 0, align 4, !dbg !508
@llvm.used = appending global [18 x i8*] [i8* bitcast (%struct._static_thread_data* @_k_thread_data_RECVTASK to i8*), i8* bitcast (%struct.k_msgq* @DEMOQX1 to i8*), i8* bitcast (%struct.k_msgq* @DEMOQX4 to i8*), i8* bitcast (%struct.k_msgq* @MB_COMM to i8*), i8* bitcast (%struct.k_msgq* @CH_COMM to i8*), i8* bitcast (%struct.k_mem_slab* @MAP1 to i8*), i8* bitcast (%struct.k_sem* @SEM0 to i8*), i8* bitcast (%struct.k_sem* @SEM1 to i8*), i8* bitcast (%struct.k_sem* @SEM2 to i8*), i8* bitcast (%struct.k_sem* @SEM3 to i8*), i8* bitcast (%struct.k_sem* @SEM4 to i8*), i8* bitcast (%struct.k_sem* @STARTRCV to i8*), i8* bitcast (%struct.k_mbox* @MAILB1 to i8*), i8* bitcast (%struct.k_mutex* @DEMO_MUTEX to i8*), i8* bitcast (%struct.k_pipe* @PIPE_NOBUFF to i8*), i8* bitcast (%struct.k_pipe* @PIPE_SMALLBUFF to i8*), i8* bitcast (%struct.k_pipe* @PIPE_BIGBUFF to i8*), i8* bitcast (%struct.k_heap.91* @poolheap_DEMOPOOL to i8*)], section "llvm.metadata"
@.str.1.74 = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.2.75 = private unnamed_addr constant [81 x i8] c"|          S I M P L E   S E R V I C E    M E A S U R E M E N T S  |  nsec    |\0A\00", align 1
@.str.3.76 = private unnamed_addr constant [81 x i8] c"|         END OF TESTS                                                        |\0A\00", align 1
@.str.4.77 = private unnamed_addr constant [30 x i8] c"PROJECT EXECUTION SUCCESSFUL\0A\00", align 1
@.str.82 = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.1.84 = private unnamed_addr constant [15 x i8] c"| %-65s|%10u|\0A\00", align 1
@.str.2.85 = private unnamed_addr constant [31 x i8] c"Error: Slab allocation failed.\00", align 1
@.str.3.89 = private unnamed_addr constant [38 x i8] c"average alloc and dealloc memory page\00", align 1
@.str.4.92 = private unnamed_addr constant [77 x i8] c"/home/kenny/ara/appl/Zephyr/app_kernel/src/master.h:%d Error: tick occurred\0A\00", align 1
@timestamp_check.93 = internal global i64 0, align 8, !dbg !552
@.str.105 = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.1.110 = private unnamed_addr constant [15 x i8] c"| %-65s|%10u|\0A\00", align 1
@.str.2.111 = private unnamed_addr constant [44 x i8] c"average alloc and dealloc memory pool block\00", align 1
@.str.3.114 = private unnamed_addr constant [77 x i8] c"/home/kenny/ara/appl/Zephyr/app_kernel/src/master.h:%d Error: tick occurred\0A\00", align 1
@timestamp_check.115 = internal global i64 0, align 8, !dbg !557
@.str.127 = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.1.132 = private unnamed_addr constant [15 x i8] c"| %-65s|%10u|\0A\00", align 1
@.str.2.133 = private unnamed_addr constant [30 x i8] c"average lock and unlock mutex\00", align 1
@.str.3.136 = private unnamed_addr constant [77 x i8] c"/home/kenny/ara/appl/Zephyr/app_kernel/src/master.h:%d Error: tick occurred\0A\00", align 1
@timestamp_check.137 = internal global i64 0, align 8, !dbg !562
@.str.151 = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.1.152 = private unnamed_addr constant [81 x i8] c"|                   P I P E   M E A S U R E M E N T S                         |\0A\00", align 1
@.str.2.153 = private unnamed_addr constant [81 x i8] c"| Send data into a pipe towards a receiving high priority task and wait       |\0A\00", align 1
@.str.3.154 = private unnamed_addr constant [81 x i8] c"|                          matching sizes (_ALL_N)                            |\0A\00", align 1
@.str.4.155 = private unnamed_addr constant [81 x i8] c"|   size(B) |       time/packet (nsec)       |          KB/sec                |\0A\00", align 1
@.str.5.156 = private unnamed_addr constant [81 x i8] c"| put | get |  no buf  | small buf| big buf  |  no buf  | small buf| big buf  |\0A\00", align 1
@.str.6.158 = private unnamed_addr constant [41 x i8] c"|%5u|%5u|%10u|%10u|%10u|%10u|%10u|%10u|\0A\00", align 1
@.str.7.159 = private unnamed_addr constant [81 x i8] c"|                      non-matching sizes (1_TO_N) to higher priority         |\0A\00", align 1
@.str.8.160 = private unnamed_addr constant [81 x i8] c"|                      non-matching sizes (1_TO_N) to lower priority          |\0A\00", align 1
@.str.9.161 = private unnamed_addr constant [41 x i8] c"|%5u|%5d|%10u|%10u|%10u|%10u|%10u|%10u|\0A\00", align 1
@.str.10 = private unnamed_addr constant [49 x i8] c"| Timer overflow.Results are invalid            \00", align 1
@.str.11 = private unnamed_addr constant [50 x i8] c"| Tick occurred. Results may be inaccurate       \00", align 1
@.str.12 = private unnamed_addr constant [32 x i8] c"                             |\0A\00", align 1
@timestamp_check.166 = internal global i64 0, align 8, !dbg !567
@.str.185 = private unnamed_addr constant [50 x i8] c"| Timer overflow. Results are invalid            \00", align 1
@.str.1.186 = private unnamed_addr constant [50 x i8] c"| Tick occurred. Results may be inaccurate       \00", align 1
@.str.2.187 = private unnamed_addr constant [32 x i8] c"                             |\0A\00", align 1
@timestamp_check.188 = internal global i64 0, align 8, !dbg !579
@data_recv = dso_local global [4096 x i8] zeroinitializer, align 1, !dbg !584
@.str.206 = private unnamed_addr constant [81 x i8] c"|-----------------------------------------------------------------------------|\0A\00", align 1
@.str.1.212 = private unnamed_addr constant [15 x i8] c"| %-65s|%10u|\0A\00", align 1
@.str.2.213 = private unnamed_addr constant [17 x i8] c"signal semaphore\00", align 1
@.str.3.215 = private unnamed_addr constant [32 x i8] c"signal to waiting high pri task\00", align 1
@.str.4.216 = private unnamed_addr constant [46 x i8] c"signal to waiting high pri task, with timeout\00", align 1
@.str.5.220 = private unnamed_addr constant [77 x i8] c"/home/kenny/ara/appl/Zephyr/app_kernel/src/master.h:%d Error: tick occurred\0A\00", align 1
@timestamp_check.221 = internal global i64 0, align 8, !dbg !591

; Function Attrs: noinline nounwind optnone
define dso_local void @queue_test() #0 !dbg !607 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_timeout_t, align 8
  %5 = alloca %struct.k_timeout_t, align 8
  %6 = alloca %struct.k_timeout_t, align 8
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !610, metadata !DIExpression()), !dbg !611
  call void @llvm.dbg.declare(metadata i32* %2, metadata !612, metadata !DIExpression()), !dbg !613
  %9 = load i32*, i32** @output_file, align 4, !dbg !614
  %10 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str, i32 0, i32 0), i32* %9) #3, !dbg !614
  %11 = call i32 @BENCH_START() #3, !dbg !615
  store i32 %11, i32* %1, align 4, !dbg !616
  store i32 0, i32* %2, align 4, !dbg !617
  br label %12, !dbg !619

12:                                               ; preds = %21, %0
  %13 = load i32, i32* %2, align 4, !dbg !620
  %14 = icmp slt i32 %13, 500, !dbg !622
  br i1 %14, label %15, label %24, !dbg !623

15:                                               ; preds = %12
  %16 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !624
  store i64 -1, i64* %16, align 8, !dbg !624
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !626
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !626
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !626
  %20 = call i32 @k_msgq_put(%struct.k_msgq* @DEMOQX1, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_bench, i32 0, i32 0), [1 x i64] %19) #3, !dbg !626
  br label %21, !dbg !627

21:                                               ; preds = %15
  %22 = load i32, i32* %2, align 4, !dbg !628
  %23 = add i32 %22, 1, !dbg !628
  store i32 %23, i32* %2, align 4, !dbg !628
  br label %12, !dbg !629, !llvm.loop !630

24:                                               ; preds = %12
  %25 = load i32, i32* %1, align 4, !dbg !632
  %26 = call i32 @TIME_STAMP_DELTA_GET(i32 %25) #3, !dbg !633
  store i32 %26, i32* %1, align 4, !dbg !634
  %27 = load i32, i32* %1, align 4, !dbg !635
  %28 = zext i32 %27 to i64, !dbg !635
  %29 = call i64 @k_cyc_to_ns_floor64(i64 %28) #3, !dbg !635
  %30 = udiv i64 %29, 500, !dbg !635
  %31 = trunc i64 %30 to i32, !dbg !635
  %32 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1, i32 0, i32 0), i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.2, i32 0, i32 0), i32 %31) #3, !dbg !635
  %33 = load i32*, i32** @output_file, align 4, !dbg !635
  %34 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %33) #3, !dbg !635
  %35 = call i32 @BENCH_START() #3, !dbg !637
  store i32 %35, i32* %1, align 4, !dbg !638
  store i32 0, i32* %2, align 4, !dbg !639
  br label %36, !dbg !641

36:                                               ; preds = %45, %24
  %37 = load i32, i32* %2, align 4, !dbg !642
  %38 = icmp slt i32 %37, 500, !dbg !644
  br i1 %38, label %39, label %48, !dbg !645

39:                                               ; preds = %36
  %40 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !646
  store i64 -1, i64* %40, align 8, !dbg !646
  %41 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !648
  %42 = bitcast i64* %41 to [1 x i64]*, !dbg !648
  %43 = load [1 x i64], [1 x i64]* %42, align 8, !dbg !648
  %44 = call i32 @k_msgq_get(%struct.k_msgq* @DEMOQX1, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_bench, i32 0, i32 0), [1 x i64] %43) #3, !dbg !648
  br label %45, !dbg !649

45:                                               ; preds = %39
  %46 = load i32, i32* %2, align 4, !dbg !650
  %47 = add i32 %46, 1, !dbg !650
  store i32 %47, i32* %2, align 4, !dbg !650
  br label %36, !dbg !651, !llvm.loop !652

48:                                               ; preds = %36
  %49 = load i32, i32* %1, align 4, !dbg !654
  %50 = call i32 @TIME_STAMP_DELTA_GET(i32 %49) #3, !dbg !655
  store i32 %50, i32* %1, align 4, !dbg !656
  call void @check_result() #3, !dbg !657
  %51 = load i32, i32* %1, align 4, !dbg !658
  %52 = zext i32 %51 to i64, !dbg !658
  %53 = call i64 @k_cyc_to_ns_floor64(i64 %52) #3, !dbg !658
  %54 = udiv i64 %53, 500, !dbg !658
  %55 = trunc i64 %54 to i32, !dbg !658
  %56 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1, i32 0, i32 0), i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.3, i32 0, i32 0), i32 %55) #3, !dbg !658
  %57 = load i32*, i32** @output_file, align 4, !dbg !658
  %58 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %57) #3, !dbg !658
  %59 = call i32 @BENCH_START() #3, !dbg !660
  store i32 %59, i32* %1, align 4, !dbg !661
  store i32 0, i32* %2, align 4, !dbg !662
  br label %60, !dbg !664

60:                                               ; preds = %69, %48
  %61 = load i32, i32* %2, align 4, !dbg !665
  %62 = icmp slt i32 %61, 500, !dbg !667
  br i1 %62, label %63, label %72, !dbg !668

63:                                               ; preds = %60
  %64 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !669
  store i64 -1, i64* %64, align 8, !dbg !669
  %65 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !671
  %66 = bitcast i64* %65 to [1 x i64]*, !dbg !671
  %67 = load [1 x i64], [1 x i64]* %66, align 8, !dbg !671
  %68 = call i32 @k_msgq_put(%struct.k_msgq* @DEMOQX4, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_bench, i32 0, i32 0), [1 x i64] %67) #3, !dbg !671
  br label %69, !dbg !672

69:                                               ; preds = %63
  %70 = load i32, i32* %2, align 4, !dbg !673
  %71 = add i32 %70, 1, !dbg !673
  store i32 %71, i32* %2, align 4, !dbg !673
  br label %60, !dbg !674, !llvm.loop !675

72:                                               ; preds = %60
  %73 = load i32, i32* %1, align 4, !dbg !677
  %74 = call i32 @TIME_STAMP_DELTA_GET(i32 %73) #3, !dbg !678
  store i32 %74, i32* %1, align 4, !dbg !679
  call void @check_result() #3, !dbg !680
  %75 = load i32, i32* %1, align 4, !dbg !681
  %76 = zext i32 %75 to i64, !dbg !681
  %77 = call i64 @k_cyc_to_ns_floor64(i64 %76) #3, !dbg !681
  %78 = udiv i64 %77, 500, !dbg !681
  %79 = trunc i64 %78 to i32, !dbg !681
  %80 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1, i32 0, i32 0), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.4, i32 0, i32 0), i32 %79) #3, !dbg !681
  %81 = load i32*, i32** @output_file, align 4, !dbg !681
  %82 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %81) #3, !dbg !681
  %83 = call i32 @BENCH_START() #3, !dbg !683
  store i32 %83, i32* %1, align 4, !dbg !684
  store i32 0, i32* %2, align 4, !dbg !685
  br label %84, !dbg !687

84:                                               ; preds = %93, %72
  %85 = load i32, i32* %2, align 4, !dbg !688
  %86 = icmp slt i32 %85, 500, !dbg !690
  br i1 %86, label %87, label %96, !dbg !691

87:                                               ; preds = %84
  %88 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %6, i32 0, i32 0, !dbg !692
  store i64 -1, i64* %88, align 8, !dbg !692
  %89 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %6, i32 0, i32 0, !dbg !694
  %90 = bitcast i64* %89 to [1 x i64]*, !dbg !694
  %91 = load [1 x i64], [1 x i64]* %90, align 8, !dbg !694
  %92 = call i32 @k_msgq_get(%struct.k_msgq* @DEMOQX4, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_bench, i32 0, i32 0), [1 x i64] %91) #3, !dbg !694
  br label %93, !dbg !695

93:                                               ; preds = %87
  %94 = load i32, i32* %2, align 4, !dbg !696
  %95 = add i32 %94, 1, !dbg !696
  store i32 %95, i32* %2, align 4, !dbg !696
  br label %84, !dbg !697, !llvm.loop !698

96:                                               ; preds = %84
  %97 = load i32, i32* %1, align 4, !dbg !700
  %98 = call i32 @TIME_STAMP_DELTA_GET(i32 %97) #3, !dbg !701
  store i32 %98, i32* %1, align 4, !dbg !702
  call void @check_result() #3, !dbg !703
  %99 = load i32, i32* %1, align 4, !dbg !704
  %100 = zext i32 %99 to i64, !dbg !704
  %101 = call i64 @k_cyc_to_ns_floor64(i64 %100) #3, !dbg !704
  %102 = udiv i64 %101, 500, !dbg !704
  %103 = trunc i64 %102 to i32, !dbg !704
  %104 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1, i32 0, i32 0), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.5, i32 0, i32 0), i32 %103) #3, !dbg !704
  %105 = load i32*, i32** @output_file, align 4, !dbg !704
  %106 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %105) #3, !dbg !704
  call void @k_sem_give(%struct.k_sem* @STARTRCV) #3, !dbg !706
  %107 = call i32 @BENCH_START() #3, !dbg !707
  store i32 %107, i32* %1, align 4, !dbg !708
  store i32 0, i32* %2, align 4, !dbg !709
  br label %108, !dbg !711

108:                                              ; preds = %117, %96
  %109 = load i32, i32* %2, align 4, !dbg !712
  %110 = icmp slt i32 %109, 500, !dbg !714
  br i1 %110, label %111, label %120, !dbg !715

111:                                              ; preds = %108
  %112 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !716
  store i64 -1, i64* %112, align 8, !dbg !716
  %113 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !718
  %114 = bitcast i64* %113 to [1 x i64]*, !dbg !718
  %115 = load [1 x i64], [1 x i64]* %114, align 8, !dbg !718
  %116 = call i32 @k_msgq_put(%struct.k_msgq* @DEMOQX1, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_bench, i32 0, i32 0), [1 x i64] %115) #3, !dbg !718
  br label %117, !dbg !719

117:                                              ; preds = %111
  %118 = load i32, i32* %2, align 4, !dbg !720
  %119 = add i32 %118, 1, !dbg !720
  store i32 %119, i32* %2, align 4, !dbg !720
  br label %108, !dbg !721, !llvm.loop !722

120:                                              ; preds = %108
  %121 = load i32, i32* %1, align 4, !dbg !724
  %122 = call i32 @TIME_STAMP_DELTA_GET(i32 %121) #3, !dbg !725
  store i32 %122, i32* %1, align 4, !dbg !726
  call void @check_result() #3, !dbg !727
  %123 = load i32, i32* %1, align 4, !dbg !728
  %124 = zext i32 %123 to i64, !dbg !728
  %125 = call i64 @k_cyc_to_ns_floor64(i64 %124) #3, !dbg !728
  %126 = udiv i64 %125, 500, !dbg !728
  %127 = trunc i64 %126 to i32, !dbg !728
  %128 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1, i32 0, i32 0), i8* getelementptr inbounds ([61 x i8], [61 x i8]* @.str.6, i32 0, i32 0), i32 %127) #3, !dbg !728
  %129 = load i32*, i32** @output_file, align 4, !dbg !728
  %130 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %129) #3, !dbg !728
  %131 = call i32 @BENCH_START() #3, !dbg !730
  store i32 %131, i32* %1, align 4, !dbg !731
  store i32 0, i32* %2, align 4, !dbg !732
  br label %132, !dbg !734

132:                                              ; preds = %141, %120
  %133 = load i32, i32* %2, align 4, !dbg !735
  %134 = icmp slt i32 %133, 500, !dbg !737
  br i1 %134, label %135, label %144, !dbg !738

135:                                              ; preds = %132
  %136 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !739
  store i64 -1, i64* %136, align 8, !dbg !739
  %137 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !741
  %138 = bitcast i64* %137 to [1 x i64]*, !dbg !741
  %139 = load [1 x i64], [1 x i64]* %138, align 8, !dbg !741
  %140 = call i32 @k_msgq_put(%struct.k_msgq* @DEMOQX4, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_bench, i32 0, i32 0), [1 x i64] %139) #3, !dbg !741
  br label %141, !dbg !742

141:                                              ; preds = %135
  %142 = load i32, i32* %2, align 4, !dbg !743
  %143 = add i32 %142, 1, !dbg !743
  store i32 %143, i32* %2, align 4, !dbg !743
  br label %132, !dbg !744, !llvm.loop !745

144:                                              ; preds = %132
  %145 = load i32, i32* %1, align 4, !dbg !747
  %146 = call i32 @TIME_STAMP_DELTA_GET(i32 %145) #3, !dbg !748
  store i32 %146, i32* %1, align 4, !dbg !749
  call void @check_result() #3, !dbg !750
  %147 = load i32, i32* %1, align 4, !dbg !751
  %148 = zext i32 %147 to i64, !dbg !751
  %149 = call i64 @k_cyc_to_ns_floor64(i64 %148) #3, !dbg !751
  %150 = udiv i64 %149, 500, !dbg !751
  %151 = trunc i64 %150 to i32, !dbg !751
  %152 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1, i32 0, i32 0), i8* getelementptr inbounds ([58 x i8], [58 x i8]* @.str.7, i32 0, i32 0), i32 %151) #3, !dbg !751
  %153 = load i32*, i32** @output_file, align 4, !dbg !751
  %154 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %153) #3, !dbg !751
  ret void, !dbg !753
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare dso_local i32 @fputs(i8*, i32*) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START() #0 !dbg !754 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !757, metadata !DIExpression()), !dbg !758
  call void @bench_test_start() #3, !dbg !759
  %2 = call i32 @TIME_STAMP_DELTA_GET(i32 0) #3, !dbg !760
  store i32 %2, i32* %1, align 4, !dbg !761
  %3 = load i32, i32* %1, align 4, !dbg !762
  ret i32 %3, !dbg !763
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msgq_put(%struct.k_msgq*, i8*, [1 x i64]) #0 !dbg !764 {
  %4 = alloca %struct.k_timeout_t, align 8
  %5 = alloca %struct.k_msgq*, align 4
  %6 = alloca i8*, align 4
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0
  %8 = bitcast i64* %7 to [1 x i64]*
  store [1 x i64] %2, [1 x i64]* %8, align 8
  store %struct.k_msgq* %0, %struct.k_msgq** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_msgq** %5, metadata !808, metadata !DIExpression()), !dbg !809
  store i8* %1, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !810, metadata !DIExpression()), !dbg !811
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %4, metadata !812, metadata !DIExpression()), !dbg !813
  br label %9, !dbg !814

9:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !815, !srcloc !817
  br label %10, !dbg !815

10:                                               ; preds = %9
  %11 = load %struct.k_msgq*, %struct.k_msgq** %5, align 4, !dbg !818
  %12 = load i8*, i8** %6, align 4, !dbg !819
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !820
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !820
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !820
  %16 = call i32 @z_impl_k_msgq_put(%struct.k_msgq* %11, i8* %12, [1 x i64] %15) #3, !dbg !820
  ret i32 %16, !dbg !821
}

; Function Attrs: noinline nounwind optnone
define internal i32 @TIME_STAMP_DELTA_GET(i32) #0 !dbg !822 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !825, metadata !DIExpression()), !dbg !826
  call void @llvm.dbg.declare(metadata i32* %3, metadata !827, metadata !DIExpression()), !dbg !828
  call void @timestamp_serialize() #3, !dbg !829
  %5 = call i32 @k_cycle_get_32() #3, !dbg !830
  store i32 %5, i32* %3, align 4, !dbg !831
  call void @llvm.dbg.declare(metadata i32* %4, metadata !832, metadata !DIExpression()), !dbg !833
  %6 = load i32, i32* %3, align 4, !dbg !834
  %7 = load i32, i32* %2, align 4, !dbg !835
  %8 = icmp uge i32 %6, %7, !dbg !836
  br i1 %8, label %9, label %13, !dbg !837

9:                                                ; preds = %1
  %10 = load i32, i32* %3, align 4, !dbg !838
  %11 = load i32, i32* %2, align 4, !dbg !839
  %12 = sub i32 %10, %11, !dbg !840
  br label %18, !dbg !837

13:                                               ; preds = %1
  %14 = load i32, i32* %2, align 4, !dbg !841
  %15 = sub i32 -1, %14, !dbg !842
  %16 = load i32, i32* %3, align 4, !dbg !843
  %17 = add i32 %15, %16, !dbg !844
  br label %18, !dbg !837

18:                                               ; preds = %13, %9
  %19 = phi i32 [ %12, %9 ], [ %17, %13 ], !dbg !837
  store i32 %19, i32* %4, align 4, !dbg !833
  %20 = load i32, i32* %2, align 4, !dbg !845
  %21 = icmp ugt i32 %20, 0, !dbg !847
  br i1 %21, label %22, label %26, !dbg !848

22:                                               ; preds = %18
  %23 = load i32, i32* @tm_off, align 4, !dbg !849
  %24 = load i32, i32* %4, align 4, !dbg !851
  %25 = sub i32 %24, %23, !dbg !851
  store i32 %25, i32* %4, align 4, !dbg !851
  br label %26, !dbg !852

26:                                               ; preds = %22, %18
  %27 = load i32, i32* %4, align 4, !dbg !853
  ret i32 %27, !dbg !854
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_cyc_to_ns_floor64(i64) #0 !dbg !855 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !859, metadata !DIExpression()), !dbg !864
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !866, metadata !DIExpression()), !dbg !867
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !868, metadata !DIExpression()), !dbg !869
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !870, metadata !DIExpression()), !dbg !871
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !872, metadata !DIExpression()), !dbg !873
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !874, metadata !DIExpression()), !dbg !875
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !876, metadata !DIExpression()), !dbg !877
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !878, metadata !DIExpression()), !dbg !879
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !880, metadata !DIExpression()), !dbg !881
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !882, metadata !DIExpression()), !dbg !883
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !884, metadata !DIExpression()), !dbg !887
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !888, metadata !DIExpression()), !dbg !889
  %15 = load i64, i64* %14, align 8, !dbg !890
  %16 = call i32 @sys_clock_hw_cycles_per_sec() #3, !dbg !891
  store i64 %15, i64* %3, align 8
  store i32 %16, i32* %4, align 4
  store i32 1000000000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 0, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %17 = load i8, i8* %6, align 1, !dbg !892
  %18 = trunc i8 %17 to i1, !dbg !892
  br i1 %18, label %19, label %28, !dbg !893

19:                                               ; preds = %1
  %20 = load i32, i32* %5, align 4, !dbg !894
  %21 = load i32, i32* %4, align 4, !dbg !895
  %22 = icmp ugt i32 %20, %21, !dbg !896
  br i1 %22, label %23, label %28, !dbg !897

23:                                               ; preds = %19
  %24 = load i32, i32* %5, align 4, !dbg !898
  %25 = load i32, i32* %4, align 4, !dbg !899
  %26 = urem i32 %24, %25, !dbg !900
  %27 = icmp eq i32 %26, 0, !dbg !901
  br label %28

28:                                               ; preds = %23, %19, %1
  %29 = phi i1 [ false, %19 ], [ false, %1 ], [ %27, %23 ], !dbg !902
  %30 = zext i1 %29 to i8, !dbg !879
  store i8 %30, i8* %10, align 1, !dbg !879
  %31 = load i8, i8* %6, align 1, !dbg !903
  %32 = trunc i8 %31 to i1, !dbg !903
  br i1 %32, label %33, label %42, !dbg !904

33:                                               ; preds = %28
  %34 = load i32, i32* %4, align 4, !dbg !905
  %35 = load i32, i32* %5, align 4, !dbg !906
  %36 = icmp ugt i32 %34, %35, !dbg !907
  br i1 %36, label %37, label %42, !dbg !908

37:                                               ; preds = %33
  %38 = load i32, i32* %4, align 4, !dbg !909
  %39 = load i32, i32* %5, align 4, !dbg !910
  %40 = urem i32 %38, %39, !dbg !911
  %41 = icmp eq i32 %40, 0, !dbg !912
  br label %42

42:                                               ; preds = %37, %33, %28
  %43 = phi i1 [ false, %33 ], [ false, %28 ], [ %41, %37 ], !dbg !902
  %44 = zext i1 %43 to i8, !dbg !881
  store i8 %44, i8* %11, align 1, !dbg !881
  %45 = load i32, i32* %4, align 4, !dbg !913
  %46 = load i32, i32* %5, align 4, !dbg !915
  %47 = icmp eq i32 %45, %46, !dbg !916
  br i1 %47, label %48, label %59, !dbg !917

48:                                               ; preds = %42
  %49 = load i8, i8* %7, align 1, !dbg !918
  %50 = trunc i8 %49 to i1, !dbg !918
  br i1 %50, label %51, label %55, !dbg !918

51:                                               ; preds = %48
  %52 = load i64, i64* %3, align 8, !dbg !920
  %53 = trunc i64 %52 to i32, !dbg !921
  %54 = zext i32 %53 to i64, !dbg !922
  br label %57, !dbg !918

55:                                               ; preds = %48
  %56 = load i64, i64* %3, align 8, !dbg !923
  br label %57, !dbg !918

57:                                               ; preds = %55, %51
  %58 = phi i64 [ %54, %51 ], [ %56, %55 ], !dbg !918
  store i64 %58, i64* %2, align 8, !dbg !924
  br label %161, !dbg !924

59:                                               ; preds = %42
  store i64 0, i64* %12, align 8, !dbg !883
  %60 = load i8, i8* %10, align 1, !dbg !925
  %61 = trunc i8 %60 to i1, !dbg !925
  br i1 %61, label %88, label %62, !dbg !926

62:                                               ; preds = %59
  %63 = load i8, i8* %11, align 1, !dbg !927
  %64 = trunc i8 %63 to i1, !dbg !927
  br i1 %64, label %65, label %69, !dbg !927

65:                                               ; preds = %62
  %66 = load i32, i32* %4, align 4, !dbg !928
  %67 = load i32, i32* %5, align 4, !dbg !929
  %68 = udiv i32 %66, %67, !dbg !930
  br label %71, !dbg !927

69:                                               ; preds = %62
  %70 = load i32, i32* %4, align 4, !dbg !931
  br label %71, !dbg !927

71:                                               ; preds = %69, %65
  %72 = phi i32 [ %68, %65 ], [ %70, %69 ], !dbg !927
  store i32 %72, i32* %13, align 4, !dbg !887
  %73 = load i8, i8* %8, align 1, !dbg !932
  %74 = trunc i8 %73 to i1, !dbg !932
  br i1 %74, label %75, label %79, !dbg !934

75:                                               ; preds = %71
  %76 = load i32, i32* %13, align 4, !dbg !935
  %77 = sub i32 %76, 1, !dbg !937
  %78 = zext i32 %77 to i64, !dbg !935
  store i64 %78, i64* %12, align 8, !dbg !938
  br label %87, !dbg !939

79:                                               ; preds = %71
  %80 = load i8, i8* %9, align 1, !dbg !940
  %81 = trunc i8 %80 to i1, !dbg !940
  br i1 %81, label %82, label %86, !dbg !942

82:                                               ; preds = %79
  %83 = load i32, i32* %13, align 4, !dbg !943
  %84 = udiv i32 %83, 2, !dbg !945
  %85 = zext i32 %84 to i64, !dbg !943
  store i64 %85, i64* %12, align 8, !dbg !946
  br label %86, !dbg !947

86:                                               ; preds = %82, %79
  br label %87

87:                                               ; preds = %86, %75
  br label %88, !dbg !948

88:                                               ; preds = %87, %59
  %89 = load i8, i8* %11, align 1, !dbg !949
  %90 = trunc i8 %89 to i1, !dbg !949
  br i1 %90, label %91, label %115, !dbg !951

91:                                               ; preds = %88
  %92 = load i64, i64* %12, align 8, !dbg !952
  %93 = load i64, i64* %3, align 8, !dbg !954
  %94 = add i64 %93, %92, !dbg !954
  store i64 %94, i64* %3, align 8, !dbg !954
  %95 = load i8, i8* %7, align 1, !dbg !955
  %96 = trunc i8 %95 to i1, !dbg !955
  br i1 %96, label %97, label %108, !dbg !957

97:                                               ; preds = %91
  %98 = load i64, i64* %3, align 8, !dbg !958
  %99 = icmp ult i64 %98, 4294967296, !dbg !959
  br i1 %99, label %100, label %108, !dbg !960

100:                                              ; preds = %97
  %101 = load i64, i64* %3, align 8, !dbg !961
  %102 = trunc i64 %101 to i32, !dbg !963
  %103 = load i32, i32* %4, align 4, !dbg !964
  %104 = load i32, i32* %5, align 4, !dbg !965
  %105 = udiv i32 %103, %104, !dbg !966
  %106 = udiv i32 %102, %105, !dbg !967
  %107 = zext i32 %106 to i64, !dbg !968
  store i64 %107, i64* %2, align 8, !dbg !969
  br label %161, !dbg !969

108:                                              ; preds = %97, %91
  %109 = load i64, i64* %3, align 8, !dbg !970
  %110 = load i32, i32* %4, align 4, !dbg !972
  %111 = load i32, i32* %5, align 4, !dbg !973
  %112 = udiv i32 %110, %111, !dbg !974
  %113 = zext i32 %112 to i64, !dbg !975
  %114 = udiv i64 %109, %113, !dbg !976
  store i64 %114, i64* %2, align 8, !dbg !977
  br label %161, !dbg !977

115:                                              ; preds = %88
  %116 = load i8, i8* %10, align 1, !dbg !978
  %117 = trunc i8 %116 to i1, !dbg !978
  br i1 %117, label %118, label %136, !dbg !980

118:                                              ; preds = %115
  %119 = load i8, i8* %7, align 1, !dbg !981
  %120 = trunc i8 %119 to i1, !dbg !981
  br i1 %120, label %121, label %129, !dbg !984

121:                                              ; preds = %118
  %122 = load i64, i64* %3, align 8, !dbg !985
  %123 = trunc i64 %122 to i32, !dbg !987
  %124 = load i32, i32* %5, align 4, !dbg !988
  %125 = load i32, i32* %4, align 4, !dbg !989
  %126 = udiv i32 %124, %125, !dbg !990
  %127 = mul i32 %123, %126, !dbg !991
  %128 = zext i32 %127 to i64, !dbg !992
  store i64 %128, i64* %2, align 8, !dbg !993
  br label %161, !dbg !993

129:                                              ; preds = %118
  %130 = load i64, i64* %3, align 8, !dbg !994
  %131 = load i32, i32* %5, align 4, !dbg !996
  %132 = load i32, i32* %4, align 4, !dbg !997
  %133 = udiv i32 %131, %132, !dbg !998
  %134 = zext i32 %133 to i64, !dbg !999
  %135 = mul i64 %130, %134, !dbg !1000
  store i64 %135, i64* %2, align 8, !dbg !1001
  br label %161, !dbg !1001

136:                                              ; preds = %115
  %137 = load i8, i8* %7, align 1, !dbg !1002
  %138 = trunc i8 %137 to i1, !dbg !1002
  br i1 %138, label %139, label %151, !dbg !1005

139:                                              ; preds = %136
  %140 = load i64, i64* %3, align 8, !dbg !1006
  %141 = load i32, i32* %5, align 4, !dbg !1008
  %142 = zext i32 %141 to i64, !dbg !1008
  %143 = mul i64 %140, %142, !dbg !1009
  %144 = load i64, i64* %12, align 8, !dbg !1010
  %145 = add i64 %143, %144, !dbg !1011
  %146 = load i32, i32* %4, align 4, !dbg !1012
  %147 = zext i32 %146 to i64, !dbg !1012
  %148 = udiv i64 %145, %147, !dbg !1013
  %149 = trunc i64 %148 to i32, !dbg !1014
  %150 = zext i32 %149 to i64, !dbg !1014
  store i64 %150, i64* %2, align 8, !dbg !1015
  br label %161, !dbg !1015

151:                                              ; preds = %136
  %152 = load i64, i64* %3, align 8, !dbg !1016
  %153 = load i32, i32* %5, align 4, !dbg !1018
  %154 = zext i32 %153 to i64, !dbg !1018
  %155 = mul i64 %152, %154, !dbg !1019
  %156 = load i64, i64* %12, align 8, !dbg !1020
  %157 = add i64 %155, %156, !dbg !1021
  %158 = load i32, i32* %4, align 4, !dbg !1022
  %159 = zext i32 %158 to i64, !dbg !1022
  %160 = udiv i64 %157, %159, !dbg !1023
  store i64 %160, i64* %2, align 8, !dbg !1024
  br label %161, !dbg !1024

161:                                              ; preds = %151, %139, %129, %121, %108, %100, %57
  %162 = load i64, i64* %2, align 8, !dbg !1025
  ret i64 %162, !dbg !1026
}

declare dso_local i32 @snprintf(i8*, i32, i8*, ...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @k_msgq_get(%struct.k_msgq*, i8*, [1 x i64]) #0 !dbg !1027 {
  %4 = alloca %struct.k_timeout_t, align 8
  %5 = alloca %struct.k_msgq*, align 4
  %6 = alloca i8*, align 4
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0
  %8 = bitcast i64* %7 to [1 x i64]*
  store [1 x i64] %2, [1 x i64]* %8, align 8
  store %struct.k_msgq* %0, %struct.k_msgq** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_msgq** %5, metadata !1030, metadata !DIExpression()), !dbg !1031
  store i8* %1, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !1032, metadata !DIExpression()), !dbg !1033
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %4, metadata !1034, metadata !DIExpression()), !dbg !1035
  br label %9, !dbg !1036

9:                                                ; preds = %3
  call void asm sideeffect "", "~{memory}"() #4, !dbg !1037, !srcloc !1039
  br label %10, !dbg !1037

10:                                               ; preds = %9
  %11 = load %struct.k_msgq*, %struct.k_msgq** %5, align 4, !dbg !1040
  %12 = load i8*, i8** %6, align 4, !dbg !1041
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !1042
  %14 = bitcast i64* %13 to [1 x i64]*, !dbg !1042
  %15 = load [1 x i64], [1 x i64]* %14, align 8, !dbg !1042
  %16 = call i32 @z_impl_k_msgq_get(%struct.k_msgq* %11, i8* %12, [1 x i64] %15) #3, !dbg !1042
  ret i32 %16, !dbg !1043
}

; Function Attrs: noinline nounwind optnone
define internal void @check_result() #0 !dbg !1044 {
  %1 = call i32 @bench_test_end() #3, !dbg !1045
  %2 = icmp slt i32 %1, 0, !dbg !1047
  br i1 %2, label %3, label %7, !dbg !1048

3:                                                ; preds = %0
  %4 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([77 x i8], [77 x i8]* @.str.8, i32 0, i32 0), i32 187) #3, !dbg !1049
  %5 = load i32*, i32** @output_file, align 4, !dbg !1049
  %6 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %5) #3, !dbg !1049
  br label %7, !dbg !1052

7:                                                ; preds = %3, %0
  ret void, !dbg !1053
}

; Function Attrs: noinline nounwind optnone
define internal void @k_sem_give(%struct.k_sem*) #0 !dbg !1054 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !1063, metadata !DIExpression()), !dbg !1064
  br label %3, !dbg !1065

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !1066, !srcloc !1068
  br label %4, !dbg !1066

4:                                                ; preds = %3
  %5 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !1069
  call void @z_impl_k_sem_give(%struct.k_sem* %5) #3, !dbg !1070
  ret void, !dbg !1071
}

declare dso_local void @z_impl_k_sem_give(%struct.k_sem*) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end() #0 !dbg !1072 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta(i64* @timestamp_check) #3, !dbg !1075
  store i64 %2, i64* @timestamp_check, align 8, !dbg !1076
  %3 = load i64, i64* @timestamp_check, align 8, !dbg !1077
  %4 = icmp sge i64 %3, 1000, !dbg !1079
  br i1 %4, label %5, label %6, !dbg !1080

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !1081
  br label %7, !dbg !1081

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !1083
  br label %7, !dbg !1083

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !1084
  ret i32 %8, !dbg !1084
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_uptime_delta(i64*) #0 !dbg !1085 {
  %2 = alloca i64*, align 4
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  store i64* %0, i64** %2, align 4
  call void @llvm.dbg.declare(metadata i64** %2, metadata !1089, metadata !DIExpression()), !dbg !1090
  call void @llvm.dbg.declare(metadata i64* %3, metadata !1091, metadata !DIExpression()), !dbg !1092
  call void @llvm.dbg.declare(metadata i64* %4, metadata !1093, metadata !DIExpression()), !dbg !1094
  %5 = call i64 @k_uptime_get() #3, !dbg !1095
  store i64 %5, i64* %3, align 8, !dbg !1096
  %6 = load i64, i64* %3, align 8, !dbg !1097
  %7 = load i64*, i64** %2, align 4, !dbg !1098
  %8 = load i64, i64* %7, align 8, !dbg !1099
  %9 = sub i64 %6, %8, !dbg !1100
  store i64 %9, i64* %4, align 8, !dbg !1101
  %10 = load i64, i64* %3, align 8, !dbg !1102
  %11 = load i64*, i64** %2, align 4, !dbg !1103
  store i64 %10, i64* %11, align 8, !dbg !1104
  %12 = load i64, i64* %4, align 8, !dbg !1105
  ret i64 %12, !dbg !1106
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_uptime_get() #0 !dbg !1107 {
  %1 = call i64 @k_uptime_ticks() #3, !dbg !1110
  %2 = call i64 @k_ticks_to_ms_floor64(i64 %1) #3, !dbg !1111
  ret i64 %2, !dbg !1112
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_uptime_ticks() #0 !dbg !1113 {
  br label %1, !dbg !1114

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory}"() #4, !dbg !1115, !srcloc !1117
  br label %2, !dbg !1115

2:                                                ; preds = %1
  %3 = call i64 bitcast (i64 (...)* @z_impl_k_uptime_ticks to i64 ()*)() #3, !dbg !1118
  ret i64 %3, !dbg !1119
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ticks_to_ms_floor64(i64) #0 !dbg !1120 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !859, metadata !DIExpression()), !dbg !1121
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !866, metadata !DIExpression()), !dbg !1123
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !868, metadata !DIExpression()), !dbg !1124
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !870, metadata !DIExpression()), !dbg !1125
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !872, metadata !DIExpression()), !dbg !1126
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !874, metadata !DIExpression()), !dbg !1127
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !876, metadata !DIExpression()), !dbg !1128
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !878, metadata !DIExpression()), !dbg !1129
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !880, metadata !DIExpression()), !dbg !1130
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !882, metadata !DIExpression()), !dbg !1131
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !884, metadata !DIExpression()), !dbg !1132
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !1133, metadata !DIExpression()), !dbg !1134
  %15 = load i64, i64* %14, align 8, !dbg !1135
  store i64 %15, i64* %3, align 8
  store i32 2, i32* %4, align 4
  store i32 1000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 0, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !1136
  %17 = trunc i8 %16 to i1, !dbg !1136
  br i1 %17, label %18, label %27, !dbg !1137

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !1138
  %20 = load i32, i32* %4, align 4, !dbg !1139
  %21 = icmp ugt i32 %19, %20, !dbg !1140
  br i1 %21, label %22, label %27, !dbg !1141

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !1142
  %24 = load i32, i32* %4, align 4, !dbg !1143
  %25 = urem i32 %23, %24, !dbg !1144
  %26 = icmp eq i32 %25, 0, !dbg !1145
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !1146
  %29 = zext i1 %28 to i8, !dbg !1129
  store i8 %29, i8* %10, align 1, !dbg !1129
  %30 = load i8, i8* %6, align 1, !dbg !1147
  %31 = trunc i8 %30 to i1, !dbg !1147
  br i1 %31, label %32, label %41, !dbg !1148

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !1149
  %34 = load i32, i32* %5, align 4, !dbg !1150
  %35 = icmp ugt i32 %33, %34, !dbg !1151
  br i1 %35, label %36, label %41, !dbg !1152

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !1153
  %38 = load i32, i32* %5, align 4, !dbg !1154
  %39 = urem i32 %37, %38, !dbg !1155
  %40 = icmp eq i32 %39, 0, !dbg !1156
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !1146
  %43 = zext i1 %42 to i8, !dbg !1130
  store i8 %43, i8* %11, align 1, !dbg !1130
  %44 = load i32, i32* %4, align 4, !dbg !1157
  %45 = load i32, i32* %5, align 4, !dbg !1158
  %46 = icmp eq i32 %44, %45, !dbg !1159
  br i1 %46, label %47, label %58, !dbg !1160

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !1161
  %49 = trunc i8 %48 to i1, !dbg !1161
  br i1 %49, label %50, label %54, !dbg !1161

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !1162
  %52 = trunc i64 %51 to i32, !dbg !1163
  %53 = zext i32 %52 to i64, !dbg !1164
  br label %56, !dbg !1161

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !1165
  br label %56, !dbg !1161

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !1161
  store i64 %57, i64* %2, align 8, !dbg !1166
  br label %160, !dbg !1166

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !1131
  %59 = load i8, i8* %10, align 1, !dbg !1167
  %60 = trunc i8 %59 to i1, !dbg !1167
  br i1 %60, label %87, label %61, !dbg !1168

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !1169
  %63 = trunc i8 %62 to i1, !dbg !1169
  br i1 %63, label %64, label %68, !dbg !1169

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !1170
  %66 = load i32, i32* %5, align 4, !dbg !1171
  %67 = udiv i32 %65, %66, !dbg !1172
  br label %70, !dbg !1169

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !1173
  br label %70, !dbg !1169

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !1169
  store i32 %71, i32* %13, align 4, !dbg !1132
  %72 = load i8, i8* %8, align 1, !dbg !1174
  %73 = trunc i8 %72 to i1, !dbg !1174
  br i1 %73, label %74, label %78, !dbg !1175

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !1176
  %76 = sub i32 %75, 1, !dbg !1177
  %77 = zext i32 %76 to i64, !dbg !1176
  store i64 %77, i64* %12, align 8, !dbg !1178
  br label %86, !dbg !1179

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !1180
  %80 = trunc i8 %79 to i1, !dbg !1180
  br i1 %80, label %81, label %85, !dbg !1181

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !1182
  %83 = udiv i32 %82, 2, !dbg !1183
  %84 = zext i32 %83 to i64, !dbg !1182
  store i64 %84, i64* %12, align 8, !dbg !1184
  br label %85, !dbg !1185

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !1186

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !1187
  %89 = trunc i8 %88 to i1, !dbg !1187
  br i1 %89, label %90, label %114, !dbg !1188

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !1189
  %92 = load i64, i64* %3, align 8, !dbg !1190
  %93 = add i64 %92, %91, !dbg !1190
  store i64 %93, i64* %3, align 8, !dbg !1190
  %94 = load i8, i8* %7, align 1, !dbg !1191
  %95 = trunc i8 %94 to i1, !dbg !1191
  br i1 %95, label %96, label %107, !dbg !1192

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !1193
  %98 = icmp ult i64 %97, 4294967296, !dbg !1194
  br i1 %98, label %99, label %107, !dbg !1195

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !1196
  %101 = trunc i64 %100 to i32, !dbg !1197
  %102 = load i32, i32* %4, align 4, !dbg !1198
  %103 = load i32, i32* %5, align 4, !dbg !1199
  %104 = udiv i32 %102, %103, !dbg !1200
  %105 = udiv i32 %101, %104, !dbg !1201
  %106 = zext i32 %105 to i64, !dbg !1202
  store i64 %106, i64* %2, align 8, !dbg !1203
  br label %160, !dbg !1203

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !1204
  %109 = load i32, i32* %4, align 4, !dbg !1205
  %110 = load i32, i32* %5, align 4, !dbg !1206
  %111 = udiv i32 %109, %110, !dbg !1207
  %112 = zext i32 %111 to i64, !dbg !1208
  %113 = udiv i64 %108, %112, !dbg !1209
  store i64 %113, i64* %2, align 8, !dbg !1210
  br label %160, !dbg !1210

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !1211
  %116 = trunc i8 %115 to i1, !dbg !1211
  br i1 %116, label %117, label %135, !dbg !1212

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !1213
  %119 = trunc i8 %118 to i1, !dbg !1213
  br i1 %119, label %120, label %128, !dbg !1214

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !1215
  %122 = trunc i64 %121 to i32, !dbg !1216
  %123 = load i32, i32* %5, align 4, !dbg !1217
  %124 = load i32, i32* %4, align 4, !dbg !1218
  %125 = udiv i32 %123, %124, !dbg !1219
  %126 = mul i32 %122, %125, !dbg !1220
  %127 = zext i32 %126 to i64, !dbg !1221
  store i64 %127, i64* %2, align 8, !dbg !1222
  br label %160, !dbg !1222

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !1223
  %130 = load i32, i32* %5, align 4, !dbg !1224
  %131 = load i32, i32* %4, align 4, !dbg !1225
  %132 = udiv i32 %130, %131, !dbg !1226
  %133 = zext i32 %132 to i64, !dbg !1227
  %134 = mul i64 %129, %133, !dbg !1228
  store i64 %134, i64* %2, align 8, !dbg !1229
  br label %160, !dbg !1229

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !1230
  %137 = trunc i8 %136 to i1, !dbg !1230
  br i1 %137, label %138, label %150, !dbg !1231

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !1232
  %140 = load i32, i32* %5, align 4, !dbg !1233
  %141 = zext i32 %140 to i64, !dbg !1233
  %142 = mul i64 %139, %141, !dbg !1234
  %143 = load i64, i64* %12, align 8, !dbg !1235
  %144 = add i64 %142, %143, !dbg !1236
  %145 = load i32, i32* %4, align 4, !dbg !1237
  %146 = zext i32 %145 to i64, !dbg !1237
  %147 = udiv i64 %144, %146, !dbg !1238
  %148 = trunc i64 %147 to i32, !dbg !1239
  %149 = zext i32 %148 to i64, !dbg !1239
  store i64 %149, i64* %2, align 8, !dbg !1240
  br label %160, !dbg !1240

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !1241
  %152 = load i32, i32* %5, align 4, !dbg !1242
  %153 = zext i32 %152 to i64, !dbg !1242
  %154 = mul i64 %151, %153, !dbg !1243
  %155 = load i64, i64* %12, align 8, !dbg !1244
  %156 = add i64 %154, %155, !dbg !1245
  %157 = load i32, i32* %4, align 4, !dbg !1246
  %158 = zext i32 %157 to i64, !dbg !1246
  %159 = udiv i64 %156, %158, !dbg !1247
  store i64 %159, i64* %2, align 8, !dbg !1248
  br label %160, !dbg !1248

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !1249
  ret i64 %161, !dbg !1250
}

declare dso_local i64 @z_impl_k_uptime_ticks(...) #2

declare dso_local i32 @z_impl_k_msgq_get(%struct.k_msgq*, i8*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @sys_clock_hw_cycles_per_sec() #0 !dbg !1251 {
  ret i32 72000000, !dbg !1252
}

; Function Attrs: noinline nounwind optnone
define internal void @timestamp_serialize() #0 !dbg !1253 {
  call void asm sideeffect "isb 0xF", "~{memory}"() #4, !dbg !1255, !srcloc !1259
  ret void, !dbg !1260
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_cycle_get_32() #0 !dbg !1261 {
  %1 = call i32 @arch_k_cycle_get_32() #3, !dbg !1262
  ret i32 %1, !dbg !1263
}

; Function Attrs: noinline nounwind optnone
define internal i32 @arch_k_cycle_get_32() #0 !dbg !1264 {
  %1 = call i32 @z_timer_cycle_get_32() #3, !dbg !1266
  ret i32 %1, !dbg !1267
}

declare dso_local i32 @z_timer_cycle_get_32() #2

declare dso_local i32 @z_impl_k_msgq_put(%struct.k_msgq*, i8*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start() #0 !dbg !1268 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check, align 8, !dbg !1269
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1270
  store i64 1, i64* %2, align 8, !dbg !1270
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1270
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !1270
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !1270
  %6 = call i32 @k_sleep([1 x i64] %5) #3, !dbg !1270
  %7 = call i64 @k_uptime_delta(i64* @timestamp_check) #3, !dbg !1271
  store i64 %7, i64* @timestamp_check, align 8, !dbg !1272
  ret void, !dbg !1273
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sleep([1 x i64]) #0 !dbg !1274 {
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0
  %4 = bitcast i64* %3 to [1 x i64]*
  store [1 x i64] %0, [1 x i64]* %4, align 8
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %2, metadata !1277, metadata !DIExpression()), !dbg !1278
  br label %5, !dbg !1279

5:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !1280, !srcloc !1282
  br label %6, !dbg !1280

6:                                                ; preds = %5
  %7 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !1283
  %8 = bitcast i64* %7 to [1 x i64]*, !dbg !1283
  %9 = load [1 x i64], [1 x i64]* %8, align 8, !dbg !1283
  %10 = call i32 @z_impl_k_sleep([1 x i64] %9) #3, !dbg !1283
  ret i32 %10, !dbg !1284
}

declare dso_local i32 @z_impl_k_sleep([1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @dequtask() #0 !dbg !1285 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1287, metadata !DIExpression()), !dbg !1288
  call void @llvm.dbg.declare(metadata i32* %2, metadata !1289, metadata !DIExpression()), !dbg !1290
  store i32 0, i32* %2, align 4, !dbg !1291
  br label %5, !dbg !1293

5:                                                ; preds = %15, %0
  %6 = load i32, i32* %2, align 4, !dbg !1294
  %7 = icmp slt i32 %6, 500, !dbg !1296
  br i1 %7, label %8, label %18, !dbg !1297

8:                                                ; preds = %5
  %9 = bitcast i32* %1 to i8*, !dbg !1298
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !1300
  store i64 -1, i64* %10, align 8, !dbg !1300
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !1301
  %12 = bitcast i64* %11 to [1 x i64]*, !dbg !1301
  %13 = load [1 x i64], [1 x i64]* %12, align 8, !dbg !1301
  %14 = call i32 @k_msgq_get(%struct.k_msgq* @DEMOQX1, i8* %9, [1 x i64] %13), !dbg !1301
  br label %15, !dbg !1302

15:                                               ; preds = %8
  %16 = load i32, i32* %2, align 4, !dbg !1303
  %17 = add i32 %16, 1, !dbg !1303
  store i32 %17, i32* %2, align 4, !dbg !1303
  br label %5, !dbg !1304, !llvm.loop !1305

18:                                               ; preds = %5
  store i32 0, i32* %2, align 4, !dbg !1307
  br label %19, !dbg !1309

19:                                               ; preds = %29, %18
  %20 = load i32, i32* %2, align 4, !dbg !1310
  %21 = icmp slt i32 %20, 500, !dbg !1312
  br i1 %21, label %22, label %32, !dbg !1313

22:                                               ; preds = %19
  %23 = bitcast i32* %1 to i8*, !dbg !1314
  %24 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !1316
  store i64 -1, i64* %24, align 8, !dbg !1316
  %25 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %4, i32 0, i32 0, !dbg !1317
  %26 = bitcast i64* %25 to [1 x i64]*, !dbg !1317
  %27 = load [1 x i64], [1 x i64]* %26, align 8, !dbg !1317
  %28 = call i32 @k_msgq_get(%struct.k_msgq* @DEMOQX4, i8* %23, [1 x i64] %27), !dbg !1317
  br label %29, !dbg !1318

29:                                               ; preds = %22
  %30 = load i32, i32* %2, align 4, !dbg !1319
  %31 = add i32 %30, 1, !dbg !1319
  store i32 %31, i32* %2, align 4, !dbg !1319
  br label %19, !dbg !1320, !llvm.loop !1321

32:                                               ; preds = %19
  ret void, !dbg !1323
}

; Function Attrs: noinline nounwind optnone
define dso_local void @mailbox_test() #0 !dbg !1324 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.getinfo, align 4
  %6 = alloca %struct.k_timeout_t, align 8
  %7 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1325, metadata !DIExpression()), !dbg !1326
  call void @llvm.dbg.declare(metadata i32* %2, metadata !1327, metadata !DIExpression()), !dbg !1328
  call void @llvm.dbg.declare(metadata i32* %3, metadata !1329, metadata !DIExpression()), !dbg !1330
  call void @llvm.dbg.declare(metadata i32* %4, metadata !1331, metadata !DIExpression()), !dbg !1332
  call void @llvm.dbg.declare(metadata %struct.getinfo* %5, metadata !1333, metadata !DIExpression()), !dbg !1340
  %8 = load i32*, i32** @output_file, align 4, !dbg !1341
  %9 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.9, i32 0, i32 0), i32* %8) #3, !dbg !1341
  %10 = load i32*, i32** @output_file, align 4, !dbg !1342
  %11 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.1.10, i32 0, i32 0), i32* %10) #3, !dbg !1342
  %12 = load i32*, i32** @output_file, align 4, !dbg !1343
  %13 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.9, i32 0, i32 0), i32* %12) #3, !dbg !1343
  %14 = load i32*, i32** @output_file, align 4, !dbg !1344
  %15 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.2.11, i32 0, i32 0), i32* %14) #3, !dbg !1344
  %16 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @.str.3.12, i32 0, i32 0), i32 128) #3, !dbg !1345
  %17 = load i32*, i32** @output_file, align 4, !dbg !1345
  %18 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %17) #3, !dbg !1345
  %19 = load i32*, i32** @output_file, align 4, !dbg !1347
  %20 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.9, i32 0, i32 0), i32* %19) #3, !dbg !1347
  %21 = load i32*, i32** @output_file, align 4, !dbg !1348
  %22 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.4.13, i32 0, i32 0), i32* %21) #3, !dbg !1348
  %23 = load i32*, i32** @output_file, align 4, !dbg !1349
  %24 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.9, i32 0, i32 0), i32* %23) #3, !dbg !1349
  call void @k_sem_reset(%struct.k_sem* @SEM0) #3, !dbg !1350
  call void @k_sem_give(%struct.k_sem* @STARTRCV), !dbg !1351
  store i32 128, i32* %3, align 4, !dbg !1352
  store i32 0, i32* %1, align 4, !dbg !1353
  %25 = load i32, i32* %1, align 4, !dbg !1354
  %26 = load i32, i32* %3, align 4, !dbg !1355
  call void @mailbox_put(i32 %25, i32 %26, i32* %2) #3, !dbg !1356
  %27 = bitcast %struct.getinfo* %5 to i8*, !dbg !1357
  %28 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %6, i32 0, i32 0, !dbg !1358
  store i64 -1, i64* %28, align 8, !dbg !1358
  %29 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %6, i32 0, i32 0, !dbg !1359
  %30 = bitcast i64* %29 to [1 x i64]*, !dbg !1359
  %31 = load [1 x i64], [1 x i64]* %30, align 8, !dbg !1359
  %32 = call i32 @k_msgq_get(%struct.k_msgq* @MB_COMM, i8* %27, [1 x i64] %31), !dbg !1359
  %33 = load i32, i32* %1, align 4, !dbg !1360
  %34 = load i32, i32* %2, align 4, !dbg !1360
  %35 = load i32, i32* %1, align 4, !dbg !1360
  %36 = zext i32 %35 to i64, !dbg !1360
  %37 = mul i64 %36, 1000000, !dbg !1360
  %38 = load i32, i32* %2, align 4, !dbg !1360
  %39 = icmp ne i32 %38, 0, !dbg !1360
  br i1 %39, label %40, label %42, !dbg !1360

40:                                               ; preds = %0
  %41 = load i32, i32* %2, align 4, !dbg !1360
  br label %43, !dbg !1360

42:                                               ; preds = %0
  br label %43, !dbg !1360

43:                                               ; preds = %42, %40
  %44 = phi i32 [ %41, %40 ], [ 1, %42 ], !dbg !1360
  %45 = zext i32 %44 to i64, !dbg !1360
  %46 = udiv i64 %37, %45, !dbg !1360
  %47 = trunc i64 %46 to i32, !dbg !1360
  %48 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.5.16, i32 0, i32 0), i32 %33, i32 %34, i32 %47) #3, !dbg !1360
  %49 = load i32*, i32** @output_file, align 4, !dbg !1360
  %50 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %49) #3, !dbg !1360
  %51 = load i32, i32* %2, align 4, !dbg !1362
  store i32 %51, i32* %4, align 4, !dbg !1363
  store i32 8, i32* %1, align 4, !dbg !1364
  br label %52, !dbg !1366

52:                                               ; preds = %82, %43
  %53 = load i32, i32* %1, align 4, !dbg !1367
  %54 = icmp ule i32 %53, 4096, !dbg !1369
  br i1 %54, label %55, label %85, !dbg !1370

55:                                               ; preds = %52
  %56 = load i32, i32* %1, align 4, !dbg !1371
  %57 = load i32, i32* %3, align 4, !dbg !1373
  call void @mailbox_put(i32 %56, i32 %57, i32* %2) #3, !dbg !1374
  %58 = bitcast %struct.getinfo* %5 to i8*, !dbg !1375
  %59 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !1376
  store i64 -1, i64* %59, align 8, !dbg !1376
  %60 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !1377
  %61 = bitcast i64* %60 to [1 x i64]*, !dbg !1377
  %62 = load [1 x i64], [1 x i64]* %61, align 8, !dbg !1377
  %63 = call i32 @k_msgq_get(%struct.k_msgq* @MB_COMM, i8* %58, [1 x i64] %62), !dbg !1377
  %64 = load i32, i32* %1, align 4, !dbg !1378
  %65 = load i32, i32* %2, align 4, !dbg !1378
  %66 = load i32, i32* %1, align 4, !dbg !1378
  %67 = zext i32 %66 to i64, !dbg !1378
  %68 = mul i64 %67, 1000000, !dbg !1378
  %69 = load i32, i32* %2, align 4, !dbg !1378
  %70 = icmp ne i32 %69, 0, !dbg !1378
  br i1 %70, label %71, label %73, !dbg !1378

71:                                               ; preds = %55
  %72 = load i32, i32* %2, align 4, !dbg !1378
  br label %74, !dbg !1378

73:                                               ; preds = %55
  br label %74, !dbg !1378

74:                                               ; preds = %73, %71
  %75 = phi i32 [ %72, %71 ], [ 1, %73 ], !dbg !1378
  %76 = zext i32 %75 to i64, !dbg !1378
  %77 = udiv i64 %68, %76, !dbg !1378
  %78 = trunc i64 %77 to i32, !dbg !1378
  %79 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.5.16, i32 0, i32 0), i32 %64, i32 %65, i32 %78) #3, !dbg !1378
  %80 = load i32*, i32** @output_file, align 4, !dbg !1378
  %81 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %80) #3, !dbg !1378
  br label %82, !dbg !1380

82:                                               ; preds = %74
  %83 = load i32, i32* %1, align 4, !dbg !1381
  %84 = shl i32 %83, 1, !dbg !1381
  store i32 %84, i32* %1, align 4, !dbg !1381
  br label %52, !dbg !1382, !llvm.loop !1383

85:                                               ; preds = %52
  %86 = load i32*, i32** @output_file, align 4, !dbg !1385
  %87 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.9, i32 0, i32 0), i32* %86) #3, !dbg !1385
  %88 = load i32, i32* %4, align 4, !dbg !1386
  %89 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([75 x i8], [75 x i8]* @.str.6.17, i32 0, i32 0), i32 %88) #3, !dbg !1386
  %90 = load i32*, i32** @output_file, align 4, !dbg !1386
  %91 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %90) #3, !dbg !1386
  %92 = load i32, i32* %1, align 4, !dbg !1388
  %93 = lshr i32 %92, 1, !dbg !1388
  %94 = zext i32 %93 to i64, !dbg !1388
  %95 = mul i64 %94, 1000000, !dbg !1388
  %96 = load i32, i32* %2, align 4, !dbg !1388
  %97 = load i32, i32* %4, align 4, !dbg !1388
  %98 = sub i32 %96, %97, !dbg !1388
  %99 = icmp ne i32 %98, 0, !dbg !1388
  br i1 %99, label %100, label %104, !dbg !1388

100:                                              ; preds = %85
  %101 = load i32, i32* %2, align 4, !dbg !1388
  %102 = load i32, i32* %4, align 4, !dbg !1388
  %103 = sub i32 %101, %102, !dbg !1388
  br label %105, !dbg !1388

104:                                              ; preds = %85
  br label %105, !dbg !1388

105:                                              ; preds = %104, %100
  %106 = phi i32 [ %103, %100 ], [ 1, %104 ], !dbg !1388
  %107 = zext i32 %106 to i64, !dbg !1388
  %108 = udiv i64 %95, %107, !dbg !1388
  %109 = trunc i64 %108 to i32, !dbg !1388
  %110 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([75 x i8], [75 x i8]* @.str.7.18, i32 0, i32 0), i32 %109) #3, !dbg !1388
  %111 = load i32*, i32** @output_file, align 4, !dbg !1388
  %112 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %111) #3, !dbg !1388
  ret void, !dbg !1390
}

; Function Attrs: noinline nounwind optnone
define internal void @k_sem_reset(%struct.k_sem*) #0 !dbg !1391 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !1394, metadata !DIExpression()), !dbg !1395
  br label %3, !dbg !1396

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !1397, !srcloc !1399
  br label %4, !dbg !1397

4:                                                ; preds = %3
  %5 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !1400
  call void @z_impl_k_sem_reset(%struct.k_sem* %5) #3, !dbg !1401
  ret void, !dbg !1402
}

; Function Attrs: noinline nounwind optnone
define dso_local void @mailbox_put(i32, i32, i32*) #0 !dbg !1403 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32*, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca %struct.k_timeout_t, align 8
  store i32 %0, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !1407, metadata !DIExpression()), !dbg !1408
  store i32 %1, i32* %5, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !1409, metadata !DIExpression()), !dbg !1410
  store i32* %2, i32** %6, align 4
  call void @llvm.dbg.declare(metadata i32** %6, metadata !1411, metadata !DIExpression()), !dbg !1412
  call void @llvm.dbg.declare(metadata i32* %7, metadata !1413, metadata !DIExpression()), !dbg !1414
  call void @llvm.dbg.declare(metadata i32* %8, metadata !1415, metadata !DIExpression()), !dbg !1416
  store %struct.k_thread.30* null, %struct.k_thread.30** getelementptr inbounds (%struct.k_mbox_msg, %struct.k_mbox_msg* @message, i32 0, i32 6), align 4, !dbg !1417
  store %struct.k_thread.30* null, %struct.k_thread.30** getelementptr inbounds (%struct.k_mbox_msg, %struct.k_mbox_msg* @message, i32 0, i32 7), align 4, !dbg !1418
  call void @k_sem_give(%struct.k_sem* @SEM0), !dbg !1419
  %10 = call i32 @BENCH_START.19() #3, !dbg !1420
  store i32 %10, i32* %8, align 4, !dbg !1421
  store i32 0, i32* %7, align 4, !dbg !1422
  br label %11, !dbg !1424

11:                                               ; preds = %21, %3
  %12 = load i32, i32* %7, align 4, !dbg !1425
  %13 = load i32, i32* %5, align 4, !dbg !1427
  %14 = icmp slt i32 %12, %13, !dbg !1428
  br i1 %14, label %15, label %24, !dbg !1429

15:                                               ; preds = %11
  %16 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !1430
  store i64 -1, i64* %16, align 8, !dbg !1430
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !1432
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !1432
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !1432
  %20 = call i32 @k_mbox_put(%struct.k_mbox* @MAILB1, %struct.k_mbox_msg* @message, [1 x i64] %19) #3, !dbg !1432
  br label %21, !dbg !1433

21:                                               ; preds = %15
  %22 = load i32, i32* %7, align 4, !dbg !1434
  %23 = add i32 %22, 1, !dbg !1434
  store i32 %23, i32* %7, align 4, !dbg !1434
  br label %11, !dbg !1435, !llvm.loop !1436

24:                                               ; preds = %11
  %25 = load i32, i32* %8, align 4, !dbg !1438
  %26 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %25), !dbg !1439
  store i32 %26, i32* %8, align 4, !dbg !1440
  %27 = load i32, i32* %8, align 4, !dbg !1441
  %28 = zext i32 %27 to i64, !dbg !1441
  %29 = call i64 @k_cyc_to_ns_floor64.109(i64 %28), !dbg !1441
  %30 = load i32, i32* %5, align 4, !dbg !1441
  %31 = sext i32 %30 to i64, !dbg !1441
  %32 = udiv i64 %29, %31, !dbg !1441
  %33 = trunc i64 %32 to i32, !dbg !1441
  %34 = load i32*, i32** %6, align 4, !dbg !1442
  store i32 %33, i32* %34, align 4, !dbg !1443
  call void @check_result.22() #3, !dbg !1444
  ret void, !dbg !1445
}

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.19() #0 !dbg !1446 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1447, metadata !DIExpression()), !dbg !1448
  call void @bench_test_start.34() #3, !dbg !1449
  %2 = call i32 @TIME_STAMP_DELTA_GET.129(i32 0), !dbg !1450
  store i32 %2, i32* %1, align 4, !dbg !1451
  %3 = load i32, i32* %1, align 4, !dbg !1452
  ret i32 %3, !dbg !1453
}

declare dso_local i32 @k_mbox_put(%struct.k_mbox*, %struct.k_mbox_msg*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal void @check_result.22() #0 !dbg !1454 {
  %1 = call i32 @bench_test_end.23() #3, !dbg !1455
  %2 = icmp slt i32 %1, 0, !dbg !1457
  br i1 %2, label %3, label %7, !dbg !1458

3:                                                ; preds = %0
  %4 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([77 x i8], [77 x i8]* @.str.8.24, i32 0, i32 0), i32 187) #3, !dbg !1459
  %5 = load i32*, i32** @output_file, align 4, !dbg !1459
  %6 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %5) #3, !dbg !1459
  br label %7, !dbg !1462

7:                                                ; preds = %3, %0
  ret void, !dbg !1463
}

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.23() #0 !dbg !1464 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.138(i64* @timestamp_check.25), !dbg !1465
  store i64 %2, i64* @timestamp_check.25, align 8, !dbg !1466
  %3 = load i64, i64* @timestamp_check.25, align 8, !dbg !1467
  %4 = icmp sge i64 %3, 1000, !dbg !1469
  br i1 %4, label %5, label %6, !dbg !1470

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !1471
  br label %7, !dbg !1471

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !1473
  br label %7, !dbg !1473

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !1474
  ret i32 %8, !dbg !1474
}

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.34() #0 !dbg !1475 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.25, align 8, !dbg !1476
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1477
  store i64 1, i64* %2, align 8, !dbg !1477
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1477
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !1477
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !1477
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !1477
  %7 = call i64 @k_uptime_delta.138(i64* @timestamp_check.25), !dbg !1478
  store i64 %7, i64* @timestamp_check.25, align 8, !dbg !1479
  ret void, !dbg !1480
}

; Function Attrs: noinline nounwind optnone
define internal void @z_impl_k_sem_reset(%struct.k_sem*) #0 !dbg !1481 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !1482, metadata !DIExpression()), !dbg !1483
  %3 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !1484
  %4 = getelementptr inbounds %struct.k_sem, %struct.k_sem* %3, i32 0, i32 1, !dbg !1485
  store i32 0, i32* %4, align 4, !dbg !1486
  ret void, !dbg !1487
}

; Function Attrs: noinline nounwind optnone
define dso_local void @mailrecvtask() #0 !dbg !1488 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca %struct.getinfo, align 4
  %5 = alloca %struct.k_timeout_t, align 8
  %6 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1490, metadata !DIExpression()), !dbg !1491
  call void @llvm.dbg.declare(metadata i32* %2, metadata !1492, metadata !DIExpression()), !dbg !1493
  call void @llvm.dbg.declare(metadata i32* %3, metadata !1494, metadata !DIExpression()), !dbg !1495
  call void @llvm.dbg.declare(metadata %struct.getinfo* %4, metadata !1496, metadata !DIExpression()), !dbg !1502
  store i32 128, i32* %3, align 4, !dbg !1503
  store i32 0, i32* %1, align 4, !dbg !1504
  %7 = load i32, i32* %1, align 4, !dbg !1505
  %8 = load i32, i32* %3, align 4, !dbg !1506
  call void @mailbox_get(%struct.k_mbox* @MAILB1, i32 %7, i32 %8, i32* %2) #3, !dbg !1507
  %9 = load i32, i32* %2, align 4, !dbg !1508
  %10 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %4, i32 0, i32 1, !dbg !1509
  store i32 %9, i32* %10, align 4, !dbg !1510
  %11 = load i32, i32* %1, align 4, !dbg !1511
  %12 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %4, i32 0, i32 2, !dbg !1512
  store i32 %11, i32* %12, align 4, !dbg !1513
  %13 = load i32, i32* %3, align 4, !dbg !1514
  %14 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %4, i32 0, i32 0, !dbg !1515
  store i32 %13, i32* %14, align 4, !dbg !1516
  %15 = bitcast %struct.getinfo* %4 to i8*, !dbg !1517
  %16 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !1518
  store i64 -1, i64* %16, align 8, !dbg !1518
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !1519
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !1519
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !1519
  %20 = call i32 @k_msgq_put(%struct.k_msgq* @MB_COMM, i8* %15, [1 x i64] %19), !dbg !1519
  store i32 8, i32* %1, align 4, !dbg !1520
  br label %21, !dbg !1522

21:                                               ; preds = %39, %0
  %22 = load i32, i32* %1, align 4, !dbg !1523
  %23 = icmp sle i32 %22, 4096, !dbg !1525
  br i1 %23, label %24, label %42, !dbg !1526

24:                                               ; preds = %21
  %25 = load i32, i32* %1, align 4, !dbg !1527
  %26 = load i32, i32* %3, align 4, !dbg !1529
  call void @mailbox_get(%struct.k_mbox* @MAILB1, i32 %25, i32 %26, i32* %2) #3, !dbg !1530
  %27 = load i32, i32* %2, align 4, !dbg !1531
  %28 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %4, i32 0, i32 1, !dbg !1532
  store i32 %27, i32* %28, align 4, !dbg !1533
  %29 = load i32, i32* %1, align 4, !dbg !1534
  %30 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %4, i32 0, i32 2, !dbg !1535
  store i32 %29, i32* %30, align 4, !dbg !1536
  %31 = load i32, i32* %3, align 4, !dbg !1537
  %32 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %4, i32 0, i32 0, !dbg !1538
  store i32 %31, i32* %32, align 4, !dbg !1539
  %33 = bitcast %struct.getinfo* %4 to i8*, !dbg !1540
  %34 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %6, i32 0, i32 0, !dbg !1541
  store i64 -1, i64* %34, align 8, !dbg !1541
  %35 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %6, i32 0, i32 0, !dbg !1542
  %36 = bitcast i64* %35 to [1 x i64]*, !dbg !1542
  %37 = load [1 x i64], [1 x i64]* %36, align 8, !dbg !1542
  %38 = call i32 @k_msgq_put(%struct.k_msgq* @MB_COMM, i8* %33, [1 x i64] %37), !dbg !1542
  br label %39, !dbg !1543

39:                                               ; preds = %24
  %40 = load i32, i32* %1, align 4, !dbg !1544
  %41 = shl i32 %40, 1, !dbg !1544
  store i32 %41, i32* %1, align 4, !dbg !1544
  br label %21, !dbg !1545, !llvm.loop !1546

42:                                               ; preds = %21
  ret void, !dbg !1548
}

; Function Attrs: noinline nounwind optnone
define dso_local void @mailbox_get(%struct.k_mbox*, i32, i32, i32*) #0 !dbg !1549 {
  %5 = alloca %struct.k_mbox*, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32*, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca %struct.k_mbox_msg, align 4
  %13 = alloca %struct.k_timeout_t, align 8
  %14 = alloca %struct.k_timeout_t, align 8
  store %struct.k_mbox* %0, %struct.k_mbox** %5, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mbox** %5, metadata !1580, metadata !DIExpression()), !dbg !1581
  store i32 %1, i32* %6, align 4
  call void @llvm.dbg.declare(metadata i32* %6, metadata !1582, metadata !DIExpression()), !dbg !1583
  store i32 %2, i32* %7, align 4
  call void @llvm.dbg.declare(metadata i32* %7, metadata !1584, metadata !DIExpression()), !dbg !1585
  store i32* %3, i32** %8, align 4
  call void @llvm.dbg.declare(metadata i32** %8, metadata !1586, metadata !DIExpression()), !dbg !1587
  call void @llvm.dbg.declare(metadata i32* %9, metadata !1588, metadata !DIExpression()), !dbg !1589
  call void @llvm.dbg.declare(metadata i32* %10, metadata !1590, metadata !DIExpression()), !dbg !1591
  call void @llvm.dbg.declare(metadata i32* %11, metadata !1592, metadata !DIExpression()), !dbg !1593
  store i32 0, i32* %11, align 4, !dbg !1593
  call void @llvm.dbg.declare(metadata %struct.k_mbox_msg* %12, metadata !1594, metadata !DIExpression()), !dbg !1712
  %15 = getelementptr inbounds %struct.k_mbox_msg, %struct.k_mbox_msg* %12, i32 0, i32 6, !dbg !1713
  store %struct.k_thread.30* null, %struct.k_thread.30** %15, align 4, !dbg !1714
  %16 = load i32, i32* %6, align 4, !dbg !1715
  %17 = getelementptr inbounds %struct.k_mbox_msg, %struct.k_mbox_msg* %12, i32 0, i32 1, !dbg !1716
  store i32 %16, i32* %17, align 4, !dbg !1717
  %18 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %13, i32 0, i32 0, !dbg !1718
  store i64 -1, i64* %18, align 8, !dbg !1718
  %19 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %13, i32 0, i32 0, !dbg !1719
  %20 = bitcast i64* %19 to [1 x i64]*, !dbg !1719
  %21 = load [1 x i64], [1 x i64]* %20, align 8, !dbg !1719
  %22 = call i32 @k_sem_take(%struct.k_sem* @SEM0, [1 x i64] %21) #3, !dbg !1719
  %23 = call i32 @BENCH_START.37() #3, !dbg !1720
  store i32 %23, i32* %10, align 4, !dbg !1721
  store i32 0, i32* %9, align 4, !dbg !1722
  br label %24, !dbg !1724

24:                                               ; preds = %37, %4
  %25 = load i32, i32* %9, align 4, !dbg !1725
  %26 = load i32, i32* %7, align 4, !dbg !1727
  %27 = icmp slt i32 %25, %26, !dbg !1728
  br i1 %27, label %28, label %40, !dbg !1729

28:                                               ; preds = %24
  %29 = load %struct.k_mbox*, %struct.k_mbox** %5, align 4, !dbg !1730
  %30 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %14, i32 0, i32 0, !dbg !1732
  store i64 -1, i64* %30, align 8, !dbg !1732
  %31 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %14, i32 0, i32 0, !dbg !1733
  %32 = bitcast i64* %31 to [1 x i64]*, !dbg !1733
  %33 = load [1 x i64], [1 x i64]* %32, align 8, !dbg !1733
  %34 = call i32 @k_mbox_get(%struct.k_mbox* %29, %struct.k_mbox_msg* %12, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_recv, i32 0, i32 0), [1 x i64] %33) #3, !dbg !1733
  %35 = load i32, i32* %11, align 4, !dbg !1734
  %36 = or i32 %35, %34, !dbg !1734
  store i32 %36, i32* %11, align 4, !dbg !1734
  br label %37, !dbg !1735

37:                                               ; preds = %28
  %38 = load i32, i32* %9, align 4, !dbg !1736
  %39 = add i32 %38, 1, !dbg !1736
  store i32 %39, i32* %9, align 4, !dbg !1736
  br label %24, !dbg !1737, !llvm.loop !1738

40:                                               ; preds = %24
  %41 = load i32, i32* %10, align 4, !dbg !1740
  %42 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %41), !dbg !1741
  store i32 %42, i32* %10, align 4, !dbg !1742
  %43 = load i32, i32* %10, align 4, !dbg !1743
  %44 = zext i32 %43 to i64, !dbg !1743
  %45 = call i64 @k_cyc_to_ns_floor64.109(i64 %44), !dbg !1743
  %46 = load i32, i32* %7, align 4, !dbg !1743
  %47 = sext i32 %46 to i64, !dbg !1743
  %48 = udiv i64 %45, %47, !dbg !1743
  %49 = trunc i64 %48 to i32, !dbg !1743
  %50 = load i32*, i32** %8, align 4, !dbg !1744
  store i32 %49, i32* %50, align 4, !dbg !1745
  %51 = call i32 @bench_test_end.40() #3, !dbg !1746
  %52 = icmp slt i32 %51, 0, !dbg !1748
  br i1 %52, label %53, label %57, !dbg !1749

53:                                               ; preds = %40
  %54 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([80 x i8], [80 x i8]* @.str.41, i32 0, i32 0), i32 99) #3, !dbg !1750
  %55 = load i32*, i32** @output_file, align 4, !dbg !1750
  %56 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %55) #3, !dbg !1750
  br label %57, !dbg !1753

57:                                               ; preds = %53, %40
  %58 = load i32, i32* %11, align 4, !dbg !1754
  %59 = icmp ne i32 %58, 0, !dbg !1756
  br i1 %59, label %60, label %63, !dbg !1757

60:                                               ; preds = %57
  br label %61, !dbg !1758

61:                                               ; preds = %60
  call void asm sideeffect "eors.n r0, r0\0A\09msr BASEPRI, r0\0A\09mov r0, $0\0A\09svc $1\0A\09", "i,i,~{memory}"(i32 4, i32 2) #4, !dbg !1760, !srcloc !1762
  br label %62, !dbg !1760

62:                                               ; preds = %61
  br label %63, !dbg !1763

63:                                               ; preds = %62, %57
  ret void, !dbg !1764
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_sem_take(%struct.k_sem*, [1 x i64]) #0 !dbg !1765 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_sem*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_sem* %0, %struct.k_sem** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %4, metadata !1772, metadata !DIExpression()), !dbg !1773
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !1774, metadata !DIExpression()), !dbg !1775
  br label %7, !dbg !1776

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !1777, !srcloc !1779
  br label %8, !dbg !1777

8:                                                ; preds = %7
  %9 = load %struct.k_sem*, %struct.k_sem** %4, align 4, !dbg !1780
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !1781
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !1781
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !1781
  %13 = call i32 @z_impl_k_sem_take(%struct.k_sem* %9, [1 x i64] %12) #3, !dbg !1781
  ret i32 %13, !dbg !1782
}

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.37() #0 !dbg !1783 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1784, metadata !DIExpression()), !dbg !1785
  call void @bench_test_start.51() #3, !dbg !1786
  %2 = call i32 @TIME_STAMP_DELTA_GET.129(i32 0), !dbg !1787
  store i32 %2, i32* %1, align 4, !dbg !1788
  %3 = load i32, i32* %1, align 4, !dbg !1789
  ret i32 %3, !dbg !1790
}

declare dso_local i32 @k_mbox_get(%struct.k_mbox*, %struct.k_mbox_msg*, i8*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.40() #0 !dbg !1791 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.138(i64* @timestamp_check.42), !dbg !1792
  store i64 %2, i64* @timestamp_check.42, align 8, !dbg !1793
  %3 = load i64, i64* @timestamp_check.42, align 8, !dbg !1794
  %4 = icmp sge i64 %3, 1000, !dbg !1796
  br i1 %4, label %5, label %6, !dbg !1797

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !1798
  br label %7, !dbg !1798

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !1800
  br label %7, !dbg !1800

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !1801
  ret i32 %8, !dbg !1801
}

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.51() #0 !dbg !1802 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.42, align 8, !dbg !1803
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1804
  store i64 1, i64* %2, align 8, !dbg !1804
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1804
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !1804
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !1804
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !1804
  %7 = call i64 @k_uptime_delta.138(i64* @timestamp_check.42), !dbg !1805
  store i64 %7, i64* @timestamp_check.42, align 8, !dbg !1806
  ret void, !dbg !1807
}

declare dso_local i32 @z_impl_k_sem_take(%struct.k_sem*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define dso_local i32 @kbhit() #0 !dbg !1808 {
  ret i32 0, !dbg !1809
}

; Function Attrs: noinline nounwind optnone
define dso_local void @init_output(i32*, i32*) #0 !dbg !1810 {
  %3 = alloca i32*, align 4
  %4 = alloca i32*, align 4
  store i32* %0, i32** %3, align 4
  call void @llvm.dbg.declare(metadata i32** %3, metadata !1814, metadata !DIExpression()), !dbg !1815
  store i32* %1, i32** %4, align 4
  call void @llvm.dbg.declare(metadata i32** %4, metadata !1816, metadata !DIExpression()), !dbg !1817
  %5 = load i32*, i32** %3, align 4, !dbg !1818
  %6 = load i32*, i32** %4, align 4, !dbg !1819
  store i32* inttoptr (i32 2 to i32*), i32** @output_file, align 4, !dbg !1820
  ret void, !dbg !1821
}

; Function Attrs: noinline nounwind optnone
define dso_local void @output_close() #0 !dbg !1822 {
  ret void, !dbg !1823
}

; Function Attrs: noinline nounwind optnone
define dso_local void @main() #0 !dbg !1824 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1825, metadata !DIExpression()), !dbg !1826
  store i32 0, i32* %1, align 4, !dbg !1826
  call void @llvm.dbg.declare(metadata i32* %2, metadata !1827, metadata !DIExpression()), !dbg !1828
  store i32 0, i32* %2, align 4, !dbg !1828
  call void @init_output(i32* %2, i32* %1) #3, !dbg !1829
  call void @bench_test_init() #3, !dbg !1830
  %3 = load i32*, i32** @output_file, align 4, !dbg !1831
  %4 = call i32 @fputs(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @newline, i32 0, i32 0), i32* %3) #3, !dbg !1831
  br label %5, !dbg !1832

5:                                                ; preds = %27, %0
  %6 = load i32*, i32** @output_file, align 4, !dbg !1833
  %7 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.1.74, i32 0, i32 0), i32* %6) #3, !dbg !1833
  %8 = load i32*, i32** @output_file, align 4, !dbg !1835
  %9 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.2.75, i32 0, i32 0), i32* %8) #3, !dbg !1835
  %10 = load i32*, i32** @output_file, align 4, !dbg !1836
  %11 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.1.74, i32 0, i32 0), i32* %10) #3, !dbg !1836
  call void @queue_test() #3, !dbg !1837
  call void @sema_test() #3, !dbg !1838
  call void @mutex_test() #3, !dbg !1839
  call void @memorymap_test() #3, !dbg !1840
  call void @mempool_test() #3, !dbg !1841
  call void @mailbox_test() #3, !dbg !1842
  call void @pipe_test() #3, !dbg !1843
  %12 = load i32*, i32** @output_file, align 4, !dbg !1844
  %13 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.3.76, i32 0, i32 0), i32* %12) #3, !dbg !1844
  %14 = load i32*, i32** @output_file, align 4, !dbg !1845
  %15 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.1.74, i32 0, i32 0), i32* %14) #3, !dbg !1845
  %16 = load i32*, i32** @output_file, align 4, !dbg !1846
  %17 = call i32 @fputs(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.4.77, i32 0, i32 0), i32* %16) #3, !dbg !1846
  br label %18, !dbg !1847

18:                                               ; preds = %5
  br label %19, !dbg !1848

19:                                               ; preds = %18
  br label %20, !dbg !1850

20:                                               ; preds = %19
  %21 = load i32, i32* %2, align 4, !dbg !1851
  %22 = icmp ne i32 %21, 0, !dbg !1851
  br i1 %22, label %23, label %27, !dbg !1852

23:                                               ; preds = %20
  %24 = call i32 @kbhit() #3, !dbg !1853
  %25 = icmp ne i32 %24, 0, !dbg !1854
  %26 = xor i1 %25, true, !dbg !1854
  br label %27

27:                                               ; preds = %23, %20
  %28 = phi i1 [ false, %20 ], [ %26, %23 ], !dbg !1855
  br i1 %28, label %5, label %29, !dbg !1850, !llvm.loop !1856

29:                                               ; preds = %27
  call void @k_thread_abort(%struct.k_thread.82* @_k_thread_obj_RECVTASK) #3, !dbg !1858
  call void @dummy_test(), !dbg !1859
  ret void, !dbg !1860
}

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_init() #0 !dbg !1861 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1862, metadata !DIExpression()), !dbg !1863
  %2 = call i32 @k_cycle_get_32.121(), !dbg !1864
  store i32 %2, i32* %1, align 4, !dbg !1863
  %3 = call i32 @k_cycle_get_32.121(), !dbg !1865
  %4 = load i32, i32* %1, align 4, !dbg !1866
  %5 = sub i32 %3, %4, !dbg !1867
  store i32 %5, i32* @tm_off, align 4, !dbg !1868
  ret void, !dbg !1869
}

; Function Attrs: noinline nounwind optnone
define internal void @k_thread_abort(%struct.k_thread.82*) #0 !dbg !1870 {
  %2 = alloca %struct.k_thread.82*, align 4
  store %struct.k_thread.82* %0, %struct.k_thread.82** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread.82** %2, metadata !1873, metadata !DIExpression()), !dbg !1874
  br label %3, !dbg !1875

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !1876, !srcloc !1878
  br label %4, !dbg !1876

4:                                                ; preds = %3
  %5 = load %struct.k_thread.82*, %struct.k_thread.82** %2, align 4, !dbg !1879
  call void @z_impl_k_thread_abort(%struct.k_thread.82* %5) #3, !dbg !1880
  ret void, !dbg !1881
}

declare dso_local void @z_impl_k_thread_abort(%struct.k_thread.82*) #2

; Function Attrs: noinline nounwind optnone
define dso_local void @dummy_test() #0 !dbg !1882 {
  ret void, !dbg !1883
}

; Function Attrs: noinline nounwind optnone
define dso_local void @memorymap_test() #0 !dbg !1884 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8*, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1886, metadata !DIExpression()), !dbg !1887
  call void @llvm.dbg.declare(metadata i32* %2, metadata !1888, metadata !DIExpression()), !dbg !1889
  call void @llvm.dbg.declare(metadata i8** %3, metadata !1890, metadata !DIExpression()), !dbg !1891
  call void @llvm.dbg.declare(metadata i32* %4, metadata !1892, metadata !DIExpression()), !dbg !1893
  %6 = load i32*, i32** @output_file, align 4, !dbg !1894
  %7 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.82, i32 0, i32 0), i32* %6) #3, !dbg !1894
  %8 = call i32 @BENCH_START.83() #3, !dbg !1895
  store i32 %8, i32* %1, align 4, !dbg !1896
  store i32 0, i32* %2, align 4, !dbg !1897
  br label %9, !dbg !1899

9:                                                ; preds = %26, %0
  %10 = load i32, i32* %2, align 4, !dbg !1900
  %11 = icmp slt i32 %10, 1000, !dbg !1902
  br i1 %11, label %12, label %29, !dbg !1903

12:                                               ; preds = %9
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !1904
  store i64 -1, i64* %13, align 8, !dbg !1904
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !1906
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !1906
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !1906
  %17 = call i32 @k_mem_slab_alloc(%struct.k_mem_slab* @MAP1, i8** %3, [1 x i64] %16) #3, !dbg !1906
  store i32 %17, i32* %4, align 4, !dbg !1907
  %18 = load i32, i32* %4, align 4, !dbg !1908
  %19 = icmp ne i32 %18, 0, !dbg !1910
  br i1 %19, label %20, label %25, !dbg !1911

20:                                               ; preds = %12
  %21 = load i32, i32* %4, align 4, !dbg !1912
  %22 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1.84, i32 0, i32 0), i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.2.85, i32 0, i32 0), i32 %21) #3, !dbg !1912
  %23 = load i32*, i32** @output_file, align 4, !dbg !1912
  %24 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %23) #3, !dbg !1912
  br label %29, !dbg !1915

25:                                               ; preds = %12
  call void @k_mem_slab_free(%struct.k_mem_slab* @MAP1, i8** %3) #3, !dbg !1916
  br label %26, !dbg !1917

26:                                               ; preds = %25
  %27 = load i32, i32* %2, align 4, !dbg !1918
  %28 = add i32 %27, 1, !dbg !1918
  store i32 %28, i32* %2, align 4, !dbg !1918
  br label %9, !dbg !1919, !llvm.loop !1920

29:                                               ; preds = %20, %9
  %30 = load i32, i32* %1, align 4, !dbg !1922
  %31 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %30), !dbg !1923
  store i32 %31, i32* %1, align 4, !dbg !1924
  call void @check_result.87() #3, !dbg !1925
  %32 = load i32, i32* %1, align 4, !dbg !1926
  %33 = zext i32 %32 to i64, !dbg !1926
  %34 = call i64 @k_cyc_to_ns_floor64.109(i64 %33), !dbg !1926
  %35 = udiv i64 %34, 2000, !dbg !1926
  %36 = trunc i64 %35 to i32, !dbg !1926
  %37 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1.84, i32 0, i32 0), i8* getelementptr inbounds ([38 x i8], [38 x i8]* @.str.3.89, i32 0, i32 0), i32 %36) #3, !dbg !1926
  %38 = load i32*, i32** @output_file, align 4, !dbg !1926
  %39 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %38) #3, !dbg !1926
  ret void, !dbg !1928
}

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.83() #0 !dbg !1929 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1930, metadata !DIExpression()), !dbg !1931
  call void @bench_test_start.101() #3, !dbg !1932
  %2 = call i32 @TIME_STAMP_DELTA_GET.129(i32 0), !dbg !1933
  store i32 %2, i32* %1, align 4, !dbg !1934
  %3 = load i32, i32* %1, align 4, !dbg !1935
  ret i32 %3, !dbg !1936
}

declare dso_local i32 @k_mem_slab_alloc(%struct.k_mem_slab*, i8**, [1 x i64]) #2

declare dso_local void @k_mem_slab_free(%struct.k_mem_slab*, i8**) #2

; Function Attrs: noinline nounwind optnone
define internal void @check_result.87() #0 !dbg !1937 {
  %1 = call i32 @bench_test_end.91() #3, !dbg !1938
  %2 = icmp slt i32 %1, 0, !dbg !1940
  br i1 %2, label %3, label %7, !dbg !1941

3:                                                ; preds = %0
  %4 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([77 x i8], [77 x i8]* @.str.4.92, i32 0, i32 0), i32 187) #3, !dbg !1942
  %5 = load i32*, i32** @output_file, align 4, !dbg !1942
  %6 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %5) #3, !dbg !1942
  br label %7, !dbg !1945

7:                                                ; preds = %3, %0
  ret void, !dbg !1946
}

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.91() #0 !dbg !1947 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.138(i64* @timestamp_check.93), !dbg !1948
  store i64 %2, i64* @timestamp_check.93, align 8, !dbg !1949
  %3 = load i64, i64* @timestamp_check.93, align 8, !dbg !1950
  %4 = icmp sge i64 %3, 1000, !dbg !1952
  br i1 %4, label %5, label %6, !dbg !1953

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !1954
  br label %7, !dbg !1954

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !1956
  br label %7, !dbg !1956

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !1957
  ret i32 %8, !dbg !1957
}

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.101() #0 !dbg !1958 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.93, align 8, !dbg !1959
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1960
  store i64 1, i64* %2, align 8, !dbg !1960
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !1960
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !1960
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !1960
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !1960
  %7 = call i64 @k_uptime_delta.138(i64* @timestamp_check.93), !dbg !1961
  store i64 %7, i64* @timestamp_check.93, align 8, !dbg !1962
  ret void, !dbg !1963
}

; Function Attrs: noinline nounwind optnone
define dso_local void @mempool_test() #0 !dbg !1964 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca %struct.k_mem_block.152, align 4
  %5 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !1966, metadata !DIExpression()), !dbg !1967
  call void @llvm.dbg.declare(metadata i32* %2, metadata !1968, metadata !DIExpression()), !dbg !1969
  call void @llvm.dbg.declare(metadata i32* %3, metadata !1970, metadata !DIExpression()), !dbg !1971
  store i32 0, i32* %3, align 4, !dbg !1971
  call void @llvm.dbg.declare(metadata %struct.k_mem_block.152* %4, metadata !1972, metadata !DIExpression()), !dbg !2016
  %6 = load i32*, i32** @output_file, align 4, !dbg !2017
  %7 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.105, i32 0, i32 0), i32* %6) #3, !dbg !2017
  %8 = call i32 @BENCH_START.106() #3, !dbg !2018
  store i32 %8, i32* %1, align 4, !dbg !2019
  store i32 0, i32* %2, align 4, !dbg !2020
  br label %9, !dbg !2022

9:                                                ; preds = %20, %0
  %10 = load i32, i32* %2, align 4, !dbg !2023
  %11 = icmp slt i32 %10, 1000, !dbg !2025
  br i1 %11, label %12, label %23, !dbg !2026

12:                                               ; preds = %9
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !2027
  store i64 -1, i64* %13, align 8, !dbg !2027
  %14 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %5, i32 0, i32 0, !dbg !2029
  %15 = bitcast i64* %14 to [1 x i64]*, !dbg !2029
  %16 = load [1 x i64], [1 x i64]* %15, align 8, !dbg !2029
  %17 = call i32 @k_mem_pool_alloc(%struct.k_mem_pool.86* @DEMOPOOL, %struct.k_mem_block.152* %4, i32 16, [1 x i64] %16) #3, !dbg !2029
  %18 = load i32, i32* %3, align 4, !dbg !2030
  %19 = or i32 %18, %17, !dbg !2030
  store i32 %19, i32* %3, align 4, !dbg !2030
  call void @k_mem_pool_free(%struct.k_mem_block.152* %4) #3, !dbg !2031
  br label %20, !dbg !2032

20:                                               ; preds = %12
  %21 = load i32, i32* %2, align 4, !dbg !2033
  %22 = add i32 %21, 1, !dbg !2033
  store i32 %22, i32* %2, align 4, !dbg !2033
  br label %9, !dbg !2034, !llvm.loop !2035

23:                                               ; preds = %9
  %24 = load i32, i32* %1, align 4, !dbg !2037
  %25 = call i32 @TIME_STAMP_DELTA_GET.107(i32 %24) #3, !dbg !2038
  store i32 %25, i32* %1, align 4, !dbg !2039
  call void @check_result.108() #3, !dbg !2040
  %26 = load i32, i32* %3, align 4, !dbg !2041
  %27 = icmp ne i32 %26, 0, !dbg !2043
  br i1 %27, label %28, label %31, !dbg !2044

28:                                               ; preds = %23
  br label %29, !dbg !2045

29:                                               ; preds = %28
  call void asm sideeffect "eors.n r0, r0\0A\09msr BASEPRI, r0\0A\09mov r0, $0\0A\09svc $1\0A\09", "i,i,~{memory}"(i32 4, i32 2) #4, !dbg !2047, !srcloc !2049
  br label %30, !dbg !2047

30:                                               ; preds = %29
  br label %31, !dbg !2050

31:                                               ; preds = %30, %23
  %32 = load i32, i32* %1, align 4, !dbg !2051
  %33 = zext i32 %32 to i64, !dbg !2051
  %34 = call i64 @k_cyc_to_ns_floor64.109(i64 %33) #3, !dbg !2051
  %35 = udiv i64 %34, 2000, !dbg !2051
  %36 = trunc i64 %35 to i32, !dbg !2051
  %37 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1.110, i32 0, i32 0), i8* getelementptr inbounds ([44 x i8], [44 x i8]* @.str.2.111, i32 0, i32 0), i32 %36) #3, !dbg !2051
  %38 = load i32*, i32** @output_file, align 4, !dbg !2051
  %39 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %38) #3, !dbg !2051
  ret void, !dbg !2053
}

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.106() #0 !dbg !2054 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !2055, metadata !DIExpression()), !dbg !2056
  call void @bench_test_start.123() #3, !dbg !2057
  %2 = call i32 @TIME_STAMP_DELTA_GET.107(i32 0) #3, !dbg !2058
  store i32 %2, i32* %1, align 4, !dbg !2059
  %3 = load i32, i32* %1, align 4, !dbg !2060
  ret i32 %3, !dbg !2061
}

declare dso_local i32 @k_mem_pool_alloc(%struct.k_mem_pool.86*, %struct.k_mem_block.152*, i32, [1 x i64]) #2

declare dso_local void @k_mem_pool_free(%struct.k_mem_block.152*) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @TIME_STAMP_DELTA_GET.107(i32) #0 !dbg !2062 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !2063, metadata !DIExpression()), !dbg !2064
  call void @llvm.dbg.declare(metadata i32* %3, metadata !2065, metadata !DIExpression()), !dbg !2066
  call void @timestamp_serialize(), !dbg !2067
  %5 = call i32 @k_cycle_get_32.121() #3, !dbg !2068
  store i32 %5, i32* %3, align 4, !dbg !2069
  call void @llvm.dbg.declare(metadata i32* %4, metadata !2070, metadata !DIExpression()), !dbg !2071
  %6 = load i32, i32* %3, align 4, !dbg !2072
  %7 = load i32, i32* %2, align 4, !dbg !2073
  %8 = icmp uge i32 %6, %7, !dbg !2074
  br i1 %8, label %9, label %13, !dbg !2075

9:                                                ; preds = %1
  %10 = load i32, i32* %3, align 4, !dbg !2076
  %11 = load i32, i32* %2, align 4, !dbg !2077
  %12 = sub i32 %10, %11, !dbg !2078
  br label %18, !dbg !2075

13:                                               ; preds = %1
  %14 = load i32, i32* %2, align 4, !dbg !2079
  %15 = sub i32 -1, %14, !dbg !2080
  %16 = load i32, i32* %3, align 4, !dbg !2081
  %17 = add i32 %15, %16, !dbg !2082
  br label %18, !dbg !2075

18:                                               ; preds = %13, %9
  %19 = phi i32 [ %12, %9 ], [ %17, %13 ], !dbg !2075
  store i32 %19, i32* %4, align 4, !dbg !2071
  %20 = load i32, i32* %2, align 4, !dbg !2083
  %21 = icmp ugt i32 %20, 0, !dbg !2085
  br i1 %21, label %22, label %26, !dbg !2086

22:                                               ; preds = %18
  %23 = load i32, i32* @tm_off, align 4, !dbg !2087
  %24 = load i32, i32* %4, align 4, !dbg !2089
  %25 = sub i32 %24, %23, !dbg !2089
  store i32 %25, i32* %4, align 4, !dbg !2089
  br label %26, !dbg !2090

26:                                               ; preds = %22, %18
  %27 = load i32, i32* %4, align 4, !dbg !2091
  ret i32 %27, !dbg !2092
}

; Function Attrs: noinline nounwind optnone
define internal void @check_result.108() #0 !dbg !2093 {
  %1 = call i32 @bench_test_end.113() #3, !dbg !2094
  %2 = icmp slt i32 %1, 0, !dbg !2096
  br i1 %2, label %3, label %7, !dbg !2097

3:                                                ; preds = %0
  %4 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([77 x i8], [77 x i8]* @.str.3.114, i32 0, i32 0), i32 187) #3, !dbg !2098
  %5 = load i32*, i32** @output_file, align 4, !dbg !2098
  %6 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %5) #3, !dbg !2098
  br label %7, !dbg !2101

7:                                                ; preds = %3, %0
  ret void, !dbg !2102
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_cyc_to_ns_floor64.109(i64) #0 !dbg !2103 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !2104, metadata !DIExpression()), !dbg !2106
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !2108, metadata !DIExpression()), !dbg !2109
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !2110, metadata !DIExpression()), !dbg !2111
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !2112, metadata !DIExpression()), !dbg !2113
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !2114, metadata !DIExpression()), !dbg !2115
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !2116, metadata !DIExpression()), !dbg !2117
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !2118, metadata !DIExpression()), !dbg !2119
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !2120, metadata !DIExpression()), !dbg !2121
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !2122, metadata !DIExpression()), !dbg !2123
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !2124, metadata !DIExpression()), !dbg !2125
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !2126, metadata !DIExpression()), !dbg !2129
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !2130, metadata !DIExpression()), !dbg !2131
  %15 = load i64, i64* %14, align 8, !dbg !2132
  %16 = call i32 @sys_clock_hw_cycles_per_sec(), !dbg !2133
  store i64 %15, i64* %3, align 8
  store i32 %16, i32* %4, align 4
  store i32 1000000000, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 0, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %17 = load i8, i8* %6, align 1, !dbg !2134
  %18 = trunc i8 %17 to i1, !dbg !2134
  br i1 %18, label %19, label %28, !dbg !2135

19:                                               ; preds = %1
  %20 = load i32, i32* %5, align 4, !dbg !2136
  %21 = load i32, i32* %4, align 4, !dbg !2137
  %22 = icmp ugt i32 %20, %21, !dbg !2138
  br i1 %22, label %23, label %28, !dbg !2139

23:                                               ; preds = %19
  %24 = load i32, i32* %5, align 4, !dbg !2140
  %25 = load i32, i32* %4, align 4, !dbg !2141
  %26 = urem i32 %24, %25, !dbg !2142
  %27 = icmp eq i32 %26, 0, !dbg !2143
  br label %28

28:                                               ; preds = %23, %19, %1
  %29 = phi i1 [ false, %19 ], [ false, %1 ], [ %27, %23 ], !dbg !2144
  %30 = zext i1 %29 to i8, !dbg !2121
  store i8 %30, i8* %10, align 1, !dbg !2121
  %31 = load i8, i8* %6, align 1, !dbg !2145
  %32 = trunc i8 %31 to i1, !dbg !2145
  br i1 %32, label %33, label %42, !dbg !2146

33:                                               ; preds = %28
  %34 = load i32, i32* %4, align 4, !dbg !2147
  %35 = load i32, i32* %5, align 4, !dbg !2148
  %36 = icmp ugt i32 %34, %35, !dbg !2149
  br i1 %36, label %37, label %42, !dbg !2150

37:                                               ; preds = %33
  %38 = load i32, i32* %4, align 4, !dbg !2151
  %39 = load i32, i32* %5, align 4, !dbg !2152
  %40 = urem i32 %38, %39, !dbg !2153
  %41 = icmp eq i32 %40, 0, !dbg !2154
  br label %42

42:                                               ; preds = %37, %33, %28
  %43 = phi i1 [ false, %33 ], [ false, %28 ], [ %41, %37 ], !dbg !2144
  %44 = zext i1 %43 to i8, !dbg !2123
  store i8 %44, i8* %11, align 1, !dbg !2123
  %45 = load i32, i32* %4, align 4, !dbg !2155
  %46 = load i32, i32* %5, align 4, !dbg !2157
  %47 = icmp eq i32 %45, %46, !dbg !2158
  br i1 %47, label %48, label %59, !dbg !2159

48:                                               ; preds = %42
  %49 = load i8, i8* %7, align 1, !dbg !2160
  %50 = trunc i8 %49 to i1, !dbg !2160
  br i1 %50, label %51, label %55, !dbg !2160

51:                                               ; preds = %48
  %52 = load i64, i64* %3, align 8, !dbg !2162
  %53 = trunc i64 %52 to i32, !dbg !2163
  %54 = zext i32 %53 to i64, !dbg !2164
  br label %57, !dbg !2160

55:                                               ; preds = %48
  %56 = load i64, i64* %3, align 8, !dbg !2165
  br label %57, !dbg !2160

57:                                               ; preds = %55, %51
  %58 = phi i64 [ %54, %51 ], [ %56, %55 ], !dbg !2160
  store i64 %58, i64* %2, align 8, !dbg !2166
  br label %161, !dbg !2166

59:                                               ; preds = %42
  store i64 0, i64* %12, align 8, !dbg !2125
  %60 = load i8, i8* %10, align 1, !dbg !2167
  %61 = trunc i8 %60 to i1, !dbg !2167
  br i1 %61, label %88, label %62, !dbg !2168

62:                                               ; preds = %59
  %63 = load i8, i8* %11, align 1, !dbg !2169
  %64 = trunc i8 %63 to i1, !dbg !2169
  br i1 %64, label %65, label %69, !dbg !2169

65:                                               ; preds = %62
  %66 = load i32, i32* %4, align 4, !dbg !2170
  %67 = load i32, i32* %5, align 4, !dbg !2171
  %68 = udiv i32 %66, %67, !dbg !2172
  br label %71, !dbg !2169

69:                                               ; preds = %62
  %70 = load i32, i32* %4, align 4, !dbg !2173
  br label %71, !dbg !2169

71:                                               ; preds = %69, %65
  %72 = phi i32 [ %68, %65 ], [ %70, %69 ], !dbg !2169
  store i32 %72, i32* %13, align 4, !dbg !2129
  %73 = load i8, i8* %8, align 1, !dbg !2174
  %74 = trunc i8 %73 to i1, !dbg !2174
  br i1 %74, label %75, label %79, !dbg !2176

75:                                               ; preds = %71
  %76 = load i32, i32* %13, align 4, !dbg !2177
  %77 = sub i32 %76, 1, !dbg !2179
  %78 = zext i32 %77 to i64, !dbg !2177
  store i64 %78, i64* %12, align 8, !dbg !2180
  br label %87, !dbg !2181

79:                                               ; preds = %71
  %80 = load i8, i8* %9, align 1, !dbg !2182
  %81 = trunc i8 %80 to i1, !dbg !2182
  br i1 %81, label %82, label %86, !dbg !2184

82:                                               ; preds = %79
  %83 = load i32, i32* %13, align 4, !dbg !2185
  %84 = udiv i32 %83, 2, !dbg !2187
  %85 = zext i32 %84 to i64, !dbg !2185
  store i64 %85, i64* %12, align 8, !dbg !2188
  br label %86, !dbg !2189

86:                                               ; preds = %82, %79
  br label %87

87:                                               ; preds = %86, %75
  br label %88, !dbg !2190

88:                                               ; preds = %87, %59
  %89 = load i8, i8* %11, align 1, !dbg !2191
  %90 = trunc i8 %89 to i1, !dbg !2191
  br i1 %90, label %91, label %115, !dbg !2193

91:                                               ; preds = %88
  %92 = load i64, i64* %12, align 8, !dbg !2194
  %93 = load i64, i64* %3, align 8, !dbg !2196
  %94 = add i64 %93, %92, !dbg !2196
  store i64 %94, i64* %3, align 8, !dbg !2196
  %95 = load i8, i8* %7, align 1, !dbg !2197
  %96 = trunc i8 %95 to i1, !dbg !2197
  br i1 %96, label %97, label %108, !dbg !2199

97:                                               ; preds = %91
  %98 = load i64, i64* %3, align 8, !dbg !2200
  %99 = icmp ult i64 %98, 4294967296, !dbg !2201
  br i1 %99, label %100, label %108, !dbg !2202

100:                                              ; preds = %97
  %101 = load i64, i64* %3, align 8, !dbg !2203
  %102 = trunc i64 %101 to i32, !dbg !2205
  %103 = load i32, i32* %4, align 4, !dbg !2206
  %104 = load i32, i32* %5, align 4, !dbg !2207
  %105 = udiv i32 %103, %104, !dbg !2208
  %106 = udiv i32 %102, %105, !dbg !2209
  %107 = zext i32 %106 to i64, !dbg !2210
  store i64 %107, i64* %2, align 8, !dbg !2211
  br label %161, !dbg !2211

108:                                              ; preds = %97, %91
  %109 = load i64, i64* %3, align 8, !dbg !2212
  %110 = load i32, i32* %4, align 4, !dbg !2214
  %111 = load i32, i32* %5, align 4, !dbg !2215
  %112 = udiv i32 %110, %111, !dbg !2216
  %113 = zext i32 %112 to i64, !dbg !2217
  %114 = udiv i64 %109, %113, !dbg !2218
  store i64 %114, i64* %2, align 8, !dbg !2219
  br label %161, !dbg !2219

115:                                              ; preds = %88
  %116 = load i8, i8* %10, align 1, !dbg !2220
  %117 = trunc i8 %116 to i1, !dbg !2220
  br i1 %117, label %118, label %136, !dbg !2222

118:                                              ; preds = %115
  %119 = load i8, i8* %7, align 1, !dbg !2223
  %120 = trunc i8 %119 to i1, !dbg !2223
  br i1 %120, label %121, label %129, !dbg !2226

121:                                              ; preds = %118
  %122 = load i64, i64* %3, align 8, !dbg !2227
  %123 = trunc i64 %122 to i32, !dbg !2229
  %124 = load i32, i32* %5, align 4, !dbg !2230
  %125 = load i32, i32* %4, align 4, !dbg !2231
  %126 = udiv i32 %124, %125, !dbg !2232
  %127 = mul i32 %123, %126, !dbg !2233
  %128 = zext i32 %127 to i64, !dbg !2234
  store i64 %128, i64* %2, align 8, !dbg !2235
  br label %161, !dbg !2235

129:                                              ; preds = %118
  %130 = load i64, i64* %3, align 8, !dbg !2236
  %131 = load i32, i32* %5, align 4, !dbg !2238
  %132 = load i32, i32* %4, align 4, !dbg !2239
  %133 = udiv i32 %131, %132, !dbg !2240
  %134 = zext i32 %133 to i64, !dbg !2241
  %135 = mul i64 %130, %134, !dbg !2242
  store i64 %135, i64* %2, align 8, !dbg !2243
  br label %161, !dbg !2243

136:                                              ; preds = %115
  %137 = load i8, i8* %7, align 1, !dbg !2244
  %138 = trunc i8 %137 to i1, !dbg !2244
  br i1 %138, label %139, label %151, !dbg !2247

139:                                              ; preds = %136
  %140 = load i64, i64* %3, align 8, !dbg !2248
  %141 = load i32, i32* %5, align 4, !dbg !2250
  %142 = zext i32 %141 to i64, !dbg !2250
  %143 = mul i64 %140, %142, !dbg !2251
  %144 = load i64, i64* %12, align 8, !dbg !2252
  %145 = add i64 %143, %144, !dbg !2253
  %146 = load i32, i32* %4, align 4, !dbg !2254
  %147 = zext i32 %146 to i64, !dbg !2254
  %148 = udiv i64 %145, %147, !dbg !2255
  %149 = trunc i64 %148 to i32, !dbg !2256
  %150 = zext i32 %149 to i64, !dbg !2256
  store i64 %150, i64* %2, align 8, !dbg !2257
  br label %161, !dbg !2257

151:                                              ; preds = %136
  %152 = load i64, i64* %3, align 8, !dbg !2258
  %153 = load i32, i32* %5, align 4, !dbg !2260
  %154 = zext i32 %153 to i64, !dbg !2260
  %155 = mul i64 %152, %154, !dbg !2261
  %156 = load i64, i64* %12, align 8, !dbg !2262
  %157 = add i64 %155, %156, !dbg !2263
  %158 = load i32, i32* %4, align 4, !dbg !2264
  %159 = zext i32 %158 to i64, !dbg !2264
  %160 = udiv i64 %157, %159, !dbg !2265
  store i64 %160, i64* %2, align 8, !dbg !2266
  br label %161, !dbg !2266

161:                                              ; preds = %151, %139, %129, %121, %108, %100, %57
  %162 = load i64, i64* %2, align 8, !dbg !2267
  ret i64 %162, !dbg !2268
}

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.113() #0 !dbg !2269 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.116(i64* @timestamp_check.115) #3, !dbg !2270
  store i64 %2, i64* @timestamp_check.115, align 8, !dbg !2271
  %3 = load i64, i64* @timestamp_check.115, align 8, !dbg !2272
  %4 = icmp sge i64 %3, 1000, !dbg !2274
  br i1 %4, label %5, label %6, !dbg !2275

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !2276
  br label %7, !dbg !2276

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !2278
  br label %7, !dbg !2278

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !2279
  ret i32 %8, !dbg !2279
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_uptime_delta.116(i64*) #0 !dbg !2280 {
  %2 = alloca i64*, align 4
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  store i64* %0, i64** %2, align 4
  call void @llvm.dbg.declare(metadata i64** %2, metadata !2281, metadata !DIExpression()), !dbg !2282
  call void @llvm.dbg.declare(metadata i64* %3, metadata !2283, metadata !DIExpression()), !dbg !2284
  call void @llvm.dbg.declare(metadata i64* %4, metadata !2285, metadata !DIExpression()), !dbg !2286
  %5 = call i64 @k_uptime_get.117() #3, !dbg !2287
  store i64 %5, i64* %3, align 8, !dbg !2288
  %6 = load i64, i64* %3, align 8, !dbg !2289
  %7 = load i64*, i64** %2, align 4, !dbg !2290
  %8 = load i64, i64* %7, align 8, !dbg !2291
  %9 = sub i64 %6, %8, !dbg !2292
  store i64 %9, i64* %4, align 8, !dbg !2293
  %10 = load i64, i64* %3, align 8, !dbg !2294
  %11 = load i64*, i64** %2, align 4, !dbg !2295
  store i64 %10, i64* %11, align 8, !dbg !2296
  %12 = load i64, i64* %4, align 8, !dbg !2297
  ret i64 %12, !dbg !2298
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_uptime_get.117() #0 !dbg !2299 {
  %1 = call i64 @k_uptime_ticks(), !dbg !2300
  %2 = call i64 @k_ticks_to_ms_floor64(i64 %1), !dbg !2301
  ret i64 %2, !dbg !2302
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_cycle_get_32.121() #0 !dbg !2303 {
  %1 = call i32 @arch_k_cycle_get_32(), !dbg !2304
  ret i32 %1, !dbg !2305
}

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.123() #0 !dbg !2306 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.115, align 8, !dbg !2307
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !2308
  store i64 1, i64* %2, align 8, !dbg !2308
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !2308
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !2308
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !2308
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !2308
  %7 = call i64 @k_uptime_delta.116(i64* @timestamp_check.115) #3, !dbg !2309
  store i64 %7, i64* @timestamp_check.115, align 8, !dbg !2310
  ret void, !dbg !2311
}

; Function Attrs: noinline nounwind optnone
define dso_local void @mutex_test() #0 !dbg !2312 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !2314, metadata !DIExpression()), !dbg !2315
  call void @llvm.dbg.declare(metadata i32* %2, metadata !2316, metadata !DIExpression()), !dbg !2317
  %4 = load i32*, i32** @output_file, align 4, !dbg !2318
  %5 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.127, i32 0, i32 0), i32* %4) #3, !dbg !2318
  %6 = call i32 @BENCH_START.128() #3, !dbg !2319
  store i32 %6, i32* %1, align 4, !dbg !2320
  store i32 0, i32* %2, align 4, !dbg !2321
  br label %7, !dbg !2323

7:                                                ; preds = %17, %0
  %8 = load i32, i32* %2, align 4, !dbg !2324
  %9 = icmp slt i32 %8, 1000, !dbg !2326
  br i1 %9, label %10, label %20, !dbg !2327

10:                                               ; preds = %7
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !2328
  store i64 -1, i64* %11, align 8, !dbg !2328
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !2330
  %13 = bitcast i64* %12 to [1 x i64]*, !dbg !2330
  %14 = load [1 x i64], [1 x i64]* %13, align 8, !dbg !2330
  %15 = call i32 @k_mutex_lock(%struct.k_mutex* @DEMO_MUTEX, [1 x i64] %14) #3, !dbg !2330
  %16 = call i32 @k_mutex_unlock(%struct.k_mutex* @DEMO_MUTEX) #3, !dbg !2331
  br label %17, !dbg !2332

17:                                               ; preds = %10
  %18 = load i32, i32* %2, align 4, !dbg !2333
  %19 = add i32 %18, 1, !dbg !2333
  store i32 %19, i32* %2, align 4, !dbg !2333
  br label %7, !dbg !2334, !llvm.loop !2335

20:                                               ; preds = %7
  %21 = load i32, i32* %1, align 4, !dbg !2337
  %22 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %21) #3, !dbg !2338
  store i32 %22, i32* %1, align 4, !dbg !2339
  call void @check_result.130() #3, !dbg !2340
  %23 = load i32, i32* %1, align 4, !dbg !2341
  %24 = zext i32 %23 to i64, !dbg !2341
  %25 = call i64 @k_cyc_to_ns_floor64.109(i64 %24), !dbg !2341
  %26 = udiv i64 %25, 2000, !dbg !2341
  %27 = trunc i64 %26 to i32, !dbg !2341
  %28 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1.132, i32 0, i32 0), i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.2.133, i32 0, i32 0), i32 %27) #3, !dbg !2341
  %29 = load i32*, i32** @output_file, align 4, !dbg !2341
  %30 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %29) #3, !dbg !2341
  ret void, !dbg !2343
}

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.128() #0 !dbg !2344 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !2345, metadata !DIExpression()), !dbg !2346
  call void @bench_test_start.145() #3, !dbg !2347
  %2 = call i32 @TIME_STAMP_DELTA_GET.129(i32 0) #3, !dbg !2348
  store i32 %2, i32* %1, align 4, !dbg !2349
  %3 = load i32, i32* %1, align 4, !dbg !2350
  ret i32 %3, !dbg !2351
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_lock(%struct.k_mutex*, [1 x i64]) #0 !dbg !2352 {
  %3 = alloca %struct.k_timeout_t, align 8
  %4 = alloca %struct.k_mutex*, align 4
  %5 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0
  %6 = bitcast i64* %5 to [1 x i64]*
  store [1 x i64] %1, [1 x i64]* %6, align 8
  store %struct.k_mutex* %0, %struct.k_mutex** %4, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %4, metadata !2474, metadata !DIExpression()), !dbg !2475
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %3, metadata !2476, metadata !DIExpression()), !dbg !2477
  br label %7, !dbg !2478

7:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !2479, !srcloc !2481
  br label %8, !dbg !2479

8:                                                ; preds = %7
  %9 = load %struct.k_mutex*, %struct.k_mutex** %4, align 4, !dbg !2482
  %10 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !2483
  %11 = bitcast i64* %10 to [1 x i64]*, !dbg !2483
  %12 = load [1 x i64], [1 x i64]* %11, align 8, !dbg !2483
  %13 = call i32 @z_impl_k_mutex_lock(%struct.k_mutex* %9, [1 x i64] %12) #3, !dbg !2483
  ret i32 %13, !dbg !2484
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_mutex_unlock(%struct.k_mutex*) #0 !dbg !2485 {
  %2 = alloca %struct.k_mutex*, align 4
  store %struct.k_mutex* %0, %struct.k_mutex** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_mutex** %2, metadata !2488, metadata !DIExpression()), !dbg !2489
  br label %3, !dbg !2490

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !2491, !srcloc !2493
  br label %4, !dbg !2491

4:                                                ; preds = %3
  %5 = load %struct.k_mutex*, %struct.k_mutex** %2, align 4, !dbg !2494
  %6 = call i32 @z_impl_k_mutex_unlock(%struct.k_mutex* %5) #3, !dbg !2495
  ret i32 %6, !dbg !2496
}

; Function Attrs: noinline nounwind optnone
define internal i32 @TIME_STAMP_DELTA_GET.129(i32) #0 !dbg !2497 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @llvm.dbg.declare(metadata i32* %2, metadata !2498, metadata !DIExpression()), !dbg !2499
  call void @llvm.dbg.declare(metadata i32* %3, metadata !2500, metadata !DIExpression()), !dbg !2501
  call void @timestamp_serialize(), !dbg !2502
  %5 = call i32 @k_cycle_get_32.121(), !dbg !2503
  store i32 %5, i32* %3, align 4, !dbg !2504
  call void @llvm.dbg.declare(metadata i32* %4, metadata !2505, metadata !DIExpression()), !dbg !2506
  %6 = load i32, i32* %3, align 4, !dbg !2507
  %7 = load i32, i32* %2, align 4, !dbg !2508
  %8 = icmp uge i32 %6, %7, !dbg !2509
  br i1 %8, label %9, label %13, !dbg !2510

9:                                                ; preds = %1
  %10 = load i32, i32* %3, align 4, !dbg !2511
  %11 = load i32, i32* %2, align 4, !dbg !2512
  %12 = sub i32 %10, %11, !dbg !2513
  br label %18, !dbg !2510

13:                                               ; preds = %1
  %14 = load i32, i32* %2, align 4, !dbg !2514
  %15 = sub i32 -1, %14, !dbg !2515
  %16 = load i32, i32* %3, align 4, !dbg !2516
  %17 = add i32 %15, %16, !dbg !2517
  br label %18, !dbg !2510

18:                                               ; preds = %13, %9
  %19 = phi i32 [ %12, %9 ], [ %17, %13 ], !dbg !2510
  store i32 %19, i32* %4, align 4, !dbg !2506
  %20 = load i32, i32* %2, align 4, !dbg !2518
  %21 = icmp ugt i32 %20, 0, !dbg !2520
  br i1 %21, label %22, label %26, !dbg !2521

22:                                               ; preds = %18
  %23 = load i32, i32* @tm_off, align 4, !dbg !2522
  %24 = load i32, i32* %4, align 4, !dbg !2524
  %25 = sub i32 %24, %23, !dbg !2524
  store i32 %25, i32* %4, align 4, !dbg !2524
  br label %26, !dbg !2525

26:                                               ; preds = %22, %18
  %27 = load i32, i32* %4, align 4, !dbg !2526
  ret i32 %27, !dbg !2527
}

; Function Attrs: noinline nounwind optnone
define internal void @check_result.130() #0 !dbg !2528 {
  %1 = call i32 @bench_test_end.135() #3, !dbg !2529
  %2 = icmp slt i32 %1, 0, !dbg !2531
  br i1 %2, label %3, label %7, !dbg !2532

3:                                                ; preds = %0
  %4 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([77 x i8], [77 x i8]* @.str.3.136, i32 0, i32 0), i32 187) #3, !dbg !2533
  %5 = load i32*, i32** @output_file, align 4, !dbg !2533
  %6 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %5) #3, !dbg !2533
  br label %7, !dbg !2536

7:                                                ; preds = %3, %0
  ret void, !dbg !2537
}

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.135() #0 !dbg !2538 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.138(i64* @timestamp_check.137) #3, !dbg !2539
  store i64 %2, i64* @timestamp_check.137, align 8, !dbg !2540
  %3 = load i64, i64* @timestamp_check.137, align 8, !dbg !2541
  %4 = icmp sge i64 %3, 1000, !dbg !2543
  br i1 %4, label %5, label %6, !dbg !2544

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !2545
  br label %7, !dbg !2545

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !2547
  br label %7, !dbg !2547

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !2548
  ret i32 %8, !dbg !2548
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_uptime_delta.138(i64*) #0 !dbg !2549 {
  %2 = alloca i64*, align 4
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  store i64* %0, i64** %2, align 4
  call void @llvm.dbg.declare(metadata i64** %2, metadata !2550, metadata !DIExpression()), !dbg !2551
  call void @llvm.dbg.declare(metadata i64* %3, metadata !2552, metadata !DIExpression()), !dbg !2553
  call void @llvm.dbg.declare(metadata i64* %4, metadata !2554, metadata !DIExpression()), !dbg !2555
  %5 = call i64 @k_uptime_get.117(), !dbg !2556
  store i64 %5, i64* %3, align 8, !dbg !2557
  %6 = load i64, i64* %3, align 8, !dbg !2558
  %7 = load i64*, i64** %2, align 4, !dbg !2559
  %8 = load i64, i64* %7, align 8, !dbg !2560
  %9 = sub i64 %6, %8, !dbg !2561
  store i64 %9, i64* %4, align 8, !dbg !2562
  %10 = load i64, i64* %3, align 8, !dbg !2563
  %11 = load i64*, i64** %2, align 4, !dbg !2564
  store i64 %10, i64* %11, align 8, !dbg !2565
  %12 = load i64, i64* %4, align 8, !dbg !2566
  ret i64 %12, !dbg !2567
}

declare dso_local i32 @z_impl_k_mutex_unlock(%struct.k_mutex*) #2

declare dso_local i32 @z_impl_k_mutex_lock(%struct.k_mutex*, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.145() #0 !dbg !2568 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.137, align 8, !dbg !2569
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !2570
  store i64 1, i64* %2, align 8, !dbg !2570
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !2570
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !2570
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !2570
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !2570
  %7 = call i64 @k_uptime_delta.138(i64* @timestamp_check.137) #3, !dbg !2571
  store i64 %7, i64* @timestamp_check.137, align 8, !dbg !2572
  ret void, !dbg !2573
}

; Function Attrs: noinline nounwind optnone
define dso_local void @pipe_test() #0 !dbg !2574 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca [3 x i32], align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca %struct.getinfo, align 4
  %9 = alloca %struct.k_timeout_t, align 8
  %10 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !2576, metadata !DIExpression()), !dbg !2577
  call void @llvm.dbg.declare(metadata i32* %2, metadata !2578, metadata !DIExpression()), !dbg !2579
  call void @llvm.dbg.declare(metadata [3 x i32]* %3, metadata !2580, metadata !DIExpression()), !dbg !2582
  call void @llvm.dbg.declare(metadata i32* %4, metadata !2583, metadata !DIExpression()), !dbg !2584
  call void @llvm.dbg.declare(metadata i32* %5, metadata !2585, metadata !DIExpression()), !dbg !2586
  call void @llvm.dbg.declare(metadata i32* %6, metadata !2587, metadata !DIExpression()), !dbg !2588
  store i32 -1, i32* %6, align 4, !dbg !2588
  call void @llvm.dbg.declare(metadata i32* %7, metadata !2589, metadata !DIExpression()), !dbg !2590
  call void @llvm.dbg.declare(metadata %struct.getinfo* %8, metadata !2591, metadata !DIExpression()), !dbg !2597
  call void @k_sem_reset.149(%struct.k_sem* @SEM0) #3, !dbg !2598
  call void @k_sem_give(%struct.k_sem* @STARTRCV), !dbg !2599
  %11 = load i32*, i32** @output_file, align 4, !dbg !2600
  %12 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %11) #3, !dbg !2600
  %13 = load i32*, i32** @output_file, align 4, !dbg !2601
  %14 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.1.152, i32 0, i32 0), i32* %13) #3, !dbg !2601
  %15 = load i32*, i32** @output_file, align 4, !dbg !2602
  %16 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %15) #3, !dbg !2602
  %17 = load i32*, i32** @output_file, align 4, !dbg !2603
  %18 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.2.153, i32 0, i32 0), i32* %17) #3, !dbg !2603
  %19 = load i32*, i32** @output_file, align 4, !dbg !2604
  %20 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %19) #3, !dbg !2604
  %21 = load i32*, i32** @output_file, align 4, !dbg !2605
  %22 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.3.154, i32 0, i32 0), i32* %21) #3, !dbg !2605
  %23 = load i32*, i32** @output_file, align 4, !dbg !2606
  %24 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %23) #3, !dbg !2606
  %25 = load i32*, i32** @output_file, align 4, !dbg !2607
  %26 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.4.155, i32 0, i32 0), i32* %25) #3, !dbg !2607
  %27 = load i32*, i32** @output_file, align 4, !dbg !2608
  %28 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %27) #3, !dbg !2608
  %29 = load i32*, i32** @output_file, align 4, !dbg !2609
  %30 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.5.156, i32 0, i32 0), i32* %29) #3, !dbg !2609
  %31 = load i32*, i32** @output_file, align 4, !dbg !2610
  %32 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %31) #3, !dbg !2610
  store i32 8, i32* %1, align 4, !dbg !2611
  br label %33, !dbg !2613

33:                                               ; preds = %106, %0
  %34 = load i32, i32* %1, align 4, !dbg !2614
  %35 = icmp ule i32 %34, 2048, !dbg !2616
  br i1 %35, label %36, label %109, !dbg !2617

36:                                               ; preds = %33
  store i32 0, i32* %5, align 4, !dbg !2618
  br label %37, !dbg !2621

37:                                               ; preds = %55, %36
  %38 = load i32, i32* %5, align 4, !dbg !2622
  %39 = icmp slt i32 %38, 3, !dbg !2624
  br i1 %39, label %40, label %58, !dbg !2625

40:                                               ; preds = %37
  store i32 256, i32* %4, align 4, !dbg !2626
  %41 = load i32, i32* %5, align 4, !dbg !2628
  %42 = getelementptr [0 x %struct.k_pipe*], [0 x %struct.k_pipe*]* bitcast ([3 x %struct.k_pipe*]* @test_pipes to [0 x %struct.k_pipe*]*), i32 0, i32 %41, !dbg !2629
  %43 = load %struct.k_pipe*, %struct.k_pipe** %42, align 4, !dbg !2629
  %44 = load i32, i32* %1, align 4, !dbg !2630
  %45 = load i32, i32* %4, align 4, !dbg !2631
  %46 = load i32, i32* %5, align 4, !dbg !2632
  %47 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 %46, !dbg !2633
  %48 = call i32 @pipeput(%struct.k_pipe* %43, i8 zeroext 2, i32 %44, i32 %45, i32* %47) #3, !dbg !2634
  %49 = bitcast %struct.getinfo* %8 to i8*, !dbg !2635
  %50 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !2636
  store i64 -1, i64* %50, align 8, !dbg !2636
  %51 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !2637
  %52 = bitcast i64* %51 to [1 x i64]*, !dbg !2637
  %53 = load [1 x i64], [1 x i64]* %52, align 8, !dbg !2637
  %54 = call i32 @k_msgq_get(%struct.k_msgq* @CH_COMM, i8* %49, [1 x i64] %53), !dbg !2637
  br label %55, !dbg !2638

55:                                               ; preds = %40
  %56 = load i32, i32* %5, align 4, !dbg !2639
  %57 = add i32 %56, 1, !dbg !2639
  store i32 %57, i32* %5, align 4, !dbg !2639
  br label %37, !dbg !2640, !llvm.loop !2641

58:                                               ; preds = %37
  %59 = load i32, i32* %1, align 4, !dbg !2643
  %60 = load i32, i32* %1, align 4, !dbg !2643
  %61 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 0, !dbg !2643
  %62 = load i32, i32* %61, align 4, !dbg !2643
  %63 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 1, !dbg !2643
  %64 = load i32, i32* %63, align 4, !dbg !2643
  %65 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 2, !dbg !2643
  %66 = load i32, i32* %65, align 4, !dbg !2643
  %67 = load i32, i32* %1, align 4, !dbg !2643
  %68 = mul i32 1000000, %67, !dbg !2643
  %69 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 0, !dbg !2643
  %70 = load i32, i32* %69, align 4, !dbg !2643
  %71 = icmp ne i32 %70, 0, !dbg !2643
  br i1 %71, label %72, label %75, !dbg !2643

72:                                               ; preds = %58
  %73 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 0, !dbg !2643
  %74 = load i32, i32* %73, align 4, !dbg !2643
  br label %76, !dbg !2643

75:                                               ; preds = %58
  br label %76, !dbg !2643

76:                                               ; preds = %75, %72
  %77 = phi i32 [ %74, %72 ], [ 1, %75 ], !dbg !2643
  %78 = udiv i32 %68, %77, !dbg !2643
  %79 = load i32, i32* %1, align 4, !dbg !2643
  %80 = mul i32 1000000, %79, !dbg !2643
  %81 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 1, !dbg !2643
  %82 = load i32, i32* %81, align 4, !dbg !2643
  %83 = icmp ne i32 %82, 0, !dbg !2643
  br i1 %83, label %84, label %87, !dbg !2643

84:                                               ; preds = %76
  %85 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 1, !dbg !2643
  %86 = load i32, i32* %85, align 4, !dbg !2643
  br label %88, !dbg !2643

87:                                               ; preds = %76
  br label %88, !dbg !2643

88:                                               ; preds = %87, %84
  %89 = phi i32 [ %86, %84 ], [ 1, %87 ], !dbg !2643
  %90 = udiv i32 %80, %89, !dbg !2643
  %91 = load i32, i32* %1, align 4, !dbg !2643
  %92 = mul i32 1000000, %91, !dbg !2643
  %93 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 2, !dbg !2643
  %94 = load i32, i32* %93, align 4, !dbg !2643
  %95 = icmp ne i32 %94, 0, !dbg !2643
  br i1 %95, label %96, label %99, !dbg !2643

96:                                               ; preds = %88
  %97 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 2, !dbg !2643
  %98 = load i32, i32* %97, align 4, !dbg !2643
  br label %100, !dbg !2643

99:                                               ; preds = %88
  br label %100, !dbg !2643

100:                                              ; preds = %99, %96
  %101 = phi i32 [ %98, %96 ], [ 1, %99 ], !dbg !2643
  %102 = udiv i32 %92, %101, !dbg !2643
  %103 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.6.158, i32 0, i32 0), i32 %59, i32 %60, i32 %62, i32 %64, i32 %66, i32 %78, i32 %90, i32 %102) #3, !dbg !2643
  %104 = load i32*, i32** @output_file, align 4, !dbg !2643
  %105 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %104) #3, !dbg !2643
  br label %106, !dbg !2645

106:                                              ; preds = %100
  %107 = load i32, i32* %1, align 4, !dbg !2646
  %108 = shl i32 %107, 1, !dbg !2646
  store i32 %108, i32* %1, align 4, !dbg !2646
  br label %33, !dbg !2647, !llvm.loop !2648

109:                                              ; preds = %33
  %110 = load i32*, i32** @output_file, align 4, !dbg !2650
  %111 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %110) #3, !dbg !2650
  store i32 0, i32* %7, align 4, !dbg !2651
  br label %112, !dbg !2653

112:                                              ; preds = %239, %109
  %113 = load i32, i32* %7, align 4, !dbg !2654
  %114 = icmp slt i32 %113, 2, !dbg !2656
  br i1 %114, label %115, label %242, !dbg !2657

115:                                              ; preds = %112
  %116 = load i32, i32* %7, align 4, !dbg !2658
  %117 = icmp eq i32 %116, 0, !dbg !2661
  br i1 %117, label %118, label %123, !dbg !2662

118:                                              ; preds = %115
  %119 = load i32*, i32** @output_file, align 4, !dbg !2663
  %120 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.7.159, i32 0, i32 0), i32* %119) #3, !dbg !2663
  %121 = call %struct.k_thread.188* @k_current_get() #3, !dbg !2665
  %122 = call i32 @k_thread_priority_get(%struct.k_thread.188* %121) #3, !dbg !2666
  store i32 %122, i32* %6, align 4, !dbg !2667
  br label %123, !dbg !2668

123:                                              ; preds = %118, %115
  %124 = load i32, i32* %7, align 4, !dbg !2669
  %125 = icmp eq i32 %124, 1, !dbg !2671
  br i1 %125, label %126, label %132, !dbg !2672

126:                                              ; preds = %123
  %127 = load i32*, i32** @output_file, align 4, !dbg !2673
  %128 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.8.160, i32 0, i32 0), i32* %127) #3, !dbg !2673
  %129 = call %struct.k_thread.188* @k_current_get() #3, !dbg !2675
  %130 = load i32, i32* %6, align 4, !dbg !2676
  %131 = sub i32 %130, 2, !dbg !2677
  call void @k_thread_priority_set(%struct.k_thread.188* %129, i32 %131) #3, !dbg !2678
  br label %132, !dbg !2679

132:                                              ; preds = %126, %123
  %133 = load i32*, i32** @output_file, align 4, !dbg !2680
  %134 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %133) #3, !dbg !2680
  br label %135, !dbg !2681

135:                                              ; preds = %132
  %136 = load i32*, i32** @output_file, align 4, !dbg !2682
  %137 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.4.155, i32 0, i32 0), i32* %136) #3, !dbg !2682
  %138 = load i32*, i32** @output_file, align 4, !dbg !2682
  %139 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %138) #3, !dbg !2682
  br label %140, !dbg !2682

140:                                              ; preds = %135
  %141 = load i32*, i32** @output_file, align 4, !dbg !2684
  %142 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.5.156, i32 0, i32 0), i32* %141) #3, !dbg !2684
  %143 = load i32*, i32** @output_file, align 4, !dbg !2685
  %144 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %143) #3, !dbg !2685
  store i32 8, i32* %1, align 4, !dbg !2686
  br label %145, !dbg !2688

145:                                              ; preds = %231, %140
  %146 = load i32, i32* %1, align 4, !dbg !2689
  %147 = icmp ule i32 %146, 2048, !dbg !2691
  br i1 %147, label %148, label %234, !dbg !2692

148:                                              ; preds = %145
  %149 = load i32, i32* %1, align 4, !dbg !2693
  %150 = udiv i32 2048, %149, !dbg !2695
  store i32 %150, i32* %4, align 4, !dbg !2696
  store i32 0, i32* %5, align 4, !dbg !2697
  br label %151, !dbg !2699

151:                                              ; preds = %171, %148
  %152 = load i32, i32* %5, align 4, !dbg !2700
  %153 = icmp slt i32 %152, 3, !dbg !2702
  br i1 %153, label %154, label %174, !dbg !2703

154:                                              ; preds = %151
  %155 = load i32, i32* %5, align 4, !dbg !2704
  %156 = getelementptr [0 x %struct.k_pipe*], [0 x %struct.k_pipe*]* bitcast ([3 x %struct.k_pipe*]* @test_pipes to [0 x %struct.k_pipe*]*), i32 0, i32 %155, !dbg !2706
  %157 = load %struct.k_pipe*, %struct.k_pipe** %156, align 4, !dbg !2706
  %158 = load i32, i32* %1, align 4, !dbg !2707
  %159 = load i32, i32* %4, align 4, !dbg !2708
  %160 = load i32, i32* %5, align 4, !dbg !2709
  %161 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 %160, !dbg !2710
  %162 = call i32 @pipeput(%struct.k_pipe* %157, i8 zeroext 1, i32 %158, i32 %159, i32* %161) #3, !dbg !2711
  %163 = bitcast %struct.getinfo* %8 to i8*, !dbg !2712
  %164 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !2713
  store i64 -1, i64* %164, align 8, !dbg !2713
  %165 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !2714
  %166 = bitcast i64* %165 to [1 x i64]*, !dbg !2714
  %167 = load [1 x i64], [1 x i64]* %166, align 8, !dbg !2714
  %168 = call i32 @k_msgq_get(%struct.k_msgq* @CH_COMM, i8* %163, [1 x i64] %167), !dbg !2714
  %169 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %8, i32 0, i32 2, !dbg !2715
  %170 = load i32, i32* %169, align 4, !dbg !2715
  store i32 %170, i32* %2, align 4, !dbg !2716
  br label %171, !dbg !2717

171:                                              ; preds = %154
  %172 = load i32, i32* %5, align 4, !dbg !2718
  %173 = add i32 %172, 1, !dbg !2718
  store i32 %173, i32* %5, align 4, !dbg !2718
  br label %151, !dbg !2719, !llvm.loop !2720

174:                                              ; preds = %151
  %175 = load i32, i32* %1, align 4, !dbg !2722
  %176 = load i32, i32* %2, align 4, !dbg !2722
  %177 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 0, !dbg !2722
  %178 = load i32, i32* %177, align 4, !dbg !2722
  %179 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 1, !dbg !2722
  %180 = load i32, i32* %179, align 4, !dbg !2722
  %181 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 2, !dbg !2722
  %182 = load i32, i32* %181, align 4, !dbg !2722
  %183 = load i32, i32* %1, align 4, !dbg !2722
  %184 = zext i32 %183 to i64, !dbg !2722
  %185 = mul i64 %184, 1000000, !dbg !2722
  %186 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 0, !dbg !2722
  %187 = load i32, i32* %186, align 4, !dbg !2722
  %188 = icmp ne i32 %187, 0, !dbg !2722
  br i1 %188, label %189, label %192, !dbg !2722

189:                                              ; preds = %174
  %190 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 0, !dbg !2722
  %191 = load i32, i32* %190, align 4, !dbg !2722
  br label %193, !dbg !2722

192:                                              ; preds = %174
  br label %193, !dbg !2722

193:                                              ; preds = %192, %189
  %194 = phi i32 [ %191, %189 ], [ 1, %192 ], !dbg !2722
  %195 = zext i32 %194 to i64, !dbg !2722
  %196 = udiv i64 %185, %195, !dbg !2722
  %197 = trunc i64 %196 to i32, !dbg !2722
  %198 = load i32, i32* %1, align 4, !dbg !2722
  %199 = zext i32 %198 to i64, !dbg !2722
  %200 = mul i64 %199, 1000000, !dbg !2722
  %201 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 1, !dbg !2722
  %202 = load i32, i32* %201, align 4, !dbg !2722
  %203 = icmp ne i32 %202, 0, !dbg !2722
  br i1 %203, label %204, label %207, !dbg !2722

204:                                              ; preds = %193
  %205 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 1, !dbg !2722
  %206 = load i32, i32* %205, align 4, !dbg !2722
  br label %208, !dbg !2722

207:                                              ; preds = %193
  br label %208, !dbg !2722

208:                                              ; preds = %207, %204
  %209 = phi i32 [ %206, %204 ], [ 1, %207 ], !dbg !2722
  %210 = zext i32 %209 to i64, !dbg !2722
  %211 = udiv i64 %200, %210, !dbg !2722
  %212 = trunc i64 %211 to i32, !dbg !2722
  %213 = load i32, i32* %1, align 4, !dbg !2722
  %214 = zext i32 %213 to i64, !dbg !2722
  %215 = mul i64 %214, 1000000, !dbg !2722
  %216 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 2, !dbg !2722
  %217 = load i32, i32* %216, align 4, !dbg !2722
  %218 = icmp ne i32 %217, 0, !dbg !2722
  br i1 %218, label %219, label %222, !dbg !2722

219:                                              ; preds = %208
  %220 = getelementptr [3 x i32], [3 x i32]* %3, i32 0, i32 2, !dbg !2722
  %221 = load i32, i32* %220, align 4, !dbg !2722
  br label %223, !dbg !2722

222:                                              ; preds = %208
  br label %223, !dbg !2722

223:                                              ; preds = %222, %219
  %224 = phi i32 [ %221, %219 ], [ 1, %222 ], !dbg !2722
  %225 = zext i32 %224 to i64, !dbg !2722
  %226 = udiv i64 %215, %225, !dbg !2722
  %227 = trunc i64 %226 to i32, !dbg !2722
  %228 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.9.161, i32 0, i32 0), i32 %175, i32 %176, i32 %178, i32 %180, i32 %182, i32 %197, i32 %212, i32 %227) #3, !dbg !2722
  %229 = load i32*, i32** @output_file, align 4, !dbg !2722
  %230 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %229) #3, !dbg !2722
  br label %231, !dbg !2724

231:                                              ; preds = %223
  %232 = load i32, i32* %1, align 4, !dbg !2725
  %233 = shl i32 %232, 1, !dbg !2725
  store i32 %233, i32* %1, align 4, !dbg !2725
  br label %145, !dbg !2726, !llvm.loop !2727

234:                                              ; preds = %145
  %235 = load i32*, i32** @output_file, align 4, !dbg !2729
  %236 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.151, i32 0, i32 0), i32* %235) #3, !dbg !2729
  %237 = call %struct.k_thread.188* @k_current_get() #3, !dbg !2730
  %238 = load i32, i32* %6, align 4, !dbg !2731
  call void @k_thread_priority_set(%struct.k_thread.188* %237, i32 %238) #3, !dbg !2732
  br label %239, !dbg !2733

239:                                              ; preds = %234
  %240 = load i32, i32* %7, align 4, !dbg !2734
  %241 = add i32 %240, 1, !dbg !2734
  store i32 %241, i32* %7, align 4, !dbg !2734
  br label %112, !dbg !2735, !llvm.loop !2736

242:                                              ; preds = %112
  ret void, !dbg !2738
}

; Function Attrs: noinline nounwind optnone
define internal void @k_sem_reset.149(%struct.k_sem*) #0 !dbg !2739 {
  %2 = alloca %struct.k_sem*, align 4
  store %struct.k_sem* %0, %struct.k_sem** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_sem** %2, metadata !2766, metadata !DIExpression()), !dbg !2767
  br label %3, !dbg !2768

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !2769, !srcloc !2771
  br label %4, !dbg !2769

4:                                                ; preds = %3
  %5 = load %struct.k_sem*, %struct.k_sem** %2, align 4, !dbg !2772
  call void @z_impl_k_sem_reset(%struct.k_sem* %5), !dbg !2773
  ret void, !dbg !2774
}

; Function Attrs: noinline nounwind optnone
define dso_local i32 @pipeput(%struct.k_pipe*, i8 zeroext, i32, i32, i32*) #0 !dbg !2775 {
  %6 = alloca i32, align 4
  %7 = alloca %struct.k_pipe*, align 4
  %8 = alloca i8, align 1
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32*, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca i32, align 4
  %18 = alloca i32, align 4
  %19 = alloca i32, align 4
  %20 = alloca %struct.k_timeout_t, align 8
  store %struct.k_pipe* %0, %struct.k_pipe** %7, align 4
  call void @llvm.dbg.declare(metadata %struct.k_pipe** %7, metadata !2796, metadata !DIExpression()), !dbg !2797
  store i8 %1, i8* %8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !2798, metadata !DIExpression()), !dbg !2799
  store i32 %2, i32* %9, align 4
  call void @llvm.dbg.declare(metadata i32* %9, metadata !2800, metadata !DIExpression()), !dbg !2801
  store i32 %3, i32* %10, align 4
  call void @llvm.dbg.declare(metadata i32* %10, metadata !2802, metadata !DIExpression()), !dbg !2803
  store i32* %4, i32** %11, align 4
  call void @llvm.dbg.declare(metadata i32** %11, metadata !2804, metadata !DIExpression()), !dbg !2805
  call void @llvm.dbg.declare(metadata i32* %12, metadata !2806, metadata !DIExpression()), !dbg !2807
  call void @llvm.dbg.declare(metadata i32* %13, metadata !2808, metadata !DIExpression()), !dbg !2809
  call void @llvm.dbg.declare(metadata i32* %14, metadata !2810, metadata !DIExpression()), !dbg !2811
  store i32 0, i32* %14, align 4, !dbg !2811
  call void @llvm.dbg.declare(metadata i32* %15, metadata !2812, metadata !DIExpression()), !dbg !2813
  %21 = load i32, i32* %9, align 4, !dbg !2814
  %22 = load i32, i32* %10, align 4, !dbg !2815
  %23 = mul i32 %21, %22, !dbg !2816
  store i32 %23, i32* %15, align 4, !dbg !2813
  call void @k_sem_give(%struct.k_sem* @SEM0), !dbg !2817
  %24 = call i32 @BENCH_START.162() #3, !dbg !2818
  store i32 %24, i32* %13, align 4, !dbg !2819
  store i32 0, i32* %12, align 4, !dbg !2820
  br label %25, !dbg !2822

25:                                               ; preds = %89, %5
  %26 = load i8, i8* %8, align 1, !dbg !2823
  %27 = zext i8 %26 to i32, !dbg !2823
  %28 = icmp eq i32 %27, 1, !dbg !2825
  br i1 %28, label %33, label %29, !dbg !2826

29:                                               ; preds = %25
  %30 = load i32, i32* %12, align 4, !dbg !2827
  %31 = load i32, i32* %10, align 4, !dbg !2828
  %32 = icmp slt i32 %30, %31, !dbg !2829
  br label %33, !dbg !2826

33:                                               ; preds = %29, %25
  %34 = phi i1 [ true, %25 ], [ %32, %29 ]
  br i1 %34, label %35, label %92, !dbg !2830

35:                                               ; preds = %33
  call void @llvm.dbg.declare(metadata i32* %16, metadata !2831, metadata !DIExpression()), !dbg !2833
  store i32 0, i32* %16, align 4, !dbg !2833
  call void @llvm.dbg.declare(metadata i32* %17, metadata !2834, metadata !DIExpression()), !dbg !2835
  %36 = load i32, i32* %9, align 4, !dbg !2836
  %37 = load i32, i32* %15, align 4, !dbg !2836
  %38 = load i32, i32* %14, align 4, !dbg !2836
  %39 = sub i32 %37, %38, !dbg !2836
  %40 = icmp ult i32 %36, %39, !dbg !2836
  br i1 %40, label %41, label %43, !dbg !2836

41:                                               ; preds = %35
  %42 = load i32, i32* %9, align 4, !dbg !2836
  br label %47, !dbg !2836

43:                                               ; preds = %35
  %44 = load i32, i32* %15, align 4, !dbg !2836
  %45 = load i32, i32* %14, align 4, !dbg !2836
  %46 = sub i32 %44, %45, !dbg !2836
  br label %47, !dbg !2836

47:                                               ; preds = %43, %41
  %48 = phi i32 [ %42, %41 ], [ %46, %43 ], !dbg !2836
  store i32 %48, i32* %17, align 4, !dbg !2835
  call void @llvm.dbg.declare(metadata i32* %18, metadata !2837, metadata !DIExpression()), !dbg !2838
  call void @llvm.dbg.declare(metadata i32* %19, metadata !2839, metadata !DIExpression()), !dbg !2840
  store i32 0, i32* %19, align 4, !dbg !2840
  %49 = load i8, i8* %8, align 1, !dbg !2841
  %50 = zext i8 %49 to i32, !dbg !2841
  %51 = icmp eq i32 %50, 2, !dbg !2843
  br i1 %51, label %52, label %54, !dbg !2844

52:                                               ; preds = %47
  %53 = load i32, i32* %17, align 4, !dbg !2845
  store i32 %53, i32* %19, align 4, !dbg !2847
  br label %54, !dbg !2848

54:                                               ; preds = %52, %47
  %55 = load %struct.k_pipe*, %struct.k_pipe** %7, align 4, !dbg !2849
  %56 = load i32, i32* %17, align 4, !dbg !2850
  %57 = load i32, i32* %19, align 4, !dbg !2851
  %58 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %20, i32 0, i32 0, !dbg !2852
  store i64 -1, i64* %58, align 8, !dbg !2852
  %59 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %20, i32 0, i32 0, !dbg !2853
  %60 = bitcast i64* %59 to [1 x i64]*, !dbg !2853
  %61 = load [1 x i64], [1 x i64]* %60, align 8, !dbg !2853
  %62 = call i32 @k_pipe_put(%struct.k_pipe* %55, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_bench, i32 0, i32 0), i32 %56, i32* %16, i32 %57, [1 x i64] %61) #3, !dbg !2853
  store i32 %62, i32* %18, align 4, !dbg !2854
  %63 = load i32, i32* %18, align 4, !dbg !2855
  %64 = icmp ne i32 %63, 0, !dbg !2857
  br i1 %64, label %65, label %66, !dbg !2858

65:                                               ; preds = %54
  store i32 1, i32* %6, align 4, !dbg !2859
  br label %118, !dbg !2859

66:                                               ; preds = %54
  %67 = load i8, i8* %8, align 1, !dbg !2861
  %68 = zext i8 %67 to i32, !dbg !2861
  %69 = icmp eq i32 %68, 2, !dbg !2863
  br i1 %69, label %70, label %75, !dbg !2864

70:                                               ; preds = %66
  %71 = load i32, i32* %16, align 4, !dbg !2865
  %72 = load i32, i32* %17, align 4, !dbg !2866
  %73 = icmp ne i32 %71, %72, !dbg !2867
  br i1 %73, label %74, label %75, !dbg !2868

74:                                               ; preds = %70
  store i32 1, i32* %6, align 4, !dbg !2869
  br label %118, !dbg !2869

75:                                               ; preds = %70, %66
  %76 = load i32, i32* %16, align 4, !dbg !2871
  %77 = load i32, i32* %14, align 4, !dbg !2872
  %78 = add i32 %77, %76, !dbg !2872
  store i32 %78, i32* %14, align 4, !dbg !2872
  %79 = load i32, i32* %15, align 4, !dbg !2873
  %80 = load i32, i32* %14, align 4, !dbg !2875
  %81 = icmp eq i32 %79, %80, !dbg !2876
  br i1 %81, label %82, label %83, !dbg !2877

82:                                               ; preds = %75
  br label %92, !dbg !2878

83:                                               ; preds = %75
  %84 = load i32, i32* %15, align 4, !dbg !2880
  %85 = load i32, i32* %14, align 4, !dbg !2882
  %86 = icmp ult i32 %84, %85, !dbg !2883
  br i1 %86, label %87, label %88, !dbg !2884

87:                                               ; preds = %83
  store i32 1, i32* %6, align 4, !dbg !2885
  br label %118, !dbg !2885

88:                                               ; preds = %83
  br label %89, !dbg !2887

89:                                               ; preds = %88
  %90 = load i32, i32* %12, align 4, !dbg !2888
  %91 = add i32 %90, 1, !dbg !2888
  store i32 %91, i32* %12, align 4, !dbg !2888
  br label %25, !dbg !2889, !llvm.loop !2890

92:                                               ; preds = %82, %33
  %93 = load i32, i32* %13, align 4, !dbg !2892
  %94 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %93), !dbg !2893
  store i32 %94, i32* %13, align 4, !dbg !2894
  %95 = load i32, i32* %13, align 4, !dbg !2895
  %96 = zext i32 %95 to i64, !dbg !2895
  %97 = call i64 @k_cyc_to_ns_floor64.109(i64 %96), !dbg !2895
  %98 = load i32, i32* %10, align 4, !dbg !2895
  %99 = sext i32 %98 to i64, !dbg !2895
  %100 = udiv i64 %97, %99, !dbg !2895
  %101 = trunc i64 %100 to i32, !dbg !2895
  %102 = load i32*, i32** %11, align 4, !dbg !2896
  store i32 %101, i32* %102, align 4, !dbg !2897
  %103 = call i32 @bench_test_end.165() #3, !dbg !2898
  %104 = icmp slt i32 %103, 0, !dbg !2900
  br i1 %104, label %105, label %117, !dbg !2901

105:                                              ; preds = %92
  %106 = call i32 @high_timer_overflow() #3, !dbg !2902
  %107 = icmp ne i32 %106, 0, !dbg !2902
  br i1 %107, label %108, label %111, !dbg !2905

108:                                              ; preds = %105
  %109 = load i32*, i32** @output_file, align 4, !dbg !2906
  %110 = call i32 @fputs(i8* getelementptr inbounds ([49 x i8], [49 x i8]* @.str.10, i32 0, i32 0), i32* %109) #3, !dbg !2906
  br label %114, !dbg !2908

111:                                              ; preds = %105
  %112 = load i32*, i32** @output_file, align 4, !dbg !2909
  %113 = call i32 @fputs(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.11, i32 0, i32 0), i32* %112) #3, !dbg !2909
  br label %114

114:                                              ; preds = %111, %108
  %115 = load i32*, i32** @output_file, align 4, !dbg !2911
  %116 = call i32 @fputs(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.12, i32 0, i32 0), i32* %115) #3, !dbg !2911
  br label %117, !dbg !2912

117:                                              ; preds = %114, %92
  store i32 0, i32* %6, align 4, !dbg !2913
  br label %118, !dbg !2913

118:                                              ; preds = %117, %87, %74, %65
  %119 = load i32, i32* %6, align 4, !dbg !2914
  ret i32 %119, !dbg !2914
}

; Function Attrs: noinline nounwind optnone
define internal %struct.k_thread.188* @k_current_get() #0 !dbg !2915 {
  br label %1, !dbg !3006

1:                                                ; preds = %0
  call void asm sideeffect "", "~{memory}"() #4, !dbg !3007, !srcloc !3009
  br label %2, !dbg !3007

2:                                                ; preds = %1
  %3 = call %struct.k_thread.188* bitcast (%struct.k_thread.188* (...)* @z_impl_k_current_get to %struct.k_thread.188* ()*)() #3, !dbg !3010
  ret %struct.k_thread.188* %3, !dbg !3011
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_thread_priority_get(%struct.k_thread.188*) #0 !dbg !3012 {
  %2 = alloca %struct.k_thread.188*, align 4
  store %struct.k_thread.188* %0, %struct.k_thread.188** %2, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread.188** %2, metadata !3015, metadata !DIExpression()), !dbg !3016
  br label %3, !dbg !3017

3:                                                ; preds = %1
  call void asm sideeffect "", "~{memory}"() #4, !dbg !3018, !srcloc !3020
  br label %4, !dbg !3018

4:                                                ; preds = %3
  %5 = load %struct.k_thread.188*, %struct.k_thread.188** %2, align 4, !dbg !3021
  %6 = call i32 @z_impl_k_thread_priority_get(%struct.k_thread.188* %5) #3, !dbg !3022
  ret i32 %6, !dbg !3023
}

; Function Attrs: noinline nounwind optnone
define internal void @k_thread_priority_set(%struct.k_thread.188*, i32) #0 !dbg !3024 {
  %3 = alloca %struct.k_thread.188*, align 4
  %4 = alloca i32, align 4
  store %struct.k_thread.188* %0, %struct.k_thread.188** %3, align 4
  call void @llvm.dbg.declare(metadata %struct.k_thread.188** %3, metadata !3027, metadata !DIExpression()), !dbg !3028
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !3029, metadata !DIExpression()), !dbg !3030
  br label %5, !dbg !3031

5:                                                ; preds = %2
  call void asm sideeffect "", "~{memory}"() #4, !dbg !3032, !srcloc !3034
  br label %6, !dbg !3032

6:                                                ; preds = %5
  %7 = load %struct.k_thread.188*, %struct.k_thread.188** %3, align 4, !dbg !3035
  %8 = load i32, i32* %4, align 4, !dbg !3036
  call void @z_impl_k_thread_priority_set(%struct.k_thread.188* %7, i32 %8) #3, !dbg !3037
  ret void, !dbg !3038
}

declare dso_local void @z_impl_k_thread_priority_set(%struct.k_thread.188*, i32) #2

declare dso_local i32 @z_impl_k_thread_priority_get(%struct.k_thread.188*) #2

declare dso_local %struct.k_thread.188* @z_impl_k_current_get(...) #2

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.162() #0 !dbg !3039 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !3040, metadata !DIExpression()), !dbg !3041
  call void @bench_test_start.175() #3, !dbg !3042
  %2 = call i32 @TIME_STAMP_DELTA_GET.129(i32 0), !dbg !3043
  store i32 %2, i32* %1, align 4, !dbg !3044
  %3 = load i32, i32* %1, align 4, !dbg !3045
  ret i32 %3, !dbg !3046
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_pipe_put(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #0 !dbg !3047 {
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_pipe*, align 4
  %9 = alloca i8*, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32*, align 4
  %12 = alloca i32, align 4
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0
  %14 = bitcast i64* %13 to [1 x i64]*
  store [1 x i64] %5, [1 x i64]* %14, align 8
  store %struct.k_pipe* %0, %struct.k_pipe** %8, align 4
  call void @llvm.dbg.declare(metadata %struct.k_pipe** %8, metadata !3055, metadata !DIExpression()), !dbg !3056
  store i8* %1, i8** %9, align 4
  call void @llvm.dbg.declare(metadata i8** %9, metadata !3057, metadata !DIExpression()), !dbg !3058
  store i32 %2, i32* %10, align 4
  call void @llvm.dbg.declare(metadata i32* %10, metadata !3059, metadata !DIExpression()), !dbg !3060
  store i32* %3, i32** %11, align 4
  call void @llvm.dbg.declare(metadata i32** %11, metadata !3061, metadata !DIExpression()), !dbg !3062
  store i32 %4, i32* %12, align 4
  call void @llvm.dbg.declare(metadata i32* %12, metadata !3063, metadata !DIExpression()), !dbg !3064
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %7, metadata !3065, metadata !DIExpression()), !dbg !3066
  br label %15, !dbg !3067

15:                                               ; preds = %6
  call void asm sideeffect "", "~{memory}"() #4, !dbg !3068, !srcloc !3070
  br label %16, !dbg !3068

16:                                               ; preds = %15
  %17 = load %struct.k_pipe*, %struct.k_pipe** %8, align 4, !dbg !3071
  %18 = load i8*, i8** %9, align 4, !dbg !3072
  %19 = load i32, i32* %10, align 4, !dbg !3073
  %20 = load i32*, i32** %11, align 4, !dbg !3074
  %21 = load i32, i32* %12, align 4, !dbg !3075
  %22 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !3076
  %23 = bitcast i64* %22 to [1 x i64]*, !dbg !3076
  %24 = load [1 x i64], [1 x i64]* %23, align 8, !dbg !3076
  %25 = call i32 @z_impl_k_pipe_put(%struct.k_pipe* %17, i8* %18, i32 %19, i32* %20, i32 %21, [1 x i64] %24) #3, !dbg !3076
  ret i32 %25, !dbg !3077
}

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.165() #0 !dbg !3078 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.138(i64* @timestamp_check.166), !dbg !3079
  store i64 %2, i64* @timestamp_check.166, align 8, !dbg !3080
  %3 = load i64, i64* @timestamp_check.166, align 8, !dbg !3081
  %4 = icmp sge i64 %3, 1000, !dbg !3083
  br i1 %4, label %5, label %6, !dbg !3084

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !3085
  br label %7, !dbg !3085

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !3087
  br label %7, !dbg !3087

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !3088
  ret i32 %8, !dbg !3088
}

; Function Attrs: noinline nounwind optnone
define internal i32 @high_timer_overflow() #0 !dbg !3089 {
  %1 = alloca i32, align 4
  %2 = load i64, i64* @timestamp_check.166, align 8, !dbg !3090
  %3 = call i64 @k_cyc_to_ns_floor64.109(i64 4294967295), !dbg !3092
  %4 = udiv i64 %3, 1000000, !dbg !3093
  %5 = icmp uge i64 %2, %4, !dbg !3094
  br i1 %5, label %6, label %7, !dbg !3095

6:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !3096
  br label %8, !dbg !3096

7:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !3098
  br label %8, !dbg !3098

8:                                                ; preds = %7, %6
  %9 = load i32, i32* %1, align 4, !dbg !3099
  ret i32 %9, !dbg !3099
}

declare dso_local i32 @z_impl_k_pipe_put(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.175() #0 !dbg !3100 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.166, align 8, !dbg !3101
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !3102
  store i64 1, i64* %2, align 8, !dbg !3102
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !3102
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !3102
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !3102
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !3102
  %7 = call i64 @k_uptime_delta.138(i64* @timestamp_check.166), !dbg !3103
  store i64 %7, i64* @timestamp_check.166, align 8, !dbg !3104
  ret void, !dbg !3105
}

; Function Attrs: noinline nounwind optnone
define dso_local void @piperecvtask() #0 !dbg !3106 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca %struct.getinfo, align 4
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !3108, metadata !DIExpression()), !dbg !3109
  call void @llvm.dbg.declare(metadata i32* %2, metadata !3110, metadata !DIExpression()), !dbg !3111
  call void @llvm.dbg.declare(metadata i32* %3, metadata !3112, metadata !DIExpression()), !dbg !3113
  call void @llvm.dbg.declare(metadata i32* %4, metadata !3114, metadata !DIExpression()), !dbg !3115
  call void @llvm.dbg.declare(metadata i32* %5, metadata !3116, metadata !DIExpression()), !dbg !3117
  call void @llvm.dbg.declare(metadata %struct.getinfo* %6, metadata !3118, metadata !DIExpression()), !dbg !3124
  store i32 8, i32* %1, align 4, !dbg !3125
  br label %9, !dbg !3127

9:                                                ; preds = %39, %0
  %10 = load i32, i32* %1, align 4, !dbg !3128
  %11 = icmp sle i32 %10, 2048, !dbg !3130
  br i1 %11, label %12, label %42, !dbg !3131

12:                                               ; preds = %9
  store i32 0, i32* %4, align 4, !dbg !3132
  br label %13, !dbg !3135

13:                                               ; preds = %35, %12
  %14 = load i32, i32* %4, align 4, !dbg !3136
  %15 = icmp slt i32 %14, 3, !dbg !3138
  br i1 %15, label %16, label %38, !dbg !3139

16:                                               ; preds = %13
  store i32 256, i32* %3, align 4, !dbg !3140
  %17 = load i32, i32* %4, align 4, !dbg !3142
  %18 = getelementptr [0 x %struct.k_pipe*], [0 x %struct.k_pipe*]* bitcast ([3 x %struct.k_pipe*]* @test_pipes to [0 x %struct.k_pipe*]*), i32 0, i32 %17, !dbg !3143
  %19 = load %struct.k_pipe*, %struct.k_pipe** %18, align 4, !dbg !3143
  %20 = load i32, i32* %1, align 4, !dbg !3144
  %21 = load i32, i32* %3, align 4, !dbg !3145
  %22 = call i32 @pipeget(%struct.k_pipe* %19, i8 zeroext 2, i32 %20, i32 %21, i32* %2) #3, !dbg !3146
  %23 = load i32, i32* %2, align 4, !dbg !3147
  %24 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %6, i32 0, i32 1, !dbg !3148
  store i32 %23, i32* %24, align 4, !dbg !3149
  %25 = load i32, i32* %1, align 4, !dbg !3150
  %26 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %6, i32 0, i32 2, !dbg !3151
  store i32 %25, i32* %26, align 4, !dbg !3152
  %27 = load i32, i32* %3, align 4, !dbg !3153
  %28 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %6, i32 0, i32 0, !dbg !3154
  store i32 %27, i32* %28, align 4, !dbg !3155
  %29 = bitcast %struct.getinfo* %6 to i8*, !dbg !3156
  %30 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !3157
  store i64 -1, i64* %30, align 8, !dbg !3157
  %31 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !3158
  %32 = bitcast i64* %31 to [1 x i64]*, !dbg !3158
  %33 = load [1 x i64], [1 x i64]* %32, align 8, !dbg !3158
  %34 = call i32 @k_msgq_put(%struct.k_msgq* @CH_COMM, i8* %29, [1 x i64] %33), !dbg !3158
  br label %35, !dbg !3159

35:                                               ; preds = %16
  %36 = load i32, i32* %4, align 4, !dbg !3160
  %37 = add i32 %36, 1, !dbg !3160
  store i32 %37, i32* %4, align 4, !dbg !3160
  br label %13, !dbg !3161, !llvm.loop !3162

38:                                               ; preds = %13
  br label %39, !dbg !3164

39:                                               ; preds = %38
  %40 = load i32, i32* %1, align 4, !dbg !3165
  %41 = shl i32 %40, 1, !dbg !3165
  store i32 %41, i32* %1, align 4, !dbg !3165
  br label %9, !dbg !3166, !llvm.loop !3167

42:                                               ; preds = %9
  store i32 0, i32* %5, align 4, !dbg !3169
  br label %43, !dbg !3171

43:                                               ; preds = %83, %42
  %44 = load i32, i32* %5, align 4, !dbg !3172
  %45 = icmp slt i32 %44, 2, !dbg !3174
  br i1 %45, label %46, label %86, !dbg !3175

46:                                               ; preds = %43
  store i32 2048, i32* %1, align 4, !dbg !3176
  br label %47, !dbg !3179

47:                                               ; preds = %79, %46
  %48 = load i32, i32* %1, align 4, !dbg !3180
  %49 = icmp sge i32 %48, 8, !dbg !3182
  br i1 %49, label %50, label %82, !dbg !3183

50:                                               ; preds = %47
  %51 = load i32, i32* %1, align 4, !dbg !3184
  %52 = sdiv i32 2048, %51, !dbg !3186
  store i32 %52, i32* %3, align 4, !dbg !3187
  store i32 0, i32* %4, align 4, !dbg !3188
  br label %53, !dbg !3190

53:                                               ; preds = %75, %50
  %54 = load i32, i32* %4, align 4, !dbg !3191
  %55 = icmp slt i32 %54, 3, !dbg !3193
  br i1 %55, label %56, label %78, !dbg !3194

56:                                               ; preds = %53
  %57 = load i32, i32* %4, align 4, !dbg !3195
  %58 = getelementptr [0 x %struct.k_pipe*], [0 x %struct.k_pipe*]* bitcast ([3 x %struct.k_pipe*]* @test_pipes to [0 x %struct.k_pipe*]*), i32 0, i32 %57, !dbg !3197
  %59 = load %struct.k_pipe*, %struct.k_pipe** %58, align 4, !dbg !3197
  %60 = load i32, i32* %1, align 4, !dbg !3198
  %61 = load i32, i32* %3, align 4, !dbg !3199
  %62 = call i32 @pipeget(%struct.k_pipe* %59, i8 zeroext 1, i32 %60, i32 %61, i32* %2) #3, !dbg !3200
  %63 = load i32, i32* %2, align 4, !dbg !3201
  %64 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %6, i32 0, i32 1, !dbg !3202
  store i32 %63, i32* %64, align 4, !dbg !3203
  %65 = load i32, i32* %1, align 4, !dbg !3204
  %66 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %6, i32 0, i32 2, !dbg !3205
  store i32 %65, i32* %66, align 4, !dbg !3206
  %67 = load i32, i32* %3, align 4, !dbg !3207
  %68 = getelementptr inbounds %struct.getinfo, %struct.getinfo* %6, i32 0, i32 0, !dbg !3208
  store i32 %67, i32* %68, align 4, !dbg !3209
  %69 = bitcast %struct.getinfo* %6 to i8*, !dbg !3210
  %70 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !3211
  store i64 -1, i64* %70, align 8, !dbg !3211
  %71 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !3212
  %72 = bitcast i64* %71 to [1 x i64]*, !dbg !3212
  %73 = load [1 x i64], [1 x i64]* %72, align 8, !dbg !3212
  %74 = call i32 @k_msgq_put(%struct.k_msgq* @CH_COMM, i8* %69, [1 x i64] %73), !dbg !3212
  br label %75, !dbg !3213

75:                                               ; preds = %56
  %76 = load i32, i32* %4, align 4, !dbg !3214
  %77 = add i32 %76, 1, !dbg !3214
  store i32 %77, i32* %4, align 4, !dbg !3214
  br label %53, !dbg !3215, !llvm.loop !3216

78:                                               ; preds = %53
  br label %79, !dbg !3218

79:                                               ; preds = %78
  %80 = load i32, i32* %1, align 4, !dbg !3219
  %81 = ashr i32 %80, 1, !dbg !3219
  store i32 %81, i32* %1, align 4, !dbg !3219
  br label %47, !dbg !3220, !llvm.loop !3221

82:                                               ; preds = %47
  br label %83, !dbg !3223

83:                                               ; preds = %82
  %84 = load i32, i32* %5, align 4, !dbg !3224
  %85 = add i32 %84, 1, !dbg !3224
  store i32 %85, i32* %5, align 4, !dbg !3224
  br label %43, !dbg !3225, !llvm.loop !3226

86:                                               ; preds = %43
  ret void, !dbg !3228
}

; Function Attrs: noinline nounwind optnone
define dso_local i32 @pipeget(%struct.k_pipe*, i8 zeroext, i32, i32, i32*) #0 !dbg !3229 {
  %6 = alloca i32, align 4
  %7 = alloca %struct.k_pipe*, align 4
  %8 = alloca i8, align 1
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32*, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca %struct.k_timeout_t, align 8
  %17 = alloca i32, align 4
  %18 = alloca i32, align 4
  %19 = alloca i32, align 4
  %20 = alloca %struct.k_timeout_t, align 8
  store %struct.k_pipe* %0, %struct.k_pipe** %7, align 4
  call void @llvm.dbg.declare(metadata %struct.k_pipe** %7, metadata !3268, metadata !DIExpression()), !dbg !3269
  store i8 %1, i8* %8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !3270, metadata !DIExpression()), !dbg !3271
  store i32 %2, i32* %9, align 4
  call void @llvm.dbg.declare(metadata i32* %9, metadata !3272, metadata !DIExpression()), !dbg !3273
  store i32 %3, i32* %10, align 4
  call void @llvm.dbg.declare(metadata i32* %10, metadata !3274, metadata !DIExpression()), !dbg !3275
  store i32* %4, i32** %11, align 4
  call void @llvm.dbg.declare(metadata i32** %11, metadata !3276, metadata !DIExpression()), !dbg !3277
  call void @llvm.dbg.declare(metadata i32* %12, metadata !3278, metadata !DIExpression()), !dbg !3279
  call void @llvm.dbg.declare(metadata i32* %13, metadata !3280, metadata !DIExpression()), !dbg !3281
  call void @llvm.dbg.declare(metadata i32* %14, metadata !3282, metadata !DIExpression()), !dbg !3283
  store i32 0, i32* %14, align 4, !dbg !3283
  call void @llvm.dbg.declare(metadata i32* %15, metadata !3284, metadata !DIExpression()), !dbg !3285
  %21 = load i32, i32* %9, align 4, !dbg !3286
  %22 = load i32, i32* %10, align 4, !dbg !3287
  %23 = mul i32 %21, %22, !dbg !3288
  store i32 %23, i32* %15, align 4, !dbg !3285
  %24 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %16, i32 0, i32 0, !dbg !3289
  store i64 -1, i64* %24, align 8, !dbg !3289
  %25 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %16, i32 0, i32 0, !dbg !3290
  %26 = bitcast i64* %25 to [1 x i64]*, !dbg !3290
  %27 = load [1 x i64], [1 x i64]* %26, align 8, !dbg !3290
  %28 = call i32 @k_sem_take(%struct.k_sem* @SEM0, [1 x i64] %27), !dbg !3290
  %29 = call i32 @BENCH_START.180() #3, !dbg !3291
  store i32 %29, i32* %13, align 4, !dbg !3292
  store i32 0, i32* %12, align 4, !dbg !3293
  br label %30, !dbg !3295

30:                                               ; preds = %89, %5
  %31 = load i8, i8* %8, align 1, !dbg !3296
  %32 = zext i8 %31 to i32, !dbg !3296
  %33 = icmp eq i32 %32, 1, !dbg !3298
  br i1 %33, label %38, label %34, !dbg !3299

34:                                               ; preds = %30
  %35 = load i32, i32* %12, align 4, !dbg !3300
  %36 = load i32, i32* %10, align 4, !dbg !3301
  %37 = icmp slt i32 %35, %36, !dbg !3302
  br label %38, !dbg !3299

38:                                               ; preds = %34, %30
  %39 = phi i1 [ true, %30 ], [ %37, %34 ]
  br i1 %39, label %40, label %92, !dbg !3303

40:                                               ; preds = %38
  call void @llvm.dbg.declare(metadata i32* %17, metadata !3304, metadata !DIExpression()), !dbg !3306
  store i32 0, i32* %17, align 4, !dbg !3306
  call void @llvm.dbg.declare(metadata i32* %18, metadata !3307, metadata !DIExpression()), !dbg !3308
  %41 = load i32, i32* %9, align 4, !dbg !3309
  %42 = load i32, i32* %15, align 4, !dbg !3309
  %43 = load i32, i32* %14, align 4, !dbg !3309
  %44 = sub i32 %42, %43, !dbg !3309
  %45 = icmp ult i32 %41, %44, !dbg !3309
  br i1 %45, label %46, label %48, !dbg !3309

46:                                               ; preds = %40
  %47 = load i32, i32* %9, align 4, !dbg !3309
  br label %52, !dbg !3309

48:                                               ; preds = %40
  %49 = load i32, i32* %15, align 4, !dbg !3309
  %50 = load i32, i32* %14, align 4, !dbg !3309
  %51 = sub i32 %49, %50, !dbg !3309
  br label %52, !dbg !3309

52:                                               ; preds = %48, %46
  %53 = phi i32 [ %47, %46 ], [ %51, %48 ], !dbg !3309
  store i32 %53, i32* %18, align 4, !dbg !3308
  call void @llvm.dbg.declare(metadata i32* %19, metadata !3310, metadata !DIExpression()), !dbg !3311
  %54 = load %struct.k_pipe*, %struct.k_pipe** %7, align 4, !dbg !3312
  %55 = load i32, i32* %18, align 4, !dbg !3313
  %56 = load i8, i8* %8, align 1, !dbg !3314
  %57 = zext i8 %56 to i32, !dbg !3314
  %58 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %20, i32 0, i32 0, !dbg !3315
  store i64 -1, i64* %58, align 8, !dbg !3315
  %59 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %20, i32 0, i32 0, !dbg !3316
  %60 = bitcast i64* %59 to [1 x i64]*, !dbg !3316
  %61 = load [1 x i64], [1 x i64]* %60, align 8, !dbg !3316
  %62 = call i32 @k_pipe_get(%struct.k_pipe* %54, i8* getelementptr inbounds ([4096 x i8], [4096 x i8]* @data_recv, i32 0, i32 0), i32 %55, i32* %17, i32 %57, [1 x i64] %61) #3, !dbg !3316
  store i32 %62, i32* %19, align 4, !dbg !3317
  %63 = load i32, i32* %19, align 4, !dbg !3318
  %64 = icmp ne i32 %63, 0, !dbg !3320
  br i1 %64, label %65, label %66, !dbg !3321

65:                                               ; preds = %52
  store i32 1, i32* %6, align 4, !dbg !3322
  br label %118, !dbg !3322

66:                                               ; preds = %52
  %67 = load i8, i8* %8, align 1, !dbg !3324
  %68 = zext i8 %67 to i32, !dbg !3324
  %69 = icmp eq i32 %68, 2, !dbg !3326
  br i1 %69, label %70, label %75, !dbg !3327

70:                                               ; preds = %66
  %71 = load i32, i32* %17, align 4, !dbg !3328
  %72 = load i32, i32* %18, align 4, !dbg !3329
  %73 = icmp ne i32 %71, %72, !dbg !3330
  br i1 %73, label %74, label %75, !dbg !3331

74:                                               ; preds = %70
  store i32 1, i32* %6, align 4, !dbg !3332
  br label %118, !dbg !3332

75:                                               ; preds = %70, %66
  %76 = load i32, i32* %17, align 4, !dbg !3334
  %77 = load i32, i32* %14, align 4, !dbg !3335
  %78 = add i32 %77, %76, !dbg !3335
  store i32 %78, i32* %14, align 4, !dbg !3335
  %79 = load i32, i32* %15, align 4, !dbg !3336
  %80 = load i32, i32* %14, align 4, !dbg !3338
  %81 = icmp eq i32 %79, %80, !dbg !3339
  br i1 %81, label %82, label %83, !dbg !3340

82:                                               ; preds = %75
  br label %92, !dbg !3341

83:                                               ; preds = %75
  %84 = load i32, i32* %15, align 4, !dbg !3343
  %85 = load i32, i32* %14, align 4, !dbg !3345
  %86 = icmp ult i32 %84, %85, !dbg !3346
  br i1 %86, label %87, label %88, !dbg !3347

87:                                               ; preds = %83
  store i32 1, i32* %6, align 4, !dbg !3348
  br label %118, !dbg !3348

88:                                               ; preds = %83
  br label %89, !dbg !3350

89:                                               ; preds = %88
  %90 = load i32, i32* %12, align 4, !dbg !3351
  %91 = add i32 %90, 1, !dbg !3351
  store i32 %91, i32* %12, align 4, !dbg !3351
  br label %30, !dbg !3352, !llvm.loop !3353

92:                                               ; preds = %82, %38
  %93 = load i32, i32* %13, align 4, !dbg !3355
  %94 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %93), !dbg !3356
  store i32 %94, i32* %13, align 4, !dbg !3357
  %95 = load i32, i32* %13, align 4, !dbg !3358
  %96 = zext i32 %95 to i64, !dbg !3358
  %97 = call i64 @k_cyc_to_ns_floor64.109(i64 %96), !dbg !3358
  %98 = load i32, i32* %10, align 4, !dbg !3358
  %99 = sext i32 %98 to i64, !dbg !3358
  %100 = udiv i64 %97, %99, !dbg !3358
  %101 = trunc i64 %100 to i32, !dbg !3358
  %102 = load i32*, i32** %11, align 4, !dbg !3359
  store i32 %101, i32* %102, align 4, !dbg !3360
  %103 = call i32 @bench_test_end.183() #3, !dbg !3361
  %104 = icmp slt i32 %103, 0, !dbg !3363
  br i1 %104, label %105, label %117, !dbg !3364

105:                                              ; preds = %92
  %106 = call i32 @high_timer_overflow.184() #3, !dbg !3365
  %107 = icmp ne i32 %106, 0, !dbg !3365
  br i1 %107, label %108, label %111, !dbg !3368

108:                                              ; preds = %105
  %109 = load i32*, i32** @output_file, align 4, !dbg !3369
  %110 = call i32 @fputs(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.185, i32 0, i32 0), i32* %109) #3, !dbg !3369
  br label %114, !dbg !3371

111:                                              ; preds = %105
  %112 = load i32*, i32** @output_file, align 4, !dbg !3372
  %113 = call i32 @fputs(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.1.186, i32 0, i32 0), i32* %112) #3, !dbg !3372
  br label %114

114:                                              ; preds = %111, %108
  %115 = load i32*, i32** @output_file, align 4, !dbg !3374
  %116 = call i32 @fputs(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.2.187, i32 0, i32 0), i32* %115) #3, !dbg !3374
  br label %117, !dbg !3375

117:                                              ; preds = %114, %92
  store i32 0, i32* %6, align 4, !dbg !3376
  br label %118, !dbg !3376

118:                                              ; preds = %117, %87, %74, %65
  %119 = load i32, i32* %6, align 4, !dbg !3377
  ret i32 %119, !dbg !3377
}

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.180() #0 !dbg !3378 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !3379, metadata !DIExpression()), !dbg !3380
  call void @bench_test_start.197() #3, !dbg !3381
  %2 = call i32 @TIME_STAMP_DELTA_GET.129(i32 0), !dbg !3382
  store i32 %2, i32* %1, align 4, !dbg !3383
  %3 = load i32, i32* %1, align 4, !dbg !3384
  ret i32 %3, !dbg !3385
}

; Function Attrs: noinline nounwind optnone
define internal i32 @k_pipe_get(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #0 !dbg !3386 {
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_pipe*, align 4
  %9 = alloca i8*, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32*, align 4
  %12 = alloca i32, align 4
  %13 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0
  %14 = bitcast i64* %13 to [1 x i64]*
  store [1 x i64] %5, [1 x i64]* %14, align 8
  store %struct.k_pipe* %0, %struct.k_pipe** %8, align 4
  call void @llvm.dbg.declare(metadata %struct.k_pipe** %8, metadata !3393, metadata !DIExpression()), !dbg !3394
  store i8* %1, i8** %9, align 4
  call void @llvm.dbg.declare(metadata i8** %9, metadata !3395, metadata !DIExpression()), !dbg !3396
  store i32 %2, i32* %10, align 4
  call void @llvm.dbg.declare(metadata i32* %10, metadata !3397, metadata !DIExpression()), !dbg !3398
  store i32* %3, i32** %11, align 4
  call void @llvm.dbg.declare(metadata i32** %11, metadata !3399, metadata !DIExpression()), !dbg !3400
  store i32 %4, i32* %12, align 4
  call void @llvm.dbg.declare(metadata i32* %12, metadata !3401, metadata !DIExpression()), !dbg !3402
  call void @llvm.dbg.declare(metadata %struct.k_timeout_t* %7, metadata !3403, metadata !DIExpression()), !dbg !3404
  br label %15, !dbg !3405

15:                                               ; preds = %6
  call void asm sideeffect "", "~{memory}"() #4, !dbg !3406, !srcloc !3408
  br label %16, !dbg !3406

16:                                               ; preds = %15
  %17 = load %struct.k_pipe*, %struct.k_pipe** %8, align 4, !dbg !3409
  %18 = load i8*, i8** %9, align 4, !dbg !3410
  %19 = load i32, i32* %10, align 4, !dbg !3411
  %20 = load i32*, i32** %11, align 4, !dbg !3412
  %21 = load i32, i32* %12, align 4, !dbg !3413
  %22 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !3414
  %23 = bitcast i64* %22 to [1 x i64]*, !dbg !3414
  %24 = load [1 x i64], [1 x i64]* %23, align 8, !dbg !3414
  %25 = call i32 @z_impl_k_pipe_get(%struct.k_pipe* %17, i8* %18, i32 %19, i32* %20, i32 %21, [1 x i64] %24) #3, !dbg !3414
  ret i32 %25, !dbg !3415
}

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.183() #0 !dbg !3416 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.138(i64* @timestamp_check.188), !dbg !3417
  store i64 %2, i64* @timestamp_check.188, align 8, !dbg !3418
  %3 = load i64, i64* @timestamp_check.188, align 8, !dbg !3419
  %4 = icmp sge i64 %3, 1000, !dbg !3421
  br i1 %4, label %5, label %6, !dbg !3422

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !3423
  br label %7, !dbg !3423

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !3425
  br label %7, !dbg !3425

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !3426
  ret i32 %8, !dbg !3426
}

; Function Attrs: noinline nounwind optnone
define internal i32 @high_timer_overflow.184() #0 !dbg !3427 {
  %1 = alloca i32, align 4
  %2 = load i64, i64* @timestamp_check.188, align 8, !dbg !3428
  %3 = call i64 @k_cyc_to_ns_floor64.109(i64 4294967295), !dbg !3430
  %4 = udiv i64 %3, 1000000, !dbg !3431
  %5 = icmp uge i64 %2, %4, !dbg !3432
  br i1 %5, label %6, label %7, !dbg !3433

6:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !3434
  br label %8, !dbg !3434

7:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !3436
  br label %8, !dbg !3436

8:                                                ; preds = %7, %6
  %9 = load i32, i32* %1, align 4, !dbg !3437
  ret i32 %9, !dbg !3437
}

declare dso_local i32 @z_impl_k_pipe_get(%struct.k_pipe*, i8*, i32, i32*, i32, [1 x i64]) #2

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.197() #0 !dbg !3438 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.188, align 8, !dbg !3439
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !3440
  store i64 1, i64* %2, align 8, !dbg !3440
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !3440
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !3440
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !3440
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !3440
  %7 = call i64 @k_uptime_delta.138(i64* @timestamp_check.188), !dbg !3441
  store i64 %7, i64* @timestamp_check.188, align 8, !dbg !3442
  ret void, !dbg !3443
}

; Function Attrs: noinline nounwind optnone
define dso_local void @recvtask(i8*, i8*, i8*) #0 !dbg !3444 {
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca %struct.k_timeout_t, align 8
  %8 = alloca %struct.k_timeout_t, align 8
  %9 = alloca %struct.k_timeout_t, align 8
  %10 = alloca %struct.k_timeout_t, align 8
  store i8* %0, i8** %4, align 4
  call void @llvm.dbg.declare(metadata i8** %4, metadata !3445, metadata !DIExpression()), !dbg !3446
  store i8* %1, i8** %5, align 4
  call void @llvm.dbg.declare(metadata i8** %5, metadata !3447, metadata !DIExpression()), !dbg !3448
  store i8* %2, i8** %6, align 4
  call void @llvm.dbg.declare(metadata i8** %6, metadata !3449, metadata !DIExpression()), !dbg !3450
  %11 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !3451
  store i64 -1, i64* %11, align 8, !dbg !3451
  %12 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %7, i32 0, i32 0, !dbg !3452
  %13 = bitcast i64* %12 to [1 x i64]*, !dbg !3452
  %14 = load [1 x i64], [1 x i64]* %13, align 8, !dbg !3452
  %15 = call i32 @k_sem_take(%struct.k_sem* @STARTRCV, [1 x i64] %14), !dbg !3452
  call void @dequtask() #3, !dbg !3453
  %16 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !3454
  store i64 -1, i64* %16, align 8, !dbg !3454
  %17 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %8, i32 0, i32 0, !dbg !3455
  %18 = bitcast i64* %17 to [1 x i64]*, !dbg !3455
  %19 = load [1 x i64], [1 x i64]* %18, align 8, !dbg !3455
  %20 = call i32 @k_sem_take(%struct.k_sem* @STARTRCV, [1 x i64] %19), !dbg !3455
  call void @waittask() #3, !dbg !3456
  %21 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !3457
  store i64 -1, i64* %21, align 8, !dbg !3457
  %22 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %9, i32 0, i32 0, !dbg !3458
  %23 = bitcast i64* %22 to [1 x i64]*, !dbg !3458
  %24 = load [1 x i64], [1 x i64]* %23, align 8, !dbg !3458
  %25 = call i32 @k_sem_take(%struct.k_sem* @STARTRCV, [1 x i64] %24), !dbg !3458
  call void @mailrecvtask() #3, !dbg !3459
  %26 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !3460
  store i64 -1, i64* %26, align 8, !dbg !3460
  %27 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %10, i32 0, i32 0, !dbg !3461
  %28 = bitcast i64* %27 to [1 x i64]*, !dbg !3461
  %29 = load [1 x i64], [1 x i64]* %28, align 8, !dbg !3461
  %30 = call i32 @k_sem_take(%struct.k_sem* @STARTRCV, [1 x i64] %29), !dbg !3461
  call void @piperecvtask() #3, !dbg !3462
  ret void, !dbg !3463
}

; Function Attrs: noinline nounwind optnone
define dso_local void @sema_test() #0 !dbg !3464 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !3466, metadata !DIExpression()), !dbg !3467
  call void @llvm.dbg.declare(metadata i32* %2, metadata !3468, metadata !DIExpression()), !dbg !3469
  %3 = load i32*, i32** @output_file, align 4, !dbg !3470
  %4 = call i32 @fputs(i8* getelementptr inbounds ([81 x i8], [81 x i8]* @.str.206, i32 0, i32 0), i32* %3) #3, !dbg !3470
  %5 = call i32 @BENCH_START.207() #3, !dbg !3471
  store i32 %5, i32* %1, align 4, !dbg !3472
  store i32 0, i32* %2, align 4, !dbg !3473
  br label %6, !dbg !3475

6:                                                ; preds = %10, %0
  %7 = load i32, i32* %2, align 4, !dbg !3476
  %8 = icmp slt i32 %7, 500, !dbg !3478
  br i1 %8, label %9, label %13, !dbg !3479

9:                                                ; preds = %6
  call void @k_sem_give(%struct.k_sem* @SEM0), !dbg !3480
  br label %10, !dbg !3482

10:                                               ; preds = %9
  %11 = load i32, i32* %2, align 4, !dbg !3483
  %12 = add i32 %11, 1, !dbg !3483
  store i32 %12, i32* %2, align 4, !dbg !3483
  br label %6, !dbg !3484, !llvm.loop !3485

13:                                               ; preds = %6
  %14 = load i32, i32* %1, align 4, !dbg !3487
  %15 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %14), !dbg !3488
  store i32 %15, i32* %1, align 4, !dbg !3489
  call void @check_result.210() #3, !dbg !3490
  %16 = load i32, i32* %1, align 4, !dbg !3491
  %17 = zext i32 %16 to i64, !dbg !3491
  %18 = call i64 @k_cyc_to_ns_floor64.109(i64 %17), !dbg !3491
  %19 = udiv i64 %18, 500, !dbg !3491
  %20 = trunc i64 %19 to i32, !dbg !3491
  %21 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1.212, i32 0, i32 0), i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.2.213, i32 0, i32 0), i32 %20) #3, !dbg !3491
  %22 = load i32*, i32** @output_file, align 4, !dbg !3491
  %23 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %22) #3, !dbg !3491
  call void @k_sem_reset.149(%struct.k_sem* @SEM1), !dbg !3493
  call void @k_sem_give(%struct.k_sem* @STARTRCV), !dbg !3494
  %24 = call i32 @BENCH_START.207() #3, !dbg !3495
  store i32 %24, i32* %1, align 4, !dbg !3496
  store i32 0, i32* %2, align 4, !dbg !3497
  br label %25, !dbg !3499

25:                                               ; preds = %29, %13
  %26 = load i32, i32* %2, align 4, !dbg !3500
  %27 = icmp slt i32 %26, 500, !dbg !3502
  br i1 %27, label %28, label %32, !dbg !3503

28:                                               ; preds = %25
  call void @k_sem_give(%struct.k_sem* @SEM1), !dbg !3504
  br label %29, !dbg !3506

29:                                               ; preds = %28
  %30 = load i32, i32* %2, align 4, !dbg !3507
  %31 = add i32 %30, 1, !dbg !3507
  store i32 %31, i32* %2, align 4, !dbg !3507
  br label %25, !dbg !3508, !llvm.loop !3509

32:                                               ; preds = %25
  %33 = load i32, i32* %1, align 4, !dbg !3511
  %34 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %33), !dbg !3512
  store i32 %34, i32* %1, align 4, !dbg !3513
  call void @check_result.210() #3, !dbg !3514
  %35 = load i32, i32* %1, align 4, !dbg !3515
  %36 = zext i32 %35 to i64, !dbg !3515
  %37 = call i64 @k_cyc_to_ns_floor64.109(i64 %36), !dbg !3515
  %38 = udiv i64 %37, 500, !dbg !3515
  %39 = trunc i64 %38 to i32, !dbg !3515
  %40 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1.212, i32 0, i32 0), i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.3.215, i32 0, i32 0), i32 %39) #3, !dbg !3515
  %41 = load i32*, i32** @output_file, align 4, !dbg !3515
  %42 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %41) #3, !dbg !3515
  %43 = call i32 @BENCH_START.207() #3, !dbg !3517
  store i32 %43, i32* %1, align 4, !dbg !3518
  store i32 0, i32* %2, align 4, !dbg !3519
  br label %44, !dbg !3521

44:                                               ; preds = %48, %32
  %45 = load i32, i32* %2, align 4, !dbg !3522
  %46 = icmp slt i32 %45, 500, !dbg !3524
  br i1 %46, label %47, label %51, !dbg !3525

47:                                               ; preds = %44
  call void @k_sem_give(%struct.k_sem* @SEM1), !dbg !3526
  br label %48, !dbg !3528

48:                                               ; preds = %47
  %49 = load i32, i32* %2, align 4, !dbg !3529
  %50 = add i32 %49, 1, !dbg !3529
  store i32 %50, i32* %2, align 4, !dbg !3529
  br label %44, !dbg !3530, !llvm.loop !3531

51:                                               ; preds = %44
  %52 = load i32, i32* %1, align 4, !dbg !3533
  %53 = call i32 @TIME_STAMP_DELTA_GET.129(i32 %52), !dbg !3534
  store i32 %53, i32* %1, align 4, !dbg !3535
  call void @check_result.210() #3, !dbg !3536
  %54 = load i32, i32* %1, align 4, !dbg !3537
  %55 = zext i32 %54 to i64, !dbg !3537
  %56 = call i64 @k_cyc_to_ns_floor64.109(i64 %55), !dbg !3537
  %57 = udiv i64 %56, 500, !dbg !3537
  %58 = trunc i64 %57 to i32, !dbg !3537
  %59 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.1.212, i32 0, i32 0), i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str.4.216, i32 0, i32 0), i32 %58) #3, !dbg !3537
  %60 = load i32*, i32** @output_file, align 4, !dbg !3537
  %61 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %60) #3, !dbg !3537
  ret void, !dbg !3539
}

; Function Attrs: noinline nounwind optnone
define internal i32 @BENCH_START.207() #0 !dbg !3540 {
  %1 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !3541, metadata !DIExpression()), !dbg !3542
  call void @bench_test_start.229() #3, !dbg !3543
  %2 = call i32 @TIME_STAMP_DELTA_GET.129(i32 0), !dbg !3544
  store i32 %2, i32* %1, align 4, !dbg !3545
  %3 = load i32, i32* %1, align 4, !dbg !3546
  ret i32 %3, !dbg !3547
}

; Function Attrs: noinline nounwind optnone
define internal void @check_result.210() #0 !dbg !3548 {
  %1 = call i32 @bench_test_end.219() #3, !dbg !3549
  %2 = icmp slt i32 %1, 0, !dbg !3551
  br i1 %2, label %3, label %7, !dbg !3552

3:                                                ; preds = %0
  %4 = call i32 (i8*, i32, i8*, ...) @snprintf(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32 256, i8* getelementptr inbounds ([77 x i8], [77 x i8]* @.str.5.220, i32 0, i32 0), i32 187) #3, !dbg !3553
  %5 = load i32*, i32** @output_file, align 4, !dbg !3553
  %6 = call i32 @fputs(i8* getelementptr inbounds ([257 x i8], [257 x i8]* @sline, i32 0, i32 0), i32* %5) #3, !dbg !3553
  br label %7, !dbg !3556

7:                                                ; preds = %3, %0
  ret void, !dbg !3557
}

; Function Attrs: noinline nounwind optnone
define internal i32 @bench_test_end.219() #0 !dbg !3558 {
  %1 = alloca i32, align 4
  %2 = call i64 @k_uptime_delta.138(i64* @timestamp_check.221), !dbg !3559
  store i64 %2, i64* @timestamp_check.221, align 8, !dbg !3560
  %3 = load i64, i64* @timestamp_check.221, align 8, !dbg !3561
  %4 = icmp sge i64 %3, 1000, !dbg !3563
  br i1 %4, label %5, label %6, !dbg !3564

5:                                                ; preds = %0
  store i32 -1, i32* %1, align 4, !dbg !3565
  br label %7, !dbg !3565

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4, !dbg !3567
  br label %7, !dbg !3567

7:                                                ; preds = %6, %5
  %8 = load i32, i32* %1, align 4, !dbg !3568
  ret i32 %8, !dbg !3568
}

; Function Attrs: noinline nounwind optnone
define internal void @bench_test_start.229() #0 !dbg !3569 {
  %1 = alloca %struct.k_timeout_t, align 8
  store i64 0, i64* @timestamp_check.221, align 8, !dbg !3570
  %2 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !3571
  store i64 1, i64* %2, align 8, !dbg !3571
  %3 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %1, i32 0, i32 0, !dbg !3571
  %4 = bitcast i64* %3 to [1 x i64]*, !dbg !3571
  %5 = load [1 x i64], [1 x i64]* %4, align 8, !dbg !3571
  %6 = call i32 @k_sleep([1 x i64] %5), !dbg !3571
  %7 = call i64 @k_uptime_delta.138(i64* @timestamp_check.221), !dbg !3572
  store i64 %7, i64* @timestamp_check.221, align 8, !dbg !3573
  ret void, !dbg !3574
}

; Function Attrs: noinline nounwind optnone
define dso_local void @waittask() #0 !dbg !3575 {
  %1 = alloca i32, align 4
  %2 = alloca %struct.k_timeout_t, align 8
  %3 = alloca %struct.k_timeout_t, align 8
  call void @llvm.dbg.declare(metadata i32* %1, metadata !3577, metadata !DIExpression()), !dbg !3578
  store i32 0, i32* %1, align 4, !dbg !3579
  br label %4, !dbg !3581

4:                                                ; preds = %13, %0
  %5 = load i32, i32* %1, align 4, !dbg !3582
  %6 = icmp slt i32 %5, 500, !dbg !3584
  br i1 %6, label %7, label %16, !dbg !3585

7:                                                ; preds = %4
  %8 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !3586
  store i64 -1, i64* %8, align 8, !dbg !3586
  %9 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %2, i32 0, i32 0, !dbg !3588
  %10 = bitcast i64* %9 to [1 x i64]*, !dbg !3588
  %11 = load [1 x i64], [1 x i64]* %10, align 8, !dbg !3588
  %12 = call i32 @k_sem_take(%struct.k_sem* @SEM1, [1 x i64] %11), !dbg !3588
  br label %13, !dbg !3589

13:                                               ; preds = %7
  %14 = load i32, i32* %1, align 4, !dbg !3590
  %15 = add i32 %14, 1, !dbg !3590
  store i32 %15, i32* %1, align 4, !dbg !3590
  br label %4, !dbg !3591, !llvm.loop !3592

16:                                               ; preds = %4
  store i32 0, i32* %1, align 4, !dbg !3594
  br label %17, !dbg !3596

17:                                               ; preds = %27, %16
  %18 = load i32, i32* %1, align 4, !dbg !3597
  %19 = icmp slt i32 %18, 500, !dbg !3599
  br i1 %19, label %20, label %30, !dbg !3600

20:                                               ; preds = %17
  %21 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !3601
  %22 = call i64 @k_ms_to_ticks_ceil64(i64 5000) #3, !dbg !3601
  store i64 %22, i64* %21, align 8, !dbg !3601
  %23 = getelementptr inbounds %struct.k_timeout_t, %struct.k_timeout_t* %3, i32 0, i32 0, !dbg !3603
  %24 = bitcast i64* %23 to [1 x i64]*, !dbg !3603
  %25 = load [1 x i64], [1 x i64]* %24, align 8, !dbg !3603
  %26 = call i32 @k_sem_take(%struct.k_sem* @SEM1, [1 x i64] %25), !dbg !3603
  br label %27, !dbg !3604

27:                                               ; preds = %20
  %28 = load i32, i32* %1, align 4, !dbg !3605
  %29 = add i32 %28, 1, !dbg !3605
  store i32 %29, i32* %1, align 4, !dbg !3605
  br label %17, !dbg !3606, !llvm.loop !3607

30:                                               ; preds = %17
  ret void, !dbg !3609
}

; Function Attrs: noinline nounwind optnone
define internal i64 @k_ms_to_ticks_ceil64(i64) #0 !dbg !3610 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %3, metadata !3611, metadata !DIExpression()), !dbg !3613
  %4 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !3615, metadata !DIExpression()), !dbg !3616
  %5 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %5, metadata !3617, metadata !DIExpression()), !dbg !3618
  %6 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %6, metadata !3619, metadata !DIExpression()), !dbg !3620
  %7 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %7, metadata !3621, metadata !DIExpression()), !dbg !3622
  %8 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %8, metadata !3623, metadata !DIExpression()), !dbg !3624
  %9 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %9, metadata !3625, metadata !DIExpression()), !dbg !3626
  %10 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %10, metadata !3627, metadata !DIExpression()), !dbg !3628
  %11 = alloca i8, align 1
  call void @llvm.dbg.declare(metadata i8* %11, metadata !3629, metadata !DIExpression()), !dbg !3630
  %12 = alloca i64, align 8
  call void @llvm.dbg.declare(metadata i64* %12, metadata !3631, metadata !DIExpression()), !dbg !3632
  %13 = alloca i32, align 4
  call void @llvm.dbg.declare(metadata i32* %13, metadata !3633, metadata !DIExpression()), !dbg !3636
  %14 = alloca i64, align 8
  store i64 %0, i64* %14, align 8
  call void @llvm.dbg.declare(metadata i64* %14, metadata !3637, metadata !DIExpression()), !dbg !3638
  %15 = load i64, i64* %14, align 8, !dbg !3639
  store i64 %15, i64* %3, align 8
  store i32 1000, i32* %4, align 4
  store i32 2, i32* %5, align 4
  store i8 1, i8* %6, align 1
  store i8 0, i8* %7, align 1
  store i8 1, i8* %8, align 1
  store i8 0, i8* %9, align 1
  %16 = load i8, i8* %6, align 1, !dbg !3640
  %17 = trunc i8 %16 to i1, !dbg !3640
  br i1 %17, label %18, label %27, !dbg !3641

18:                                               ; preds = %1
  %19 = load i32, i32* %5, align 4, !dbg !3642
  %20 = load i32, i32* %4, align 4, !dbg !3643
  %21 = icmp ugt i32 %19, %20, !dbg !3644
  br i1 %21, label %22, label %27, !dbg !3645

22:                                               ; preds = %18
  %23 = load i32, i32* %5, align 4, !dbg !3646
  %24 = load i32, i32* %4, align 4, !dbg !3647
  %25 = urem i32 %23, %24, !dbg !3648
  %26 = icmp eq i32 %25, 0, !dbg !3649
  br label %27

27:                                               ; preds = %22, %18, %1
  %28 = phi i1 [ false, %18 ], [ false, %1 ], [ %26, %22 ], !dbg !3650
  %29 = zext i1 %28 to i8, !dbg !3628
  store i8 %29, i8* %10, align 1, !dbg !3628
  %30 = load i8, i8* %6, align 1, !dbg !3651
  %31 = trunc i8 %30 to i1, !dbg !3651
  br i1 %31, label %32, label %41, !dbg !3652

32:                                               ; preds = %27
  %33 = load i32, i32* %4, align 4, !dbg !3653
  %34 = load i32, i32* %5, align 4, !dbg !3654
  %35 = icmp ugt i32 %33, %34, !dbg !3655
  br i1 %35, label %36, label %41, !dbg !3656

36:                                               ; preds = %32
  %37 = load i32, i32* %4, align 4, !dbg !3657
  %38 = load i32, i32* %5, align 4, !dbg !3658
  %39 = urem i32 %37, %38, !dbg !3659
  %40 = icmp eq i32 %39, 0, !dbg !3660
  br label %41

41:                                               ; preds = %36, %32, %27
  %42 = phi i1 [ false, %32 ], [ false, %27 ], [ %40, %36 ], !dbg !3650
  %43 = zext i1 %42 to i8, !dbg !3630
  store i8 %43, i8* %11, align 1, !dbg !3630
  %44 = load i32, i32* %4, align 4, !dbg !3661
  %45 = load i32, i32* %5, align 4, !dbg !3663
  %46 = icmp eq i32 %44, %45, !dbg !3664
  br i1 %46, label %47, label %58, !dbg !3665

47:                                               ; preds = %41
  %48 = load i8, i8* %7, align 1, !dbg !3666
  %49 = trunc i8 %48 to i1, !dbg !3666
  br i1 %49, label %50, label %54, !dbg !3666

50:                                               ; preds = %47
  %51 = load i64, i64* %3, align 8, !dbg !3668
  %52 = trunc i64 %51 to i32, !dbg !3669
  %53 = zext i32 %52 to i64, !dbg !3670
  br label %56, !dbg !3666

54:                                               ; preds = %47
  %55 = load i64, i64* %3, align 8, !dbg !3671
  br label %56, !dbg !3666

56:                                               ; preds = %54, %50
  %57 = phi i64 [ %53, %50 ], [ %55, %54 ], !dbg !3666
  store i64 %57, i64* %2, align 8, !dbg !3672
  br label %160, !dbg !3672

58:                                               ; preds = %41
  store i64 0, i64* %12, align 8, !dbg !3632
  %59 = load i8, i8* %10, align 1, !dbg !3673
  %60 = trunc i8 %59 to i1, !dbg !3673
  br i1 %60, label %87, label %61, !dbg !3674

61:                                               ; preds = %58
  %62 = load i8, i8* %11, align 1, !dbg !3675
  %63 = trunc i8 %62 to i1, !dbg !3675
  br i1 %63, label %64, label %68, !dbg !3675

64:                                               ; preds = %61
  %65 = load i32, i32* %4, align 4, !dbg !3676
  %66 = load i32, i32* %5, align 4, !dbg !3677
  %67 = udiv i32 %65, %66, !dbg !3678
  br label %70, !dbg !3675

68:                                               ; preds = %61
  %69 = load i32, i32* %4, align 4, !dbg !3679
  br label %70, !dbg !3675

70:                                               ; preds = %68, %64
  %71 = phi i32 [ %67, %64 ], [ %69, %68 ], !dbg !3675
  store i32 %71, i32* %13, align 4, !dbg !3636
  %72 = load i8, i8* %8, align 1, !dbg !3680
  %73 = trunc i8 %72 to i1, !dbg !3680
  br i1 %73, label %74, label %78, !dbg !3682

74:                                               ; preds = %70
  %75 = load i32, i32* %13, align 4, !dbg !3683
  %76 = sub i32 %75, 1, !dbg !3685
  %77 = zext i32 %76 to i64, !dbg !3683
  store i64 %77, i64* %12, align 8, !dbg !3686
  br label %86, !dbg !3687

78:                                               ; preds = %70
  %79 = load i8, i8* %9, align 1, !dbg !3688
  %80 = trunc i8 %79 to i1, !dbg !3688
  br i1 %80, label %81, label %85, !dbg !3690

81:                                               ; preds = %78
  %82 = load i32, i32* %13, align 4, !dbg !3691
  %83 = udiv i32 %82, 2, !dbg !3693
  %84 = zext i32 %83 to i64, !dbg !3691
  store i64 %84, i64* %12, align 8, !dbg !3694
  br label %85, !dbg !3695

85:                                               ; preds = %81, %78
  br label %86

86:                                               ; preds = %85, %74
  br label %87, !dbg !3696

87:                                               ; preds = %86, %58
  %88 = load i8, i8* %11, align 1, !dbg !3697
  %89 = trunc i8 %88 to i1, !dbg !3697
  br i1 %89, label %90, label %114, !dbg !3699

90:                                               ; preds = %87
  %91 = load i64, i64* %12, align 8, !dbg !3700
  %92 = load i64, i64* %3, align 8, !dbg !3702
  %93 = add i64 %92, %91, !dbg !3702
  store i64 %93, i64* %3, align 8, !dbg !3702
  %94 = load i8, i8* %7, align 1, !dbg !3703
  %95 = trunc i8 %94 to i1, !dbg !3703
  br i1 %95, label %96, label %107, !dbg !3705

96:                                               ; preds = %90
  %97 = load i64, i64* %3, align 8, !dbg !3706
  %98 = icmp ult i64 %97, 4294967296, !dbg !3707
  br i1 %98, label %99, label %107, !dbg !3708

99:                                               ; preds = %96
  %100 = load i64, i64* %3, align 8, !dbg !3709
  %101 = trunc i64 %100 to i32, !dbg !3711
  %102 = load i32, i32* %4, align 4, !dbg !3712
  %103 = load i32, i32* %5, align 4, !dbg !3713
  %104 = udiv i32 %102, %103, !dbg !3714
  %105 = udiv i32 %101, %104, !dbg !3715
  %106 = zext i32 %105 to i64, !dbg !3716
  store i64 %106, i64* %2, align 8, !dbg !3717
  br label %160, !dbg !3717

107:                                              ; preds = %96, %90
  %108 = load i64, i64* %3, align 8, !dbg !3718
  %109 = load i32, i32* %4, align 4, !dbg !3720
  %110 = load i32, i32* %5, align 4, !dbg !3721
  %111 = udiv i32 %109, %110, !dbg !3722
  %112 = zext i32 %111 to i64, !dbg !3723
  %113 = udiv i64 %108, %112, !dbg !3724
  store i64 %113, i64* %2, align 8, !dbg !3725
  br label %160, !dbg !3725

114:                                              ; preds = %87
  %115 = load i8, i8* %10, align 1, !dbg !3726
  %116 = trunc i8 %115 to i1, !dbg !3726
  br i1 %116, label %117, label %135, !dbg !3728

117:                                              ; preds = %114
  %118 = load i8, i8* %7, align 1, !dbg !3729
  %119 = trunc i8 %118 to i1, !dbg !3729
  br i1 %119, label %120, label %128, !dbg !3732

120:                                              ; preds = %117
  %121 = load i64, i64* %3, align 8, !dbg !3733
  %122 = trunc i64 %121 to i32, !dbg !3735
  %123 = load i32, i32* %5, align 4, !dbg !3736
  %124 = load i32, i32* %4, align 4, !dbg !3737
  %125 = udiv i32 %123, %124, !dbg !3738
  %126 = mul i32 %122, %125, !dbg !3739
  %127 = zext i32 %126 to i64, !dbg !3740
  store i64 %127, i64* %2, align 8, !dbg !3741
  br label %160, !dbg !3741

128:                                              ; preds = %117
  %129 = load i64, i64* %3, align 8, !dbg !3742
  %130 = load i32, i32* %5, align 4, !dbg !3744
  %131 = load i32, i32* %4, align 4, !dbg !3745
  %132 = udiv i32 %130, %131, !dbg !3746
  %133 = zext i32 %132 to i64, !dbg !3747
  %134 = mul i64 %129, %133, !dbg !3748
  store i64 %134, i64* %2, align 8, !dbg !3749
  br label %160, !dbg !3749

135:                                              ; preds = %114
  %136 = load i8, i8* %7, align 1, !dbg !3750
  %137 = trunc i8 %136 to i1, !dbg !3750
  br i1 %137, label %138, label %150, !dbg !3753

138:                                              ; preds = %135
  %139 = load i64, i64* %3, align 8, !dbg !3754
  %140 = load i32, i32* %5, align 4, !dbg !3756
  %141 = zext i32 %140 to i64, !dbg !3756
  %142 = mul i64 %139, %141, !dbg !3757
  %143 = load i64, i64* %12, align 8, !dbg !3758
  %144 = add i64 %142, %143, !dbg !3759
  %145 = load i32, i32* %4, align 4, !dbg !3760
  %146 = zext i32 %145 to i64, !dbg !3760
  %147 = udiv i64 %144, %146, !dbg !3761
  %148 = trunc i64 %147 to i32, !dbg !3762
  %149 = zext i32 %148 to i64, !dbg !3762
  store i64 %149, i64* %2, align 8, !dbg !3763
  br label %160, !dbg !3763

150:                                              ; preds = %135
  %151 = load i64, i64* %3, align 8, !dbg !3764
  %152 = load i32, i32* %5, align 4, !dbg !3766
  %153 = zext i32 %152 to i64, !dbg !3766
  %154 = mul i64 %151, %153, !dbg !3767
  %155 = load i64, i64* %12, align 8, !dbg !3768
  %156 = add i64 %154, %155, !dbg !3769
  %157 = load i32, i32* %4, align 4, !dbg !3770
  %158 = zext i32 %157 to i64, !dbg !3770
  %159 = udiv i64 %156, %158, !dbg !3771
  store i64 %159, i64* %2, align 8, !dbg !3772
  br label %160, !dbg !3772

160:                                              ; preds = %150, %138, %128, %120, %107, %99, %56
  %161 = load i64, i64* %2, align 8, !dbg !3773
  ret i64 %161, !dbg !3774
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #1 = { nounwind readnone speculatable }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+hwdiv,+soft-float,+strict-align,+thumb-mode,-aes,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fp64,-fpregs,-fullfp16,-hwdiv-arm,-lob,-mve,-mve.fp,-neon,-ras,-sb,-sha2,-vfp2,-vfp2d16,-vfp2d16sp,-vfp2sp,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" "unsafe-fp-math"="false" "use-soft-float"="true" }
attributes #3 = { nobuiltin }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2, !597, !66, !241, !246, !554, !559, !564, !569, !581, !586, !593, !599}
!llvm.ident = !{!602, !602, !602, !602, !602, !602, !602, !602, !602, !602, !602, !602, !602}
!llvm.module.flags = !{!603, !604, !605, !606}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !2, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !62, nameTableKind: None)
!3 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/fifo_b.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "k_objects", file: !6, line: 121, baseType: !7, size: 8, elements: !8)
!6 = !DIFile(filename: "zephyrproject/zephyr/include/kernel.h", directory: "/home/kenny")
!7 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!8 = !{!9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49, !50, !51}
!9 = !DIEnumerator(name: "K_OBJ_ANY", value: 0, isUnsigned: true)
!10 = !DIEnumerator(name: "K_OBJ_MEM_SLAB", value: 1, isUnsigned: true)
!11 = !DIEnumerator(name: "K_OBJ_MSGQ", value: 2, isUnsigned: true)
!12 = !DIEnumerator(name: "K_OBJ_MUTEX", value: 3, isUnsigned: true)
!13 = !DIEnumerator(name: "K_OBJ_PIPE", value: 4, isUnsigned: true)
!14 = !DIEnumerator(name: "K_OBJ_QUEUE", value: 5, isUnsigned: true)
!15 = !DIEnumerator(name: "K_OBJ_POLL_SIGNAL", value: 6, isUnsigned: true)
!16 = !DIEnumerator(name: "K_OBJ_SEM", value: 7, isUnsigned: true)
!17 = !DIEnumerator(name: "K_OBJ_STACK", value: 8, isUnsigned: true)
!18 = !DIEnumerator(name: "K_OBJ_THREAD", value: 9, isUnsigned: true)
!19 = !DIEnumerator(name: "K_OBJ_TIMER", value: 10, isUnsigned: true)
!20 = !DIEnumerator(name: "K_OBJ_THREAD_STACK_ELEMENT", value: 11, isUnsigned: true)
!21 = !DIEnumerator(name: "K_OBJ_NET_SOCKET", value: 12, isUnsigned: true)
!22 = !DIEnumerator(name: "K_OBJ_NET_IF", value: 13, isUnsigned: true)
!23 = !DIEnumerator(name: "K_OBJ_SYS_MUTEX", value: 14, isUnsigned: true)
!24 = !DIEnumerator(name: "K_OBJ_FUTEX", value: 15, isUnsigned: true)
!25 = !DIEnumerator(name: "K_OBJ_DRIVER_PTP_CLOCK", value: 16, isUnsigned: true)
!26 = !DIEnumerator(name: "K_OBJ_DRIVER_CRYPTO", value: 17, isUnsigned: true)
!27 = !DIEnumerator(name: "K_OBJ_DRIVER_ADC", value: 18, isUnsigned: true)
!28 = !DIEnumerator(name: "K_OBJ_DRIVER_CAN", value: 19, isUnsigned: true)
!29 = !DIEnumerator(name: "K_OBJ_DRIVER_COUNTER", value: 20, isUnsigned: true)
!30 = !DIEnumerator(name: "K_OBJ_DRIVER_DAC", value: 21, isUnsigned: true)
!31 = !DIEnumerator(name: "K_OBJ_DRIVER_DMA", value: 22, isUnsigned: true)
!32 = !DIEnumerator(name: "K_OBJ_DRIVER_EC_HOST_CMD_PERIPH_API", value: 23, isUnsigned: true)
!33 = !DIEnumerator(name: "K_OBJ_DRIVER_EEPROM", value: 24, isUnsigned: true)
!34 = !DIEnumerator(name: "K_OBJ_DRIVER_ENTROPY", value: 25, isUnsigned: true)
!35 = !DIEnumerator(name: "K_OBJ_DRIVER_ESPI", value: 26, isUnsigned: true)
!36 = !DIEnumerator(name: "K_OBJ_DRIVER_FLASH", value: 27, isUnsigned: true)
!37 = !DIEnumerator(name: "K_OBJ_DRIVER_GPIO", value: 28, isUnsigned: true)
!38 = !DIEnumerator(name: "K_OBJ_DRIVER_I2C", value: 29, isUnsigned: true)
!39 = !DIEnumerator(name: "K_OBJ_DRIVER_I2S", value: 30, isUnsigned: true)
!40 = !DIEnumerator(name: "K_OBJ_DRIVER_IPM", value: 31, isUnsigned: true)
!41 = !DIEnumerator(name: "K_OBJ_DRIVER_KSCAN", value: 32, isUnsigned: true)
!42 = !DIEnumerator(name: "K_OBJ_DRIVER_LED", value: 33, isUnsigned: true)
!43 = !DIEnumerator(name: "K_OBJ_DRIVER_PINMUX", value: 34, isUnsigned: true)
!44 = !DIEnumerator(name: "K_OBJ_DRIVER_PS2", value: 35, isUnsigned: true)
!45 = !DIEnumerator(name: "K_OBJ_DRIVER_PWM", value: 36, isUnsigned: true)
!46 = !DIEnumerator(name: "K_OBJ_DRIVER_SENSOR", value: 37, isUnsigned: true)
!47 = !DIEnumerator(name: "K_OBJ_DRIVER_SPI", value: 38, isUnsigned: true)
!48 = !DIEnumerator(name: "K_OBJ_DRIVER_UART", value: 39, isUnsigned: true)
!49 = !DIEnumerator(name: "K_OBJ_DRIVER_WDT", value: 40, isUnsigned: true)
!50 = !DIEnumerator(name: "K_OBJ_DRIVER_UART_MUX", value: 41, isUnsigned: true)
!51 = !DIEnumerator(name: "K_OBJ_LAST", value: 42, isUnsigned: true)
!52 = !{!53, !58, !60, !61}
!53 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_ticks_t", file: !54, line: 46, baseType: !55)
!54 = !DIFile(filename: "zephyrproject/zephyr/include/sys_clock.h", directory: "/home/kenny")
!55 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !56, line: 43, baseType: !57)
!56 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdint.h", directory: "/home/kenny")
!57 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!58 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !56, line: 57, baseType: !59)
!59 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!60 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32)
!61 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!62 = !{!0}
!63 = !DIFile(filename: "zephyrproject/zephyr/subsys/testsuite/include/timestamp.h", directory: "/home/kenny")
!64 = !DIGlobalVariableExpression(var: !65, expr: !DIExpression())
!65 = distinct !DIGlobalVariable(name: "message", scope: !66, file: !74, line: 13, type: !75, isLocal: true, isDefinition: true)
!66 = distinct !DICompileUnit(language: DW_LANG_C99, file: !67, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !68, globals: !71, nameTableKind: None)
!67 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/mailbox_b.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!68 = !{!53, !58, !69, !60, !61}
!69 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !56, line: 58, baseType: !70)
!70 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!71 = !{!64, !72}
!72 = !DIGlobalVariableExpression(var: !73, expr: !DIExpression())
!73 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !66, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!74 = !DIFile(filename: "appl/Zephyr/app_kernel/src/mailbox_b.c", directory: "/home/kenny/ara")
!75 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mbox_msg", file: !6, line: 4124, size: 352, elements: !76)
!76 = !{!77, !78, !81, !82, !83, !84, !136, !230, !231, !232}
!77 = !DIDerivedType(tag: DW_TAG_member, name: "_mailbox", scope: !75, file: !6, line: 4126, baseType: !58, size: 32)
!78 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !75, file: !6, line: 4128, baseType: !79, size: 32, offset: 32)
!79 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !80, line: 46, baseType: !59)
!80 = !DIFile(filename: "/usr/lib/llvm-9/lib/clang/9.0.1/include/stddef.h", directory: "")
!81 = !DIDerivedType(tag: DW_TAG_member, name: "info", scope: !75, file: !6, line: 4130, baseType: !58, size: 32, offset: 64)
!82 = !DIDerivedType(tag: DW_TAG_member, name: "tx_data", scope: !75, file: !6, line: 4132, baseType: !60, size: 32, offset: 96)
!83 = !DIDerivedType(tag: DW_TAG_member, name: "_rx_data", scope: !75, file: !6, line: 4134, baseType: !60, size: 32, offset: 128)
!84 = !DIDerivedType(tag: DW_TAG_member, name: "tx_block", scope: !75, file: !6, line: 4136, baseType: !85, size: 64, offset: 160)
!85 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_block", file: !86, line: 23, size: 64, elements: !87)
!86 = !DIFile(filename: "zephyrproject/zephyr/include/mempool_heap.h", directory: "/home/kenny")
!87 = !{!88}
!88 = !DIDerivedType(tag: DW_TAG_member, scope: !85, file: !86, line: 24, baseType: !89, size: 64)
!89 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !85, file: !86, line: 24, size: 64, elements: !90)
!90 = !{!91, !92}
!91 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !89, file: !86, line: 25, baseType: !60, size: 32)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !89, file: !86, line: 26, baseType: !93, size: 64)
!93 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_block_id", file: !86, line: 15, size: 64, elements: !94)
!94 = !{!95, !96}
!95 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !93, file: !86, line: 16, baseType: !60, size: 32)
!96 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !93, file: !86, line: 17, baseType: !97, size: 32, offset: 32)
!97 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !98, size: 32)
!98 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !99, line: 267, size: 192, elements: !100)
!99 = !DIFile(filename: "zephyrproject/zephyr/include/kernel_structs.h", directory: "/home/kenny")
!100 = !{!101, !110, !130}
!101 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !98, file: !99, line: 268, baseType: !102, size: 96)
!102 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !103, line: 51, size: 96, elements: !104)
!103 = !DIFile(filename: "zephyrproject/zephyr/include/sys/sys_heap.h", directory: "/home/kenny")
!104 = !{!105, !108, !109}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !102, file: !103, line: 52, baseType: !106, size: 32)
!106 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !107, size: 32)
!107 = !DICompositeType(tag: DW_TAG_structure_type, name: "z_heap", file: !103, line: 52, flags: DIFlagFwdDecl)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !102, file: !103, line: 53, baseType: !60, size: 32, offset: 32)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !102, file: !103, line: 54, baseType: !79, size: 32, offset: 64)
!110 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !98, file: !99, line: 269, baseType: !111, size: 64, offset: 96)
!111 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !112)
!112 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !113)
!113 = !{!114}
!114 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !112, file: !99, line: 209, baseType: !115, size: 64)
!115 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !117)
!116 = !DIFile(filename: "zephyrproject/zephyr/include/sys/dlist.h", directory: "/home/kenny")
!117 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !118)
!118 = !{!119, !125}
!119 = !DIDerivedType(tag: DW_TAG_member, scope: !117, file: !116, line: 32, baseType: !120, size: 32)
!120 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !117, file: !116, line: 32, size: 32, elements: !121)
!121 = !{!122, !124}
!122 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !120, file: !116, line: 33, baseType: !123, size: 32)
!123 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !117, size: 32)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !120, file: !116, line: 34, baseType: !123, size: 32)
!125 = !DIDerivedType(tag: DW_TAG_member, scope: !117, file: !116, line: 36, baseType: !126, size: 32, offset: 32)
!126 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !117, file: !116, line: 36, size: 32, elements: !127)
!127 = !{!128, !129}
!128 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !126, file: !116, line: 37, baseType: !123, size: 32)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !126, file: !116, line: 38, baseType: !123, size: 32)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !98, file: !99, line: 270, baseType: !131, size: 32, offset: 160)
!131 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !132)
!132 = !{!133}
!133 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !131, file: !99, line: 243, baseType: !134, size: 32)
!134 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !56, line: 71, baseType: !135)
!135 = !DIBasicType(name: "long unsigned int", size: 32, encoding: DW_ATE_unsigned)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "rx_source_thread", scope: !75, file: !6, line: 4138, baseType: !137, size: 32, offset: 224)
!137 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !138)
!138 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !139, size: 32)
!139 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1280, elements: !140)
!140 = !{!141, !190, !203, !204, !208, !213, !214, !220, !225}
!141 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !139, file: !6, line: 572, baseType: !142, size: 448)
!142 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !143)
!143 = !{!144, !158, !160, !162, !163, !176, !177, !178, !189}
!144 = !DIDerivedType(tag: DW_TAG_member, scope: !142, file: !6, line: 444, baseType: !145, size: 64)
!145 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !142, file: !6, line: 444, size: 64, elements: !146)
!146 = !{!147, !149}
!147 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !145, file: !6, line: 445, baseType: !148, size: 64)
!148 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !116, line: 43, baseType: !117)
!149 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !145, file: !6, line: 446, baseType: !150, size: 64)
!150 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !151, line: 48, size: 64, elements: !152)
!151 = !DIFile(filename: "zephyrproject/zephyr/include/sys/rb.h", directory: "/home/kenny")
!152 = !{!153}
!153 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !150, file: !151, line: 49, baseType: !154, size: 64)
!154 = !DICompositeType(tag: DW_TAG_array_type, baseType: !155, size: 64, elements: !156)
!155 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !150, size: 32)
!156 = !{!157}
!157 = !DISubrange(count: 2)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !142, file: !6, line: 452, baseType: !159, size: 32, offset: 64)
!159 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !111, size: 32)
!160 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !142, file: !6, line: 455, baseType: !161, size: 8, offset: 96)
!161 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !56, line: 55, baseType: !7)
!162 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !142, file: !6, line: 458, baseType: !161, size: 8, offset: 104)
!163 = !DIDerivedType(tag: DW_TAG_member, scope: !142, file: !6, line: 474, baseType: !164, size: 16, offset: 112)
!164 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !142, file: !6, line: 474, size: 16, elements: !165)
!165 = !{!166, !173}
!166 = !DIDerivedType(tag: DW_TAG_member, scope: !164, file: !6, line: 475, baseType: !167, size: 16)
!167 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !164, file: !6, line: 475, size: 16, elements: !168)
!168 = !{!169, !172}
!169 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !167, file: !6, line: 480, baseType: !170, size: 8)
!170 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !56, line: 40, baseType: !171)
!171 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!172 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !167, file: !6, line: 481, baseType: !161, size: 8, offset: 8)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !164, file: !6, line: 484, baseType: !174, size: 16)
!174 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !56, line: 56, baseType: !175)
!175 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!176 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !142, file: !6, line: 491, baseType: !58, size: 32, offset: 128)
!177 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !142, file: !6, line: 511, baseType: !60, size: 32, offset: 160)
!178 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !142, file: !6, line: 515, baseType: !179, size: 192, offset: 192)
!179 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !99, line: 221, size: 192, elements: !180)
!180 = !{!181, !182, !188}
!181 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !179, file: !99, line: 222, baseType: !148, size: 64)
!182 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !179, file: !99, line: 223, baseType: !183, size: 32, offset: 64)
!183 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !99, line: 219, baseType: !184)
!184 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !185, size: 32)
!185 = !DISubroutineType(types: !186)
!186 = !{null, !187}
!187 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !179, size: 32)
!188 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !179, file: !99, line: 226, baseType: !55, size: 64, offset: 128)
!189 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !142, file: !6, line: 518, baseType: !111, size: 64, offset: 384)
!190 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !139, file: !6, line: 575, baseType: !191, size: 288, offset: 448)
!191 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !192, line: 25, size: 288, elements: !193)
!192 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/thread.h", directory: "/home/kenny")
!193 = !{!194, !195, !196, !197, !198, !199, !200, !201, !202}
!194 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !191, file: !192, line: 26, baseType: !58, size: 32)
!195 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !191, file: !192, line: 27, baseType: !58, size: 32, offset: 32)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !191, file: !192, line: 28, baseType: !58, size: 32, offset: 64)
!197 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !191, file: !192, line: 29, baseType: !58, size: 32, offset: 96)
!198 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !191, file: !192, line: 30, baseType: !58, size: 32, offset: 128)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !191, file: !192, line: 31, baseType: !58, size: 32, offset: 160)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !191, file: !192, line: 32, baseType: !58, size: 32, offset: 192)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !191, file: !192, line: 33, baseType: !58, size: 32, offset: 224)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !191, file: !192, line: 34, baseType: !58, size: 32, offset: 256)
!203 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !139, file: !6, line: 578, baseType: !60, size: 32, offset: 736)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !139, file: !6, line: 583, baseType: !205, size: 32, offset: 768)
!205 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !206, size: 32)
!206 = !DISubroutineType(types: !207)
!207 = !{null}
!208 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !139, file: !6, line: 595, baseType: !209, size: 256, offset: 800)
!209 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 256, elements: !211)
!210 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_unsigned_char)
!211 = !{!212}
!212 = !DISubrange(count: 32)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !139, file: !6, line: 610, baseType: !61, size: 32, offset: 1056)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !139, file: !6, line: 616, baseType: !215, size: 96, offset: 1088)
!215 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !216)
!216 = !{!217, !218, !219}
!217 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !215, file: !6, line: 529, baseType: !134, size: 32)
!218 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !215, file: !6, line: 538, baseType: !79, size: 32, offset: 32)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !215, file: !6, line: 544, baseType: !79, size: 32, offset: 64)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !139, file: !6, line: 641, baseType: !221, size: 32, offset: 1184)
!221 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !222, size: 32)
!222 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !86, line: 30, size: 32, elements: !223)
!223 = !{!224}
!224 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !222, file: !86, line: 31, baseType: !97, size: 32)
!225 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !139, file: !6, line: 644, baseType: !226, size: 64, offset: 1216)
!226 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !192, line: 60, size: 64, elements: !227)
!227 = !{!228, !229}
!228 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !226, file: !192, line: 63, baseType: !58, size: 32)
!229 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !226, file: !192, line: 66, baseType: !58, size: 32, offset: 32)
!230 = !DIDerivedType(tag: DW_TAG_member, name: "tx_target_thread", scope: !75, file: !6, line: 4140, baseType: !137, size: 32, offset: 256)
!231 = !DIDerivedType(tag: DW_TAG_member, name: "_syncing_thread", scope: !75, file: !6, line: 4142, baseType: !137, size: 32, offset: 288)
!232 = !DIDerivedType(tag: DW_TAG_member, name: "_async_sem", scope: !75, file: !6, line: 4145, baseType: !233, size: 32, offset: 320)
!233 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !234, size: 32)
!234 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3704, size: 128, elements: !235)
!235 = !{!236, !237, !238}
!236 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !234, file: !6, line: 3705, baseType: !111, size: 64)
!237 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !234, file: !6, line: 3706, baseType: !58, size: 32, offset: 64)
!238 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !234, file: !6, line: 3707, baseType: !58, size: 32, offset: 96)
!239 = !DIGlobalVariableExpression(var: !240, expr: !DIExpression())
!240 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !241, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!241 = distinct !DICompileUnit(language: DW_LANG_C99, file: !242, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !243, nameTableKind: None)
!242 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/mailbox_r.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!243 = !{!239}
!244 = !DIGlobalVariableExpression(var: !245, expr: !DIExpression())
!245 = distinct !DIGlobalVariable(name: "PIPE_NOBUFF", scope: !246, file: !255, line: 60, type: !258, isLocal: false, isDefinition: true, align: 32)
!246 = distinct !DICompileUnit(language: DW_LANG_C99, file: !247, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !248, globals: !252, nameTableKind: None)
!247 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/master.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!248 = !{!249, !60, !61}
!249 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !250, size: 32)
!250 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !251, line: 23, baseType: !61)
!251 = !DIFile(filename: "zephyrproject/zephyr/lib/libc/minimal/include/stdio.h", directory: "/home/kenny")
!252 = !{!253, !296, !300, !416, !420, !435, !437, !439, !441, !451, !458, !460, !462, !464, !466, !468, !475, !244, !483, !485, !487, !489, !491, !496, !501, !506, !508, !510, !515, !517, !522, !527, !532, !534, !536, !541, !544, !547}
!253 = !DIGlobalVariableExpression(var: !254, expr: !DIExpression())
!254 = distinct !DIGlobalVariable(name: "test_pipes", scope: !246, file: !255, line: 24, type: !256, isLocal: false, isDefinition: true)
!255 = !DIFile(filename: "appl/Zephyr/app_kernel/src/master.c", directory: "/home/kenny/ara")
!256 = !DICompositeType(tag: DW_TAG_array_type, baseType: !257, size: 96, elements: !294)
!257 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !258, size: 32)
!258 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_pipe", file: !6, line: 4324, size: 352, elements: !259)
!259 = !{!260, !262, !263, !264, !265, !266, !270, !293}
!260 = !DIDerivedType(tag: DW_TAG_member, name: "buffer", scope: !258, file: !6, line: 4325, baseType: !261, size: 32)
!261 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !7, size: 32)
!262 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !258, file: !6, line: 4326, baseType: !79, size: 32, offset: 32)
!263 = !DIDerivedType(tag: DW_TAG_member, name: "bytes_used", scope: !258, file: !6, line: 4327, baseType: !79, size: 32, offset: 64)
!264 = !DIDerivedType(tag: DW_TAG_member, name: "read_index", scope: !258, file: !6, line: 4328, baseType: !79, size: 32, offset: 96)
!265 = !DIDerivedType(tag: DW_TAG_member, name: "write_index", scope: !258, file: !6, line: 4329, baseType: !79, size: 32, offset: 128)
!266 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !258, file: !6, line: 4330, baseType: !267, size: 32, offset: 160)
!267 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !268)
!268 = !{!269}
!269 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !267, file: !99, line: 243, baseType: !134, size: 32)
!270 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !258, file: !6, line: 4335, baseType: !271, size: 128, offset: 192)
!271 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !258, file: !6, line: 4332, size: 128, elements: !272)
!272 = !{!273, !292}
!273 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !271, file: !6, line: 4333, baseType: !274, size: 64)
!274 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !275)
!275 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !276)
!276 = !{!277}
!277 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !275, file: !99, line: 209, baseType: !278, size: 64)
!278 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !279)
!279 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !280)
!280 = !{!281, !287}
!281 = !DIDerivedType(tag: DW_TAG_member, scope: !279, file: !116, line: 32, baseType: !282, size: 32)
!282 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !279, file: !116, line: 32, size: 32, elements: !283)
!283 = !{!284, !286}
!284 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !282, file: !116, line: 33, baseType: !285, size: 32)
!285 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !279, size: 32)
!286 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !282, file: !116, line: 34, baseType: !285, size: 32)
!287 = !DIDerivedType(tag: DW_TAG_member, scope: !279, file: !116, line: 36, baseType: !288, size: 32, offset: 32)
!288 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !279, file: !116, line: 36, size: 32, elements: !289)
!289 = !{!290, !291}
!290 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !288, file: !116, line: 37, baseType: !285, size: 32)
!291 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !288, file: !116, line: 38, baseType: !285, size: 32)
!292 = !DIDerivedType(tag: DW_TAG_member, name: "writers", scope: !271, file: !6, line: 4334, baseType: !274, size: 64, offset: 64)
!293 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !258, file: !6, line: 4339, baseType: !161, size: 8, offset: 320)
!294 = !{!295}
!295 = !DISubrange(count: 3)
!296 = !DIGlobalVariableExpression(var: !297, expr: !DIExpression())
!297 = distinct !DIGlobalVariable(name: "newline", scope: !246, file: !255, line: 27, type: !298, isLocal: false, isDefinition: true)
!298 = !DICompositeType(tag: DW_TAG_array_type, baseType: !299, size: 16, elements: !156)
!299 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !210)
!300 = !DIGlobalVariableExpression(var: !301, expr: !DIExpression())
!301 = distinct !DIGlobalVariable(name: "_k_thread_data_RECVTASK", scope: !246, file: !255, line: 40, type: !302, isLocal: false, isDefinition: true, align: 32)
!302 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_static_thread_data", file: !6, line: 1099, size: 384, elements: !303)
!303 = !{!304, !392, !400, !401, !406, !407, !408, !409, !410, !411, !413, !414}
!304 = !DIDerivedType(tag: DW_TAG_member, name: "init_thread", scope: !302, file: !6, line: 1100, baseType: !305, size: 32)
!305 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !306, size: 32)
!306 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1280, elements: !307)
!307 = !{!308, !349, !361, !362, !363, !364, !365, !371, !387}
!308 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !306, file: !6, line: 572, baseType: !309, size: 448)
!309 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !310)
!310 = !{!311, !322, !324, !325, !326, !335, !336, !337, !348}
!311 = !DIDerivedType(tag: DW_TAG_member, scope: !309, file: !6, line: 444, baseType: !312, size: 64)
!312 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !309, file: !6, line: 444, size: 64, elements: !313)
!313 = !{!314, !316}
!314 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !312, file: !6, line: 445, baseType: !315, size: 64)
!315 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !116, line: 43, baseType: !279)
!316 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !312, file: !6, line: 446, baseType: !317, size: 64)
!317 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !151, line: 48, size: 64, elements: !318)
!318 = !{!319}
!319 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !317, file: !151, line: 49, baseType: !320, size: 64)
!320 = !DICompositeType(tag: DW_TAG_array_type, baseType: !321, size: 64, elements: !156)
!321 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !317, size: 32)
!322 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !309, file: !6, line: 452, baseType: !323, size: 32, offset: 64)
!323 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !274, size: 32)
!324 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !309, file: !6, line: 455, baseType: !161, size: 8, offset: 96)
!325 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !309, file: !6, line: 458, baseType: !161, size: 8, offset: 104)
!326 = !DIDerivedType(tag: DW_TAG_member, scope: !309, file: !6, line: 474, baseType: !327, size: 16, offset: 112)
!327 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !309, file: !6, line: 474, size: 16, elements: !328)
!328 = !{!329, !334}
!329 = !DIDerivedType(tag: DW_TAG_member, scope: !327, file: !6, line: 475, baseType: !330, size: 16)
!330 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !327, file: !6, line: 475, size: 16, elements: !331)
!331 = !{!332, !333}
!332 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !330, file: !6, line: 480, baseType: !170, size: 8)
!333 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !330, file: !6, line: 481, baseType: !161, size: 8, offset: 8)
!334 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !327, file: !6, line: 484, baseType: !174, size: 16)
!335 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !309, file: !6, line: 491, baseType: !58, size: 32, offset: 128)
!336 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !309, file: !6, line: 511, baseType: !60, size: 32, offset: 160)
!337 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !309, file: !6, line: 515, baseType: !338, size: 192, offset: 192)
!338 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !99, line: 221, size: 192, elements: !339)
!339 = !{!340, !341, !347}
!340 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !338, file: !99, line: 222, baseType: !315, size: 64)
!341 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !338, file: !99, line: 223, baseType: !342, size: 32, offset: 64)
!342 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !99, line: 219, baseType: !343)
!343 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !344, size: 32)
!344 = !DISubroutineType(types: !345)
!345 = !{null, !346}
!346 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !338, size: 32)
!347 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !338, file: !99, line: 226, baseType: !55, size: 64, offset: 128)
!348 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !309, file: !6, line: 518, baseType: !274, size: 64, offset: 384)
!349 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !306, file: !6, line: 575, baseType: !350, size: 288, offset: 448)
!350 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !192, line: 25, size: 288, elements: !351)
!351 = !{!352, !353, !354, !355, !356, !357, !358, !359, !360}
!352 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !350, file: !192, line: 26, baseType: !58, size: 32)
!353 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !350, file: !192, line: 27, baseType: !58, size: 32, offset: 32)
!354 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !350, file: !192, line: 28, baseType: !58, size: 32, offset: 64)
!355 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !350, file: !192, line: 29, baseType: !58, size: 32, offset: 96)
!356 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !350, file: !192, line: 30, baseType: !58, size: 32, offset: 128)
!357 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !350, file: !192, line: 31, baseType: !58, size: 32, offset: 160)
!358 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !350, file: !192, line: 32, baseType: !58, size: 32, offset: 192)
!359 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !350, file: !192, line: 33, baseType: !58, size: 32, offset: 224)
!360 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !350, file: !192, line: 34, baseType: !58, size: 32, offset: 256)
!361 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !306, file: !6, line: 578, baseType: !60, size: 32, offset: 736)
!362 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !306, file: !6, line: 583, baseType: !205, size: 32, offset: 768)
!363 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !306, file: !6, line: 595, baseType: !209, size: 256, offset: 800)
!364 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !306, file: !6, line: 610, baseType: !61, size: 32, offset: 1056)
!365 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !306, file: !6, line: 616, baseType: !366, size: 96, offset: 1088)
!366 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !367)
!367 = !{!368, !369, !370}
!368 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !366, file: !6, line: 529, baseType: !134, size: 32)
!369 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !366, file: !6, line: 538, baseType: !79, size: 32, offset: 32)
!370 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !366, file: !6, line: 544, baseType: !79, size: 32, offset: 64)
!371 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !306, file: !6, line: 641, baseType: !372, size: 32, offset: 1184)
!372 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !373, size: 32)
!373 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !86, line: 30, size: 32, elements: !374)
!374 = !{!375}
!375 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !373, file: !86, line: 31, baseType: !376, size: 32)
!376 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !377, size: 32)
!377 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !99, line: 267, size: 192, elements: !378)
!378 = !{!379, !385, !386}
!379 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !377, file: !99, line: 268, baseType: !380, size: 96)
!380 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !103, line: 51, size: 96, elements: !381)
!381 = !{!382, !383, !384}
!382 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !380, file: !103, line: 52, baseType: !106, size: 32)
!383 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !380, file: !103, line: 53, baseType: !60, size: 32, offset: 32)
!384 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !380, file: !103, line: 54, baseType: !79, size: 32, offset: 64)
!385 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !377, file: !99, line: 269, baseType: !274, size: 64, offset: 96)
!386 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !377, file: !99, line: 270, baseType: !267, size: 32, offset: 160)
!387 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !306, file: !6, line: 644, baseType: !388, size: 64, offset: 1216)
!388 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !192, line: 60, size: 64, elements: !389)
!389 = !{!390, !391}
!390 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !388, file: !192, line: 63, baseType: !58, size: 32)
!391 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !388, file: !192, line: 66, baseType: !58, size: 32, offset: 32)
!392 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack", scope: !302, file: !6, line: 1101, baseType: !393, size: 32, offset: 32)
!393 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !394, size: 32)
!394 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_stack_t", file: !395, line: 44, baseType: !396)
!395 = !DIFile(filename: "zephyrproject/zephyr/include/sys/arch_interface.h", directory: "/home/kenny")
!396 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "z_thread_stack_element", file: !397, line: 35, size: 8, elements: !398)
!397 = !DIFile(filename: "zephyrproject/zephyr/include/sys/thread_stack.h", directory: "/home/kenny")
!398 = !{!399}
!399 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !396, file: !397, line: 36, baseType: !210, size: 8)
!400 = !DIDerivedType(tag: DW_TAG_member, name: "init_stack_size", scope: !302, file: !6, line: 1102, baseType: !59, size: 32, offset: 64)
!401 = !DIDerivedType(tag: DW_TAG_member, name: "init_entry", scope: !302, file: !6, line: 1103, baseType: !402, size: 32, offset: 96)
!402 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_thread_entry_t", file: !395, line: 46, baseType: !403)
!403 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !404, size: 32)
!404 = !DISubroutineType(types: !405)
!405 = !{null, !60, !60, !60}
!406 = !DIDerivedType(tag: DW_TAG_member, name: "init_p1", scope: !302, file: !6, line: 1104, baseType: !60, size: 32, offset: 128)
!407 = !DIDerivedType(tag: DW_TAG_member, name: "init_p2", scope: !302, file: !6, line: 1105, baseType: !60, size: 32, offset: 160)
!408 = !DIDerivedType(tag: DW_TAG_member, name: "init_p3", scope: !302, file: !6, line: 1106, baseType: !60, size: 32, offset: 192)
!409 = !DIDerivedType(tag: DW_TAG_member, name: "init_prio", scope: !302, file: !6, line: 1107, baseType: !61, size: 32, offset: 224)
!410 = !DIDerivedType(tag: DW_TAG_member, name: "init_options", scope: !302, file: !6, line: 1108, baseType: !58, size: 32, offset: 256)
!411 = !DIDerivedType(tag: DW_TAG_member, name: "init_delay", scope: !302, file: !6, line: 1109, baseType: !412, size: 32, offset: 288)
!412 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !56, line: 42, baseType: !61)
!413 = !DIDerivedType(tag: DW_TAG_member, name: "init_abort", scope: !302, file: !6, line: 1110, baseType: !205, size: 32, offset: 320)
!414 = !DIDerivedType(tag: DW_TAG_member, name: "init_name", scope: !302, file: !6, line: 1111, baseType: !415, size: 32, offset: 352)
!415 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !299, size: 32)
!416 = !DIGlobalVariableExpression(var: !417, expr: !DIExpression())
!417 = distinct !DIGlobalVariable(name: "RECVTASK", scope: !246, file: !255, line: 40, type: !418, isLocal: false, isDefinition: true)
!418 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !419)
!419 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !305)
!420 = !DIGlobalVariableExpression(var: !421, expr: !DIExpression())
!421 = distinct !DIGlobalVariable(name: "DEMOQX1", scope: !246, file: !255, line: 42, type: !422, isLocal: false, isDefinition: true, align: 32)
!422 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_msgq", file: !6, line: 3848, size: 352, elements: !423)
!423 = !{!424, !425, !426, !427, !428, !430, !431, !432, !433, !434}
!424 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !422, file: !6, line: 3850, baseType: !274, size: 64)
!425 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !422, file: !6, line: 3852, baseType: !267, size: 32, offset: 64)
!426 = !DIDerivedType(tag: DW_TAG_member, name: "msg_size", scope: !422, file: !6, line: 3854, baseType: !79, size: 32, offset: 96)
!427 = !DIDerivedType(tag: DW_TAG_member, name: "max_msgs", scope: !422, file: !6, line: 3856, baseType: !58, size: 32, offset: 128)
!428 = !DIDerivedType(tag: DW_TAG_member, name: "buffer_start", scope: !422, file: !6, line: 3858, baseType: !429, size: 32, offset: 160)
!429 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !210, size: 32)
!430 = !DIDerivedType(tag: DW_TAG_member, name: "buffer_end", scope: !422, file: !6, line: 3860, baseType: !429, size: 32, offset: 192)
!431 = !DIDerivedType(tag: DW_TAG_member, name: "read_ptr", scope: !422, file: !6, line: 3862, baseType: !429, size: 32, offset: 224)
!432 = !DIDerivedType(tag: DW_TAG_member, name: "write_ptr", scope: !422, file: !6, line: 3864, baseType: !429, size: 32, offset: 256)
!433 = !DIDerivedType(tag: DW_TAG_member, name: "used_msgs", scope: !422, file: !6, line: 3866, baseType: !58, size: 32, offset: 288)
!434 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !422, file: !6, line: 3872, baseType: !161, size: 8, offset: 320)
!435 = !DIGlobalVariableExpression(var: !436, expr: !DIExpression())
!436 = distinct !DIGlobalVariable(name: "DEMOQX4", scope: !246, file: !255, line: 43, type: !422, isLocal: false, isDefinition: true, align: 32)
!437 = !DIGlobalVariableExpression(var: !438, expr: !DIExpression())
!438 = distinct !DIGlobalVariable(name: "MB_COMM", scope: !246, file: !255, line: 44, type: !422, isLocal: false, isDefinition: true, align: 32)
!439 = !DIGlobalVariableExpression(var: !440, expr: !DIExpression())
!440 = distinct !DIGlobalVariable(name: "CH_COMM", scope: !246, file: !255, line: 45, type: !422, isLocal: false, isDefinition: true, align: 32)
!441 = !DIGlobalVariableExpression(var: !442, expr: !DIExpression())
!442 = distinct !DIGlobalVariable(name: "MAP1", scope: !246, file: !255, line: 47, type: !443, isLocal: false, isDefinition: true, align: 32)
!443 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_slab", file: !6, line: 4521, size: 224, elements: !444)
!444 = !{!445, !446, !447, !448, !449, !450}
!445 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !443, file: !6, line: 4522, baseType: !274, size: 64)
!446 = !DIDerivedType(tag: DW_TAG_member, name: "num_blocks", scope: !443, file: !6, line: 4523, baseType: !58, size: 32, offset: 64)
!447 = !DIDerivedType(tag: DW_TAG_member, name: "block_size", scope: !443, file: !6, line: 4524, baseType: !79, size: 32, offset: 96)
!448 = !DIDerivedType(tag: DW_TAG_member, name: "buffer", scope: !443, file: !6, line: 4525, baseType: !429, size: 32, offset: 128)
!449 = !DIDerivedType(tag: DW_TAG_member, name: "free_list", scope: !443, file: !6, line: 4526, baseType: !429, size: 32, offset: 160)
!450 = !DIDerivedType(tag: DW_TAG_member, name: "num_used", scope: !443, file: !6, line: 4527, baseType: !58, size: 32, offset: 192)
!451 = !DIGlobalVariableExpression(var: !452, expr: !DIExpression())
!452 = distinct !DIGlobalVariable(name: "SEM0", scope: !246, file: !255, line: 49, type: !453, isLocal: false, isDefinition: true, align: 32)
!453 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3704, size: 128, elements: !454)
!454 = !{!455, !456, !457}
!455 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !453, file: !6, line: 3705, baseType: !274, size: 64)
!456 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !453, file: !6, line: 3706, baseType: !58, size: 32, offset: 64)
!457 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !453, file: !6, line: 3707, baseType: !58, size: 32, offset: 96)
!458 = !DIGlobalVariableExpression(var: !459, expr: !DIExpression())
!459 = distinct !DIGlobalVariable(name: "SEM1", scope: !246, file: !255, line: 50, type: !453, isLocal: false, isDefinition: true, align: 32)
!460 = !DIGlobalVariableExpression(var: !461, expr: !DIExpression())
!461 = distinct !DIGlobalVariable(name: "SEM2", scope: !246, file: !255, line: 51, type: !453, isLocal: false, isDefinition: true, align: 32)
!462 = !DIGlobalVariableExpression(var: !463, expr: !DIExpression())
!463 = distinct !DIGlobalVariable(name: "SEM3", scope: !246, file: !255, line: 52, type: !453, isLocal: false, isDefinition: true, align: 32)
!464 = !DIGlobalVariableExpression(var: !465, expr: !DIExpression())
!465 = distinct !DIGlobalVariable(name: "SEM4", scope: !246, file: !255, line: 53, type: !453, isLocal: false, isDefinition: true, align: 32)
!466 = !DIGlobalVariableExpression(var: !467, expr: !DIExpression())
!467 = distinct !DIGlobalVariable(name: "STARTRCV", scope: !246, file: !255, line: 54, type: !453, isLocal: false, isDefinition: true, align: 32)
!468 = !DIGlobalVariableExpression(var: !469, expr: !DIExpression())
!469 = distinct !DIGlobalVariable(name: "MAILB1", scope: !246, file: !255, line: 56, type: !470, isLocal: false, isDefinition: true, align: 32)
!470 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mbox", file: !6, line: 4152, size: 160, elements: !471)
!471 = !{!472, !473, !474}
!472 = !DIDerivedType(tag: DW_TAG_member, name: "tx_msg_queue", scope: !470, file: !6, line: 4154, baseType: !274, size: 64)
!473 = !DIDerivedType(tag: DW_TAG_member, name: "rx_msg_queue", scope: !470, file: !6, line: 4156, baseType: !274, size: 64, offset: 64)
!474 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !470, file: !6, line: 4157, baseType: !267, size: 32, offset: 128)
!475 = !DIGlobalVariableExpression(var: !476, expr: !DIExpression())
!476 = distinct !DIGlobalVariable(name: "DEMO_MUTEX", scope: !246, file: !255, line: 58, type: !477, isLocal: false, isDefinition: true, align: 32)
!477 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mutex", file: !6, line: 3589, size: 160, elements: !478)
!478 = !{!479, !480, !481, !482}
!479 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !477, file: !6, line: 3591, baseType: !274, size: 64)
!480 = !DIDerivedType(tag: DW_TAG_member, name: "owner", scope: !477, file: !6, line: 3593, baseType: !305, size: 32, offset: 64)
!481 = !DIDerivedType(tag: DW_TAG_member, name: "lock_count", scope: !477, file: !6, line: 3596, baseType: !58, size: 32, offset: 96)
!482 = !DIDerivedType(tag: DW_TAG_member, name: "owner_orig_prio", scope: !477, file: !6, line: 3599, baseType: !61, size: 32, offset: 128)
!483 = !DIGlobalVariableExpression(var: !484, expr: !DIExpression())
!484 = distinct !DIGlobalVariable(name: "PIPE_SMALLBUFF", scope: !246, file: !255, line: 61, type: !258, isLocal: false, isDefinition: true, align: 32)
!485 = !DIGlobalVariableExpression(var: !486, expr: !DIExpression())
!486 = distinct !DIGlobalVariable(name: "PIPE_BIGBUFF", scope: !246, file: !255, line: 62, type: !258, isLocal: false, isDefinition: true, align: 32)
!487 = !DIGlobalVariableExpression(var: !488, expr: !DIExpression())
!488 = distinct !DIGlobalVariable(name: "poolheap_DEMOPOOL", scope: !246, file: !255, line: 64, type: !377, isLocal: false, isDefinition: true, align: 32)
!489 = !DIGlobalVariableExpression(var: !490, expr: !DIExpression())
!490 = distinct !DIGlobalVariable(name: "DEMOPOOL", scope: !246, file: !255, line: 64, type: !373, isLocal: false, isDefinition: true)
!491 = !DIGlobalVariableExpression(var: !492, expr: !DIExpression())
!492 = distinct !DIGlobalVariable(name: "msg", scope: !246, file: !255, line: 20, type: !493, isLocal: false, isDefinition: true)
!493 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 2048, elements: !494)
!494 = !{!495}
!495 = !DISubrange(count: 256)
!496 = !DIGlobalVariableExpression(var: !497, expr: !DIExpression())
!497 = distinct !DIGlobalVariable(name: "data_bench", scope: !246, file: !255, line: 21, type: !498, isLocal: false, isDefinition: true)
!498 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 32768, elements: !499)
!499 = !{!500}
!500 = !DISubrange(count: 4096)
!501 = !DIGlobalVariableExpression(var: !502, expr: !DIExpression())
!502 = distinct !DIGlobalVariable(name: "sline", scope: !246, file: !255, line: 26, type: !503, isLocal: false, isDefinition: true)
!503 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 2056, elements: !504)
!504 = !{!505}
!505 = !DISubrange(count: 257)
!506 = !DIGlobalVariableExpression(var: !507, expr: !DIExpression())
!507 = distinct !DIGlobalVariable(name: "output_file", scope: !246, file: !255, line: 29, type: !249, isLocal: false, isDefinition: true)
!508 = !DIGlobalVariableExpression(var: !509, expr: !DIExpression())
!509 = distinct !DIGlobalVariable(name: "tm_off", scope: !246, file: !255, line: 35, type: !58, isLocal: false, isDefinition: true)
!510 = !DIGlobalVariableExpression(var: !511, expr: !DIExpression())
!511 = distinct !DIGlobalVariable(name: "_k_thread_stack_RECVTASK", scope: !246, file: !255, line: 40, type: !512, isLocal: false, isDefinition: true, align: 64)
!512 = !DICompositeType(tag: DW_TAG_array_type, baseType: !396, size: 8192, elements: !513)
!513 = !{!514}
!514 = !DISubrange(count: 1024)
!515 = !DIGlobalVariableExpression(var: !516, expr: !DIExpression())
!516 = distinct !DIGlobalVariable(name: "_k_thread_obj_RECVTASK", scope: !246, file: !255, line: 40, type: !306, isLocal: false, isDefinition: true)
!517 = !DIGlobalVariableExpression(var: !518, expr: !DIExpression())
!518 = distinct !DIGlobalVariable(name: "_k_fifo_buf_DEMOQX1", scope: !246, file: !255, line: 42, type: !519, isLocal: true, isDefinition: true, align: 32)
!519 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 4000, elements: !520)
!520 = !{!521}
!521 = !DISubrange(count: 500)
!522 = !DIGlobalVariableExpression(var: !523, expr: !DIExpression())
!523 = distinct !DIGlobalVariable(name: "_k_fifo_buf_DEMOQX4", scope: !246, file: !255, line: 43, type: !524, isLocal: true, isDefinition: true, align: 32)
!524 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 16000, elements: !525)
!525 = !{!526}
!526 = !DISubrange(count: 2000)
!527 = !DIGlobalVariableExpression(var: !528, expr: !DIExpression())
!528 = distinct !DIGlobalVariable(name: "_k_fifo_buf_MB_COMM", scope: !246, file: !255, line: 44, type: !529, isLocal: true, isDefinition: true, align: 32)
!529 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 96, elements: !530)
!530 = !{!531}
!531 = !DISubrange(count: 12)
!532 = !DIGlobalVariableExpression(var: !533, expr: !DIExpression())
!533 = distinct !DIGlobalVariable(name: "_k_fifo_buf_CH_COMM", scope: !246, file: !255, line: 45, type: !529, isLocal: true, isDefinition: true, align: 32)
!534 = !DIGlobalVariableExpression(var: !535, expr: !DIExpression())
!535 = distinct !DIGlobalVariable(name: "_k_mem_slab_buf_MAP1", scope: !246, file: !255, line: 47, type: !209, isLocal: false, isDefinition: true, align: 32)
!536 = !DIGlobalVariableExpression(var: !537, expr: !DIExpression())
!537 = distinct !DIGlobalVariable(name: "_k_pipe_buf_PIPE_NOBUFF", scope: !246, file: !255, line: 60, type: !538, isLocal: true, isDefinition: true, align: 32)
!538 = !DICompositeType(tag: DW_TAG_array_type, baseType: !7, elements: !539)
!539 = !{!540}
!540 = !DISubrange(count: 0)
!541 = !DIGlobalVariableExpression(var: !542, expr: !DIExpression())
!542 = distinct !DIGlobalVariable(name: "_k_pipe_buf_PIPE_SMALLBUFF", scope: !246, file: !255, line: 61, type: !543, isLocal: true, isDefinition: true, align: 32)
!543 = !DICompositeType(tag: DW_TAG_array_type, baseType: !7, size: 2048, elements: !494)
!544 = !DIGlobalVariableExpression(var: !545, expr: !DIExpression())
!545 = distinct !DIGlobalVariable(name: "_k_pipe_buf_PIPE_BIGBUFF", scope: !246, file: !255, line: 62, type: !546, isLocal: true, isDefinition: true, align: 32)
!546 = !DICompositeType(tag: DW_TAG_array_type, baseType: !7, size: 32768, elements: !499)
!547 = !DIGlobalVariableExpression(var: !548, expr: !DIExpression())
!548 = distinct !DIGlobalVariable(name: "kheap_poolheap_DEMOPOOL", scope: !246, file: !255, line: 64, type: !549, isLocal: false, isDefinition: true, align: 32)
!549 = !DICompositeType(tag: DW_TAG_array_type, baseType: !210, size: 672, elements: !550)
!550 = !{!551}
!551 = !DISubrange(count: 84)
!552 = !DIGlobalVariableExpression(var: !553, expr: !DIExpression())
!553 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !554, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!554 = distinct !DICompileUnit(language: DW_LANG_C99, file: !555, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !556, nameTableKind: None)
!555 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/memmap_b.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!556 = !{!552}
!557 = !DIGlobalVariableExpression(var: !558, expr: !DIExpression())
!558 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !559, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!559 = distinct !DICompileUnit(language: DW_LANG_C99, file: !560, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !561, nameTableKind: None)
!560 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/mempool_b.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!561 = !{!557}
!562 = !DIGlobalVariableExpression(var: !563, expr: !DIExpression())
!563 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !564, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!564 = distinct !DICompileUnit(language: DW_LANG_C99, file: !565, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !52, globals: !566, nameTableKind: None)
!565 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/mutex_b.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!566 = !{!562}
!567 = !DIGlobalVariableExpression(var: !568, expr: !DIExpression())
!568 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !569, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!569 = distinct !DICompileUnit(language: DW_LANG_C99, file: !570, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !571, retainedTypes: !68, globals: !578, nameTableKind: None)
!570 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/pipe_b.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!571 = !{!572, !5}
!572 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "pipe_options", file: !573, line: 68, baseType: !7, size: 8, elements: !574)
!573 = !DIFile(filename: "appl/Zephyr/app_kernel/src/master.h", directory: "/home/kenny/ara")
!574 = !{!575, !576, !577}
!575 = !DIEnumerator(name: "_0_TO_N", value: 0, isUnsigned: true)
!576 = !DIEnumerator(name: "_1_TO_N", value: 1, isUnsigned: true)
!577 = !DIEnumerator(name: "_ALL_N", value: 2, isUnsigned: true)
!578 = !{!567}
!579 = !DIGlobalVariableExpression(var: !580, expr: !DIExpression())
!580 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !581, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!581 = distinct !DICompileUnit(language: DW_LANG_C99, file: !582, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !571, retainedTypes: !52, globals: !583, nameTableKind: None)
!582 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/pipe_r.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!583 = !{!579}
!584 = !DIGlobalVariableExpression(var: !585, expr: !DIExpression())
!585 = distinct !DIGlobalVariable(name: "data_recv", scope: !586, file: !590, line: 20, type: !498, isLocal: false, isDefinition: true)
!586 = distinct !DICompileUnit(language: DW_LANG_C99, file: !587, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !588, globals: !589, nameTableKind: None)
!587 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/receiver.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!588 = !{!53, !60, !61}
!589 = !{!584}
!590 = !DIFile(filename: "appl/Zephyr/app_kernel/src/receiver.c", directory: "/home/kenny/ara")
!591 = !DIGlobalVariableExpression(var: !592, expr: !DIExpression())
!592 = distinct !DIGlobalVariable(name: "timestamp_check", scope: !593, file: !63, line: 62, type: !55, isLocal: true, isDefinition: true)
!593 = distinct !DICompileUnit(language: DW_LANG_C99, file: !594, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !595, globals: !596, nameTableKind: None)
!594 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/sema_b.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!595 = !{!58, !60, !61}
!596 = !{!591}
!597 = distinct !DICompileUnit(language: DW_LANG_C99, file: !598, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !588, nameTableKind: None)
!598 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/fifo_r.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!599 = distinct !DICompileUnit(language: DW_LANG_C99, file: !600, producer: "clang version 9.0.1-12 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !601, nameTableKind: None)
!600 = !DIFile(filename: "/home/kenny/ara/appl/Zephyr/app_kernel/src/sema_r.c", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!601 = !{!53, !60, !61, !58}
!602 = !{!"clang version 9.0.1-12 "}
!603 = !{i32 2, !"Dwarf Version", i32 4}
!604 = !{i32 2, !"Debug Info Version", i32 3}
!605 = !{i32 1, !"wchar_size", i32 4}
!606 = !{i32 1, !"min_enum_size", i32 1}
!607 = distinct !DISubprogram(name: "queue_test", scope: !608, file: !608, line: 19, type: !206, scopeLine: 20, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !609)
!608 = !DIFile(filename: "appl/Zephyr/app_kernel/src/fifo_b.c", directory: "/home/kenny/ara")
!609 = !{}
!610 = !DILocalVariable(name: "et", scope: !607, file: !608, line: 21, type: !58)
!611 = !DILocation(line: 21, column: 11, scope: !607)
!612 = !DILocalVariable(name: "i", scope: !607, file: !608, line: 22, type: !61)
!613 = !DILocation(line: 22, column: 6, scope: !607)
!614 = !DILocation(line: 24, column: 2, scope: !607)
!615 = !DILocation(line: 25, column: 7, scope: !607)
!616 = !DILocation(line: 25, column: 5, scope: !607)
!617 = !DILocation(line: 26, column: 9, scope: !618)
!618 = distinct !DILexicalBlock(scope: !607, file: !608, line: 26, column: 2)
!619 = !DILocation(line: 26, column: 7, scope: !618)
!620 = !DILocation(line: 26, column: 14, scope: !621)
!621 = distinct !DILexicalBlock(scope: !618, file: !608, line: 26, column: 2)
!622 = !DILocation(line: 26, column: 16, scope: !621)
!623 = !DILocation(line: 26, column: 2, scope: !618)
!624 = !DILocation(line: 27, column: 36, scope: !625)
!625 = distinct !DILexicalBlock(scope: !621, file: !608, line: 26, column: 40)
!626 = !DILocation(line: 27, column: 3, scope: !625)
!627 = !DILocation(line: 28, column: 2, scope: !625)
!628 = !DILocation(line: 26, column: 36, scope: !621)
!629 = !DILocation(line: 26, column: 2, scope: !621)
!630 = distinct !{!630, !623, !631}
!631 = !DILocation(line: 28, column: 2, scope: !618)
!632 = !DILocation(line: 29, column: 28, scope: !607)
!633 = !DILocation(line: 29, column: 7, scope: !607)
!634 = !DILocation(line: 29, column: 5, scope: !607)
!635 = !DILocation(line: 31, column: 2, scope: !636)
!636 = distinct !DILexicalBlock(scope: !607, file: !608, line: 31, column: 2)
!637 = !DILocation(line: 34, column: 7, scope: !607)
!638 = !DILocation(line: 34, column: 5, scope: !607)
!639 = !DILocation(line: 35, column: 9, scope: !640)
!640 = distinct !DILexicalBlock(scope: !607, file: !608, line: 35, column: 2)
!641 = !DILocation(line: 35, column: 7, scope: !640)
!642 = !DILocation(line: 35, column: 14, scope: !643)
!643 = distinct !DILexicalBlock(scope: !640, file: !608, line: 35, column: 2)
!644 = !DILocation(line: 35, column: 16, scope: !643)
!645 = !DILocation(line: 35, column: 2, scope: !640)
!646 = !DILocation(line: 36, column: 36, scope: !647)
!647 = distinct !DILexicalBlock(scope: !643, file: !608, line: 35, column: 40)
!648 = !DILocation(line: 36, column: 3, scope: !647)
!649 = !DILocation(line: 37, column: 2, scope: !647)
!650 = !DILocation(line: 35, column: 36, scope: !643)
!651 = !DILocation(line: 35, column: 2, scope: !643)
!652 = distinct !{!652, !645, !653}
!653 = !DILocation(line: 37, column: 2, scope: !640)
!654 = !DILocation(line: 38, column: 28, scope: !607)
!655 = !DILocation(line: 38, column: 7, scope: !607)
!656 = !DILocation(line: 38, column: 5, scope: !607)
!657 = !DILocation(line: 39, column: 2, scope: !607)
!658 = !DILocation(line: 41, column: 2, scope: !659)
!659 = distinct !DILexicalBlock(scope: !607, file: !608, line: 41, column: 2)
!660 = !DILocation(line: 44, column: 7, scope: !607)
!661 = !DILocation(line: 44, column: 5, scope: !607)
!662 = !DILocation(line: 45, column: 9, scope: !663)
!663 = distinct !DILexicalBlock(scope: !607, file: !608, line: 45, column: 2)
!664 = !DILocation(line: 45, column: 7, scope: !663)
!665 = !DILocation(line: 45, column: 14, scope: !666)
!666 = distinct !DILexicalBlock(scope: !663, file: !608, line: 45, column: 2)
!667 = !DILocation(line: 45, column: 16, scope: !666)
!668 = !DILocation(line: 45, column: 2, scope: !663)
!669 = !DILocation(line: 46, column: 36, scope: !670)
!670 = distinct !DILexicalBlock(scope: !666, file: !608, line: 45, column: 40)
!671 = !DILocation(line: 46, column: 3, scope: !670)
!672 = !DILocation(line: 47, column: 2, scope: !670)
!673 = !DILocation(line: 45, column: 36, scope: !666)
!674 = !DILocation(line: 45, column: 2, scope: !666)
!675 = distinct !{!675, !668, !676}
!676 = !DILocation(line: 47, column: 2, scope: !663)
!677 = !DILocation(line: 48, column: 28, scope: !607)
!678 = !DILocation(line: 48, column: 7, scope: !607)
!679 = !DILocation(line: 48, column: 5, scope: !607)
!680 = !DILocation(line: 49, column: 2, scope: !607)
!681 = !DILocation(line: 51, column: 2, scope: !682)
!682 = distinct !DILexicalBlock(scope: !607, file: !608, line: 51, column: 2)
!683 = !DILocation(line: 54, column: 7, scope: !607)
!684 = !DILocation(line: 54, column: 5, scope: !607)
!685 = !DILocation(line: 55, column: 9, scope: !686)
!686 = distinct !DILexicalBlock(scope: !607, file: !608, line: 55, column: 2)
!687 = !DILocation(line: 55, column: 7, scope: !686)
!688 = !DILocation(line: 55, column: 14, scope: !689)
!689 = distinct !DILexicalBlock(scope: !686, file: !608, line: 55, column: 2)
!690 = !DILocation(line: 55, column: 16, scope: !689)
!691 = !DILocation(line: 55, column: 2, scope: !686)
!692 = !DILocation(line: 56, column: 36, scope: !693)
!693 = distinct !DILexicalBlock(scope: !689, file: !608, line: 55, column: 40)
!694 = !DILocation(line: 56, column: 3, scope: !693)
!695 = !DILocation(line: 57, column: 2, scope: !693)
!696 = !DILocation(line: 55, column: 36, scope: !689)
!697 = !DILocation(line: 55, column: 2, scope: !689)
!698 = distinct !{!698, !691, !699}
!699 = !DILocation(line: 57, column: 2, scope: !686)
!700 = !DILocation(line: 58, column: 28, scope: !607)
!701 = !DILocation(line: 58, column: 7, scope: !607)
!702 = !DILocation(line: 58, column: 5, scope: !607)
!703 = !DILocation(line: 59, column: 2, scope: !607)
!704 = !DILocation(line: 61, column: 2, scope: !705)
!705 = distinct !DILexicalBlock(scope: !607, file: !608, line: 61, column: 2)
!706 = !DILocation(line: 64, column: 2, scope: !607)
!707 = !DILocation(line: 66, column: 7, scope: !607)
!708 = !DILocation(line: 66, column: 5, scope: !607)
!709 = !DILocation(line: 67, column: 9, scope: !710)
!710 = distinct !DILexicalBlock(scope: !607, file: !608, line: 67, column: 2)
!711 = !DILocation(line: 67, column: 7, scope: !710)
!712 = !DILocation(line: 67, column: 14, scope: !713)
!713 = distinct !DILexicalBlock(scope: !710, file: !608, line: 67, column: 2)
!714 = !DILocation(line: 67, column: 16, scope: !713)
!715 = !DILocation(line: 67, column: 2, scope: !710)
!716 = !DILocation(line: 68, column: 36, scope: !717)
!717 = distinct !DILexicalBlock(scope: !713, file: !608, line: 67, column: 40)
!718 = !DILocation(line: 68, column: 3, scope: !717)
!719 = !DILocation(line: 69, column: 2, scope: !717)
!720 = !DILocation(line: 67, column: 36, scope: !713)
!721 = !DILocation(line: 67, column: 2, scope: !713)
!722 = distinct !{!722, !715, !723}
!723 = !DILocation(line: 69, column: 2, scope: !710)
!724 = !DILocation(line: 70, column: 28, scope: !607)
!725 = !DILocation(line: 70, column: 7, scope: !607)
!726 = !DILocation(line: 70, column: 5, scope: !607)
!727 = !DILocation(line: 71, column: 2, scope: !607)
!728 = !DILocation(line: 73, column: 2, scope: !729)
!729 = distinct !DILexicalBlock(scope: !607, file: !608, line: 73, column: 2)
!730 = !DILocation(line: 77, column: 7, scope: !607)
!731 = !DILocation(line: 77, column: 5, scope: !607)
!732 = !DILocation(line: 78, column: 9, scope: !733)
!733 = distinct !DILexicalBlock(scope: !607, file: !608, line: 78, column: 2)
!734 = !DILocation(line: 78, column: 7, scope: !733)
!735 = !DILocation(line: 78, column: 14, scope: !736)
!736 = distinct !DILexicalBlock(scope: !733, file: !608, line: 78, column: 2)
!737 = !DILocation(line: 78, column: 16, scope: !736)
!738 = !DILocation(line: 78, column: 2, scope: !733)
!739 = !DILocation(line: 79, column: 36, scope: !740)
!740 = distinct !DILexicalBlock(scope: !736, file: !608, line: 78, column: 40)
!741 = !DILocation(line: 79, column: 3, scope: !740)
!742 = !DILocation(line: 80, column: 2, scope: !740)
!743 = !DILocation(line: 78, column: 36, scope: !736)
!744 = !DILocation(line: 78, column: 2, scope: !736)
!745 = distinct !{!745, !738, !746}
!746 = !DILocation(line: 80, column: 2, scope: !733)
!747 = !DILocation(line: 81, column: 28, scope: !607)
!748 = !DILocation(line: 81, column: 7, scope: !607)
!749 = !DILocation(line: 81, column: 5, scope: !607)
!750 = !DILocation(line: 82, column: 2, scope: !607)
!751 = !DILocation(line: 84, column: 2, scope: !752)
!752 = distinct !DILexicalBlock(scope: !607, file: !608, line: 84, column: 2)
!753 = !DILocation(line: 87, column: 1, scope: !607)
!754 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!755 = !DISubroutineType(types: !756)
!756 = !{!58}
!757 = !DILocalVariable(name: "et", scope: !754, file: !573, line: 177, type: !58)
!758 = !DILocation(line: 177, column: 11, scope: !754)
!759 = !DILocation(line: 179, column: 2, scope: !754)
!760 = !DILocation(line: 180, column: 7, scope: !754)
!761 = !DILocation(line: 180, column: 5, scope: !754)
!762 = !DILocation(line: 181, column: 9, scope: !754)
!763 = !DILocation(line: 181, column: 2, scope: !754)
!764 = distinct !DISubprogram(name: "k_msgq_put", scope: !765, file: !765, line: 815, type: !766, scopeLine: 816, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!765 = !DIFile(filename: "zephyr/include/generated/syscalls/kernel.h", directory: "/home/kenny/ara/build/appl/Zephyr/app_kernel")
!766 = !DISubroutineType(types: !767)
!767 = !{!61, !768, !802, !804}
!768 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !769, size: 32)
!769 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_msgq", file: !6, line: 3848, size: 352, elements: !770)
!770 = !{!771, !790, !794, !795, !796, !797, !798, !799, !800, !801}
!771 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !769, file: !6, line: 3850, baseType: !772, size: 64)
!772 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !773)
!773 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !774)
!774 = !{!775}
!775 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !773, file: !99, line: 209, baseType: !776, size: 64)
!776 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !777)
!777 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !778)
!778 = !{!779, !785}
!779 = !DIDerivedType(tag: DW_TAG_member, scope: !777, file: !116, line: 32, baseType: !780, size: 32)
!780 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !777, file: !116, line: 32, size: 32, elements: !781)
!781 = !{!782, !784}
!782 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !780, file: !116, line: 33, baseType: !783, size: 32)
!783 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !777, size: 32)
!784 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !780, file: !116, line: 34, baseType: !783, size: 32)
!785 = !DIDerivedType(tag: DW_TAG_member, scope: !777, file: !116, line: 36, baseType: !786, size: 32, offset: 32)
!786 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !777, file: !116, line: 36, size: 32, elements: !787)
!787 = !{!788, !789}
!788 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !786, file: !116, line: 37, baseType: !783, size: 32)
!789 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !786, file: !116, line: 38, baseType: !783, size: 32)
!790 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !769, file: !6, line: 3852, baseType: !791, size: 32, offset: 64)
!791 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !792)
!792 = !{!793}
!793 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !791, file: !99, line: 243, baseType: !134, size: 32)
!794 = !DIDerivedType(tag: DW_TAG_member, name: "msg_size", scope: !769, file: !6, line: 3854, baseType: !79, size: 32, offset: 96)
!795 = !DIDerivedType(tag: DW_TAG_member, name: "max_msgs", scope: !769, file: !6, line: 3856, baseType: !58, size: 32, offset: 128)
!796 = !DIDerivedType(tag: DW_TAG_member, name: "buffer_start", scope: !769, file: !6, line: 3858, baseType: !429, size: 32, offset: 160)
!797 = !DIDerivedType(tag: DW_TAG_member, name: "buffer_end", scope: !769, file: !6, line: 3860, baseType: !429, size: 32, offset: 192)
!798 = !DIDerivedType(tag: DW_TAG_member, name: "read_ptr", scope: !769, file: !6, line: 3862, baseType: !429, size: 32, offset: 224)
!799 = !DIDerivedType(tag: DW_TAG_member, name: "write_ptr", scope: !769, file: !6, line: 3864, baseType: !429, size: 32, offset: 256)
!800 = !DIDerivedType(tag: DW_TAG_member, name: "used_msgs", scope: !769, file: !6, line: 3866, baseType: !58, size: 32, offset: 288)
!801 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !769, file: !6, line: 3872, baseType: !161, size: 8, offset: 320)
!802 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !803, size: 32)
!803 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!804 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !805)
!805 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !806)
!806 = !{!807}
!807 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !805, file: !54, line: 68, baseType: !53, size: 64)
!808 = !DILocalVariable(name: "msgq", arg: 1, scope: !764, file: !765, line: 815, type: !768)
!809 = !DILocation(line: 815, column: 64, scope: !764)
!810 = !DILocalVariable(name: "data", arg: 2, scope: !764, file: !765, line: 815, type: !802)
!811 = !DILocation(line: 815, column: 83, scope: !764)
!812 = !DILocalVariable(name: "timeout", arg: 3, scope: !764, file: !765, line: 815, type: !804)
!813 = !DILocation(line: 815, column: 101, scope: !764)
!814 = !DILocation(line: 824, column: 2, scope: !764)
!815 = !DILocation(line: 824, column: 2, scope: !816)
!816 = distinct !DILexicalBlock(scope: !764, file: !765, line: 824, column: 2)
!817 = !{i32 -2141848207}
!818 = !DILocation(line: 825, column: 27, scope: !764)
!819 = !DILocation(line: 825, column: 33, scope: !764)
!820 = !DILocation(line: 825, column: 9, scope: !764)
!821 = !DILocation(line: 825, column: 2, scope: !764)
!822 = distinct !DISubprogram(name: "TIME_STAMP_DELTA_GET", scope: !63, file: !63, line: 33, type: !823, scopeLine: 34, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!823 = !DISubroutineType(types: !824)
!824 = !{!58, !58}
!825 = !DILocalVariable(name: "ts", arg: 1, scope: !822, file: !63, line: 33, type: !58)
!826 = !DILocation(line: 33, column: 54, scope: !822)
!827 = !DILocalVariable(name: "t", scope: !822, file: !63, line: 35, type: !58)
!828 = !DILocation(line: 35, column: 11, scope: !822)
!829 = !DILocation(line: 38, column: 2, scope: !822)
!830 = !DILocation(line: 40, column: 6, scope: !822)
!831 = !DILocation(line: 40, column: 4, scope: !822)
!832 = !DILocalVariable(name: "res", scope: !822, file: !63, line: 41, type: !58)
!833 = !DILocation(line: 41, column: 11, scope: !822)
!834 = !DILocation(line: 41, column: 18, scope: !822)
!835 = !DILocation(line: 41, column: 23, scope: !822)
!836 = !DILocation(line: 41, column: 20, scope: !822)
!837 = !DILocation(line: 41, column: 17, scope: !822)
!838 = !DILocation(line: 41, column: 30, scope: !822)
!839 = !DILocation(line: 41, column: 34, scope: !822)
!840 = !DILocation(line: 41, column: 32, scope: !822)
!841 = !DILocation(line: 41, column: 53, scope: !822)
!842 = !DILocation(line: 41, column: 51, scope: !822)
!843 = !DILocation(line: 41, column: 58, scope: !822)
!844 = !DILocation(line: 41, column: 56, scope: !822)
!845 = !DILocation(line: 43, column: 6, scope: !846)
!846 = distinct !DILexicalBlock(scope: !822, file: !63, line: 43, column: 6)
!847 = !DILocation(line: 43, column: 9, scope: !846)
!848 = !DILocation(line: 43, column: 6, scope: !822)
!849 = !DILocation(line: 44, column: 10, scope: !850)
!850 = distinct !DILexicalBlock(scope: !846, file: !63, line: 43, column: 14)
!851 = !DILocation(line: 44, column: 7, scope: !850)
!852 = !DILocation(line: 45, column: 2, scope: !850)
!853 = !DILocation(line: 46, column: 9, scope: !822)
!854 = !DILocation(line: 46, column: 2, scope: !822)
!855 = distinct !DISubprogram(name: "k_cyc_to_ns_floor64", scope: !856, file: !856, line: 901, type: !857, scopeLine: 902, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!856 = !DIFile(filename: "zephyrproject/zephyr/include/sys/time_units.h", directory: "/home/kenny")
!857 = !DISubroutineType(types: !858)
!858 = !{!69, !69}
!859 = !DILocalVariable(name: "t", arg: 1, scope: !860, file: !856, line: 78, type: !69)
!860 = distinct !DISubprogram(name: "z_tmcvt", scope: !856, file: !856, line: 78, type: !861, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!861 = !DISubroutineType(types: !862)
!862 = !{!69, !69, !58, !58, !863, !863, !863, !863}
!863 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!864 = !DILocation(line: 78, column: 63, scope: !860, inlinedAt: !865)
!865 = distinct !DILocation(line: 904, column: 9, scope: !855)
!866 = !DILocalVariable(name: "from_hz", arg: 2, scope: !860, file: !856, line: 78, type: !58)
!867 = !DILocation(line: 78, column: 75, scope: !860, inlinedAt: !865)
!868 = !DILocalVariable(name: "to_hz", arg: 3, scope: !860, file: !856, line: 79, type: !58)
!869 = !DILocation(line: 79, column: 18, scope: !860, inlinedAt: !865)
!870 = !DILocalVariable(name: "const_hz", arg: 4, scope: !860, file: !856, line: 79, type: !863)
!871 = !DILocation(line: 79, column: 30, scope: !860, inlinedAt: !865)
!872 = !DILocalVariable(name: "result32", arg: 5, scope: !860, file: !856, line: 80, type: !863)
!873 = !DILocation(line: 80, column: 14, scope: !860, inlinedAt: !865)
!874 = !DILocalVariable(name: "round_up", arg: 6, scope: !860, file: !856, line: 80, type: !863)
!875 = !DILocation(line: 80, column: 29, scope: !860, inlinedAt: !865)
!876 = !DILocalVariable(name: "round_off", arg: 7, scope: !860, file: !856, line: 81, type: !863)
!877 = !DILocation(line: 81, column: 14, scope: !860, inlinedAt: !865)
!878 = !DILocalVariable(name: "mul_ratio", scope: !860, file: !856, line: 84, type: !863)
!879 = !DILocation(line: 84, column: 7, scope: !860, inlinedAt: !865)
!880 = !DILocalVariable(name: "div_ratio", scope: !860, file: !856, line: 86, type: !863)
!881 = !DILocation(line: 86, column: 7, scope: !860, inlinedAt: !865)
!882 = !DILocalVariable(name: "off", scope: !860, file: !856, line: 93, type: !69)
!883 = !DILocation(line: 93, column: 11, scope: !860, inlinedAt: !865)
!884 = !DILocalVariable(name: "rdivisor", scope: !885, file: !856, line: 96, type: !58)
!885 = distinct !DILexicalBlock(scope: !886, file: !856, line: 95, column: 18)
!886 = distinct !DILexicalBlock(scope: !860, file: !856, line: 95, column: 6)
!887 = !DILocation(line: 96, column: 12, scope: !885, inlinedAt: !865)
!888 = !DILocalVariable(name: "t", arg: 1, scope: !855, file: !856, line: 901, type: !69)
!889 = !DILocation(line: 901, column: 68, scope: !855)
!890 = !DILocation(line: 904, column: 17, scope: !855)
!891 = !DILocation(line: 904, column: 20, scope: !855)
!892 = !DILocation(line: 84, column: 19, scope: !860, inlinedAt: !865)
!893 = !DILocation(line: 84, column: 28, scope: !860, inlinedAt: !865)
!894 = !DILocation(line: 85, column: 4, scope: !860, inlinedAt: !865)
!895 = !DILocation(line: 85, column: 12, scope: !860, inlinedAt: !865)
!896 = !DILocation(line: 85, column: 10, scope: !860, inlinedAt: !865)
!897 = !DILocation(line: 85, column: 21, scope: !860, inlinedAt: !865)
!898 = !DILocation(line: 85, column: 26, scope: !860, inlinedAt: !865)
!899 = !DILocation(line: 85, column: 34, scope: !860, inlinedAt: !865)
!900 = !DILocation(line: 85, column: 32, scope: !860, inlinedAt: !865)
!901 = !DILocation(line: 85, column: 43, scope: !860, inlinedAt: !865)
!902 = !DILocation(line: 0, scope: !860, inlinedAt: !865)
!903 = !DILocation(line: 86, column: 19, scope: !860, inlinedAt: !865)
!904 = !DILocation(line: 86, column: 28, scope: !860, inlinedAt: !865)
!905 = !DILocation(line: 87, column: 4, scope: !860, inlinedAt: !865)
!906 = !DILocation(line: 87, column: 14, scope: !860, inlinedAt: !865)
!907 = !DILocation(line: 87, column: 12, scope: !860, inlinedAt: !865)
!908 = !DILocation(line: 87, column: 21, scope: !860, inlinedAt: !865)
!909 = !DILocation(line: 87, column: 26, scope: !860, inlinedAt: !865)
!910 = !DILocation(line: 87, column: 36, scope: !860, inlinedAt: !865)
!911 = !DILocation(line: 87, column: 34, scope: !860, inlinedAt: !865)
!912 = !DILocation(line: 87, column: 43, scope: !860, inlinedAt: !865)
!913 = !DILocation(line: 89, column: 6, scope: !914, inlinedAt: !865)
!914 = distinct !DILexicalBlock(scope: !860, file: !856, line: 89, column: 6)
!915 = !DILocation(line: 89, column: 17, scope: !914, inlinedAt: !865)
!916 = !DILocation(line: 89, column: 14, scope: !914, inlinedAt: !865)
!917 = !DILocation(line: 89, column: 6, scope: !860, inlinedAt: !865)
!918 = !DILocation(line: 90, column: 10, scope: !919, inlinedAt: !865)
!919 = distinct !DILexicalBlock(scope: !914, file: !856, line: 89, column: 24)
!920 = !DILocation(line: 90, column: 32, scope: !919, inlinedAt: !865)
!921 = !DILocation(line: 90, column: 22, scope: !919, inlinedAt: !865)
!922 = !DILocation(line: 90, column: 21, scope: !919, inlinedAt: !865)
!923 = !DILocation(line: 90, column: 37, scope: !919, inlinedAt: !865)
!924 = !DILocation(line: 90, column: 3, scope: !919, inlinedAt: !865)
!925 = !DILocation(line: 95, column: 7, scope: !886, inlinedAt: !865)
!926 = !DILocation(line: 95, column: 6, scope: !860, inlinedAt: !865)
!927 = !DILocation(line: 96, column: 23, scope: !885, inlinedAt: !865)
!928 = !DILocation(line: 96, column: 36, scope: !885, inlinedAt: !865)
!929 = !DILocation(line: 96, column: 46, scope: !885, inlinedAt: !865)
!930 = !DILocation(line: 96, column: 44, scope: !885, inlinedAt: !865)
!931 = !DILocation(line: 96, column: 55, scope: !885, inlinedAt: !865)
!932 = !DILocation(line: 98, column: 7, scope: !933, inlinedAt: !865)
!933 = distinct !DILexicalBlock(scope: !885, file: !856, line: 98, column: 7)
!934 = !DILocation(line: 98, column: 7, scope: !885, inlinedAt: !865)
!935 = !DILocation(line: 99, column: 10, scope: !936, inlinedAt: !865)
!936 = distinct !DILexicalBlock(scope: !933, file: !856, line: 98, column: 17)
!937 = !DILocation(line: 99, column: 19, scope: !936, inlinedAt: !865)
!938 = !DILocation(line: 99, column: 8, scope: !936, inlinedAt: !865)
!939 = !DILocation(line: 100, column: 3, scope: !936, inlinedAt: !865)
!940 = !DILocation(line: 100, column: 14, scope: !941, inlinedAt: !865)
!941 = distinct !DILexicalBlock(scope: !933, file: !856, line: 100, column: 14)
!942 = !DILocation(line: 100, column: 14, scope: !933, inlinedAt: !865)
!943 = !DILocation(line: 101, column: 10, scope: !944, inlinedAt: !865)
!944 = distinct !DILexicalBlock(scope: !941, file: !856, line: 100, column: 25)
!945 = !DILocation(line: 101, column: 19, scope: !944, inlinedAt: !865)
!946 = !DILocation(line: 101, column: 8, scope: !944, inlinedAt: !865)
!947 = !DILocation(line: 102, column: 3, scope: !944, inlinedAt: !865)
!948 = !DILocation(line: 103, column: 2, scope: !885, inlinedAt: !865)
!949 = !DILocation(line: 110, column: 6, scope: !950, inlinedAt: !865)
!950 = distinct !DILexicalBlock(scope: !860, file: !856, line: 110, column: 6)
!951 = !DILocation(line: 110, column: 6, scope: !860, inlinedAt: !865)
!952 = !DILocation(line: 111, column: 8, scope: !953, inlinedAt: !865)
!953 = distinct !DILexicalBlock(scope: !950, file: !856, line: 110, column: 17)
!954 = !DILocation(line: 111, column: 5, scope: !953, inlinedAt: !865)
!955 = !DILocation(line: 112, column: 7, scope: !956, inlinedAt: !865)
!956 = distinct !DILexicalBlock(scope: !953, file: !856, line: 112, column: 7)
!957 = !DILocation(line: 112, column: 16, scope: !956, inlinedAt: !865)
!958 = !DILocation(line: 112, column: 20, scope: !956, inlinedAt: !865)
!959 = !DILocation(line: 112, column: 22, scope: !956, inlinedAt: !865)
!960 = !DILocation(line: 112, column: 7, scope: !953, inlinedAt: !865)
!961 = !DILocation(line: 113, column: 22, scope: !962, inlinedAt: !865)
!962 = distinct !DILexicalBlock(scope: !956, file: !856, line: 112, column: 36)
!963 = !DILocation(line: 113, column: 12, scope: !962, inlinedAt: !865)
!964 = !DILocation(line: 113, column: 28, scope: !962, inlinedAt: !865)
!965 = !DILocation(line: 113, column: 38, scope: !962, inlinedAt: !865)
!966 = !DILocation(line: 113, column: 36, scope: !962, inlinedAt: !865)
!967 = !DILocation(line: 113, column: 25, scope: !962, inlinedAt: !865)
!968 = !DILocation(line: 113, column: 11, scope: !962, inlinedAt: !865)
!969 = !DILocation(line: 113, column: 4, scope: !962, inlinedAt: !865)
!970 = !DILocation(line: 115, column: 11, scope: !971, inlinedAt: !865)
!971 = distinct !DILexicalBlock(scope: !956, file: !856, line: 114, column: 10)
!972 = !DILocation(line: 115, column: 16, scope: !971, inlinedAt: !865)
!973 = !DILocation(line: 115, column: 26, scope: !971, inlinedAt: !865)
!974 = !DILocation(line: 115, column: 24, scope: !971, inlinedAt: !865)
!975 = !DILocation(line: 115, column: 15, scope: !971, inlinedAt: !865)
!976 = !DILocation(line: 115, column: 13, scope: !971, inlinedAt: !865)
!977 = !DILocation(line: 115, column: 4, scope: !971, inlinedAt: !865)
!978 = !DILocation(line: 117, column: 13, scope: !979, inlinedAt: !865)
!979 = distinct !DILexicalBlock(scope: !950, file: !856, line: 117, column: 13)
!980 = !DILocation(line: 117, column: 13, scope: !950, inlinedAt: !865)
!981 = !DILocation(line: 118, column: 7, scope: !982, inlinedAt: !865)
!982 = distinct !DILexicalBlock(scope: !983, file: !856, line: 118, column: 7)
!983 = distinct !DILexicalBlock(scope: !979, file: !856, line: 117, column: 24)
!984 = !DILocation(line: 118, column: 7, scope: !983, inlinedAt: !865)
!985 = !DILocation(line: 119, column: 22, scope: !986, inlinedAt: !865)
!986 = distinct !DILexicalBlock(scope: !982, file: !856, line: 118, column: 17)
!987 = !DILocation(line: 119, column: 12, scope: !986, inlinedAt: !865)
!988 = !DILocation(line: 119, column: 28, scope: !986, inlinedAt: !865)
!989 = !DILocation(line: 119, column: 36, scope: !986, inlinedAt: !865)
!990 = !DILocation(line: 119, column: 34, scope: !986, inlinedAt: !865)
!991 = !DILocation(line: 119, column: 25, scope: !986, inlinedAt: !865)
!992 = !DILocation(line: 119, column: 11, scope: !986, inlinedAt: !865)
!993 = !DILocation(line: 119, column: 4, scope: !986, inlinedAt: !865)
!994 = !DILocation(line: 121, column: 11, scope: !995, inlinedAt: !865)
!995 = distinct !DILexicalBlock(scope: !982, file: !856, line: 120, column: 10)
!996 = !DILocation(line: 121, column: 16, scope: !995, inlinedAt: !865)
!997 = !DILocation(line: 121, column: 24, scope: !995, inlinedAt: !865)
!998 = !DILocation(line: 121, column: 22, scope: !995, inlinedAt: !865)
!999 = !DILocation(line: 121, column: 15, scope: !995, inlinedAt: !865)
!1000 = !DILocation(line: 121, column: 13, scope: !995, inlinedAt: !865)
!1001 = !DILocation(line: 121, column: 4, scope: !995, inlinedAt: !865)
!1002 = !DILocation(line: 124, column: 7, scope: !1003, inlinedAt: !865)
!1003 = distinct !DILexicalBlock(scope: !1004, file: !856, line: 124, column: 7)
!1004 = distinct !DILexicalBlock(scope: !979, file: !856, line: 123, column: 9)
!1005 = !DILocation(line: 124, column: 7, scope: !1004, inlinedAt: !865)
!1006 = !DILocation(line: 125, column: 23, scope: !1007, inlinedAt: !865)
!1007 = distinct !DILexicalBlock(scope: !1003, file: !856, line: 124, column: 17)
!1008 = !DILocation(line: 125, column: 27, scope: !1007, inlinedAt: !865)
!1009 = !DILocation(line: 125, column: 25, scope: !1007, inlinedAt: !865)
!1010 = !DILocation(line: 125, column: 35, scope: !1007, inlinedAt: !865)
!1011 = !DILocation(line: 125, column: 33, scope: !1007, inlinedAt: !865)
!1012 = !DILocation(line: 125, column: 42, scope: !1007, inlinedAt: !865)
!1013 = !DILocation(line: 125, column: 40, scope: !1007, inlinedAt: !865)
!1014 = !DILocation(line: 125, column: 11, scope: !1007, inlinedAt: !865)
!1015 = !DILocation(line: 125, column: 4, scope: !1007, inlinedAt: !865)
!1016 = !DILocation(line: 127, column: 12, scope: !1017, inlinedAt: !865)
!1017 = distinct !DILexicalBlock(scope: !1003, file: !856, line: 126, column: 10)
!1018 = !DILocation(line: 127, column: 16, scope: !1017, inlinedAt: !865)
!1019 = !DILocation(line: 127, column: 14, scope: !1017, inlinedAt: !865)
!1020 = !DILocation(line: 127, column: 24, scope: !1017, inlinedAt: !865)
!1021 = !DILocation(line: 127, column: 22, scope: !1017, inlinedAt: !865)
!1022 = !DILocation(line: 127, column: 31, scope: !1017, inlinedAt: !865)
!1023 = !DILocation(line: 127, column: 29, scope: !1017, inlinedAt: !865)
!1024 = !DILocation(line: 127, column: 4, scope: !1017, inlinedAt: !865)
!1025 = !DILocation(line: 130, column: 1, scope: !860, inlinedAt: !865)
!1026 = !DILocation(line: 904, column: 2, scope: !855)
!1027 = distinct !DISubprogram(name: "k_msgq_get", scope: !765, file: !765, line: 830, type: !1028, scopeLine: 831, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1028 = !DISubroutineType(types: !1029)
!1029 = !{!61, !768, !60, !804}
!1030 = !DILocalVariable(name: "msgq", arg: 1, scope: !1027, file: !765, line: 830, type: !768)
!1031 = !DILocation(line: 830, column: 64, scope: !1027)
!1032 = !DILocalVariable(name: "data", arg: 2, scope: !1027, file: !765, line: 830, type: !60)
!1033 = !DILocation(line: 830, column: 77, scope: !1027)
!1034 = !DILocalVariable(name: "timeout", arg: 3, scope: !1027, file: !765, line: 830, type: !804)
!1035 = !DILocation(line: 830, column: 95, scope: !1027)
!1036 = !DILocation(line: 839, column: 2, scope: !1027)
!1037 = !DILocation(line: 839, column: 2, scope: !1038)
!1038 = distinct !DILexicalBlock(scope: !1027, file: !765, line: 839, column: 2)
!1039 = !{i32 -2141848139}
!1040 = !DILocation(line: 840, column: 27, scope: !1027)
!1041 = !DILocation(line: 840, column: 33, scope: !1027)
!1042 = !DILocation(line: 840, column: 9, scope: !1027)
!1043 = !DILocation(line: 840, column: 2, scope: !1027)
!1044 = distinct !DISubprogram(name: "check_result", scope: !573, file: !573, line: 184, type: !206, scopeLine: 185, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1045 = !DILocation(line: 186, column: 6, scope: !1046)
!1046 = distinct !DILexicalBlock(scope: !1044, file: !573, line: 186, column: 6)
!1047 = !DILocation(line: 186, column: 23, scope: !1046)
!1048 = !DILocation(line: 186, column: 6, scope: !1044)
!1049 = !DILocation(line: 187, column: 3, scope: !1050)
!1050 = distinct !DILexicalBlock(scope: !1051, file: !573, line: 187, column: 3)
!1051 = distinct !DILexicalBlock(scope: !1046, file: !573, line: 186, column: 28)
!1052 = !DILocation(line: 188, column: 3, scope: !1051)
!1053 = !DILocation(line: 190, column: 1, scope: !1044)
!1054 = distinct !DISubprogram(name: "k_sem_give", scope: !765, file: !765, line: 761, type: !1055, scopeLine: 762, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1055 = !DISubroutineType(types: !1056)
!1056 = !{null, !1057}
!1057 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1058, size: 32)
!1058 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3704, size: 128, elements: !1059)
!1059 = !{!1060, !1061, !1062}
!1060 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !1058, file: !6, line: 3705, baseType: !772, size: 64)
!1061 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !1058, file: !6, line: 3706, baseType: !58, size: 32, offset: 64)
!1062 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !1058, file: !6, line: 3707, baseType: !58, size: 32, offset: 96)
!1063 = !DILocalVariable(name: "sem", arg: 1, scope: !1054, file: !765, line: 761, type: !1057)
!1064 = !DILocation(line: 761, column: 64, scope: !1054)
!1065 = !DILocation(line: 769, column: 2, scope: !1054)
!1066 = !DILocation(line: 769, column: 2, scope: !1067)
!1067 = distinct !DILexicalBlock(scope: !1054, file: !765, line: 769, column: 2)
!1068 = !{i32 -2141848479}
!1069 = !DILocation(line: 770, column: 20, scope: !1054)
!1070 = !DILocation(line: 770, column: 2, scope: !1054)
!1071 = !DILocation(line: 771, column: 1, scope: !1054)
!1072 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1073 = !DISubroutineType(types: !1074)
!1074 = !{!61}
!1075 = !DILocation(line: 82, column: 20, scope: !1072)
!1076 = !DILocation(line: 82, column: 18, scope: !1072)
!1077 = !DILocation(line: 90, column: 6, scope: !1078)
!1078 = distinct !DILexicalBlock(scope: !1072, file: !63, line: 90, column: 6)
!1079 = !DILocation(line: 90, column: 22, scope: !1078)
!1080 = !DILocation(line: 90, column: 6, scope: !1072)
!1081 = !DILocation(line: 91, column: 3, scope: !1082)
!1082 = distinct !DILexicalBlock(scope: !1078, file: !63, line: 90, column: 39)
!1083 = !DILocation(line: 93, column: 2, scope: !1072)
!1084 = !DILocation(line: 94, column: 1, scope: !1072)
!1085 = distinct !DISubprogram(name: "k_uptime_delta", scope: !6, file: !6, line: 2133, type: !1086, scopeLine: 2134, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1086 = !DISubroutineType(types: !1087)
!1087 = !{!55, !1088}
!1088 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !55, size: 32)
!1089 = !DILocalVariable(name: "reftime", arg: 1, scope: !1085, file: !6, line: 2133, type: !1088)
!1090 = !DILocation(line: 2133, column: 47, scope: !1085)
!1091 = !DILocalVariable(name: "uptime", scope: !1085, file: !6, line: 2135, type: !55)
!1092 = !DILocation(line: 2135, column: 10, scope: !1085)
!1093 = !DILocalVariable(name: "delta", scope: !1085, file: !6, line: 2135, type: !55)
!1094 = !DILocation(line: 2135, column: 18, scope: !1085)
!1095 = !DILocation(line: 2137, column: 11, scope: !1085)
!1096 = !DILocation(line: 2137, column: 9, scope: !1085)
!1097 = !DILocation(line: 2138, column: 10, scope: !1085)
!1098 = !DILocation(line: 2138, column: 20, scope: !1085)
!1099 = !DILocation(line: 2138, column: 19, scope: !1085)
!1100 = !DILocation(line: 2138, column: 17, scope: !1085)
!1101 = !DILocation(line: 2138, column: 8, scope: !1085)
!1102 = !DILocation(line: 2139, column: 13, scope: !1085)
!1103 = !DILocation(line: 2139, column: 3, scope: !1085)
!1104 = !DILocation(line: 2139, column: 11, scope: !1085)
!1105 = !DILocation(line: 2141, column: 9, scope: !1085)
!1106 = !DILocation(line: 2141, column: 2, scope: !1085)
!1107 = distinct !DISubprogram(name: "k_uptime_get", scope: !6, file: !6, line: 2059, type: !1108, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1108 = !DISubroutineType(types: !1109)
!1109 = !{!55}
!1110 = !DILocation(line: 2061, column: 31, scope: !1107)
!1111 = !DILocation(line: 2061, column: 9, scope: !1107)
!1112 = !DILocation(line: 2061, column: 2, scope: !1107)
!1113 = distinct !DISubprogram(name: "k_uptime_ticks", scope: !765, file: !765, line: 500, type: !1108, scopeLine: 501, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1114 = !DILocation(line: 509, column: 2, scope: !1113)
!1115 = !DILocation(line: 509, column: 2, scope: !1116)
!1116 = distinct !DILexicalBlock(scope: !1113, file: !765, line: 509, column: 2)
!1117 = !{i32 -2141849783}
!1118 = !DILocation(line: 510, column: 9, scope: !1113)
!1119 = !DILocation(line: 510, column: 2, scope: !1113)
!1120 = distinct !DISubprogram(name: "k_ticks_to_ms_floor64", scope: !856, file: !856, line: 1069, type: !857, scopeLine: 1070, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1121 = !DILocation(line: 78, column: 63, scope: !860, inlinedAt: !1122)
!1122 = distinct !DILocation(line: 1072, column: 9, scope: !1120)
!1123 = !DILocation(line: 78, column: 75, scope: !860, inlinedAt: !1122)
!1124 = !DILocation(line: 79, column: 18, scope: !860, inlinedAt: !1122)
!1125 = !DILocation(line: 79, column: 30, scope: !860, inlinedAt: !1122)
!1126 = !DILocation(line: 80, column: 14, scope: !860, inlinedAt: !1122)
!1127 = !DILocation(line: 80, column: 29, scope: !860, inlinedAt: !1122)
!1128 = !DILocation(line: 81, column: 14, scope: !860, inlinedAt: !1122)
!1129 = !DILocation(line: 84, column: 7, scope: !860, inlinedAt: !1122)
!1130 = !DILocation(line: 86, column: 7, scope: !860, inlinedAt: !1122)
!1131 = !DILocation(line: 93, column: 11, scope: !860, inlinedAt: !1122)
!1132 = !DILocation(line: 96, column: 12, scope: !885, inlinedAt: !1122)
!1133 = !DILocalVariable(name: "t", arg: 1, scope: !1120, file: !856, line: 1069, type: !69)
!1134 = !DILocation(line: 1069, column: 70, scope: !1120)
!1135 = !DILocation(line: 1072, column: 17, scope: !1120)
!1136 = !DILocation(line: 84, column: 19, scope: !860, inlinedAt: !1122)
!1137 = !DILocation(line: 84, column: 28, scope: !860, inlinedAt: !1122)
!1138 = !DILocation(line: 85, column: 4, scope: !860, inlinedAt: !1122)
!1139 = !DILocation(line: 85, column: 12, scope: !860, inlinedAt: !1122)
!1140 = !DILocation(line: 85, column: 10, scope: !860, inlinedAt: !1122)
!1141 = !DILocation(line: 85, column: 21, scope: !860, inlinedAt: !1122)
!1142 = !DILocation(line: 85, column: 26, scope: !860, inlinedAt: !1122)
!1143 = !DILocation(line: 85, column: 34, scope: !860, inlinedAt: !1122)
!1144 = !DILocation(line: 85, column: 32, scope: !860, inlinedAt: !1122)
!1145 = !DILocation(line: 85, column: 43, scope: !860, inlinedAt: !1122)
!1146 = !DILocation(line: 0, scope: !860, inlinedAt: !1122)
!1147 = !DILocation(line: 86, column: 19, scope: !860, inlinedAt: !1122)
!1148 = !DILocation(line: 86, column: 28, scope: !860, inlinedAt: !1122)
!1149 = !DILocation(line: 87, column: 4, scope: !860, inlinedAt: !1122)
!1150 = !DILocation(line: 87, column: 14, scope: !860, inlinedAt: !1122)
!1151 = !DILocation(line: 87, column: 12, scope: !860, inlinedAt: !1122)
!1152 = !DILocation(line: 87, column: 21, scope: !860, inlinedAt: !1122)
!1153 = !DILocation(line: 87, column: 26, scope: !860, inlinedAt: !1122)
!1154 = !DILocation(line: 87, column: 36, scope: !860, inlinedAt: !1122)
!1155 = !DILocation(line: 87, column: 34, scope: !860, inlinedAt: !1122)
!1156 = !DILocation(line: 87, column: 43, scope: !860, inlinedAt: !1122)
!1157 = !DILocation(line: 89, column: 6, scope: !914, inlinedAt: !1122)
!1158 = !DILocation(line: 89, column: 17, scope: !914, inlinedAt: !1122)
!1159 = !DILocation(line: 89, column: 14, scope: !914, inlinedAt: !1122)
!1160 = !DILocation(line: 89, column: 6, scope: !860, inlinedAt: !1122)
!1161 = !DILocation(line: 90, column: 10, scope: !919, inlinedAt: !1122)
!1162 = !DILocation(line: 90, column: 32, scope: !919, inlinedAt: !1122)
!1163 = !DILocation(line: 90, column: 22, scope: !919, inlinedAt: !1122)
!1164 = !DILocation(line: 90, column: 21, scope: !919, inlinedAt: !1122)
!1165 = !DILocation(line: 90, column: 37, scope: !919, inlinedAt: !1122)
!1166 = !DILocation(line: 90, column: 3, scope: !919, inlinedAt: !1122)
!1167 = !DILocation(line: 95, column: 7, scope: !886, inlinedAt: !1122)
!1168 = !DILocation(line: 95, column: 6, scope: !860, inlinedAt: !1122)
!1169 = !DILocation(line: 96, column: 23, scope: !885, inlinedAt: !1122)
!1170 = !DILocation(line: 96, column: 36, scope: !885, inlinedAt: !1122)
!1171 = !DILocation(line: 96, column: 46, scope: !885, inlinedAt: !1122)
!1172 = !DILocation(line: 96, column: 44, scope: !885, inlinedAt: !1122)
!1173 = !DILocation(line: 96, column: 55, scope: !885, inlinedAt: !1122)
!1174 = !DILocation(line: 98, column: 7, scope: !933, inlinedAt: !1122)
!1175 = !DILocation(line: 98, column: 7, scope: !885, inlinedAt: !1122)
!1176 = !DILocation(line: 99, column: 10, scope: !936, inlinedAt: !1122)
!1177 = !DILocation(line: 99, column: 19, scope: !936, inlinedAt: !1122)
!1178 = !DILocation(line: 99, column: 8, scope: !936, inlinedAt: !1122)
!1179 = !DILocation(line: 100, column: 3, scope: !936, inlinedAt: !1122)
!1180 = !DILocation(line: 100, column: 14, scope: !941, inlinedAt: !1122)
!1181 = !DILocation(line: 100, column: 14, scope: !933, inlinedAt: !1122)
!1182 = !DILocation(line: 101, column: 10, scope: !944, inlinedAt: !1122)
!1183 = !DILocation(line: 101, column: 19, scope: !944, inlinedAt: !1122)
!1184 = !DILocation(line: 101, column: 8, scope: !944, inlinedAt: !1122)
!1185 = !DILocation(line: 102, column: 3, scope: !944, inlinedAt: !1122)
!1186 = !DILocation(line: 103, column: 2, scope: !885, inlinedAt: !1122)
!1187 = !DILocation(line: 110, column: 6, scope: !950, inlinedAt: !1122)
!1188 = !DILocation(line: 110, column: 6, scope: !860, inlinedAt: !1122)
!1189 = !DILocation(line: 111, column: 8, scope: !953, inlinedAt: !1122)
!1190 = !DILocation(line: 111, column: 5, scope: !953, inlinedAt: !1122)
!1191 = !DILocation(line: 112, column: 7, scope: !956, inlinedAt: !1122)
!1192 = !DILocation(line: 112, column: 16, scope: !956, inlinedAt: !1122)
!1193 = !DILocation(line: 112, column: 20, scope: !956, inlinedAt: !1122)
!1194 = !DILocation(line: 112, column: 22, scope: !956, inlinedAt: !1122)
!1195 = !DILocation(line: 112, column: 7, scope: !953, inlinedAt: !1122)
!1196 = !DILocation(line: 113, column: 22, scope: !962, inlinedAt: !1122)
!1197 = !DILocation(line: 113, column: 12, scope: !962, inlinedAt: !1122)
!1198 = !DILocation(line: 113, column: 28, scope: !962, inlinedAt: !1122)
!1199 = !DILocation(line: 113, column: 38, scope: !962, inlinedAt: !1122)
!1200 = !DILocation(line: 113, column: 36, scope: !962, inlinedAt: !1122)
!1201 = !DILocation(line: 113, column: 25, scope: !962, inlinedAt: !1122)
!1202 = !DILocation(line: 113, column: 11, scope: !962, inlinedAt: !1122)
!1203 = !DILocation(line: 113, column: 4, scope: !962, inlinedAt: !1122)
!1204 = !DILocation(line: 115, column: 11, scope: !971, inlinedAt: !1122)
!1205 = !DILocation(line: 115, column: 16, scope: !971, inlinedAt: !1122)
!1206 = !DILocation(line: 115, column: 26, scope: !971, inlinedAt: !1122)
!1207 = !DILocation(line: 115, column: 24, scope: !971, inlinedAt: !1122)
!1208 = !DILocation(line: 115, column: 15, scope: !971, inlinedAt: !1122)
!1209 = !DILocation(line: 115, column: 13, scope: !971, inlinedAt: !1122)
!1210 = !DILocation(line: 115, column: 4, scope: !971, inlinedAt: !1122)
!1211 = !DILocation(line: 117, column: 13, scope: !979, inlinedAt: !1122)
!1212 = !DILocation(line: 117, column: 13, scope: !950, inlinedAt: !1122)
!1213 = !DILocation(line: 118, column: 7, scope: !982, inlinedAt: !1122)
!1214 = !DILocation(line: 118, column: 7, scope: !983, inlinedAt: !1122)
!1215 = !DILocation(line: 119, column: 22, scope: !986, inlinedAt: !1122)
!1216 = !DILocation(line: 119, column: 12, scope: !986, inlinedAt: !1122)
!1217 = !DILocation(line: 119, column: 28, scope: !986, inlinedAt: !1122)
!1218 = !DILocation(line: 119, column: 36, scope: !986, inlinedAt: !1122)
!1219 = !DILocation(line: 119, column: 34, scope: !986, inlinedAt: !1122)
!1220 = !DILocation(line: 119, column: 25, scope: !986, inlinedAt: !1122)
!1221 = !DILocation(line: 119, column: 11, scope: !986, inlinedAt: !1122)
!1222 = !DILocation(line: 119, column: 4, scope: !986, inlinedAt: !1122)
!1223 = !DILocation(line: 121, column: 11, scope: !995, inlinedAt: !1122)
!1224 = !DILocation(line: 121, column: 16, scope: !995, inlinedAt: !1122)
!1225 = !DILocation(line: 121, column: 24, scope: !995, inlinedAt: !1122)
!1226 = !DILocation(line: 121, column: 22, scope: !995, inlinedAt: !1122)
!1227 = !DILocation(line: 121, column: 15, scope: !995, inlinedAt: !1122)
!1228 = !DILocation(line: 121, column: 13, scope: !995, inlinedAt: !1122)
!1229 = !DILocation(line: 121, column: 4, scope: !995, inlinedAt: !1122)
!1230 = !DILocation(line: 124, column: 7, scope: !1003, inlinedAt: !1122)
!1231 = !DILocation(line: 124, column: 7, scope: !1004, inlinedAt: !1122)
!1232 = !DILocation(line: 125, column: 23, scope: !1007, inlinedAt: !1122)
!1233 = !DILocation(line: 125, column: 27, scope: !1007, inlinedAt: !1122)
!1234 = !DILocation(line: 125, column: 25, scope: !1007, inlinedAt: !1122)
!1235 = !DILocation(line: 125, column: 35, scope: !1007, inlinedAt: !1122)
!1236 = !DILocation(line: 125, column: 33, scope: !1007, inlinedAt: !1122)
!1237 = !DILocation(line: 125, column: 42, scope: !1007, inlinedAt: !1122)
!1238 = !DILocation(line: 125, column: 40, scope: !1007, inlinedAt: !1122)
!1239 = !DILocation(line: 125, column: 11, scope: !1007, inlinedAt: !1122)
!1240 = !DILocation(line: 125, column: 4, scope: !1007, inlinedAt: !1122)
!1241 = !DILocation(line: 127, column: 12, scope: !1017, inlinedAt: !1122)
!1242 = !DILocation(line: 127, column: 16, scope: !1017, inlinedAt: !1122)
!1243 = !DILocation(line: 127, column: 14, scope: !1017, inlinedAt: !1122)
!1244 = !DILocation(line: 127, column: 24, scope: !1017, inlinedAt: !1122)
!1245 = !DILocation(line: 127, column: 22, scope: !1017, inlinedAt: !1122)
!1246 = !DILocation(line: 127, column: 31, scope: !1017, inlinedAt: !1122)
!1247 = !DILocation(line: 127, column: 29, scope: !1017, inlinedAt: !1122)
!1248 = !DILocation(line: 127, column: 4, scope: !1017, inlinedAt: !1122)
!1249 = !DILocation(line: 130, column: 1, scope: !860, inlinedAt: !1122)
!1250 = !DILocation(line: 1072, column: 2, scope: !1120)
!1251 = distinct !DISubprogram(name: "sys_clock_hw_cycles_per_sec", scope: !856, file: !856, line: 50, type: !1073, scopeLine: 51, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1252 = !DILocation(line: 55, column: 2, scope: !1251)
!1253 = distinct !DISubprogram(name: "timestamp_serialize", scope: !1254, file: !1254, line: 28, type: !206, scopeLine: 29, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1254 = !DIFile(filename: "zephyrproject/zephyr/subsys/testsuite/include/test_asm_inline_gcc.h", directory: "/home/kenny")
!1255 = !DILocation(line: 935, column: 3, scope: !1256, inlinedAt: !1258)
!1256 = distinct !DISubprogram(name: "__ISB", scope: !1257, file: !1257, line: 933, type: !206, scopeLine: 934, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1257 = !DIFile(filename: "zephyrproject/modules/hal/cmsis/CMSIS/Core/Include/cmsis_gcc.h", directory: "/home/kenny")
!1258 = distinct !DILocation(line: 31, column: 2, scope: !1253)
!1259 = !{i32 2225343}
!1260 = !DILocation(line: 32, column: 1, scope: !1253)
!1261 = distinct !DISubprogram(name: "k_cycle_get_32", scope: !6, file: !6, line: 2172, type: !755, scopeLine: 2173, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1262 = !DILocation(line: 2174, column: 9, scope: !1261)
!1263 = !DILocation(line: 2174, column: 2, scope: !1261)
!1264 = distinct !DISubprogram(name: "arch_k_cycle_get_32", scope: !1265, file: !1265, line: 24, type: !755, scopeLine: 25, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1265 = !DIFile(filename: "zephyrproject/zephyr/include/arch/arm/aarch32/misc.h", directory: "/home/kenny")
!1266 = !DILocation(line: 26, column: 9, scope: !1264)
!1267 = !DILocation(line: 26, column: 2, scope: !1264)
!1268 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1269 = !DILocation(line: 72, column: 18, scope: !1268)
!1270 = !DILocation(line: 74, column: 2, scope: !1268)
!1271 = !DILocation(line: 75, column: 20, scope: !1268)
!1272 = !DILocation(line: 75, column: 18, scope: !1268)
!1273 = !DILocation(line: 76, column: 1, scope: !1268)
!1274 = distinct !DISubprogram(name: "k_sleep", scope: !765, file: !765, line: 117, type: !1275, scopeLine: 118, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !609)
!1275 = !DISubroutineType(types: !1276)
!1276 = !{!412, !804}
!1277 = !DILocalVariable(name: "timeout", arg: 1, scope: !1274, file: !765, line: 117, type: !804)
!1278 = !DILocation(line: 117, column: 61, scope: !1274)
!1279 = !DILocation(line: 126, column: 2, scope: !1274)
!1280 = !DILocation(line: 126, column: 2, scope: !1281)
!1281 = distinct !DILexicalBlock(scope: !1274, file: !765, line: 126, column: 2)
!1282 = !{i32 -2141851687}
!1283 = !DILocation(line: 127, column: 9, scope: !1274)
!1284 = !DILocation(line: 127, column: 2, scope: !1274)
!1285 = distinct !DISubprogram(name: "dequtask", scope: !1286, file: !1286, line: 21, type: !206, scopeLine: 22, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !597, retainedNodes: !609)
!1286 = !DIFile(filename: "appl/Zephyr/app_kernel/src/fifo_r.c", directory: "/home/kenny/ara")
!1287 = !DILocalVariable(name: "x", scope: !1285, file: !1286, line: 23, type: !61)
!1288 = !DILocation(line: 23, column: 6, scope: !1285)
!1289 = !DILocalVariable(name: "i", scope: !1285, file: !1286, line: 23, type: !61)
!1290 = !DILocation(line: 23, column: 9, scope: !1285)
!1291 = !DILocation(line: 25, column: 9, scope: !1292)
!1292 = distinct !DILexicalBlock(scope: !1285, file: !1286, line: 25, column: 2)
!1293 = !DILocation(line: 25, column: 7, scope: !1292)
!1294 = !DILocation(line: 25, column: 14, scope: !1295)
!1295 = distinct !DILexicalBlock(scope: !1292, file: !1286, line: 25, column: 2)
!1296 = !DILocation(line: 25, column: 16, scope: !1295)
!1297 = !DILocation(line: 25, column: 2, scope: !1292)
!1298 = !DILocation(line: 26, column: 24, scope: !1299)
!1299 = distinct !DILexicalBlock(scope: !1295, file: !1286, line: 25, column: 40)
!1300 = !DILocation(line: 26, column: 28, scope: !1299)
!1301 = !DILocation(line: 26, column: 3, scope: !1299)
!1302 = !DILocation(line: 27, column: 2, scope: !1299)
!1303 = !DILocation(line: 25, column: 36, scope: !1295)
!1304 = !DILocation(line: 25, column: 2, scope: !1295)
!1305 = distinct !{!1305, !1297, !1306}
!1306 = !DILocation(line: 27, column: 2, scope: !1292)
!1307 = !DILocation(line: 29, column: 9, scope: !1308)
!1308 = distinct !DILexicalBlock(scope: !1285, file: !1286, line: 29, column: 2)
!1309 = !DILocation(line: 29, column: 7, scope: !1308)
!1310 = !DILocation(line: 29, column: 14, scope: !1311)
!1311 = distinct !DILexicalBlock(scope: !1308, file: !1286, line: 29, column: 2)
!1312 = !DILocation(line: 29, column: 16, scope: !1311)
!1313 = !DILocation(line: 29, column: 2, scope: !1308)
!1314 = !DILocation(line: 30, column: 24, scope: !1315)
!1315 = distinct !DILexicalBlock(scope: !1311, file: !1286, line: 29, column: 40)
!1316 = !DILocation(line: 30, column: 28, scope: !1315)
!1317 = !DILocation(line: 30, column: 3, scope: !1315)
!1318 = !DILocation(line: 31, column: 2, scope: !1315)
!1319 = !DILocation(line: 29, column: 36, scope: !1311)
!1320 = !DILocation(line: 29, column: 2, scope: !1311)
!1321 = distinct !{!1321, !1313, !1322}
!1322 = !DILocation(line: 31, column: 2, scope: !1308)
!1323 = !DILocation(line: 32, column: 1, scope: !1285)
!1324 = distinct !DISubprogram(name: "mailbox_test", scope: !74, file: !74, line: 76, type: !206, scopeLine: 77, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1325 = !DILocalVariable(name: "putsize", scope: !1324, file: !74, line: 78, type: !58)
!1326 = !DILocation(line: 78, column: 11, scope: !1324)
!1327 = !DILocalVariable(name: "puttime", scope: !1324, file: !74, line: 79, type: !58)
!1328 = !DILocation(line: 79, column: 11, scope: !1324)
!1329 = !DILocalVariable(name: "putcount", scope: !1324, file: !74, line: 80, type: !61)
!1330 = !DILocation(line: 80, column: 6, scope: !1324)
!1331 = !DILocalVariable(name: "empty_msg_put_time", scope: !1324, file: !74, line: 81, type: !59)
!1332 = !DILocation(line: 81, column: 15, scope: !1324)
!1333 = !DILocalVariable(name: "getinfo", scope: !1324, file: !74, line: 82, type: !1334)
!1334 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getinfo", file: !1335, line: 18, size: 96, elements: !1336)
!1335 = !DIFile(filename: "appl/Zephyr/app_kernel/src/receiver.h", directory: "/home/kenny/ara")
!1336 = !{!1337, !1338, !1339}
!1337 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !1334, file: !1335, line: 19, baseType: !61, size: 32)
!1338 = !DIDerivedType(tag: DW_TAG_member, name: "time", scope: !1334, file: !1335, line: 20, baseType: !59, size: 32, offset: 32)
!1339 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !1334, file: !1335, line: 21, baseType: !61, size: 32, offset: 64)
!1340 = !DILocation(line: 82, column: 17, scope: !1324)
!1341 = !DILocation(line: 84, column: 2, scope: !1324)
!1342 = !DILocation(line: 85, column: 2, scope: !1324)
!1343 = !DILocation(line: 88, column: 2, scope: !1324)
!1344 = !DILocation(line: 89, column: 2, scope: !1324)
!1345 = !DILocation(line: 91, column: 2, scope: !1346)
!1346 = distinct !DILexicalBlock(scope: !1324, file: !74, line: 91, column: 2)
!1347 = !DILocation(line: 94, column: 2, scope: !1324)
!1348 = !DILocation(line: 95, column: 2, scope: !1324)
!1349 = !DILocation(line: 96, column: 2, scope: !1324)
!1350 = !DILocation(line: 97, column: 2, scope: !1324)
!1351 = !DILocation(line: 98, column: 2, scope: !1324)
!1352 = !DILocation(line: 100, column: 11, scope: !1324)
!1353 = !DILocation(line: 102, column: 10, scope: !1324)
!1354 = !DILocation(line: 103, column: 14, scope: !1324)
!1355 = !DILocation(line: 103, column: 23, scope: !1324)
!1356 = !DILocation(line: 103, column: 2, scope: !1324)
!1357 = !DILocation(line: 105, column: 23, scope: !1324)
!1358 = !DILocation(line: 105, column: 33, scope: !1324)
!1359 = !DILocation(line: 105, column: 2, scope: !1324)
!1360 = !DILocation(line: 106, column: 2, scope: !1361)
!1361 = distinct !DILexicalBlock(scope: !1324, file: !74, line: 106, column: 2)
!1362 = !DILocation(line: 107, column: 23, scope: !1324)
!1363 = !DILocation(line: 107, column: 21, scope: !1324)
!1364 = !DILocation(line: 108, column: 15, scope: !1365)
!1365 = distinct !DILexicalBlock(scope: !1324, file: !74, line: 108, column: 2)
!1366 = !DILocation(line: 108, column: 7, scope: !1365)
!1367 = !DILocation(line: 108, column: 21, scope: !1368)
!1368 = distinct !DILexicalBlock(scope: !1365, file: !74, line: 108, column: 2)
!1369 = !DILocation(line: 108, column: 29, scope: !1368)
!1370 = !DILocation(line: 108, column: 2, scope: !1365)
!1371 = !DILocation(line: 109, column: 15, scope: !1372)
!1372 = distinct !DILexicalBlock(scope: !1368, file: !74, line: 108, column: 61)
!1373 = !DILocation(line: 109, column: 24, scope: !1372)
!1374 = !DILocation(line: 109, column: 3, scope: !1372)
!1375 = !DILocation(line: 111, column: 24, scope: !1372)
!1376 = !DILocation(line: 111, column: 34, scope: !1372)
!1377 = !DILocation(line: 111, column: 3, scope: !1372)
!1378 = !DILocation(line: 112, column: 3, scope: !1379)
!1379 = distinct !DILexicalBlock(scope: !1372, file: !74, line: 112, column: 3)
!1380 = !DILocation(line: 113, column: 2, scope: !1372)
!1381 = !DILocation(line: 108, column: 54, scope: !1368)
!1382 = !DILocation(line: 108, column: 2, scope: !1368)
!1383 = distinct !{!1383, !1370, !1384}
!1384 = !DILocation(line: 113, column: 2, scope: !1365)
!1385 = !DILocation(line: 114, column: 2, scope: !1324)
!1386 = !DILocation(line: 115, column: 2, scope: !1387)
!1387 = distinct !DILexicalBlock(scope: !1324, file: !74, line: 115, column: 2)
!1388 = !DILocation(line: 116, column: 2, scope: !1389)
!1389 = distinct !DILexicalBlock(scope: !1324, file: !74, line: 116, column: 2)
!1390 = !DILocation(line: 117, column: 1, scope: !1324)
!1391 = distinct !DISubprogram(name: "k_sem_reset", scope: !765, file: !765, line: 775, type: !1392, scopeLine: 776, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1392 = !DISubroutineType(types: !1393)
!1393 = !{null, !233}
!1394 = !DILocalVariable(name: "sem", arg: 1, scope: !1391, file: !765, line: 775, type: !233)
!1395 = !DILocation(line: 775, column: 65, scope: !1391)
!1396 = !DILocation(line: 783, column: 2, scope: !1391)
!1397 = !DILocation(line: 783, column: 2, scope: !1398)
!1398 = distinct !DILexicalBlock(scope: !1391, file: !765, line: 783, column: 2)
!1399 = !{i32 -2141846069}
!1400 = !DILocation(line: 784, column: 21, scope: !1391)
!1401 = !DILocation(line: 784, column: 2, scope: !1391)
!1402 = !DILocation(line: 785, column: 1, scope: !1391)
!1403 = distinct !DISubprogram(name: "mailbox_put", scope: !74, file: !74, line: 130, type: !1404, scopeLine: 131, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1404 = !DISubroutineType(types: !1405)
!1405 = !{null, !58, !61, !1406}
!1406 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !58, size: 32)
!1407 = !DILocalVariable(name: "size", arg: 1, scope: !1403, file: !74, line: 130, type: !58)
!1408 = !DILocation(line: 130, column: 27, scope: !1403)
!1409 = !DILocalVariable(name: "count", arg: 2, scope: !1403, file: !74, line: 130, type: !61)
!1410 = !DILocation(line: 130, column: 37, scope: !1403)
!1411 = !DILocalVariable(name: "time", arg: 3, scope: !1403, file: !74, line: 130, type: !1406)
!1412 = !DILocation(line: 130, column: 54, scope: !1403)
!1413 = !DILocalVariable(name: "i", scope: !1403, file: !74, line: 132, type: !61)
!1414 = !DILocation(line: 132, column: 6, scope: !1403)
!1415 = !DILocalVariable(name: "t", scope: !1403, file: !74, line: 133, type: !59)
!1416 = !DILocation(line: 133, column: 15, scope: !1403)
!1417 = !DILocation(line: 135, column: 27, scope: !1403)
!1418 = !DILocation(line: 136, column: 27, scope: !1403)
!1419 = !DILocation(line: 139, column: 2, scope: !1403)
!1420 = !DILocation(line: 140, column: 6, scope: !1403)
!1421 = !DILocation(line: 140, column: 4, scope: !1403)
!1422 = !DILocation(line: 141, column: 9, scope: !1423)
!1423 = distinct !DILexicalBlock(scope: !1403, file: !74, line: 141, column: 2)
!1424 = !DILocation(line: 141, column: 7, scope: !1423)
!1425 = !DILocation(line: 141, column: 14, scope: !1426)
!1426 = distinct !DILexicalBlock(scope: !1423, file: !74, line: 141, column: 2)
!1427 = !DILocation(line: 141, column: 18, scope: !1426)
!1428 = !DILocation(line: 141, column: 16, scope: !1426)
!1429 = !DILocation(line: 141, column: 2, scope: !1423)
!1430 = !DILocation(line: 142, column: 33, scope: !1431)
!1431 = distinct !DILexicalBlock(scope: !1426, file: !74, line: 141, column: 30)
!1432 = !DILocation(line: 142, column: 3, scope: !1431)
!1433 = !DILocation(line: 143, column: 2, scope: !1431)
!1434 = !DILocation(line: 141, column: 26, scope: !1426)
!1435 = !DILocation(line: 141, column: 2, scope: !1426)
!1436 = distinct !{!1436, !1429, !1437}
!1437 = !DILocation(line: 143, column: 2, scope: !1423)
!1438 = !DILocation(line: 144, column: 27, scope: !1403)
!1439 = !DILocation(line: 144, column: 6, scope: !1403)
!1440 = !DILocation(line: 144, column: 4, scope: !1403)
!1441 = !DILocation(line: 145, column: 10, scope: !1403)
!1442 = !DILocation(line: 145, column: 3, scope: !1403)
!1443 = !DILocation(line: 145, column: 8, scope: !1403)
!1444 = !DILocation(line: 146, column: 2, scope: !1403)
!1445 = !DILocation(line: 147, column: 1, scope: !1403)
!1446 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1447 = !DILocalVariable(name: "et", scope: !1446, file: !573, line: 177, type: !58)
!1448 = !DILocation(line: 177, column: 11, scope: !1446)
!1449 = !DILocation(line: 179, column: 2, scope: !1446)
!1450 = !DILocation(line: 180, column: 7, scope: !1446)
!1451 = !DILocation(line: 180, column: 5, scope: !1446)
!1452 = !DILocation(line: 181, column: 9, scope: !1446)
!1453 = !DILocation(line: 181, column: 2, scope: !1446)
!1454 = distinct !DISubprogram(name: "check_result", scope: !573, file: !573, line: 184, type: !206, scopeLine: 185, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1455 = !DILocation(line: 186, column: 6, scope: !1456)
!1456 = distinct !DILexicalBlock(scope: !1454, file: !573, line: 186, column: 6)
!1457 = !DILocation(line: 186, column: 23, scope: !1456)
!1458 = !DILocation(line: 186, column: 6, scope: !1454)
!1459 = !DILocation(line: 187, column: 3, scope: !1460)
!1460 = distinct !DILexicalBlock(scope: !1461, file: !573, line: 187, column: 3)
!1461 = distinct !DILexicalBlock(scope: !1456, file: !573, line: 186, column: 28)
!1462 = !DILocation(line: 188, column: 3, scope: !1461)
!1463 = !DILocation(line: 190, column: 1, scope: !1454)
!1464 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1465 = !DILocation(line: 82, column: 20, scope: !1464)
!1466 = !DILocation(line: 82, column: 18, scope: !1464)
!1467 = !DILocation(line: 90, column: 6, scope: !1468)
!1468 = distinct !DILexicalBlock(scope: !1464, file: !63, line: 90, column: 6)
!1469 = !DILocation(line: 90, column: 22, scope: !1468)
!1470 = !DILocation(line: 90, column: 6, scope: !1464)
!1471 = !DILocation(line: 91, column: 3, scope: !1472)
!1472 = distinct !DILexicalBlock(scope: !1468, file: !63, line: 90, column: 39)
!1473 = !DILocation(line: 93, column: 2, scope: !1464)
!1474 = !DILocation(line: 94, column: 1, scope: !1464)
!1475 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1476 = !DILocation(line: 72, column: 18, scope: !1475)
!1477 = !DILocation(line: 74, column: 2, scope: !1475)
!1478 = !DILocation(line: 75, column: 20, scope: !1475)
!1479 = !DILocation(line: 75, column: 18, scope: !1475)
!1480 = !DILocation(line: 76, column: 1, scope: !1475)
!1481 = distinct !DISubprogram(name: "z_impl_k_sem_reset", scope: !6, file: !6, line: 3796, type: !1392, scopeLine: 3797, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !66, retainedNodes: !609)
!1482 = !DILocalVariable(name: "sem", arg: 1, scope: !1481, file: !6, line: 3796, type: !233)
!1483 = !DILocation(line: 3796, column: 53, scope: !1481)
!1484 = !DILocation(line: 3798, column: 2, scope: !1481)
!1485 = !DILocation(line: 3798, column: 7, scope: !1481)
!1486 = !DILocation(line: 3798, column: 13, scope: !1481)
!1487 = !DILocation(line: 3799, column: 1, scope: !1481)
!1488 = distinct !DISubprogram(name: "mailrecvtask", scope: !1489, file: !1489, line: 34, type: !206, scopeLine: 35, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !241, retainedNodes: !609)
!1489 = !DIFile(filename: "appl/Zephyr/app_kernel/src/mailbox_r.c", directory: "/home/kenny/ara")
!1490 = !DILocalVariable(name: "getsize", scope: !1488, file: !1489, line: 36, type: !61)
!1491 = !DILocation(line: 36, column: 6, scope: !1488)
!1492 = !DILocalVariable(name: "gettime", scope: !1488, file: !1489, line: 37, type: !59)
!1493 = !DILocation(line: 37, column: 15, scope: !1488)
!1494 = !DILocalVariable(name: "getcount", scope: !1488, file: !1489, line: 38, type: !61)
!1495 = !DILocation(line: 38, column: 6, scope: !1488)
!1496 = !DILocalVariable(name: "getinfo", scope: !1488, file: !1489, line: 39, type: !1497)
!1497 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getinfo", file: !1335, line: 18, size: 96, elements: !1498)
!1498 = !{!1499, !1500, !1501}
!1499 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !1497, file: !1335, line: 19, baseType: !61, size: 32)
!1500 = !DIDerivedType(tag: DW_TAG_member, name: "time", scope: !1497, file: !1335, line: 20, baseType: !59, size: 32, offset: 32)
!1501 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !1497, file: !1335, line: 21, baseType: !61, size: 32, offset: 64)
!1502 = !DILocation(line: 39, column: 17, scope: !1488)
!1503 = !DILocation(line: 41, column: 11, scope: !1488)
!1504 = !DILocation(line: 43, column: 10, scope: !1488)
!1505 = !DILocation(line: 44, column: 23, scope: !1488)
!1506 = !DILocation(line: 44, column: 32, scope: !1488)
!1507 = !DILocation(line: 44, column: 2, scope: !1488)
!1508 = !DILocation(line: 45, column: 17, scope: !1488)
!1509 = !DILocation(line: 45, column: 10, scope: !1488)
!1510 = !DILocation(line: 45, column: 15, scope: !1488)
!1511 = !DILocation(line: 46, column: 17, scope: !1488)
!1512 = !DILocation(line: 46, column: 10, scope: !1488)
!1513 = !DILocation(line: 46, column: 15, scope: !1488)
!1514 = !DILocation(line: 47, column: 18, scope: !1488)
!1515 = !DILocation(line: 47, column: 10, scope: !1488)
!1516 = !DILocation(line: 47, column: 16, scope: !1488)
!1517 = !DILocation(line: 49, column: 23, scope: !1488)
!1518 = !DILocation(line: 49, column: 33, scope: !1488)
!1519 = !DILocation(line: 49, column: 2, scope: !1488)
!1520 = !DILocation(line: 51, column: 15, scope: !1521)
!1521 = distinct !DILexicalBlock(scope: !1488, file: !1489, line: 51, column: 2)
!1522 = !DILocation(line: 51, column: 7, scope: !1521)
!1523 = !DILocation(line: 51, column: 20, scope: !1524)
!1524 = distinct !DILexicalBlock(scope: !1521, file: !1489, line: 51, column: 2)
!1525 = !DILocation(line: 51, column: 28, scope: !1524)
!1526 = !DILocation(line: 51, column: 2, scope: !1521)
!1527 = !DILocation(line: 52, column: 24, scope: !1528)
!1528 = distinct !DILexicalBlock(scope: !1524, file: !1489, line: 51, column: 60)
!1529 = !DILocation(line: 52, column: 33, scope: !1528)
!1530 = !DILocation(line: 52, column: 3, scope: !1528)
!1531 = !DILocation(line: 53, column: 18, scope: !1528)
!1532 = !DILocation(line: 53, column: 11, scope: !1528)
!1533 = !DILocation(line: 53, column: 16, scope: !1528)
!1534 = !DILocation(line: 54, column: 18, scope: !1528)
!1535 = !DILocation(line: 54, column: 11, scope: !1528)
!1536 = !DILocation(line: 54, column: 16, scope: !1528)
!1537 = !DILocation(line: 55, column: 19, scope: !1528)
!1538 = !DILocation(line: 55, column: 11, scope: !1528)
!1539 = !DILocation(line: 55, column: 17, scope: !1528)
!1540 = !DILocation(line: 57, column: 24, scope: !1528)
!1541 = !DILocation(line: 57, column: 34, scope: !1528)
!1542 = !DILocation(line: 57, column: 3, scope: !1528)
!1543 = !DILocation(line: 58, column: 2, scope: !1528)
!1544 = !DILocation(line: 51, column: 53, scope: !1524)
!1545 = !DILocation(line: 51, column: 2, scope: !1524)
!1546 = distinct !{!1546, !1526, !1547}
!1547 = !DILocation(line: 58, column: 2, scope: !1521)
!1548 = !DILocation(line: 59, column: 1, scope: !1488)
!1549 = distinct !DISubprogram(name: "mailbox_get", scope: !1489, file: !1489, line: 73, type: !1550, scopeLine: 77, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !241, retainedNodes: !609)
!1550 = !DISubroutineType(types: !1551)
!1551 = !{null, !1552, !61, !61, !1579}
!1552 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1553, size: 32)
!1553 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mbox", file: !6, line: 4152, size: 160, elements: !1554)
!1554 = !{!1555, !1574, !1575}
!1555 = !DIDerivedType(tag: DW_TAG_member, name: "tx_msg_queue", scope: !1553, file: !6, line: 4154, baseType: !1556, size: 64)
!1556 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !1557)
!1557 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !1558)
!1558 = !{!1559}
!1559 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !1557, file: !99, line: 209, baseType: !1560, size: 64)
!1560 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !1561)
!1561 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !1562)
!1562 = !{!1563, !1569}
!1563 = !DIDerivedType(tag: DW_TAG_member, scope: !1561, file: !116, line: 32, baseType: !1564, size: 32)
!1564 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1561, file: !116, line: 32, size: 32, elements: !1565)
!1565 = !{!1566, !1568}
!1566 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !1564, file: !116, line: 33, baseType: !1567, size: 32)
!1567 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1561, size: 32)
!1568 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !1564, file: !116, line: 34, baseType: !1567, size: 32)
!1569 = !DIDerivedType(tag: DW_TAG_member, scope: !1561, file: !116, line: 36, baseType: !1570, size: 32, offset: 32)
!1570 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1561, file: !116, line: 36, size: 32, elements: !1571)
!1571 = !{!1572, !1573}
!1572 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !1570, file: !116, line: 37, baseType: !1567, size: 32)
!1573 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !1570, file: !116, line: 38, baseType: !1567, size: 32)
!1574 = !DIDerivedType(tag: DW_TAG_member, name: "rx_msg_queue", scope: !1553, file: !6, line: 4156, baseType: !1556, size: 64, offset: 64)
!1575 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !1553, file: !6, line: 4157, baseType: !1576, size: 32, offset: 128)
!1576 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !1577)
!1577 = !{!1578}
!1578 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !1576, file: !99, line: 243, baseType: !134, size: 32)
!1579 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !59, size: 32)
!1580 = !DILocalVariable(name: "mailbox", arg: 1, scope: !1549, file: !1489, line: 73, type: !1552)
!1581 = !DILocation(line: 73, column: 33, scope: !1549)
!1582 = !DILocalVariable(name: "size", arg: 2, scope: !1549, file: !1489, line: 74, type: !61)
!1583 = !DILocation(line: 74, column: 8, scope: !1549)
!1584 = !DILocalVariable(name: "count", arg: 3, scope: !1549, file: !1489, line: 75, type: !61)
!1585 = !DILocation(line: 75, column: 8, scope: !1549)
!1586 = !DILocalVariable(name: "time", arg: 4, scope: !1549, file: !1489, line: 76, type: !1579)
!1587 = !DILocation(line: 76, column: 18, scope: !1549)
!1588 = !DILocalVariable(name: "i", scope: !1549, file: !1489, line: 78, type: !61)
!1589 = !DILocation(line: 78, column: 6, scope: !1549)
!1590 = !DILocalVariable(name: "t", scope: !1549, file: !1489, line: 79, type: !59)
!1591 = !DILocation(line: 79, column: 15, scope: !1549)
!1592 = !DILocalVariable(name: "return_value", scope: !1549, file: !1489, line: 80, type: !412)
!1593 = !DILocation(line: 80, column: 10, scope: !1549)
!1594 = !DILocalVariable(name: "Message", scope: !1549, file: !1489, line: 81, type: !1595)
!1595 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mbox_msg", file: !6, line: 4124, size: 352, elements: !1596)
!1596 = !{!1597, !1598, !1599, !1600, !1601, !1602, !1625, !1703, !1704, !1705}
!1597 = !DIDerivedType(tag: DW_TAG_member, name: "_mailbox", scope: !1595, file: !6, line: 4126, baseType: !58, size: 32)
!1598 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !1595, file: !6, line: 4128, baseType: !79, size: 32, offset: 32)
!1599 = !DIDerivedType(tag: DW_TAG_member, name: "info", scope: !1595, file: !6, line: 4130, baseType: !58, size: 32, offset: 64)
!1600 = !DIDerivedType(tag: DW_TAG_member, name: "tx_data", scope: !1595, file: !6, line: 4132, baseType: !60, size: 32, offset: 96)
!1601 = !DIDerivedType(tag: DW_TAG_member, name: "_rx_data", scope: !1595, file: !6, line: 4134, baseType: !60, size: 32, offset: 128)
!1602 = !DIDerivedType(tag: DW_TAG_member, name: "tx_block", scope: !1595, file: !6, line: 4136, baseType: !1603, size: 64, offset: 160)
!1603 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_block", file: !86, line: 23, size: 64, elements: !1604)
!1604 = !{!1605}
!1605 = !DIDerivedType(tag: DW_TAG_member, scope: !1603, file: !86, line: 24, baseType: !1606, size: 64)
!1606 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1603, file: !86, line: 24, size: 64, elements: !1607)
!1607 = !{!1608, !1609}
!1608 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !1606, file: !86, line: 25, baseType: !60, size: 32)
!1609 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !1606, file: !86, line: 26, baseType: !1610, size: 64)
!1610 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_block_id", file: !86, line: 15, size: 64, elements: !1611)
!1611 = !{!1612, !1613}
!1612 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !1610, file: !86, line: 16, baseType: !60, size: 32)
!1613 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !1610, file: !86, line: 17, baseType: !1614, size: 32, offset: 32)
!1614 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1615, size: 32)
!1615 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !99, line: 267, size: 192, elements: !1616)
!1616 = !{!1617, !1623, !1624}
!1617 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !1615, file: !99, line: 268, baseType: !1618, size: 96)
!1618 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !103, line: 51, size: 96, elements: !1619)
!1619 = !{!1620, !1621, !1622}
!1620 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !1618, file: !103, line: 52, baseType: !106, size: 32)
!1621 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !1618, file: !103, line: 53, baseType: !60, size: 32, offset: 32)
!1622 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !1618, file: !103, line: 54, baseType: !79, size: 32, offset: 64)
!1623 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !1615, file: !99, line: 269, baseType: !1556, size: 64, offset: 96)
!1624 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !1615, file: !99, line: 270, baseType: !1576, size: 32, offset: 160)
!1625 = !DIDerivedType(tag: DW_TAG_member, name: "rx_source_thread", scope: !1595, file: !6, line: 4138, baseType: !1626, size: 32, offset: 224)
!1626 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !1627)
!1627 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1628, size: 32)
!1628 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1280, elements: !1629)
!1629 = !{!1630, !1671, !1683, !1684, !1685, !1686, !1687, !1693, !1698}
!1630 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !1628, file: !6, line: 572, baseType: !1631, size: 448)
!1631 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !1632)
!1632 = !{!1633, !1644, !1646, !1647, !1648, !1657, !1658, !1659, !1670}
!1633 = !DIDerivedType(tag: DW_TAG_member, scope: !1631, file: !6, line: 444, baseType: !1634, size: 64)
!1634 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1631, file: !6, line: 444, size: 64, elements: !1635)
!1635 = !{!1636, !1638}
!1636 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !1634, file: !6, line: 445, baseType: !1637, size: 64)
!1637 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !116, line: 43, baseType: !1561)
!1638 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !1634, file: !6, line: 446, baseType: !1639, size: 64)
!1639 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !151, line: 48, size: 64, elements: !1640)
!1640 = !{!1641}
!1641 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !1639, file: !151, line: 49, baseType: !1642, size: 64)
!1642 = !DICompositeType(tag: DW_TAG_array_type, baseType: !1643, size: 64, elements: !156)
!1643 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1639, size: 32)
!1644 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !1631, file: !6, line: 452, baseType: !1645, size: 32, offset: 64)
!1645 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1556, size: 32)
!1646 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !1631, file: !6, line: 455, baseType: !161, size: 8, offset: 96)
!1647 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !1631, file: !6, line: 458, baseType: !161, size: 8, offset: 104)
!1648 = !DIDerivedType(tag: DW_TAG_member, scope: !1631, file: !6, line: 474, baseType: !1649, size: 16, offset: 112)
!1649 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1631, file: !6, line: 474, size: 16, elements: !1650)
!1650 = !{!1651, !1656}
!1651 = !DIDerivedType(tag: DW_TAG_member, scope: !1649, file: !6, line: 475, baseType: !1652, size: 16)
!1652 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !1649, file: !6, line: 475, size: 16, elements: !1653)
!1653 = !{!1654, !1655}
!1654 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !1652, file: !6, line: 480, baseType: !170, size: 8)
!1655 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !1652, file: !6, line: 481, baseType: !161, size: 8, offset: 8)
!1656 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !1649, file: !6, line: 484, baseType: !174, size: 16)
!1657 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !1631, file: !6, line: 491, baseType: !58, size: 32, offset: 128)
!1658 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !1631, file: !6, line: 511, baseType: !60, size: 32, offset: 160)
!1659 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !1631, file: !6, line: 515, baseType: !1660, size: 192, offset: 192)
!1660 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !99, line: 221, size: 192, elements: !1661)
!1661 = !{!1662, !1663, !1669}
!1662 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !1660, file: !99, line: 222, baseType: !1637, size: 64)
!1663 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !1660, file: !99, line: 223, baseType: !1664, size: 32, offset: 64)
!1664 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !99, line: 219, baseType: !1665)
!1665 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1666, size: 32)
!1666 = !DISubroutineType(types: !1667)
!1667 = !{null, !1668}
!1668 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1660, size: 32)
!1669 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !1660, file: !99, line: 226, baseType: !55, size: 64, offset: 128)
!1670 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !1631, file: !6, line: 518, baseType: !1556, size: 64, offset: 384)
!1671 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !1628, file: !6, line: 575, baseType: !1672, size: 288, offset: 448)
!1672 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !192, line: 25, size: 288, elements: !1673)
!1673 = !{!1674, !1675, !1676, !1677, !1678, !1679, !1680, !1681, !1682}
!1674 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !1672, file: !192, line: 26, baseType: !58, size: 32)
!1675 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !1672, file: !192, line: 27, baseType: !58, size: 32, offset: 32)
!1676 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !1672, file: !192, line: 28, baseType: !58, size: 32, offset: 64)
!1677 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !1672, file: !192, line: 29, baseType: !58, size: 32, offset: 96)
!1678 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !1672, file: !192, line: 30, baseType: !58, size: 32, offset: 128)
!1679 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !1672, file: !192, line: 31, baseType: !58, size: 32, offset: 160)
!1680 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !1672, file: !192, line: 32, baseType: !58, size: 32, offset: 192)
!1681 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !1672, file: !192, line: 33, baseType: !58, size: 32, offset: 224)
!1682 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !1672, file: !192, line: 34, baseType: !58, size: 32, offset: 256)
!1683 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !1628, file: !6, line: 578, baseType: !60, size: 32, offset: 736)
!1684 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !1628, file: !6, line: 583, baseType: !205, size: 32, offset: 768)
!1685 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !1628, file: !6, line: 595, baseType: !209, size: 256, offset: 800)
!1686 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !1628, file: !6, line: 610, baseType: !61, size: 32, offset: 1056)
!1687 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !1628, file: !6, line: 616, baseType: !1688, size: 96, offset: 1088)
!1688 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !1689)
!1689 = !{!1690, !1691, !1692}
!1690 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !1688, file: !6, line: 529, baseType: !134, size: 32)
!1691 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !1688, file: !6, line: 538, baseType: !79, size: 32, offset: 32)
!1692 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !1688, file: !6, line: 544, baseType: !79, size: 32, offset: 64)
!1693 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !1628, file: !6, line: 641, baseType: !1694, size: 32, offset: 1184)
!1694 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1695, size: 32)
!1695 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !86, line: 30, size: 32, elements: !1696)
!1696 = !{!1697}
!1697 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !1695, file: !86, line: 31, baseType: !1614, size: 32)
!1698 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !1628, file: !6, line: 644, baseType: !1699, size: 64, offset: 1216)
!1699 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !192, line: 60, size: 64, elements: !1700)
!1700 = !{!1701, !1702}
!1701 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !1699, file: !192, line: 63, baseType: !58, size: 32)
!1702 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !1699, file: !192, line: 66, baseType: !58, size: 32, offset: 32)
!1703 = !DIDerivedType(tag: DW_TAG_member, name: "tx_target_thread", scope: !1595, file: !6, line: 4140, baseType: !1626, size: 32, offset: 256)
!1704 = !DIDerivedType(tag: DW_TAG_member, name: "_syncing_thread", scope: !1595, file: !6, line: 4142, baseType: !1626, size: 32, offset: 288)
!1705 = !DIDerivedType(tag: DW_TAG_member, name: "_async_sem", scope: !1595, file: !6, line: 4145, baseType: !1706, size: 32, offset: 320)
!1706 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1707, size: 32)
!1707 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3704, size: 128, elements: !1708)
!1708 = !{!1709, !1710, !1711}
!1709 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !1707, file: !6, line: 3705, baseType: !1556, size: 64)
!1710 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !1707, file: !6, line: 3706, baseType: !58, size: 32, offset: 64)
!1711 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !1707, file: !6, line: 3707, baseType: !58, size: 32, offset: 96)
!1712 = !DILocation(line: 81, column: 20, scope: !1549)
!1713 = !DILocation(line: 83, column: 10, scope: !1549)
!1714 = !DILocation(line: 83, column: 27, scope: !1549)
!1715 = !DILocation(line: 84, column: 17, scope: !1549)
!1716 = !DILocation(line: 84, column: 10, scope: !1549)
!1717 = !DILocation(line: 84, column: 15, scope: !1549)
!1718 = !DILocation(line: 87, column: 20, scope: !1549)
!1719 = !DILocation(line: 87, column: 2, scope: !1549)
!1720 = !DILocation(line: 88, column: 6, scope: !1549)
!1721 = !DILocation(line: 88, column: 4, scope: !1549)
!1722 = !DILocation(line: 89, column: 9, scope: !1723)
!1723 = distinct !DILexicalBlock(scope: !1549, file: !1489, line: 89, column: 2)
!1724 = !DILocation(line: 89, column: 7, scope: !1723)
!1725 = !DILocation(line: 89, column: 14, scope: !1726)
!1726 = distinct !DILexicalBlock(scope: !1723, file: !1489, line: 89, column: 2)
!1727 = !DILocation(line: 89, column: 18, scope: !1726)
!1728 = !DILocation(line: 89, column: 16, scope: !1726)
!1729 = !DILocation(line: 89, column: 2, scope: !1723)
!1730 = !DILocation(line: 90, column: 30, scope: !1731)
!1731 = distinct !DILexicalBlock(scope: !1726, file: !1489, line: 89, column: 30)
!1732 = !DILocation(line: 93, column: 8, scope: !1731)
!1733 = !DILocation(line: 90, column: 19, scope: !1731)
!1734 = !DILocation(line: 90, column: 16, scope: !1731)
!1735 = !DILocation(line: 94, column: 2, scope: !1731)
!1736 = !DILocation(line: 89, column: 26, scope: !1726)
!1737 = !DILocation(line: 89, column: 2, scope: !1726)
!1738 = distinct !{!1738, !1729, !1739}
!1739 = !DILocation(line: 94, column: 2, scope: !1723)
!1740 = !DILocation(line: 96, column: 27, scope: !1549)
!1741 = !DILocation(line: 96, column: 6, scope: !1549)
!1742 = !DILocation(line: 96, column: 4, scope: !1549)
!1743 = !DILocation(line: 97, column: 10, scope: !1549)
!1744 = !DILocation(line: 97, column: 3, scope: !1549)
!1745 = !DILocation(line: 97, column: 8, scope: !1549)
!1746 = !DILocation(line: 98, column: 6, scope: !1747)
!1747 = distinct !DILexicalBlock(scope: !1549, file: !1489, line: 98, column: 6)
!1748 = !DILocation(line: 98, column: 23, scope: !1747)
!1749 = !DILocation(line: 98, column: 6, scope: !1549)
!1750 = !DILocation(line: 99, column: 3, scope: !1751)
!1751 = distinct !DILexicalBlock(scope: !1752, file: !1489, line: 99, column: 3)
!1752 = distinct !DILexicalBlock(scope: !1747, file: !1489, line: 98, column: 28)
!1753 = !DILocation(line: 100, column: 2, scope: !1752)
!1754 = !DILocation(line: 101, column: 6, scope: !1755)
!1755 = distinct !DILexicalBlock(scope: !1549, file: !1489, line: 101, column: 6)
!1756 = !DILocation(line: 101, column: 19, scope: !1755)
!1757 = !DILocation(line: 101, column: 6, scope: !1549)
!1758 = !DILocation(line: 102, column: 3, scope: !1759)
!1759 = distinct !DILexicalBlock(scope: !1755, file: !1489, line: 101, column: 25)
!1760 = !DILocation(line: 102, column: 3, scope: !1761)
!1761 = distinct !DILexicalBlock(scope: !1759, file: !1489, line: 102, column: 3)
!1762 = !{i32 -2141827805, i32 -2141827789, i32 -2141827763, i32 -2141827735, i32 -2141827715}
!1763 = !DILocation(line: 103, column: 2, scope: !1759)
!1764 = !DILocation(line: 104, column: 1, scope: !1549)
!1765 = distinct !DISubprogram(name: "k_sem_take", scope: !765, file: !765, line: 746, type: !1766, scopeLine: 747, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !241, retainedNodes: !609)
!1766 = !DISubroutineType(types: !1767)
!1767 = !{!61, !1706, !1768}
!1768 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !1769)
!1769 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !1770)
!1770 = !{!1771}
!1771 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !1769, file: !54, line: 68, baseType: !53, size: 64)
!1772 = !DILocalVariable(name: "sem", arg: 1, scope: !1765, file: !765, line: 746, type: !1706)
!1773 = !DILocation(line: 746, column: 63, scope: !1765)
!1774 = !DILocalVariable(name: "timeout", arg: 2, scope: !1765, file: !765, line: 746, type: !1768)
!1775 = !DILocation(line: 746, column: 80, scope: !1765)
!1776 = !DILocation(line: 755, column: 2, scope: !1765)
!1777 = !DILocation(line: 755, column: 2, scope: !1778)
!1778 = distinct !DILexicalBlock(scope: !1765, file: !765, line: 755, column: 2)
!1779 = !{i32 -2141852293}
!1780 = !DILocation(line: 756, column: 27, scope: !1765)
!1781 = !DILocation(line: 756, column: 9, scope: !1765)
!1782 = !DILocation(line: 756, column: 2, scope: !1765)
!1783 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !241, retainedNodes: !609)
!1784 = !DILocalVariable(name: "et", scope: !1783, file: !573, line: 177, type: !58)
!1785 = !DILocation(line: 177, column: 11, scope: !1783)
!1786 = !DILocation(line: 179, column: 2, scope: !1783)
!1787 = !DILocation(line: 180, column: 7, scope: !1783)
!1788 = !DILocation(line: 180, column: 5, scope: !1783)
!1789 = !DILocation(line: 181, column: 9, scope: !1783)
!1790 = !DILocation(line: 181, column: 2, scope: !1783)
!1791 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !241, retainedNodes: !609)
!1792 = !DILocation(line: 82, column: 20, scope: !1791)
!1793 = !DILocation(line: 82, column: 18, scope: !1791)
!1794 = !DILocation(line: 90, column: 6, scope: !1795)
!1795 = distinct !DILexicalBlock(scope: !1791, file: !63, line: 90, column: 6)
!1796 = !DILocation(line: 90, column: 22, scope: !1795)
!1797 = !DILocation(line: 90, column: 6, scope: !1791)
!1798 = !DILocation(line: 91, column: 3, scope: !1799)
!1799 = distinct !DILexicalBlock(scope: !1795, file: !63, line: 90, column: 39)
!1800 = !DILocation(line: 93, column: 2, scope: !1791)
!1801 = !DILocation(line: 94, column: 1, scope: !1791)
!1802 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !241, retainedNodes: !609)
!1803 = !DILocation(line: 72, column: 18, scope: !1802)
!1804 = !DILocation(line: 74, column: 2, scope: !1802)
!1805 = !DILocation(line: 75, column: 20, scope: !1802)
!1806 = !DILocation(line: 75, column: 18, scope: !1802)
!1807 = !DILocation(line: 76, column: 1, scope: !1802)
!1808 = distinct !DISubprogram(name: "kbhit", scope: !255, file: !255, line: 73, type: !1073, scopeLine: 74, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !246, retainedNodes: !609)
!1809 = !DILocation(line: 75, column: 2, scope: !1808)
!1810 = distinct !DISubprogram(name: "init_output", scope: !255, file: !255, line: 88, type: !1811, scopeLine: 89, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !246, retainedNodes: !609)
!1811 = !DISubroutineType(types: !1812)
!1812 = !{null, !1813, !1813}
!1813 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !61, size: 32)
!1814 = !DILocalVariable(name: "continuously", arg: 1, scope: !1810, file: !255, line: 88, type: !1813)
!1815 = !DILocation(line: 88, column: 23, scope: !1810)
!1816 = !DILocalVariable(name: "autorun", arg: 2, scope: !1810, file: !255, line: 88, type: !1813)
!1817 = !DILocation(line: 88, column: 42, scope: !1810)
!1818 = !DILocation(line: 90, column: 2, scope: !1810)
!1819 = !DILocation(line: 91, column: 2, scope: !1810)
!1820 = !DILocation(line: 96, column: 14, scope: !1810)
!1821 = !DILocation(line: 97, column: 1, scope: !1810)
!1822 = distinct !DISubprogram(name: "output_close", scope: !255, file: !255, line: 105, type: !206, scopeLine: 106, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !246, retainedNodes: !609)
!1823 = !DILocation(line: 107, column: 1, scope: !1822)
!1824 = distinct !DISubprogram(name: "main", scope: !255, file: !255, line: 120, type: !206, scopeLine: 121, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !246, retainedNodes: !609)
!1825 = !DILocalVariable(name: "autorun", scope: !1824, file: !255, line: 122, type: !61)
!1826 = !DILocation(line: 122, column: 6, scope: !1824)
!1827 = !DILocalVariable(name: "continuously", scope: !1824, file: !255, line: 122, type: !61)
!1828 = !DILocation(line: 122, column: 19, scope: !1824)
!1829 = !DILocation(line: 124, column: 2, scope: !1824)
!1830 = !DILocation(line: 125, column: 2, scope: !1824)
!1831 = !DILocation(line: 127, column: 2, scope: !1824)
!1832 = !DILocation(line: 128, column: 2, scope: !1824)
!1833 = !DILocation(line: 129, column: 3, scope: !1834)
!1834 = distinct !DILexicalBlock(scope: !1824, file: !255, line: 128, column: 5)
!1835 = !DILocation(line: 130, column: 3, scope: !1834)
!1836 = !DILocation(line: 133, column: 3, scope: !1834)
!1837 = !DILocation(line: 134, column: 3, scope: !1834)
!1838 = !DILocation(line: 135, column: 3, scope: !1834)
!1839 = !DILocation(line: 136, column: 3, scope: !1834)
!1840 = !DILocation(line: 137, column: 3, scope: !1834)
!1841 = !DILocation(line: 138, column: 3, scope: !1834)
!1842 = !DILocation(line: 139, column: 3, scope: !1834)
!1843 = !DILocation(line: 140, column: 3, scope: !1834)
!1844 = !DILocation(line: 141, column: 3, scope: !1834)
!1845 = !DILocation(line: 144, column: 3, scope: !1834)
!1846 = !DILocation(line: 145, column: 3, scope: !1834)
!1847 = !DILocation(line: 146, column: 3, scope: !1834)
!1848 = !DILocation(line: 146, column: 3, scope: !1849)
!1849 = distinct !DILexicalBlock(scope: !1834, file: !255, line: 146, column: 3)
!1850 = !DILocation(line: 147, column: 2, scope: !1834)
!1851 = !DILocation(line: 147, column: 11, scope: !1824)
!1852 = !DILocation(line: 147, column: 24, scope: !1824)
!1853 = !DILocation(line: 147, column: 28, scope: !1824)
!1854 = !DILocation(line: 147, column: 27, scope: !1824)
!1855 = !DILocation(line: 0, scope: !1824)
!1856 = distinct !{!1856, !1832, !1857}
!1857 = !DILocation(line: 147, column: 35, scope: !1824)
!1858 = !DILocation(line: 151, column: 2, scope: !1824)
!1859 = !DILocation(line: 153, column: 2, scope: !1824)
!1860 = !DILocation(line: 154, column: 1, scope: !1824)
!1861 = distinct !DISubprogram(name: "bench_test_init", scope: !63, file: !63, line: 53, type: !206, scopeLine: 54, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !246, retainedNodes: !609)
!1862 = !DILocalVariable(name: "t", scope: !1861, file: !63, line: 55, type: !58)
!1863 = !DILocation(line: 55, column: 11, scope: !1861)
!1864 = !DILocation(line: 55, column: 15, scope: !1861)
!1865 = !DILocation(line: 57, column: 11, scope: !1861)
!1866 = !DILocation(line: 57, column: 27, scope: !1861)
!1867 = !DILocation(line: 57, column: 25, scope: !1861)
!1868 = !DILocation(line: 57, column: 9, scope: !1861)
!1869 = !DILocation(line: 58, column: 1, scope: !1861)
!1870 = distinct !DISubprogram(name: "k_thread_abort", scope: !765, file: !765, line: 200, type: !1871, scopeLine: 201, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !246, retainedNodes: !609)
!1871 = !DISubroutineType(types: !1872)
!1872 = !{null, !419}
!1873 = !DILocalVariable(name: "thread", arg: 1, scope: !1870, file: !765, line: 200, type: !419)
!1874 = !DILocation(line: 200, column: 61, scope: !1870)
!1875 = !DILocation(line: 208, column: 2, scope: !1870)
!1876 = !DILocation(line: 208, column: 2, scope: !1877)
!1877 = distinct !DILexicalBlock(scope: !1870, file: !765, line: 208, column: 2)
!1878 = !{i32 -2141850071}
!1879 = !DILocation(line: 209, column: 24, scope: !1870)
!1880 = !DILocation(line: 209, column: 2, scope: !1870)
!1881 = !DILocation(line: 210, column: 1, scope: !1870)
!1882 = distinct !DISubprogram(name: "dummy_test", scope: !255, file: !255, line: 163, type: !206, scopeLine: 164, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !246, retainedNodes: !609)
!1883 = !DILocation(line: 165, column: 1, scope: !1882)
!1884 = distinct !DISubprogram(name: "memorymap_test", scope: !1885, file: !1885, line: 21, type: !206, scopeLine: 22, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !554, retainedNodes: !609)
!1885 = !DIFile(filename: "appl/Zephyr/app_kernel/src/memmap_b.c", directory: "/home/kenny/ara")
!1886 = !DILocalVariable(name: "et", scope: !1884, file: !1885, line: 23, type: !58)
!1887 = !DILocation(line: 23, column: 11, scope: !1884)
!1888 = !DILocalVariable(name: "i", scope: !1884, file: !1885, line: 24, type: !61)
!1889 = !DILocation(line: 24, column: 6, scope: !1884)
!1890 = !DILocalVariable(name: "p", scope: !1884, file: !1885, line: 25, type: !60)
!1891 = !DILocation(line: 25, column: 8, scope: !1884)
!1892 = !DILocalVariable(name: "alloc_status", scope: !1884, file: !1885, line: 26, type: !61)
!1893 = !DILocation(line: 26, column: 6, scope: !1884)
!1894 = !DILocation(line: 28, column: 2, scope: !1884)
!1895 = !DILocation(line: 29, column: 7, scope: !1884)
!1896 = !DILocation(line: 29, column: 5, scope: !1884)
!1897 = !DILocation(line: 30, column: 9, scope: !1898)
!1898 = distinct !DILexicalBlock(scope: !1884, file: !1885, line: 30, column: 2)
!1899 = !DILocation(line: 30, column: 7, scope: !1898)
!1900 = !DILocation(line: 30, column: 14, scope: !1901)
!1901 = distinct !DILexicalBlock(scope: !1898, file: !1885, line: 30, column: 2)
!1902 = !DILocation(line: 30, column: 16, scope: !1901)
!1903 = !DILocation(line: 30, column: 2, scope: !1898)
!1904 = !DILocation(line: 31, column: 46, scope: !1905)
!1905 = distinct !DILexicalBlock(scope: !1901, file: !1885, line: 30, column: 39)
!1906 = !DILocation(line: 31, column: 18, scope: !1905)
!1907 = !DILocation(line: 31, column: 16, scope: !1905)
!1908 = !DILocation(line: 32, column: 7, scope: !1909)
!1909 = distinct !DILexicalBlock(scope: !1905, file: !1885, line: 32, column: 7)
!1910 = !DILocation(line: 32, column: 20, scope: !1909)
!1911 = !DILocation(line: 32, column: 7, scope: !1905)
!1912 = !DILocation(line: 33, column: 4, scope: !1913)
!1913 = distinct !DILexicalBlock(scope: !1914, file: !1885, line: 33, column: 4)
!1914 = distinct !DILexicalBlock(scope: !1909, file: !1885, line: 32, column: 26)
!1915 = !DILocation(line: 35, column: 4, scope: !1914)
!1916 = !DILocation(line: 37, column: 3, scope: !1905)
!1917 = !DILocation(line: 38, column: 2, scope: !1905)
!1918 = !DILocation(line: 30, column: 35, scope: !1901)
!1919 = !DILocation(line: 30, column: 2, scope: !1901)
!1920 = distinct !{!1920, !1903, !1921}
!1921 = !DILocation(line: 38, column: 2, scope: !1898)
!1922 = !DILocation(line: 39, column: 28, scope: !1884)
!1923 = !DILocation(line: 39, column: 7, scope: !1884)
!1924 = !DILocation(line: 39, column: 5, scope: !1884)
!1925 = !DILocation(line: 40, column: 2, scope: !1884)
!1926 = !DILocation(line: 42, column: 2, scope: !1927)
!1927 = distinct !DILexicalBlock(scope: !1884, file: !1885, line: 42, column: 2)
!1928 = !DILocation(line: 44, column: 1, scope: !1884)
!1929 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !554, retainedNodes: !609)
!1930 = !DILocalVariable(name: "et", scope: !1929, file: !573, line: 177, type: !58)
!1931 = !DILocation(line: 177, column: 11, scope: !1929)
!1932 = !DILocation(line: 179, column: 2, scope: !1929)
!1933 = !DILocation(line: 180, column: 7, scope: !1929)
!1934 = !DILocation(line: 180, column: 5, scope: !1929)
!1935 = !DILocation(line: 181, column: 9, scope: !1929)
!1936 = !DILocation(line: 181, column: 2, scope: !1929)
!1937 = distinct !DISubprogram(name: "check_result", scope: !573, file: !573, line: 184, type: !206, scopeLine: 185, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !554, retainedNodes: !609)
!1938 = !DILocation(line: 186, column: 6, scope: !1939)
!1939 = distinct !DILexicalBlock(scope: !1937, file: !573, line: 186, column: 6)
!1940 = !DILocation(line: 186, column: 23, scope: !1939)
!1941 = !DILocation(line: 186, column: 6, scope: !1937)
!1942 = !DILocation(line: 187, column: 3, scope: !1943)
!1943 = distinct !DILexicalBlock(scope: !1944, file: !573, line: 187, column: 3)
!1944 = distinct !DILexicalBlock(scope: !1939, file: !573, line: 186, column: 28)
!1945 = !DILocation(line: 188, column: 3, scope: !1944)
!1946 = !DILocation(line: 190, column: 1, scope: !1937)
!1947 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !554, retainedNodes: !609)
!1948 = !DILocation(line: 82, column: 20, scope: !1947)
!1949 = !DILocation(line: 82, column: 18, scope: !1947)
!1950 = !DILocation(line: 90, column: 6, scope: !1951)
!1951 = distinct !DILexicalBlock(scope: !1947, file: !63, line: 90, column: 6)
!1952 = !DILocation(line: 90, column: 22, scope: !1951)
!1953 = !DILocation(line: 90, column: 6, scope: !1947)
!1954 = !DILocation(line: 91, column: 3, scope: !1955)
!1955 = distinct !DILexicalBlock(scope: !1951, file: !63, line: 90, column: 39)
!1956 = !DILocation(line: 93, column: 2, scope: !1947)
!1957 = !DILocation(line: 94, column: 1, scope: !1947)
!1958 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !554, retainedNodes: !609)
!1959 = !DILocation(line: 72, column: 18, scope: !1958)
!1960 = !DILocation(line: 74, column: 2, scope: !1958)
!1961 = !DILocation(line: 75, column: 20, scope: !1958)
!1962 = !DILocation(line: 75, column: 18, scope: !1958)
!1963 = !DILocation(line: 76, column: 1, scope: !1958)
!1964 = distinct !DISubprogram(name: "mempool_test", scope: !1965, file: !1965, line: 19, type: !206, scopeLine: 20, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !559, retainedNodes: !609)
!1965 = !DIFile(filename: "appl/Zephyr/app_kernel/src/mempool_b.c", directory: "/home/kenny/ara")
!1966 = !DILocalVariable(name: "et", scope: !1964, file: !1965, line: 21, type: !58)
!1967 = !DILocation(line: 21, column: 11, scope: !1964)
!1968 = !DILocalVariable(name: "i", scope: !1964, file: !1965, line: 22, type: !61)
!1969 = !DILocation(line: 22, column: 6, scope: !1964)
!1970 = !DILocalVariable(name: "return_value", scope: !1964, file: !1965, line: 23, type: !412)
!1971 = !DILocation(line: 23, column: 10, scope: !1964)
!1972 = !DILocalVariable(name: "block", scope: !1964, file: !1965, line: 24, type: !1973)
!1973 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_block", file: !86, line: 23, size: 64, elements: !1974)
!1974 = !{!1975}
!1975 = !DIDerivedType(tag: DW_TAG_member, scope: !1973, file: !86, line: 24, baseType: !1976, size: 64)
!1976 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1973, file: !86, line: 24, size: 64, elements: !1977)
!1977 = !{!1978, !1979}
!1978 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !1976, file: !86, line: 25, baseType: !60, size: 32)
!1979 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !1976, file: !86, line: 26, baseType: !1980, size: 64)
!1980 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_block_id", file: !86, line: 15, size: 64, elements: !1981)
!1981 = !{!1982, !1983}
!1982 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !1980, file: !86, line: 16, baseType: !60, size: 32)
!1983 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !1980, file: !86, line: 17, baseType: !1984, size: 32, offset: 32)
!1984 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1985, size: 32)
!1985 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !99, line: 267, size: 192, elements: !1986)
!1986 = !{!1987, !1993, !2012}
!1987 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !1985, file: !99, line: 268, baseType: !1988, size: 96)
!1988 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !103, line: 51, size: 96, elements: !1989)
!1989 = !{!1990, !1991, !1992}
!1990 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !1988, file: !103, line: 52, baseType: !106, size: 32)
!1991 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !1988, file: !103, line: 53, baseType: !60, size: 32, offset: 32)
!1992 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !1988, file: !103, line: 54, baseType: !79, size: 32, offset: 64)
!1993 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !1985, file: !99, line: 269, baseType: !1994, size: 64, offset: 96)
!1994 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !1995)
!1995 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !1996)
!1996 = !{!1997}
!1997 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !1995, file: !99, line: 209, baseType: !1998, size: 64)
!1998 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !1999)
!1999 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !2000)
!2000 = !{!2001, !2007}
!2001 = !DIDerivedType(tag: DW_TAG_member, scope: !1999, file: !116, line: 32, baseType: !2002, size: 32)
!2002 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1999, file: !116, line: 32, size: 32, elements: !2003)
!2003 = !{!2004, !2006}
!2004 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !2002, file: !116, line: 33, baseType: !2005, size: 32)
!2005 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1999, size: 32)
!2006 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !2002, file: !116, line: 34, baseType: !2005, size: 32)
!2007 = !DIDerivedType(tag: DW_TAG_member, scope: !1999, file: !116, line: 36, baseType: !2008, size: 32, offset: 32)
!2008 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !1999, file: !116, line: 36, size: 32, elements: !2009)
!2009 = !{!2010, !2011}
!2010 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !2008, file: !116, line: 37, baseType: !2005, size: 32)
!2011 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !2008, file: !116, line: 38, baseType: !2005, size: 32)
!2012 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !1985, file: !99, line: 270, baseType: !2013, size: 32, offset: 160)
!2013 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !2014)
!2014 = !{!2015}
!2015 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !2013, file: !99, line: 243, baseType: !134, size: 32)
!2016 = !DILocation(line: 24, column: 21, scope: !1964)
!2017 = !DILocation(line: 26, column: 2, scope: !1964)
!2018 = !DILocation(line: 27, column: 7, scope: !1964)
!2019 = !DILocation(line: 27, column: 5, scope: !1964)
!2020 = !DILocation(line: 28, column: 9, scope: !2021)
!2021 = distinct !DILexicalBlock(scope: !1964, file: !1965, line: 28, column: 2)
!2022 = !DILocation(line: 28, column: 7, scope: !2021)
!2023 = !DILocation(line: 28, column: 14, scope: !2024)
!2024 = distinct !DILexicalBlock(scope: !2021, file: !1965, line: 28, column: 2)
!2025 = !DILocation(line: 28, column: 16, scope: !2024)
!2026 = !DILocation(line: 28, column: 2, scope: !2021)
!2027 = !DILocation(line: 32, column: 7, scope: !2028)
!2028 = distinct !DILexicalBlock(scope: !2024, file: !1965, line: 28, column: 40)
!2029 = !DILocation(line: 29, column: 19, scope: !2028)
!2030 = !DILocation(line: 29, column: 16, scope: !2028)
!2031 = !DILocation(line: 33, column: 3, scope: !2028)
!2032 = !DILocation(line: 34, column: 2, scope: !2028)
!2033 = !DILocation(line: 28, column: 36, scope: !2024)
!2034 = !DILocation(line: 28, column: 2, scope: !2024)
!2035 = distinct !{!2035, !2026, !2036}
!2036 = !DILocation(line: 34, column: 2, scope: !2021)
!2037 = !DILocation(line: 35, column: 28, scope: !1964)
!2038 = !DILocation(line: 35, column: 7, scope: !1964)
!2039 = !DILocation(line: 35, column: 5, scope: !1964)
!2040 = !DILocation(line: 36, column: 2, scope: !1964)
!2041 = !DILocation(line: 38, column: 6, scope: !2042)
!2042 = distinct !DILexicalBlock(scope: !1964, file: !1965, line: 38, column: 6)
!2043 = !DILocation(line: 38, column: 19, scope: !2042)
!2044 = !DILocation(line: 38, column: 6, scope: !1964)
!2045 = !DILocation(line: 39, column: 3, scope: !2046)
!2046 = distinct !DILexicalBlock(scope: !2042, file: !1965, line: 38, column: 25)
!2047 = !DILocation(line: 39, column: 3, scope: !2048)
!2048 = distinct !DILexicalBlock(scope: !2046, file: !1965, line: 39, column: 3)
!2049 = !{i32 -2141825908, i32 -2141825892, i32 -2141825866, i32 -2141825838, i32 -2141825818}
!2050 = !DILocation(line: 40, column: 2, scope: !2046)
!2051 = !DILocation(line: 41, column: 2, scope: !2052)
!2052 = distinct !DILexicalBlock(scope: !1964, file: !1965, line: 41, column: 2)
!2053 = !DILocation(line: 44, column: 1, scope: !1964)
!2054 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2055 = !DILocalVariable(name: "et", scope: !2054, file: !573, line: 177, type: !58)
!2056 = !DILocation(line: 177, column: 11, scope: !2054)
!2057 = !DILocation(line: 179, column: 2, scope: !2054)
!2058 = !DILocation(line: 180, column: 7, scope: !2054)
!2059 = !DILocation(line: 180, column: 5, scope: !2054)
!2060 = !DILocation(line: 181, column: 9, scope: !2054)
!2061 = !DILocation(line: 181, column: 2, scope: !2054)
!2062 = distinct !DISubprogram(name: "TIME_STAMP_DELTA_GET", scope: !63, file: !63, line: 33, type: !823, scopeLine: 34, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2063 = !DILocalVariable(name: "ts", arg: 1, scope: !2062, file: !63, line: 33, type: !58)
!2064 = !DILocation(line: 33, column: 54, scope: !2062)
!2065 = !DILocalVariable(name: "t", scope: !2062, file: !63, line: 35, type: !58)
!2066 = !DILocation(line: 35, column: 11, scope: !2062)
!2067 = !DILocation(line: 38, column: 2, scope: !2062)
!2068 = !DILocation(line: 40, column: 6, scope: !2062)
!2069 = !DILocation(line: 40, column: 4, scope: !2062)
!2070 = !DILocalVariable(name: "res", scope: !2062, file: !63, line: 41, type: !58)
!2071 = !DILocation(line: 41, column: 11, scope: !2062)
!2072 = !DILocation(line: 41, column: 18, scope: !2062)
!2073 = !DILocation(line: 41, column: 23, scope: !2062)
!2074 = !DILocation(line: 41, column: 20, scope: !2062)
!2075 = !DILocation(line: 41, column: 17, scope: !2062)
!2076 = !DILocation(line: 41, column: 30, scope: !2062)
!2077 = !DILocation(line: 41, column: 34, scope: !2062)
!2078 = !DILocation(line: 41, column: 32, scope: !2062)
!2079 = !DILocation(line: 41, column: 53, scope: !2062)
!2080 = !DILocation(line: 41, column: 51, scope: !2062)
!2081 = !DILocation(line: 41, column: 58, scope: !2062)
!2082 = !DILocation(line: 41, column: 56, scope: !2062)
!2083 = !DILocation(line: 43, column: 6, scope: !2084)
!2084 = distinct !DILexicalBlock(scope: !2062, file: !63, line: 43, column: 6)
!2085 = !DILocation(line: 43, column: 9, scope: !2084)
!2086 = !DILocation(line: 43, column: 6, scope: !2062)
!2087 = !DILocation(line: 44, column: 10, scope: !2088)
!2088 = distinct !DILexicalBlock(scope: !2084, file: !63, line: 43, column: 14)
!2089 = !DILocation(line: 44, column: 7, scope: !2088)
!2090 = !DILocation(line: 45, column: 2, scope: !2088)
!2091 = !DILocation(line: 46, column: 9, scope: !2062)
!2092 = !DILocation(line: 46, column: 2, scope: !2062)
!2093 = distinct !DISubprogram(name: "check_result", scope: !573, file: !573, line: 184, type: !206, scopeLine: 185, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2094 = !DILocation(line: 186, column: 6, scope: !2095)
!2095 = distinct !DILexicalBlock(scope: !2093, file: !573, line: 186, column: 6)
!2096 = !DILocation(line: 186, column: 23, scope: !2095)
!2097 = !DILocation(line: 186, column: 6, scope: !2093)
!2098 = !DILocation(line: 187, column: 3, scope: !2099)
!2099 = distinct !DILexicalBlock(scope: !2100, file: !573, line: 187, column: 3)
!2100 = distinct !DILexicalBlock(scope: !2095, file: !573, line: 186, column: 28)
!2101 = !DILocation(line: 188, column: 3, scope: !2100)
!2102 = !DILocation(line: 190, column: 1, scope: !2093)
!2103 = distinct !DISubprogram(name: "k_cyc_to_ns_floor64", scope: !856, file: !856, line: 901, type: !857, scopeLine: 902, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2104 = !DILocalVariable(name: "t", arg: 1, scope: !2105, file: !856, line: 78, type: !69)
!2105 = distinct !DISubprogram(name: "z_tmcvt", scope: !856, file: !856, line: 78, type: !861, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2106 = !DILocation(line: 78, column: 63, scope: !2105, inlinedAt: !2107)
!2107 = distinct !DILocation(line: 904, column: 9, scope: !2103)
!2108 = !DILocalVariable(name: "from_hz", arg: 2, scope: !2105, file: !856, line: 78, type: !58)
!2109 = !DILocation(line: 78, column: 75, scope: !2105, inlinedAt: !2107)
!2110 = !DILocalVariable(name: "to_hz", arg: 3, scope: !2105, file: !856, line: 79, type: !58)
!2111 = !DILocation(line: 79, column: 18, scope: !2105, inlinedAt: !2107)
!2112 = !DILocalVariable(name: "const_hz", arg: 4, scope: !2105, file: !856, line: 79, type: !863)
!2113 = !DILocation(line: 79, column: 30, scope: !2105, inlinedAt: !2107)
!2114 = !DILocalVariable(name: "result32", arg: 5, scope: !2105, file: !856, line: 80, type: !863)
!2115 = !DILocation(line: 80, column: 14, scope: !2105, inlinedAt: !2107)
!2116 = !DILocalVariable(name: "round_up", arg: 6, scope: !2105, file: !856, line: 80, type: !863)
!2117 = !DILocation(line: 80, column: 29, scope: !2105, inlinedAt: !2107)
!2118 = !DILocalVariable(name: "round_off", arg: 7, scope: !2105, file: !856, line: 81, type: !863)
!2119 = !DILocation(line: 81, column: 14, scope: !2105, inlinedAt: !2107)
!2120 = !DILocalVariable(name: "mul_ratio", scope: !2105, file: !856, line: 84, type: !863)
!2121 = !DILocation(line: 84, column: 7, scope: !2105, inlinedAt: !2107)
!2122 = !DILocalVariable(name: "div_ratio", scope: !2105, file: !856, line: 86, type: !863)
!2123 = !DILocation(line: 86, column: 7, scope: !2105, inlinedAt: !2107)
!2124 = !DILocalVariable(name: "off", scope: !2105, file: !856, line: 93, type: !69)
!2125 = !DILocation(line: 93, column: 11, scope: !2105, inlinedAt: !2107)
!2126 = !DILocalVariable(name: "rdivisor", scope: !2127, file: !856, line: 96, type: !58)
!2127 = distinct !DILexicalBlock(scope: !2128, file: !856, line: 95, column: 18)
!2128 = distinct !DILexicalBlock(scope: !2105, file: !856, line: 95, column: 6)
!2129 = !DILocation(line: 96, column: 12, scope: !2127, inlinedAt: !2107)
!2130 = !DILocalVariable(name: "t", arg: 1, scope: !2103, file: !856, line: 901, type: !69)
!2131 = !DILocation(line: 901, column: 68, scope: !2103)
!2132 = !DILocation(line: 904, column: 17, scope: !2103)
!2133 = !DILocation(line: 904, column: 20, scope: !2103)
!2134 = !DILocation(line: 84, column: 19, scope: !2105, inlinedAt: !2107)
!2135 = !DILocation(line: 84, column: 28, scope: !2105, inlinedAt: !2107)
!2136 = !DILocation(line: 85, column: 4, scope: !2105, inlinedAt: !2107)
!2137 = !DILocation(line: 85, column: 12, scope: !2105, inlinedAt: !2107)
!2138 = !DILocation(line: 85, column: 10, scope: !2105, inlinedAt: !2107)
!2139 = !DILocation(line: 85, column: 21, scope: !2105, inlinedAt: !2107)
!2140 = !DILocation(line: 85, column: 26, scope: !2105, inlinedAt: !2107)
!2141 = !DILocation(line: 85, column: 34, scope: !2105, inlinedAt: !2107)
!2142 = !DILocation(line: 85, column: 32, scope: !2105, inlinedAt: !2107)
!2143 = !DILocation(line: 85, column: 43, scope: !2105, inlinedAt: !2107)
!2144 = !DILocation(line: 0, scope: !2105, inlinedAt: !2107)
!2145 = !DILocation(line: 86, column: 19, scope: !2105, inlinedAt: !2107)
!2146 = !DILocation(line: 86, column: 28, scope: !2105, inlinedAt: !2107)
!2147 = !DILocation(line: 87, column: 4, scope: !2105, inlinedAt: !2107)
!2148 = !DILocation(line: 87, column: 14, scope: !2105, inlinedAt: !2107)
!2149 = !DILocation(line: 87, column: 12, scope: !2105, inlinedAt: !2107)
!2150 = !DILocation(line: 87, column: 21, scope: !2105, inlinedAt: !2107)
!2151 = !DILocation(line: 87, column: 26, scope: !2105, inlinedAt: !2107)
!2152 = !DILocation(line: 87, column: 36, scope: !2105, inlinedAt: !2107)
!2153 = !DILocation(line: 87, column: 34, scope: !2105, inlinedAt: !2107)
!2154 = !DILocation(line: 87, column: 43, scope: !2105, inlinedAt: !2107)
!2155 = !DILocation(line: 89, column: 6, scope: !2156, inlinedAt: !2107)
!2156 = distinct !DILexicalBlock(scope: !2105, file: !856, line: 89, column: 6)
!2157 = !DILocation(line: 89, column: 17, scope: !2156, inlinedAt: !2107)
!2158 = !DILocation(line: 89, column: 14, scope: !2156, inlinedAt: !2107)
!2159 = !DILocation(line: 89, column: 6, scope: !2105, inlinedAt: !2107)
!2160 = !DILocation(line: 90, column: 10, scope: !2161, inlinedAt: !2107)
!2161 = distinct !DILexicalBlock(scope: !2156, file: !856, line: 89, column: 24)
!2162 = !DILocation(line: 90, column: 32, scope: !2161, inlinedAt: !2107)
!2163 = !DILocation(line: 90, column: 22, scope: !2161, inlinedAt: !2107)
!2164 = !DILocation(line: 90, column: 21, scope: !2161, inlinedAt: !2107)
!2165 = !DILocation(line: 90, column: 37, scope: !2161, inlinedAt: !2107)
!2166 = !DILocation(line: 90, column: 3, scope: !2161, inlinedAt: !2107)
!2167 = !DILocation(line: 95, column: 7, scope: !2128, inlinedAt: !2107)
!2168 = !DILocation(line: 95, column: 6, scope: !2105, inlinedAt: !2107)
!2169 = !DILocation(line: 96, column: 23, scope: !2127, inlinedAt: !2107)
!2170 = !DILocation(line: 96, column: 36, scope: !2127, inlinedAt: !2107)
!2171 = !DILocation(line: 96, column: 46, scope: !2127, inlinedAt: !2107)
!2172 = !DILocation(line: 96, column: 44, scope: !2127, inlinedAt: !2107)
!2173 = !DILocation(line: 96, column: 55, scope: !2127, inlinedAt: !2107)
!2174 = !DILocation(line: 98, column: 7, scope: !2175, inlinedAt: !2107)
!2175 = distinct !DILexicalBlock(scope: !2127, file: !856, line: 98, column: 7)
!2176 = !DILocation(line: 98, column: 7, scope: !2127, inlinedAt: !2107)
!2177 = !DILocation(line: 99, column: 10, scope: !2178, inlinedAt: !2107)
!2178 = distinct !DILexicalBlock(scope: !2175, file: !856, line: 98, column: 17)
!2179 = !DILocation(line: 99, column: 19, scope: !2178, inlinedAt: !2107)
!2180 = !DILocation(line: 99, column: 8, scope: !2178, inlinedAt: !2107)
!2181 = !DILocation(line: 100, column: 3, scope: !2178, inlinedAt: !2107)
!2182 = !DILocation(line: 100, column: 14, scope: !2183, inlinedAt: !2107)
!2183 = distinct !DILexicalBlock(scope: !2175, file: !856, line: 100, column: 14)
!2184 = !DILocation(line: 100, column: 14, scope: !2175, inlinedAt: !2107)
!2185 = !DILocation(line: 101, column: 10, scope: !2186, inlinedAt: !2107)
!2186 = distinct !DILexicalBlock(scope: !2183, file: !856, line: 100, column: 25)
!2187 = !DILocation(line: 101, column: 19, scope: !2186, inlinedAt: !2107)
!2188 = !DILocation(line: 101, column: 8, scope: !2186, inlinedAt: !2107)
!2189 = !DILocation(line: 102, column: 3, scope: !2186, inlinedAt: !2107)
!2190 = !DILocation(line: 103, column: 2, scope: !2127, inlinedAt: !2107)
!2191 = !DILocation(line: 110, column: 6, scope: !2192, inlinedAt: !2107)
!2192 = distinct !DILexicalBlock(scope: !2105, file: !856, line: 110, column: 6)
!2193 = !DILocation(line: 110, column: 6, scope: !2105, inlinedAt: !2107)
!2194 = !DILocation(line: 111, column: 8, scope: !2195, inlinedAt: !2107)
!2195 = distinct !DILexicalBlock(scope: !2192, file: !856, line: 110, column: 17)
!2196 = !DILocation(line: 111, column: 5, scope: !2195, inlinedAt: !2107)
!2197 = !DILocation(line: 112, column: 7, scope: !2198, inlinedAt: !2107)
!2198 = distinct !DILexicalBlock(scope: !2195, file: !856, line: 112, column: 7)
!2199 = !DILocation(line: 112, column: 16, scope: !2198, inlinedAt: !2107)
!2200 = !DILocation(line: 112, column: 20, scope: !2198, inlinedAt: !2107)
!2201 = !DILocation(line: 112, column: 22, scope: !2198, inlinedAt: !2107)
!2202 = !DILocation(line: 112, column: 7, scope: !2195, inlinedAt: !2107)
!2203 = !DILocation(line: 113, column: 22, scope: !2204, inlinedAt: !2107)
!2204 = distinct !DILexicalBlock(scope: !2198, file: !856, line: 112, column: 36)
!2205 = !DILocation(line: 113, column: 12, scope: !2204, inlinedAt: !2107)
!2206 = !DILocation(line: 113, column: 28, scope: !2204, inlinedAt: !2107)
!2207 = !DILocation(line: 113, column: 38, scope: !2204, inlinedAt: !2107)
!2208 = !DILocation(line: 113, column: 36, scope: !2204, inlinedAt: !2107)
!2209 = !DILocation(line: 113, column: 25, scope: !2204, inlinedAt: !2107)
!2210 = !DILocation(line: 113, column: 11, scope: !2204, inlinedAt: !2107)
!2211 = !DILocation(line: 113, column: 4, scope: !2204, inlinedAt: !2107)
!2212 = !DILocation(line: 115, column: 11, scope: !2213, inlinedAt: !2107)
!2213 = distinct !DILexicalBlock(scope: !2198, file: !856, line: 114, column: 10)
!2214 = !DILocation(line: 115, column: 16, scope: !2213, inlinedAt: !2107)
!2215 = !DILocation(line: 115, column: 26, scope: !2213, inlinedAt: !2107)
!2216 = !DILocation(line: 115, column: 24, scope: !2213, inlinedAt: !2107)
!2217 = !DILocation(line: 115, column: 15, scope: !2213, inlinedAt: !2107)
!2218 = !DILocation(line: 115, column: 13, scope: !2213, inlinedAt: !2107)
!2219 = !DILocation(line: 115, column: 4, scope: !2213, inlinedAt: !2107)
!2220 = !DILocation(line: 117, column: 13, scope: !2221, inlinedAt: !2107)
!2221 = distinct !DILexicalBlock(scope: !2192, file: !856, line: 117, column: 13)
!2222 = !DILocation(line: 117, column: 13, scope: !2192, inlinedAt: !2107)
!2223 = !DILocation(line: 118, column: 7, scope: !2224, inlinedAt: !2107)
!2224 = distinct !DILexicalBlock(scope: !2225, file: !856, line: 118, column: 7)
!2225 = distinct !DILexicalBlock(scope: !2221, file: !856, line: 117, column: 24)
!2226 = !DILocation(line: 118, column: 7, scope: !2225, inlinedAt: !2107)
!2227 = !DILocation(line: 119, column: 22, scope: !2228, inlinedAt: !2107)
!2228 = distinct !DILexicalBlock(scope: !2224, file: !856, line: 118, column: 17)
!2229 = !DILocation(line: 119, column: 12, scope: !2228, inlinedAt: !2107)
!2230 = !DILocation(line: 119, column: 28, scope: !2228, inlinedAt: !2107)
!2231 = !DILocation(line: 119, column: 36, scope: !2228, inlinedAt: !2107)
!2232 = !DILocation(line: 119, column: 34, scope: !2228, inlinedAt: !2107)
!2233 = !DILocation(line: 119, column: 25, scope: !2228, inlinedAt: !2107)
!2234 = !DILocation(line: 119, column: 11, scope: !2228, inlinedAt: !2107)
!2235 = !DILocation(line: 119, column: 4, scope: !2228, inlinedAt: !2107)
!2236 = !DILocation(line: 121, column: 11, scope: !2237, inlinedAt: !2107)
!2237 = distinct !DILexicalBlock(scope: !2224, file: !856, line: 120, column: 10)
!2238 = !DILocation(line: 121, column: 16, scope: !2237, inlinedAt: !2107)
!2239 = !DILocation(line: 121, column: 24, scope: !2237, inlinedAt: !2107)
!2240 = !DILocation(line: 121, column: 22, scope: !2237, inlinedAt: !2107)
!2241 = !DILocation(line: 121, column: 15, scope: !2237, inlinedAt: !2107)
!2242 = !DILocation(line: 121, column: 13, scope: !2237, inlinedAt: !2107)
!2243 = !DILocation(line: 121, column: 4, scope: !2237, inlinedAt: !2107)
!2244 = !DILocation(line: 124, column: 7, scope: !2245, inlinedAt: !2107)
!2245 = distinct !DILexicalBlock(scope: !2246, file: !856, line: 124, column: 7)
!2246 = distinct !DILexicalBlock(scope: !2221, file: !856, line: 123, column: 9)
!2247 = !DILocation(line: 124, column: 7, scope: !2246, inlinedAt: !2107)
!2248 = !DILocation(line: 125, column: 23, scope: !2249, inlinedAt: !2107)
!2249 = distinct !DILexicalBlock(scope: !2245, file: !856, line: 124, column: 17)
!2250 = !DILocation(line: 125, column: 27, scope: !2249, inlinedAt: !2107)
!2251 = !DILocation(line: 125, column: 25, scope: !2249, inlinedAt: !2107)
!2252 = !DILocation(line: 125, column: 35, scope: !2249, inlinedAt: !2107)
!2253 = !DILocation(line: 125, column: 33, scope: !2249, inlinedAt: !2107)
!2254 = !DILocation(line: 125, column: 42, scope: !2249, inlinedAt: !2107)
!2255 = !DILocation(line: 125, column: 40, scope: !2249, inlinedAt: !2107)
!2256 = !DILocation(line: 125, column: 11, scope: !2249, inlinedAt: !2107)
!2257 = !DILocation(line: 125, column: 4, scope: !2249, inlinedAt: !2107)
!2258 = !DILocation(line: 127, column: 12, scope: !2259, inlinedAt: !2107)
!2259 = distinct !DILexicalBlock(scope: !2245, file: !856, line: 126, column: 10)
!2260 = !DILocation(line: 127, column: 16, scope: !2259, inlinedAt: !2107)
!2261 = !DILocation(line: 127, column: 14, scope: !2259, inlinedAt: !2107)
!2262 = !DILocation(line: 127, column: 24, scope: !2259, inlinedAt: !2107)
!2263 = !DILocation(line: 127, column: 22, scope: !2259, inlinedAt: !2107)
!2264 = !DILocation(line: 127, column: 31, scope: !2259, inlinedAt: !2107)
!2265 = !DILocation(line: 127, column: 29, scope: !2259, inlinedAt: !2107)
!2266 = !DILocation(line: 127, column: 4, scope: !2259, inlinedAt: !2107)
!2267 = !DILocation(line: 130, column: 1, scope: !2105, inlinedAt: !2107)
!2268 = !DILocation(line: 904, column: 2, scope: !2103)
!2269 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2270 = !DILocation(line: 82, column: 20, scope: !2269)
!2271 = !DILocation(line: 82, column: 18, scope: !2269)
!2272 = !DILocation(line: 90, column: 6, scope: !2273)
!2273 = distinct !DILexicalBlock(scope: !2269, file: !63, line: 90, column: 6)
!2274 = !DILocation(line: 90, column: 22, scope: !2273)
!2275 = !DILocation(line: 90, column: 6, scope: !2269)
!2276 = !DILocation(line: 91, column: 3, scope: !2277)
!2277 = distinct !DILexicalBlock(scope: !2273, file: !63, line: 90, column: 39)
!2278 = !DILocation(line: 93, column: 2, scope: !2269)
!2279 = !DILocation(line: 94, column: 1, scope: !2269)
!2280 = distinct !DISubprogram(name: "k_uptime_delta", scope: !6, file: !6, line: 2133, type: !1086, scopeLine: 2134, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2281 = !DILocalVariable(name: "reftime", arg: 1, scope: !2280, file: !6, line: 2133, type: !1088)
!2282 = !DILocation(line: 2133, column: 47, scope: !2280)
!2283 = !DILocalVariable(name: "uptime", scope: !2280, file: !6, line: 2135, type: !55)
!2284 = !DILocation(line: 2135, column: 10, scope: !2280)
!2285 = !DILocalVariable(name: "delta", scope: !2280, file: !6, line: 2135, type: !55)
!2286 = !DILocation(line: 2135, column: 18, scope: !2280)
!2287 = !DILocation(line: 2137, column: 11, scope: !2280)
!2288 = !DILocation(line: 2137, column: 9, scope: !2280)
!2289 = !DILocation(line: 2138, column: 10, scope: !2280)
!2290 = !DILocation(line: 2138, column: 20, scope: !2280)
!2291 = !DILocation(line: 2138, column: 19, scope: !2280)
!2292 = !DILocation(line: 2138, column: 17, scope: !2280)
!2293 = !DILocation(line: 2138, column: 8, scope: !2280)
!2294 = !DILocation(line: 2139, column: 13, scope: !2280)
!2295 = !DILocation(line: 2139, column: 3, scope: !2280)
!2296 = !DILocation(line: 2139, column: 11, scope: !2280)
!2297 = !DILocation(line: 2141, column: 9, scope: !2280)
!2298 = !DILocation(line: 2141, column: 2, scope: !2280)
!2299 = distinct !DISubprogram(name: "k_uptime_get", scope: !6, file: !6, line: 2059, type: !1108, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2300 = !DILocation(line: 2061, column: 31, scope: !2299)
!2301 = !DILocation(line: 2061, column: 9, scope: !2299)
!2302 = !DILocation(line: 2061, column: 2, scope: !2299)
!2303 = distinct !DISubprogram(name: "k_cycle_get_32", scope: !6, file: !6, line: 2172, type: !755, scopeLine: 2173, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2304 = !DILocation(line: 2174, column: 9, scope: !2303)
!2305 = !DILocation(line: 2174, column: 2, scope: !2303)
!2306 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !559, retainedNodes: !609)
!2307 = !DILocation(line: 72, column: 18, scope: !2306)
!2308 = !DILocation(line: 74, column: 2, scope: !2306)
!2309 = !DILocation(line: 75, column: 20, scope: !2306)
!2310 = !DILocation(line: 75, column: 18, scope: !2306)
!2311 = !DILocation(line: 76, column: 1, scope: !2306)
!2312 = distinct !DISubprogram(name: "mutex_test", scope: !2313, file: !2313, line: 19, type: !206, scopeLine: 20, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2313 = !DIFile(filename: "appl/Zephyr/app_kernel/src/mutex_b.c", directory: "/home/kenny/ara")
!2314 = !DILocalVariable(name: "et", scope: !2312, file: !2313, line: 21, type: !58)
!2315 = !DILocation(line: 21, column: 11, scope: !2312)
!2316 = !DILocalVariable(name: "i", scope: !2312, file: !2313, line: 22, type: !61)
!2317 = !DILocation(line: 22, column: 6, scope: !2312)
!2318 = !DILocation(line: 24, column: 2, scope: !2312)
!2319 = !DILocation(line: 25, column: 7, scope: !2312)
!2320 = !DILocation(line: 25, column: 5, scope: !2312)
!2321 = !DILocation(line: 26, column: 9, scope: !2322)
!2322 = distinct !DILexicalBlock(scope: !2312, file: !2313, line: 26, column: 2)
!2323 = !DILocation(line: 26, column: 7, scope: !2322)
!2324 = !DILocation(line: 26, column: 14, scope: !2325)
!2325 = distinct !DILexicalBlock(scope: !2322, file: !2313, line: 26, column: 2)
!2326 = !DILocation(line: 26, column: 16, scope: !2325)
!2327 = !DILocation(line: 26, column: 2, scope: !2322)
!2328 = !DILocation(line: 27, column: 29, scope: !2329)
!2329 = distinct !DILexicalBlock(scope: !2325, file: !2313, line: 26, column: 41)
!2330 = !DILocation(line: 27, column: 3, scope: !2329)
!2331 = !DILocation(line: 28, column: 3, scope: !2329)
!2332 = !DILocation(line: 29, column: 2, scope: !2329)
!2333 = !DILocation(line: 26, column: 37, scope: !2325)
!2334 = !DILocation(line: 26, column: 2, scope: !2325)
!2335 = distinct !{!2335, !2327, !2336}
!2336 = !DILocation(line: 29, column: 2, scope: !2322)
!2337 = !DILocation(line: 30, column: 28, scope: !2312)
!2338 = !DILocation(line: 30, column: 7, scope: !2312)
!2339 = !DILocation(line: 30, column: 5, scope: !2312)
!2340 = !DILocation(line: 31, column: 2, scope: !2312)
!2341 = !DILocation(line: 33, column: 2, scope: !2342)
!2342 = distinct !DILexicalBlock(scope: !2312, file: !2313, line: 33, column: 2)
!2343 = !DILocation(line: 35, column: 1, scope: !2312)
!2344 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2345 = !DILocalVariable(name: "et", scope: !2344, file: !573, line: 177, type: !58)
!2346 = !DILocation(line: 177, column: 11, scope: !2344)
!2347 = !DILocation(line: 179, column: 2, scope: !2344)
!2348 = !DILocation(line: 180, column: 7, scope: !2344)
!2349 = !DILocation(line: 180, column: 5, scope: !2344)
!2350 = !DILocation(line: 181, column: 9, scope: !2344)
!2351 = !DILocation(line: 181, column: 2, scope: !2344)
!2352 = distinct !DISubprogram(name: "k_mutex_lock", scope: !765, file: !765, line: 705, type: !2353, scopeLine: 706, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2353 = !DISubroutineType(types: !2354)
!2354 = !{!61, !2355, !2470}
!2355 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2356, size: 32)
!2356 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mutex", file: !6, line: 3589, size: 160, elements: !2357)
!2357 = !{!2358, !2377, !2468, !2469}
!2358 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !2356, file: !6, line: 3591, baseType: !2359, size: 64)
!2359 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !2360)
!2360 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !2361)
!2361 = !{!2362}
!2362 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !2360, file: !99, line: 209, baseType: !2363, size: 64)
!2363 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !2364)
!2364 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !2365)
!2365 = !{!2366, !2372}
!2366 = !DIDerivedType(tag: DW_TAG_member, scope: !2364, file: !116, line: 32, baseType: !2367, size: 32)
!2367 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2364, file: !116, line: 32, size: 32, elements: !2368)
!2368 = !{!2369, !2371}
!2369 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !2367, file: !116, line: 33, baseType: !2370, size: 32)
!2370 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2364, size: 32)
!2371 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !2367, file: !116, line: 34, baseType: !2370, size: 32)
!2372 = !DIDerivedType(tag: DW_TAG_member, scope: !2364, file: !116, line: 36, baseType: !2373, size: 32, offset: 32)
!2373 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2364, file: !116, line: 36, size: 32, elements: !2374)
!2374 = !{!2375, !2376}
!2375 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !2373, file: !116, line: 37, baseType: !2370, size: 32)
!2376 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !2373, file: !116, line: 38, baseType: !2370, size: 32)
!2377 = !DIDerivedType(tag: DW_TAG_member, name: "owner", scope: !2356, file: !6, line: 3593, baseType: !2378, size: 32, offset: 64)
!2378 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2379, size: 32)
!2379 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1280, elements: !2380)
!2380 = !{!2381, !2422, !2434, !2435, !2436, !2437, !2438, !2444, !2463}
!2381 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !2379, file: !6, line: 572, baseType: !2382, size: 448)
!2382 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !2383)
!2383 = !{!2384, !2395, !2397, !2398, !2399, !2408, !2409, !2410, !2421}
!2384 = !DIDerivedType(tag: DW_TAG_member, scope: !2382, file: !6, line: 444, baseType: !2385, size: 64)
!2385 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2382, file: !6, line: 444, size: 64, elements: !2386)
!2386 = !{!2387, !2389}
!2387 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !2385, file: !6, line: 445, baseType: !2388, size: 64)
!2388 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !116, line: 43, baseType: !2364)
!2389 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !2385, file: !6, line: 446, baseType: !2390, size: 64)
!2390 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !151, line: 48, size: 64, elements: !2391)
!2391 = !{!2392}
!2392 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !2390, file: !151, line: 49, baseType: !2393, size: 64)
!2393 = !DICompositeType(tag: DW_TAG_array_type, baseType: !2394, size: 64, elements: !156)
!2394 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2390, size: 32)
!2395 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !2382, file: !6, line: 452, baseType: !2396, size: 32, offset: 64)
!2396 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2359, size: 32)
!2397 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !2382, file: !6, line: 455, baseType: !161, size: 8, offset: 96)
!2398 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !2382, file: !6, line: 458, baseType: !161, size: 8, offset: 104)
!2399 = !DIDerivedType(tag: DW_TAG_member, scope: !2382, file: !6, line: 474, baseType: !2400, size: 16, offset: 112)
!2400 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2382, file: !6, line: 474, size: 16, elements: !2401)
!2401 = !{!2402, !2407}
!2402 = !DIDerivedType(tag: DW_TAG_member, scope: !2400, file: !6, line: 475, baseType: !2403, size: 16)
!2403 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !2400, file: !6, line: 475, size: 16, elements: !2404)
!2404 = !{!2405, !2406}
!2405 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !2403, file: !6, line: 480, baseType: !170, size: 8)
!2406 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !2403, file: !6, line: 481, baseType: !161, size: 8, offset: 8)
!2407 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !2400, file: !6, line: 484, baseType: !174, size: 16)
!2408 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !2382, file: !6, line: 491, baseType: !58, size: 32, offset: 128)
!2409 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !2382, file: !6, line: 511, baseType: !60, size: 32, offset: 160)
!2410 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !2382, file: !6, line: 515, baseType: !2411, size: 192, offset: 192)
!2411 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !99, line: 221, size: 192, elements: !2412)
!2412 = !{!2413, !2414, !2420}
!2413 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !2411, file: !99, line: 222, baseType: !2388, size: 64)
!2414 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !2411, file: !99, line: 223, baseType: !2415, size: 32, offset: 64)
!2415 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !99, line: 219, baseType: !2416)
!2416 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2417, size: 32)
!2417 = !DISubroutineType(types: !2418)
!2418 = !{null, !2419}
!2419 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2411, size: 32)
!2420 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !2411, file: !99, line: 226, baseType: !55, size: 64, offset: 128)
!2421 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !2382, file: !6, line: 518, baseType: !2359, size: 64, offset: 384)
!2422 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !2379, file: !6, line: 575, baseType: !2423, size: 288, offset: 448)
!2423 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !192, line: 25, size: 288, elements: !2424)
!2424 = !{!2425, !2426, !2427, !2428, !2429, !2430, !2431, !2432, !2433}
!2425 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !2423, file: !192, line: 26, baseType: !58, size: 32)
!2426 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !2423, file: !192, line: 27, baseType: !58, size: 32, offset: 32)
!2427 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !2423, file: !192, line: 28, baseType: !58, size: 32, offset: 64)
!2428 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !2423, file: !192, line: 29, baseType: !58, size: 32, offset: 96)
!2429 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !2423, file: !192, line: 30, baseType: !58, size: 32, offset: 128)
!2430 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !2423, file: !192, line: 31, baseType: !58, size: 32, offset: 160)
!2431 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !2423, file: !192, line: 32, baseType: !58, size: 32, offset: 192)
!2432 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !2423, file: !192, line: 33, baseType: !58, size: 32, offset: 224)
!2433 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !2423, file: !192, line: 34, baseType: !58, size: 32, offset: 256)
!2434 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !2379, file: !6, line: 578, baseType: !60, size: 32, offset: 736)
!2435 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !2379, file: !6, line: 583, baseType: !205, size: 32, offset: 768)
!2436 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !2379, file: !6, line: 595, baseType: !209, size: 256, offset: 800)
!2437 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !2379, file: !6, line: 610, baseType: !61, size: 32, offset: 1056)
!2438 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !2379, file: !6, line: 616, baseType: !2439, size: 96, offset: 1088)
!2439 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !2440)
!2440 = !{!2441, !2442, !2443}
!2441 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !2439, file: !6, line: 529, baseType: !134, size: 32)
!2442 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !2439, file: !6, line: 538, baseType: !79, size: 32, offset: 32)
!2443 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !2439, file: !6, line: 544, baseType: !79, size: 32, offset: 64)
!2444 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !2379, file: !6, line: 641, baseType: !2445, size: 32, offset: 1184)
!2445 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2446, size: 32)
!2446 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !86, line: 30, size: 32, elements: !2447)
!2447 = !{!2448}
!2448 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !2446, file: !86, line: 31, baseType: !2449, size: 32)
!2449 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2450, size: 32)
!2450 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !99, line: 267, size: 192, elements: !2451)
!2451 = !{!2452, !2458, !2459}
!2452 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !2450, file: !99, line: 268, baseType: !2453, size: 96)
!2453 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !103, line: 51, size: 96, elements: !2454)
!2454 = !{!2455, !2456, !2457}
!2455 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !2453, file: !103, line: 52, baseType: !106, size: 32)
!2456 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !2453, file: !103, line: 53, baseType: !60, size: 32, offset: 32)
!2457 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !2453, file: !103, line: 54, baseType: !79, size: 32, offset: 64)
!2458 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !2450, file: !99, line: 269, baseType: !2359, size: 64, offset: 96)
!2459 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !2450, file: !99, line: 270, baseType: !2460, size: 32, offset: 160)
!2460 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !2461)
!2461 = !{!2462}
!2462 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !2460, file: !99, line: 243, baseType: !134, size: 32)
!2463 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !2379, file: !6, line: 644, baseType: !2464, size: 64, offset: 1216)
!2464 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !192, line: 60, size: 64, elements: !2465)
!2465 = !{!2466, !2467}
!2466 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !2464, file: !192, line: 63, baseType: !58, size: 32)
!2467 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !2464, file: !192, line: 66, baseType: !58, size: 32, offset: 32)
!2468 = !DIDerivedType(tag: DW_TAG_member, name: "lock_count", scope: !2356, file: !6, line: 3596, baseType: !58, size: 32, offset: 96)
!2469 = !DIDerivedType(tag: DW_TAG_member, name: "owner_orig_prio", scope: !2356, file: !6, line: 3599, baseType: !61, size: 32, offset: 128)
!2470 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !2471)
!2471 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !2472)
!2472 = !{!2473}
!2473 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !2471, file: !54, line: 68, baseType: !53, size: 64)
!2474 = !DILocalVariable(name: "mutex", arg: 1, scope: !2352, file: !765, line: 705, type: !2355)
!2475 = !DILocation(line: 705, column: 67, scope: !2352)
!2476 = !DILocalVariable(name: "timeout", arg: 2, scope: !2352, file: !765, line: 705, type: !2470)
!2477 = !DILocation(line: 705, column: 86, scope: !2352)
!2478 = !DILocation(line: 714, column: 2, scope: !2352)
!2479 = !DILocation(line: 714, column: 2, scope: !2480)
!2480 = distinct !DILexicalBlock(scope: !2352, file: !765, line: 714, column: 2)
!2481 = !{i32 -2141850193}
!2482 = !DILocation(line: 715, column: 29, scope: !2352)
!2483 = !DILocation(line: 715, column: 9, scope: !2352)
!2484 = !DILocation(line: 715, column: 2, scope: !2352)
!2485 = distinct !DISubprogram(name: "k_mutex_unlock", scope: !765, file: !765, line: 720, type: !2486, scopeLine: 721, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2486 = !DISubroutineType(types: !2487)
!2487 = !{!61, !2355}
!2488 = !DILocalVariable(name: "mutex", arg: 1, scope: !2485, file: !765, line: 720, type: !2355)
!2489 = !DILocation(line: 720, column: 69, scope: !2485)
!2490 = !DILocation(line: 727, column: 2, scope: !2485)
!2491 = !DILocation(line: 727, column: 2, scope: !2492)
!2492 = distinct !DILexicalBlock(scope: !2485, file: !765, line: 727, column: 2)
!2493 = !{i32 -2141850125}
!2494 = !DILocation(line: 728, column: 31, scope: !2485)
!2495 = !DILocation(line: 728, column: 9, scope: !2485)
!2496 = !DILocation(line: 728, column: 2, scope: !2485)
!2497 = distinct !DISubprogram(name: "TIME_STAMP_DELTA_GET", scope: !63, file: !63, line: 33, type: !823, scopeLine: 34, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2498 = !DILocalVariable(name: "ts", arg: 1, scope: !2497, file: !63, line: 33, type: !58)
!2499 = !DILocation(line: 33, column: 54, scope: !2497)
!2500 = !DILocalVariable(name: "t", scope: !2497, file: !63, line: 35, type: !58)
!2501 = !DILocation(line: 35, column: 11, scope: !2497)
!2502 = !DILocation(line: 38, column: 2, scope: !2497)
!2503 = !DILocation(line: 40, column: 6, scope: !2497)
!2504 = !DILocation(line: 40, column: 4, scope: !2497)
!2505 = !DILocalVariable(name: "res", scope: !2497, file: !63, line: 41, type: !58)
!2506 = !DILocation(line: 41, column: 11, scope: !2497)
!2507 = !DILocation(line: 41, column: 18, scope: !2497)
!2508 = !DILocation(line: 41, column: 23, scope: !2497)
!2509 = !DILocation(line: 41, column: 20, scope: !2497)
!2510 = !DILocation(line: 41, column: 17, scope: !2497)
!2511 = !DILocation(line: 41, column: 30, scope: !2497)
!2512 = !DILocation(line: 41, column: 34, scope: !2497)
!2513 = !DILocation(line: 41, column: 32, scope: !2497)
!2514 = !DILocation(line: 41, column: 53, scope: !2497)
!2515 = !DILocation(line: 41, column: 51, scope: !2497)
!2516 = !DILocation(line: 41, column: 58, scope: !2497)
!2517 = !DILocation(line: 41, column: 56, scope: !2497)
!2518 = !DILocation(line: 43, column: 6, scope: !2519)
!2519 = distinct !DILexicalBlock(scope: !2497, file: !63, line: 43, column: 6)
!2520 = !DILocation(line: 43, column: 9, scope: !2519)
!2521 = !DILocation(line: 43, column: 6, scope: !2497)
!2522 = !DILocation(line: 44, column: 10, scope: !2523)
!2523 = distinct !DILexicalBlock(scope: !2519, file: !63, line: 43, column: 14)
!2524 = !DILocation(line: 44, column: 7, scope: !2523)
!2525 = !DILocation(line: 45, column: 2, scope: !2523)
!2526 = !DILocation(line: 46, column: 9, scope: !2497)
!2527 = !DILocation(line: 46, column: 2, scope: !2497)
!2528 = distinct !DISubprogram(name: "check_result", scope: !573, file: !573, line: 184, type: !206, scopeLine: 185, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2529 = !DILocation(line: 186, column: 6, scope: !2530)
!2530 = distinct !DILexicalBlock(scope: !2528, file: !573, line: 186, column: 6)
!2531 = !DILocation(line: 186, column: 23, scope: !2530)
!2532 = !DILocation(line: 186, column: 6, scope: !2528)
!2533 = !DILocation(line: 187, column: 3, scope: !2534)
!2534 = distinct !DILexicalBlock(scope: !2535, file: !573, line: 187, column: 3)
!2535 = distinct !DILexicalBlock(scope: !2530, file: !573, line: 186, column: 28)
!2536 = !DILocation(line: 188, column: 3, scope: !2535)
!2537 = !DILocation(line: 190, column: 1, scope: !2528)
!2538 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2539 = !DILocation(line: 82, column: 20, scope: !2538)
!2540 = !DILocation(line: 82, column: 18, scope: !2538)
!2541 = !DILocation(line: 90, column: 6, scope: !2542)
!2542 = distinct !DILexicalBlock(scope: !2538, file: !63, line: 90, column: 6)
!2543 = !DILocation(line: 90, column: 22, scope: !2542)
!2544 = !DILocation(line: 90, column: 6, scope: !2538)
!2545 = !DILocation(line: 91, column: 3, scope: !2546)
!2546 = distinct !DILexicalBlock(scope: !2542, file: !63, line: 90, column: 39)
!2547 = !DILocation(line: 93, column: 2, scope: !2538)
!2548 = !DILocation(line: 94, column: 1, scope: !2538)
!2549 = distinct !DISubprogram(name: "k_uptime_delta", scope: !6, file: !6, line: 2133, type: !1086, scopeLine: 2134, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2550 = !DILocalVariable(name: "reftime", arg: 1, scope: !2549, file: !6, line: 2133, type: !1088)
!2551 = !DILocation(line: 2133, column: 47, scope: !2549)
!2552 = !DILocalVariable(name: "uptime", scope: !2549, file: !6, line: 2135, type: !55)
!2553 = !DILocation(line: 2135, column: 10, scope: !2549)
!2554 = !DILocalVariable(name: "delta", scope: !2549, file: !6, line: 2135, type: !55)
!2555 = !DILocation(line: 2135, column: 18, scope: !2549)
!2556 = !DILocation(line: 2137, column: 11, scope: !2549)
!2557 = !DILocation(line: 2137, column: 9, scope: !2549)
!2558 = !DILocation(line: 2138, column: 10, scope: !2549)
!2559 = !DILocation(line: 2138, column: 20, scope: !2549)
!2560 = !DILocation(line: 2138, column: 19, scope: !2549)
!2561 = !DILocation(line: 2138, column: 17, scope: !2549)
!2562 = !DILocation(line: 2138, column: 8, scope: !2549)
!2563 = !DILocation(line: 2139, column: 13, scope: !2549)
!2564 = !DILocation(line: 2139, column: 3, scope: !2549)
!2565 = !DILocation(line: 2139, column: 11, scope: !2549)
!2566 = !DILocation(line: 2141, column: 9, scope: !2549)
!2567 = !DILocation(line: 2141, column: 2, scope: !2549)
!2568 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !564, retainedNodes: !609)
!2569 = !DILocation(line: 72, column: 18, scope: !2568)
!2570 = !DILocation(line: 74, column: 2, scope: !2568)
!2571 = !DILocation(line: 75, column: 20, scope: !2568)
!2572 = !DILocation(line: 75, column: 18, scope: !2568)
!2573 = !DILocation(line: 76, column: 1, scope: !2568)
!2574 = distinct !DISubprogram(name: "pipe_test", scope: !2575, file: !2575, line: 96, type: !206, scopeLine: 97, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !569, retainedNodes: !609)
!2575 = !DIFile(filename: "appl/Zephyr/app_kernel/src/pipe_b.c", directory: "/home/kenny/ara")
!2576 = !DILocalVariable(name: "putsize", scope: !2574, file: !2575, line: 98, type: !58)
!2577 = !DILocation(line: 98, column: 11, scope: !2574)
!2578 = !DILocalVariable(name: "getsize", scope: !2574, file: !2575, line: 99, type: !61)
!2579 = !DILocation(line: 99, column: 14, scope: !2574)
!2580 = !DILocalVariable(name: "puttime", scope: !2574, file: !2575, line: 100, type: !2581)
!2581 = !DICompositeType(tag: DW_TAG_array_type, baseType: !58, size: 96, elements: !294)
!2582 = !DILocation(line: 100, column: 11, scope: !2574)
!2583 = !DILocalVariable(name: "putcount", scope: !2574, file: !2575, line: 101, type: !61)
!2584 = !DILocation(line: 101, column: 7, scope: !2574)
!2585 = !DILocalVariable(name: "pipe", scope: !2574, file: !2575, line: 102, type: !61)
!2586 = !DILocation(line: 102, column: 7, scope: !2574)
!2587 = !DILocalVariable(name: "TaskPrio", scope: !2574, file: !2575, line: 103, type: !58)
!2588 = !DILocation(line: 103, column: 11, scope: !2574)
!2589 = !DILocalVariable(name: "prio", scope: !2574, file: !2575, line: 104, type: !61)
!2590 = !DILocation(line: 104, column: 7, scope: !2574)
!2591 = !DILocalVariable(name: "getinfo", scope: !2574, file: !2575, line: 105, type: !2592)
!2592 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getinfo", file: !1335, line: 18, size: 96, elements: !2593)
!2593 = !{!2594, !2595, !2596}
!2594 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !2592, file: !1335, line: 19, baseType: !61, size: 32)
!2595 = !DIDerivedType(tag: DW_TAG_member, name: "time", scope: !2592, file: !1335, line: 20, baseType: !59, size: 32, offset: 32)
!2596 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !2592, file: !1335, line: 21, baseType: !61, size: 32, offset: 64)
!2597 = !DILocation(line: 105, column: 17, scope: !2574)
!2598 = !DILocation(line: 107, column: 2, scope: !2574)
!2599 = !DILocation(line: 108, column: 2, scope: !2574)
!2600 = !DILocation(line: 113, column: 2, scope: !2574)
!2601 = !DILocation(line: 114, column: 2, scope: !2574)
!2602 = !DILocation(line: 117, column: 2, scope: !2574)
!2603 = !DILocation(line: 118, column: 2, scope: !2574)
!2604 = !DILocation(line: 121, column: 2, scope: !2574)
!2605 = !DILocation(line: 122, column: 2, scope: !2574)
!2606 = !DILocation(line: 125, column: 2, scope: !2574)
!2607 = !DILocation(line: 126, column: 2, scope: !2574)
!2608 = !DILocation(line: 127, column: 2, scope: !2574)
!2609 = !DILocation(line: 128, column: 2, scope: !2574)
!2610 = !DILocation(line: 130, column: 2, scope: !2574)
!2611 = !DILocation(line: 132, column: 15, scope: !2612)
!2612 = distinct !DILexicalBlock(scope: !2574, file: !2575, line: 132, column: 2)
!2613 = !DILocation(line: 132, column: 7, scope: !2612)
!2614 = !DILocation(line: 132, column: 21, scope: !2615)
!2615 = distinct !DILexicalBlock(scope: !2612, file: !2575, line: 132, column: 2)
!2616 = !DILocation(line: 132, column: 29, scope: !2615)
!2617 = !DILocation(line: 132, column: 2, scope: !2612)
!2618 = !DILocation(line: 133, column: 13, scope: !2619)
!2619 = distinct !DILexicalBlock(scope: !2620, file: !2575, line: 133, column: 3)
!2620 = distinct !DILexicalBlock(scope: !2615, file: !2575, line: 132, column: 66)
!2621 = !DILocation(line: 133, column: 8, scope: !2619)
!2622 = !DILocation(line: 133, column: 18, scope: !2623)
!2623 = distinct !DILexicalBlock(scope: !2619, file: !2575, line: 133, column: 3)
!2624 = !DILocation(line: 133, column: 23, scope: !2623)
!2625 = !DILocation(line: 133, column: 3, scope: !2619)
!2626 = !DILocation(line: 134, column: 13, scope: !2627)
!2627 = distinct !DILexicalBlock(scope: !2623, file: !2575, line: 133, column: 36)
!2628 = !DILocation(line: 135, column: 23, scope: !2627)
!2629 = !DILocation(line: 135, column: 12, scope: !2627)
!2630 = !DILocation(line: 135, column: 38, scope: !2627)
!2631 = !DILocation(line: 135, column: 47, scope: !2627)
!2632 = !DILocation(line: 136, column: 15, scope: !2627)
!2633 = !DILocation(line: 136, column: 7, scope: !2627)
!2634 = !DILocation(line: 135, column: 4, scope: !2627)
!2635 = !DILocation(line: 139, column: 25, scope: !2627)
!2636 = !DILocation(line: 139, column: 35, scope: !2627)
!2637 = !DILocation(line: 139, column: 4, scope: !2627)
!2638 = !DILocation(line: 140, column: 3, scope: !2627)
!2639 = !DILocation(line: 133, column: 32, scope: !2623)
!2640 = !DILocation(line: 133, column: 3, scope: !2623)
!2641 = distinct !{!2641, !2625, !2642}
!2642 = !DILocation(line: 140, column: 3, scope: !2619)
!2643 = !DILocation(line: 141, column: 3, scope: !2644)
!2644 = distinct !DILexicalBlock(scope: !2620, file: !2575, line: 141, column: 3)
!2645 = !DILocation(line: 142, column: 2, scope: !2620)
!2646 = !DILocation(line: 132, column: 59, scope: !2615)
!2647 = !DILocation(line: 132, column: 2, scope: !2615)
!2648 = distinct !{!2648, !2617, !2649}
!2649 = !DILocation(line: 142, column: 2, scope: !2612)
!2650 = !DILocation(line: 143, column: 2, scope: !2574)
!2651 = !DILocation(line: 146, column: 12, scope: !2652)
!2652 = distinct !DILexicalBlock(scope: !2574, file: !2575, line: 146, column: 2)
!2653 = !DILocation(line: 146, column: 7, scope: !2652)
!2654 = !DILocation(line: 146, column: 17, scope: !2655)
!2655 = distinct !DILexicalBlock(scope: !2652, file: !2575, line: 146, column: 2)
!2656 = !DILocation(line: 146, column: 22, scope: !2655)
!2657 = !DILocation(line: 146, column: 2, scope: !2652)
!2658 = !DILocation(line: 148, column: 7, scope: !2659)
!2659 = distinct !DILexicalBlock(scope: !2660, file: !2575, line: 148, column: 7)
!2660 = distinct !DILexicalBlock(scope: !2655, file: !2575, line: 146, column: 35)
!2661 = !DILocation(line: 148, column: 12, scope: !2659)
!2662 = !DILocation(line: 148, column: 7, scope: !2660)
!2663 = !DILocation(line: 149, column: 4, scope: !2664)
!2664 = distinct !DILexicalBlock(scope: !2659, file: !2575, line: 148, column: 18)
!2665 = !DILocation(line: 152, column: 37, scope: !2664)
!2666 = !DILocation(line: 152, column: 15, scope: !2664)
!2667 = !DILocation(line: 152, column: 13, scope: !2664)
!2668 = !DILocation(line: 153, column: 3, scope: !2664)
!2669 = !DILocation(line: 154, column: 7, scope: !2670)
!2670 = distinct !DILexicalBlock(scope: !2660, file: !2575, line: 154, column: 7)
!2671 = !DILocation(line: 154, column: 12, scope: !2670)
!2672 = !DILocation(line: 154, column: 7, scope: !2660)
!2673 = !DILocation(line: 155, column: 4, scope: !2674)
!2674 = distinct !DILexicalBlock(scope: !2670, file: !2575, line: 154, column: 18)
!2675 = !DILocation(line: 158, column: 26, scope: !2674)
!2676 = !DILocation(line: 158, column: 43, scope: !2674)
!2677 = !DILocation(line: 158, column: 52, scope: !2674)
!2678 = !DILocation(line: 158, column: 4, scope: !2674)
!2679 = !DILocation(line: 159, column: 3, scope: !2674)
!2680 = !DILocation(line: 160, column: 3, scope: !2660)
!2681 = !DILocation(line: 161, column: 3, scope: !2660)
!2682 = !DILocation(line: 161, column: 3, scope: !2683)
!2683 = distinct !DILexicalBlock(scope: !2660, file: !2575, line: 161, column: 3)
!2684 = !DILocation(line: 162, column: 3, scope: !2660)
!2685 = !DILocation(line: 164, column: 3, scope: !2660)
!2686 = !DILocation(line: 166, column: 15, scope: !2687)
!2687 = distinct !DILexicalBlock(scope: !2660, file: !2575, line: 166, column: 2)
!2688 = !DILocation(line: 166, column: 7, scope: !2687)
!2689 = !DILocation(line: 166, column: 21, scope: !2690)
!2690 = distinct !DILexicalBlock(scope: !2687, file: !2575, line: 166, column: 2)
!2691 = !DILocation(line: 166, column: 29, scope: !2690)
!2692 = !DILocation(line: 166, column: 2, scope: !2687)
!2693 = !DILocation(line: 167, column: 34, scope: !2694)
!2694 = distinct !DILexicalBlock(scope: !2690, file: !2575, line: 166, column: 68)
!2695 = !DILocation(line: 167, column: 32, scope: !2694)
!2696 = !DILocation(line: 167, column: 12, scope: !2694)
!2697 = !DILocation(line: 168, column: 13, scope: !2698)
!2698 = distinct !DILexicalBlock(scope: !2694, file: !2575, line: 168, column: 3)
!2699 = !DILocation(line: 168, column: 8, scope: !2698)
!2700 = !DILocation(line: 168, column: 18, scope: !2701)
!2701 = distinct !DILexicalBlock(scope: !2698, file: !2575, line: 168, column: 3)
!2702 = !DILocation(line: 168, column: 23, scope: !2701)
!2703 = !DILocation(line: 168, column: 3, scope: !2698)
!2704 = !DILocation(line: 169, column: 23, scope: !2705)
!2705 = distinct !DILexicalBlock(scope: !2701, file: !2575, line: 168, column: 36)
!2706 = !DILocation(line: 169, column: 12, scope: !2705)
!2707 = !DILocation(line: 169, column: 39, scope: !2705)
!2708 = !DILocation(line: 170, column: 7, scope: !2705)
!2709 = !DILocation(line: 170, column: 26, scope: !2705)
!2710 = !DILocation(line: 170, column: 18, scope: !2705)
!2711 = !DILocation(line: 169, column: 4, scope: !2705)
!2712 = !DILocation(line: 173, column: 25, scope: !2705)
!2713 = !DILocation(line: 173, column: 35, scope: !2705)
!2714 = !DILocation(line: 173, column: 4, scope: !2705)
!2715 = !DILocation(line: 174, column: 22, scope: !2705)
!2716 = !DILocation(line: 174, column: 12, scope: !2705)
!2717 = !DILocation(line: 175, column: 3, scope: !2705)
!2718 = !DILocation(line: 168, column: 32, scope: !2701)
!2719 = !DILocation(line: 168, column: 3, scope: !2701)
!2720 = distinct !{!2720, !2703, !2721}
!2721 = !DILocation(line: 175, column: 3, scope: !2698)
!2722 = !DILocation(line: 176, column: 3, scope: !2723)
!2723 = distinct !DILexicalBlock(scope: !2694, file: !2575, line: 176, column: 3)
!2724 = !DILocation(line: 177, column: 2, scope: !2694)
!2725 = !DILocation(line: 166, column: 61, scope: !2690)
!2726 = !DILocation(line: 166, column: 2, scope: !2690)
!2727 = distinct !{!2727, !2692, !2728}
!2728 = !DILocation(line: 177, column: 2, scope: !2687)
!2729 = !DILocation(line: 178, column: 3, scope: !2660)
!2730 = !DILocation(line: 179, column: 25, scope: !2660)
!2731 = !DILocation(line: 179, column: 42, scope: !2660)
!2732 = !DILocation(line: 179, column: 3, scope: !2660)
!2733 = !DILocation(line: 180, column: 2, scope: !2660)
!2734 = !DILocation(line: 146, column: 31, scope: !2655)
!2735 = !DILocation(line: 146, column: 2, scope: !2655)
!2736 = distinct !{!2736, !2657, !2737}
!2737 = !DILocation(line: 180, column: 2, scope: !2652)
!2738 = !DILocation(line: 181, column: 1, scope: !2574)
!2739 = distinct !DISubprogram(name: "k_sem_reset", scope: !765, file: !765, line: 775, type: !2740, scopeLine: 776, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!2740 = !DISubroutineType(types: !2741)
!2741 = !{null, !2742}
!2742 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2743, size: 32)
!2743 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_sem", file: !6, line: 3704, size: 128, elements: !2744)
!2744 = !{!2745, !2764, !2765}
!2745 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !2743, file: !6, line: 3705, baseType: !2746, size: 64)
!2746 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !2747)
!2747 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !2748)
!2748 = !{!2749}
!2749 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !2747, file: !99, line: 209, baseType: !2750, size: 64)
!2750 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !2751)
!2751 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !2752)
!2752 = !{!2753, !2759}
!2753 = !DIDerivedType(tag: DW_TAG_member, scope: !2751, file: !116, line: 32, baseType: !2754, size: 32)
!2754 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2751, file: !116, line: 32, size: 32, elements: !2755)
!2755 = !{!2756, !2758}
!2756 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !2754, file: !116, line: 33, baseType: !2757, size: 32)
!2757 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2751, size: 32)
!2758 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !2754, file: !116, line: 34, baseType: !2757, size: 32)
!2759 = !DIDerivedType(tag: DW_TAG_member, scope: !2751, file: !116, line: 36, baseType: !2760, size: 32, offset: 32)
!2760 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2751, file: !116, line: 36, size: 32, elements: !2761)
!2761 = !{!2762, !2763}
!2762 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !2760, file: !116, line: 37, baseType: !2757, size: 32)
!2763 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !2760, file: !116, line: 38, baseType: !2757, size: 32)
!2764 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !2743, file: !6, line: 3706, baseType: !58, size: 32, offset: 64)
!2765 = !DIDerivedType(tag: DW_TAG_member, name: "limit", scope: !2743, file: !6, line: 3707, baseType: !58, size: 32, offset: 96)
!2766 = !DILocalVariable(name: "sem", arg: 1, scope: !2739, file: !765, line: 775, type: !2742)
!2767 = !DILocation(line: 775, column: 65, scope: !2739)
!2768 = !DILocation(line: 783, column: 2, scope: !2739)
!2769 = !DILocation(line: 783, column: 2, scope: !2770)
!2770 = distinct !DILexicalBlock(scope: !2739, file: !765, line: 783, column: 2)
!2771 = !{i32 -2141842432}
!2772 = !DILocation(line: 784, column: 21, scope: !2739)
!2773 = !DILocation(line: 784, column: 2, scope: !2739)
!2774 = !DILocation(line: 785, column: 1, scope: !2739)
!2775 = distinct !DISubprogram(name: "pipeput", scope: !2575, file: !2575, line: 196, type: !2776, scopeLine: 201, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !569, retainedNodes: !609)
!2776 = !DISubroutineType(types: !2777)
!2777 = !{!61, !2778, !572, !61, !61, !1406}
!2778 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2779, size: 32)
!2779 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_pipe", file: !6, line: 4324, size: 352, elements: !2780)
!2780 = !{!2781, !2782, !2783, !2784, !2785, !2786, !2790, !2795}
!2781 = !DIDerivedType(tag: DW_TAG_member, name: "buffer", scope: !2779, file: !6, line: 4325, baseType: !261, size: 32)
!2782 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !2779, file: !6, line: 4326, baseType: !79, size: 32, offset: 32)
!2783 = !DIDerivedType(tag: DW_TAG_member, name: "bytes_used", scope: !2779, file: !6, line: 4327, baseType: !79, size: 32, offset: 64)
!2784 = !DIDerivedType(tag: DW_TAG_member, name: "read_index", scope: !2779, file: !6, line: 4328, baseType: !79, size: 32, offset: 96)
!2785 = !DIDerivedType(tag: DW_TAG_member, name: "write_index", scope: !2779, file: !6, line: 4329, baseType: !79, size: 32, offset: 128)
!2786 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !2779, file: !6, line: 4330, baseType: !2787, size: 32, offset: 160)
!2787 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !2788)
!2788 = !{!2789}
!2789 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !2787, file: !99, line: 243, baseType: !134, size: 32)
!2790 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !2779, file: !6, line: 4335, baseType: !2791, size: 128, offset: 192)
!2791 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !2779, file: !6, line: 4332, size: 128, elements: !2792)
!2792 = !{!2793, !2794}
!2793 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !2791, file: !6, line: 4333, baseType: !2746, size: 64)
!2794 = !DIDerivedType(tag: DW_TAG_member, name: "writers", scope: !2791, file: !6, line: 4334, baseType: !2746, size: 64, offset: 64)
!2795 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !2779, file: !6, line: 4339, baseType: !161, size: 8, offset: 320)
!2796 = !DILocalVariable(name: "pipe", arg: 1, scope: !2775, file: !2575, line: 196, type: !2778)
!2797 = !DILocation(line: 196, column: 28, scope: !2775)
!2798 = !DILocalVariable(name: "option", arg: 2, scope: !2775, file: !2575, line: 197, type: !572)
!2799 = !DILocation(line: 197, column: 24, scope: !2775)
!2800 = !DILocalVariable(name: "size", arg: 3, scope: !2775, file: !2575, line: 198, type: !61)
!2801 = !DILocation(line: 198, column: 10, scope: !2775)
!2802 = !DILocalVariable(name: "count", arg: 4, scope: !2775, file: !2575, line: 199, type: !61)
!2803 = !DILocation(line: 199, column: 10, scope: !2775)
!2804 = !DILocalVariable(name: "time", arg: 5, scope: !2775, file: !2575, line: 200, type: !1406)
!2805 = !DILocation(line: 200, column: 16, scope: !2775)
!2806 = !DILocalVariable(name: "i", scope: !2775, file: !2575, line: 202, type: !61)
!2807 = !DILocation(line: 202, column: 6, scope: !2775)
!2808 = !DILocalVariable(name: "t", scope: !2775, file: !2575, line: 203, type: !59)
!2809 = !DILocation(line: 203, column: 15, scope: !2775)
!2810 = !DILocalVariable(name: "sizexferd_total", scope: !2775, file: !2575, line: 204, type: !79)
!2811 = !DILocation(line: 204, column: 9, scope: !2775)
!2812 = !DILocalVariable(name: "size2xfer_total", scope: !2775, file: !2575, line: 205, type: !79)
!2813 = !DILocation(line: 205, column: 9, scope: !2775)
!2814 = !DILocation(line: 205, column: 27, scope: !2775)
!2815 = !DILocation(line: 205, column: 34, scope: !2775)
!2816 = !DILocation(line: 205, column: 32, scope: !2775)
!2817 = !DILocation(line: 208, column: 2, scope: !2775)
!2818 = !DILocation(line: 209, column: 6, scope: !2775)
!2819 = !DILocation(line: 209, column: 4, scope: !2775)
!2820 = !DILocation(line: 210, column: 9, scope: !2821)
!2821 = distinct !DILexicalBlock(scope: !2775, file: !2575, line: 210, column: 2)
!2822 = !DILocation(line: 210, column: 7, scope: !2821)
!2823 = !DILocation(line: 210, column: 14, scope: !2824)
!2824 = distinct !DILexicalBlock(scope: !2821, file: !2575, line: 210, column: 2)
!2825 = !DILocation(line: 210, column: 21, scope: !2824)
!2826 = !DILocation(line: 210, column: 32, scope: !2824)
!2827 = !DILocation(line: 210, column: 36, scope: !2824)
!2828 = !DILocation(line: 210, column: 40, scope: !2824)
!2829 = !DILocation(line: 210, column: 38, scope: !2824)
!2830 = !DILocation(line: 210, column: 2, scope: !2821)
!2831 = !DILocalVariable(name: "sizexferd", scope: !2832, file: !2575, line: 211, type: !79)
!2832 = distinct !DILexicalBlock(scope: !2824, file: !2575, line: 210, column: 53)
!2833 = !DILocation(line: 211, column: 10, scope: !2832)
!2834 = !DILocalVariable(name: "size2xfer", scope: !2832, file: !2575, line: 212, type: !79)
!2835 = !DILocation(line: 212, column: 10, scope: !2832)
!2836 = !DILocation(line: 212, column: 22, scope: !2832)
!2837 = !DILocalVariable(name: "ret", scope: !2832, file: !2575, line: 213, type: !61)
!2838 = !DILocation(line: 213, column: 7, scope: !2832)
!2839 = !DILocalVariable(name: "mim_num_of_bytes", scope: !2832, file: !2575, line: 214, type: !79)
!2840 = !DILocation(line: 214, column: 10, scope: !2832)
!2841 = !DILocation(line: 216, column: 7, scope: !2842)
!2842 = distinct !DILexicalBlock(scope: !2832, file: !2575, line: 216, column: 7)
!2843 = !DILocation(line: 216, column: 14, scope: !2842)
!2844 = !DILocation(line: 216, column: 7, scope: !2832)
!2845 = !DILocation(line: 217, column: 23, scope: !2846)
!2846 = distinct !DILexicalBlock(scope: !2842, file: !2575, line: 216, column: 25)
!2847 = !DILocation(line: 217, column: 21, scope: !2846)
!2848 = !DILocation(line: 218, column: 3, scope: !2846)
!2849 = !DILocation(line: 219, column: 20, scope: !2832)
!2850 = !DILocation(line: 219, column: 38, scope: !2832)
!2851 = !DILocation(line: 220, column: 17, scope: !2832)
!2852 = !DILocation(line: 220, column: 35, scope: !2832)
!2853 = !DILocation(line: 219, column: 9, scope: !2832)
!2854 = !DILocation(line: 219, column: 7, scope: !2832)
!2855 = !DILocation(line: 222, column: 7, scope: !2856)
!2856 = distinct !DILexicalBlock(scope: !2832, file: !2575, line: 222, column: 7)
!2857 = !DILocation(line: 222, column: 11, scope: !2856)
!2858 = !DILocation(line: 222, column: 7, scope: !2832)
!2859 = !DILocation(line: 223, column: 4, scope: !2860)
!2860 = distinct !DILexicalBlock(scope: !2856, file: !2575, line: 222, column: 17)
!2861 = !DILocation(line: 225, column: 7, scope: !2862)
!2862 = distinct !DILexicalBlock(scope: !2832, file: !2575, line: 225, column: 7)
!2863 = !DILocation(line: 225, column: 14, scope: !2862)
!2864 = !DILocation(line: 225, column: 24, scope: !2862)
!2865 = !DILocation(line: 225, column: 27, scope: !2862)
!2866 = !DILocation(line: 225, column: 40, scope: !2862)
!2867 = !DILocation(line: 225, column: 37, scope: !2862)
!2868 = !DILocation(line: 225, column: 7, scope: !2832)
!2869 = !DILocation(line: 226, column: 4, scope: !2870)
!2870 = distinct !DILexicalBlock(scope: !2862, file: !2575, line: 225, column: 51)
!2871 = !DILocation(line: 229, column: 22, scope: !2832)
!2872 = !DILocation(line: 229, column: 19, scope: !2832)
!2873 = !DILocation(line: 230, column: 7, scope: !2874)
!2874 = distinct !DILexicalBlock(scope: !2832, file: !2575, line: 230, column: 7)
!2875 = !DILocation(line: 230, column: 26, scope: !2874)
!2876 = !DILocation(line: 230, column: 23, scope: !2874)
!2877 = !DILocation(line: 230, column: 7, scope: !2832)
!2878 = !DILocation(line: 231, column: 4, scope: !2879)
!2879 = distinct !DILexicalBlock(scope: !2874, file: !2575, line: 230, column: 43)
!2880 = !DILocation(line: 234, column: 7, scope: !2881)
!2881 = distinct !DILexicalBlock(scope: !2832, file: !2575, line: 234, column: 7)
!2882 = !DILocation(line: 234, column: 25, scope: !2881)
!2883 = !DILocation(line: 234, column: 23, scope: !2881)
!2884 = !DILocation(line: 234, column: 7, scope: !2832)
!2885 = !DILocation(line: 235, column: 4, scope: !2886)
!2886 = distinct !DILexicalBlock(scope: !2881, file: !2575, line: 234, column: 42)
!2887 = !DILocation(line: 237, column: 2, scope: !2832)
!2888 = !DILocation(line: 210, column: 49, scope: !2824)
!2889 = !DILocation(line: 210, column: 2, scope: !2824)
!2890 = distinct !{!2890, !2830, !2891}
!2891 = !DILocation(line: 237, column: 2, scope: !2821)
!2892 = !DILocation(line: 239, column: 27, scope: !2775)
!2893 = !DILocation(line: 239, column: 6, scope: !2775)
!2894 = !DILocation(line: 239, column: 4, scope: !2775)
!2895 = !DILocation(line: 240, column: 10, scope: !2775)
!2896 = !DILocation(line: 240, column: 3, scope: !2775)
!2897 = !DILocation(line: 240, column: 8, scope: !2775)
!2898 = !DILocation(line: 241, column: 6, scope: !2899)
!2899 = distinct !DILexicalBlock(scope: !2775, file: !2575, line: 241, column: 6)
!2900 = !DILocation(line: 241, column: 23, scope: !2899)
!2901 = !DILocation(line: 241, column: 6, scope: !2775)
!2902 = !DILocation(line: 242, column: 7, scope: !2903)
!2903 = distinct !DILexicalBlock(scope: !2904, file: !2575, line: 242, column: 7)
!2904 = distinct !DILexicalBlock(scope: !2899, file: !2575, line: 241, column: 28)
!2905 = !DILocation(line: 242, column: 7, scope: !2904)
!2906 = !DILocation(line: 243, column: 4, scope: !2907)
!2907 = distinct !DILexicalBlock(scope: !2903, file: !2575, line: 242, column: 30)
!2908 = !DILocation(line: 246, column: 3, scope: !2907)
!2909 = !DILocation(line: 247, column: 2, scope: !2910)
!2910 = distinct !DILexicalBlock(scope: !2903, file: !2575, line: 246, column: 10)
!2911 = !DILocation(line: 250, column: 3, scope: !2904)
!2912 = !DILocation(line: 251, column: 2, scope: !2904)
!2913 = !DILocation(line: 252, column: 2, scope: !2775)
!2914 = !DILocation(line: 253, column: 1, scope: !2775)
!2915 = distinct !DISubprogram(name: "k_current_get", scope: !765, file: !765, line: 187, type: !2916, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!2916 = !DISubroutineType(types: !2917)
!2917 = !{!2918}
!2918 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_tid_t", file: !6, line: 648, baseType: !2919)
!2919 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2920, size: 32)
!2920 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_thread", file: !6, line: 570, size: 1280, elements: !2921)
!2921 = !{!2922, !2963, !2975, !2976, !2977, !2978, !2979, !2985, !3001}
!2922 = !DIDerivedType(tag: DW_TAG_member, name: "base", scope: !2920, file: !6, line: 572, baseType: !2923, size: 448)
!2923 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_base", file: !6, line: 441, size: 448, elements: !2924)
!2924 = !{!2925, !2936, !2938, !2939, !2940, !2949, !2950, !2951, !2962}
!2925 = !DIDerivedType(tag: DW_TAG_member, scope: !2923, file: !6, line: 444, baseType: !2926, size: 64)
!2926 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2923, file: !6, line: 444, size: 64, elements: !2927)
!2927 = !{!2928, !2930}
!2928 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_dlist", scope: !2926, file: !6, line: 445, baseType: !2929, size: 64)
!2929 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dnode_t", file: !116, line: 43, baseType: !2751)
!2930 = !DIDerivedType(tag: DW_TAG_member, name: "qnode_rb", scope: !2926, file: !6, line: 446, baseType: !2931, size: 64)
!2931 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "rbnode", file: !151, line: 48, size: 64, elements: !2932)
!2932 = !{!2933}
!2933 = !DIDerivedType(tag: DW_TAG_member, name: "children", scope: !2931, file: !151, line: 49, baseType: !2934, size: 64)
!2934 = !DICompositeType(tag: DW_TAG_array_type, baseType: !2935, size: 64, elements: !156)
!2935 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2931, size: 32)
!2936 = !DIDerivedType(tag: DW_TAG_member, name: "pended_on", scope: !2923, file: !6, line: 452, baseType: !2937, size: 32, offset: 64)
!2937 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2746, size: 32)
!2938 = !DIDerivedType(tag: DW_TAG_member, name: "user_options", scope: !2923, file: !6, line: 455, baseType: !161, size: 8, offset: 96)
!2939 = !DIDerivedType(tag: DW_TAG_member, name: "thread_state", scope: !2923, file: !6, line: 458, baseType: !161, size: 8, offset: 104)
!2940 = !DIDerivedType(tag: DW_TAG_member, scope: !2923, file: !6, line: 474, baseType: !2941, size: 16, offset: 112)
!2941 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !2923, file: !6, line: 474, size: 16, elements: !2942)
!2942 = !{!2943, !2948}
!2943 = !DIDerivedType(tag: DW_TAG_member, scope: !2941, file: !6, line: 475, baseType: !2944, size: 16)
!2944 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !2941, file: !6, line: 475, size: 16, elements: !2945)
!2945 = !{!2946, !2947}
!2946 = !DIDerivedType(tag: DW_TAG_member, name: "prio", scope: !2944, file: !6, line: 480, baseType: !170, size: 8)
!2947 = !DIDerivedType(tag: DW_TAG_member, name: "sched_locked", scope: !2944, file: !6, line: 481, baseType: !161, size: 8, offset: 8)
!2948 = !DIDerivedType(tag: DW_TAG_member, name: "preempt", scope: !2941, file: !6, line: 484, baseType: !174, size: 16)
!2949 = !DIDerivedType(tag: DW_TAG_member, name: "order_key", scope: !2923, file: !6, line: 491, baseType: !58, size: 32, offset: 128)
!2950 = !DIDerivedType(tag: DW_TAG_member, name: "swap_data", scope: !2923, file: !6, line: 511, baseType: !60, size: 32, offset: 160)
!2951 = !DIDerivedType(tag: DW_TAG_member, name: "timeout", scope: !2923, file: !6, line: 515, baseType: !2952, size: 192, offset: 192)
!2952 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_timeout", file: !99, line: 221, size: 192, elements: !2953)
!2953 = !{!2954, !2955, !2961}
!2954 = !DIDerivedType(tag: DW_TAG_member, name: "node", scope: !2952, file: !99, line: 222, baseType: !2929, size: 64)
!2955 = !DIDerivedType(tag: DW_TAG_member, name: "fn", scope: !2952, file: !99, line: 223, baseType: !2956, size: 32, offset: 64)
!2956 = !DIDerivedType(tag: DW_TAG_typedef, name: "_timeout_func_t", file: !99, line: 219, baseType: !2957)
!2957 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2958, size: 32)
!2958 = !DISubroutineType(types: !2959)
!2959 = !{null, !2960}
!2960 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2952, size: 32)
!2961 = !DIDerivedType(tag: DW_TAG_member, name: "dticks", scope: !2952, file: !99, line: 226, baseType: !55, size: 64, offset: 128)
!2962 = !DIDerivedType(tag: DW_TAG_member, name: "join_waiters", scope: !2923, file: !6, line: 518, baseType: !2746, size: 64, offset: 384)
!2963 = !DIDerivedType(tag: DW_TAG_member, name: "callee_saved", scope: !2920, file: !6, line: 575, baseType: !2964, size: 288, offset: 448)
!2964 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_callee_saved", file: !192, line: 25, size: 288, elements: !2965)
!2965 = !{!2966, !2967, !2968, !2969, !2970, !2971, !2972, !2973, !2974}
!2966 = !DIDerivedType(tag: DW_TAG_member, name: "v1", scope: !2964, file: !192, line: 26, baseType: !58, size: 32)
!2967 = !DIDerivedType(tag: DW_TAG_member, name: "v2", scope: !2964, file: !192, line: 27, baseType: !58, size: 32, offset: 32)
!2968 = !DIDerivedType(tag: DW_TAG_member, name: "v3", scope: !2964, file: !192, line: 28, baseType: !58, size: 32, offset: 64)
!2969 = !DIDerivedType(tag: DW_TAG_member, name: "v4", scope: !2964, file: !192, line: 29, baseType: !58, size: 32, offset: 96)
!2970 = !DIDerivedType(tag: DW_TAG_member, name: "v5", scope: !2964, file: !192, line: 30, baseType: !58, size: 32, offset: 128)
!2971 = !DIDerivedType(tag: DW_TAG_member, name: "v6", scope: !2964, file: !192, line: 31, baseType: !58, size: 32, offset: 160)
!2972 = !DIDerivedType(tag: DW_TAG_member, name: "v7", scope: !2964, file: !192, line: 32, baseType: !58, size: 32, offset: 192)
!2973 = !DIDerivedType(tag: DW_TAG_member, name: "v8", scope: !2964, file: !192, line: 33, baseType: !58, size: 32, offset: 224)
!2974 = !DIDerivedType(tag: DW_TAG_member, name: "psp", scope: !2964, file: !192, line: 34, baseType: !58, size: 32, offset: 256)
!2975 = !DIDerivedType(tag: DW_TAG_member, name: "init_data", scope: !2920, file: !6, line: 578, baseType: !60, size: 32, offset: 736)
!2976 = !DIDerivedType(tag: DW_TAG_member, name: "fn_abort", scope: !2920, file: !6, line: 583, baseType: !205, size: 32, offset: 768)
!2977 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !2920, file: !6, line: 595, baseType: !209, size: 256, offset: 800)
!2978 = !DIDerivedType(tag: DW_TAG_member, name: "errno_var", scope: !2920, file: !6, line: 610, baseType: !61, size: 32, offset: 1056)
!2979 = !DIDerivedType(tag: DW_TAG_member, name: "stack_info", scope: !2920, file: !6, line: 616, baseType: !2980, size: 96, offset: 1088)
!2980 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_stack_info", file: !6, line: 525, size: 96, elements: !2981)
!2981 = !{!2982, !2983, !2984}
!2982 = !DIDerivedType(tag: DW_TAG_member, name: "start", scope: !2980, file: !6, line: 529, baseType: !134, size: 32)
!2983 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !2980, file: !6, line: 538, baseType: !79, size: 32, offset: 32)
!2984 = !DIDerivedType(tag: DW_TAG_member, name: "delta", scope: !2980, file: !6, line: 544, baseType: !79, size: 32, offset: 64)
!2985 = !DIDerivedType(tag: DW_TAG_member, name: "resource_pool", scope: !2920, file: !6, line: 641, baseType: !2986, size: 32, offset: 1184)
!2986 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2987, size: 32)
!2987 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_mem_pool", file: !86, line: 30, size: 32, elements: !2988)
!2988 = !{!2989}
!2989 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !2987, file: !86, line: 31, baseType: !2990, size: 32)
!2990 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2991, size: 32)
!2991 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_heap", file: !99, line: 267, size: 192, elements: !2992)
!2992 = !{!2993, !2999, !3000}
!2993 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !2991, file: !99, line: 268, baseType: !2994, size: 96)
!2994 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sys_heap", file: !103, line: 51, size: 96, elements: !2995)
!2995 = !{!2996, !2997, !2998}
!2996 = !DIDerivedType(tag: DW_TAG_member, name: "heap", scope: !2994, file: !103, line: 52, baseType: !106, size: 32)
!2997 = !DIDerivedType(tag: DW_TAG_member, name: "init_mem", scope: !2994, file: !103, line: 53, baseType: !60, size: 32, offset: 32)
!2998 = !DIDerivedType(tag: DW_TAG_member, name: "init_bytes", scope: !2994, file: !103, line: 54, baseType: !79, size: 32, offset: 64)
!2999 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !2991, file: !99, line: 269, baseType: !2746, size: 64, offset: 96)
!3000 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !2991, file: !99, line: 270, baseType: !2787, size: 32, offset: 160)
!3001 = !DIDerivedType(tag: DW_TAG_member, name: "arch", scope: !2920, file: !6, line: 644, baseType: !3002, size: 64, offset: 1216)
!3002 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_thread_arch", file: !192, line: 60, size: 64, elements: !3003)
!3003 = !{!3004, !3005}
!3004 = !DIDerivedType(tag: DW_TAG_member, name: "basepri", scope: !3002, file: !192, line: 63, baseType: !58, size: 32)
!3005 = !DIDerivedType(tag: DW_TAG_member, name: "swap_return_value", scope: !3002, file: !192, line: 66, baseType: !58, size: 32, offset: 32)
!3006 = !DILocation(line: 194, column: 2, scope: !2915)
!3007 = !DILocation(line: 194, column: 2, scope: !3008)
!3008 = distinct !DILexicalBlock(scope: !2915, file: !765, line: 194, column: 2)
!3009 = !{i32 -2141845368}
!3010 = !DILocation(line: 195, column: 9, scope: !2915)
!3011 = !DILocation(line: 195, column: 2, scope: !2915)
!3012 = distinct !DISubprogram(name: "k_thread_priority_get", scope: !765, file: !765, line: 254, type: !3013, scopeLine: 255, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!3013 = !DISubroutineType(types: !3014)
!3014 = !{!61, !2918}
!3015 = !DILocalVariable(name: "thread", arg: 1, scope: !3012, file: !765, line: 254, type: !2918)
!3016 = !DILocation(line: 254, column: 67, scope: !3012)
!3017 = !DILocation(line: 261, column: 2, scope: !3012)
!3018 = !DILocation(line: 261, column: 2, scope: !3019)
!3019 = distinct !DILexicalBlock(scope: !3012, file: !765, line: 261, column: 2)
!3020 = !{i32 -2141845028}
!3021 = !DILocation(line: 262, column: 38, scope: !3012)
!3022 = !DILocation(line: 262, column: 9, scope: !3012)
!3023 = !DILocation(line: 262, column: 2, scope: !3012)
!3024 = distinct !DISubprogram(name: "k_thread_priority_set", scope: !765, file: !765, line: 267, type: !3025, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!3025 = !DISubroutineType(types: !3026)
!3026 = !{null, !2918, !61}
!3027 = !DILocalVariable(name: "thread", arg: 1, scope: !3024, file: !765, line: 267, type: !2918)
!3028 = !DILocation(line: 267, column: 68, scope: !3024)
!3029 = !DILocalVariable(name: "prio", arg: 2, scope: !3024, file: !765, line: 267, type: !61)
!3030 = !DILocation(line: 267, column: 80, scope: !3024)
!3031 = !DILocation(line: 275, column: 2, scope: !3024)
!3032 = !DILocation(line: 275, column: 2, scope: !3033)
!3033 = distinct !DILexicalBlock(scope: !3024, file: !765, line: 275, column: 2)
!3034 = !{i32 -2141844960}
!3035 = !DILocation(line: 276, column: 31, scope: !3024)
!3036 = !DILocation(line: 276, column: 39, scope: !3024)
!3037 = !DILocation(line: 276, column: 2, scope: !3024)
!3038 = !DILocation(line: 277, column: 1, scope: !3024)
!3039 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!3040 = !DILocalVariable(name: "et", scope: !3039, file: !573, line: 177, type: !58)
!3041 = !DILocation(line: 177, column: 11, scope: !3039)
!3042 = !DILocation(line: 179, column: 2, scope: !3039)
!3043 = !DILocation(line: 180, column: 7, scope: !3039)
!3044 = !DILocation(line: 180, column: 5, scope: !3039)
!3045 = !DILocation(line: 181, column: 9, scope: !3039)
!3046 = !DILocation(line: 181, column: 2, scope: !3039)
!3047 = distinct !DISubprogram(name: "k_pipe_put", scope: !765, file: !765, line: 925, type: !3048, scopeLine: 926, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!3048 = !DISubroutineType(types: !3049)
!3049 = !{!61, !2778, !60, !79, !3050, !79, !3051}
!3050 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !79, size: 32)
!3051 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !3052)
!3052 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !3053)
!3053 = !{!3054}
!3054 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !3052, file: !54, line: 68, baseType: !53, size: 64)
!3055 = !DILocalVariable(name: "pipe", arg: 1, scope: !3047, file: !765, line: 925, type: !2778)
!3056 = !DILocation(line: 925, column: 64, scope: !3047)
!3057 = !DILocalVariable(name: "data", arg: 2, scope: !3047, file: !765, line: 925, type: !60)
!3058 = !DILocation(line: 925, column: 77, scope: !3047)
!3059 = !DILocalVariable(name: "bytes_to_write", arg: 3, scope: !3047, file: !765, line: 925, type: !79)
!3060 = !DILocation(line: 925, column: 90, scope: !3047)
!3061 = !DILocalVariable(name: "bytes_written", arg: 4, scope: !3047, file: !765, line: 925, type: !3050)
!3062 = !DILocation(line: 925, column: 115, scope: !3047)
!3063 = !DILocalVariable(name: "min_xfer", arg: 5, scope: !3047, file: !765, line: 925, type: !79)
!3064 = !DILocation(line: 925, column: 137, scope: !3047)
!3065 = !DILocalVariable(name: "timeout", arg: 6, scope: !3047, file: !765, line: 925, type: !3051)
!3066 = !DILocation(line: 925, column: 159, scope: !3047)
!3067 = !DILocation(line: 938, column: 2, scope: !3047)
!3068 = !DILocation(line: 938, column: 2, scope: !3069)
!3069 = distinct !DILexicalBlock(scope: !3047, file: !765, line: 938, column: 2)
!3070 = !{i32 -2141841684}
!3071 = !DILocation(line: 939, column: 27, scope: !3047)
!3072 = !DILocation(line: 939, column: 33, scope: !3047)
!3073 = !DILocation(line: 939, column: 39, scope: !3047)
!3074 = !DILocation(line: 939, column: 55, scope: !3047)
!3075 = !DILocation(line: 939, column: 70, scope: !3047)
!3076 = !DILocation(line: 939, column: 9, scope: !3047)
!3077 = !DILocation(line: 939, column: 2, scope: !3047)
!3078 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!3079 = !DILocation(line: 82, column: 20, scope: !3078)
!3080 = !DILocation(line: 82, column: 18, scope: !3078)
!3081 = !DILocation(line: 90, column: 6, scope: !3082)
!3082 = distinct !DILexicalBlock(scope: !3078, file: !63, line: 90, column: 6)
!3083 = !DILocation(line: 90, column: 22, scope: !3082)
!3084 = !DILocation(line: 90, column: 6, scope: !3078)
!3085 = !DILocation(line: 91, column: 3, scope: !3086)
!3086 = distinct !DILexicalBlock(scope: !3082, file: !63, line: 90, column: 39)
!3087 = !DILocation(line: 93, column: 2, scope: !3078)
!3088 = !DILocation(line: 94, column: 1, scope: !3078)
!3089 = distinct !DISubprogram(name: "high_timer_overflow", scope: !63, file: !63, line: 102, type: !1073, scopeLine: 103, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!3090 = !DILocation(line: 107, column: 6, scope: !3091)
!3091 = distinct !DILexicalBlock(scope: !3089, file: !63, line: 107, column: 6)
!3092 = !DILocation(line: 107, column: 26, scope: !3091)
!3093 = !DILocation(line: 107, column: 56, scope: !3091)
!3094 = !DILocation(line: 107, column: 22, scope: !3091)
!3095 = !DILocation(line: 107, column: 6, scope: !3089)
!3096 = !DILocation(line: 109, column: 3, scope: !3097)
!3097 = distinct !DILexicalBlock(scope: !3091, file: !63, line: 108, column: 39)
!3098 = !DILocation(line: 111, column: 2, scope: !3089)
!3099 = !DILocation(line: 112, column: 1, scope: !3089)
!3100 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !569, retainedNodes: !609)
!3101 = !DILocation(line: 72, column: 18, scope: !3100)
!3102 = !DILocation(line: 74, column: 2, scope: !3100)
!3103 = !DILocation(line: 75, column: 20, scope: !3100)
!3104 = !DILocation(line: 75, column: 18, scope: !3100)
!3105 = !DILocation(line: 76, column: 1, scope: !3100)
!3106 = distinct !DISubprogram(name: "piperecvtask", scope: !3107, file: !3107, line: 33, type: !206, scopeLine: 34, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !581, retainedNodes: !609)
!3107 = !DIFile(filename: "appl/Zephyr/app_kernel/src/pipe_r.c", directory: "/home/kenny/ara")
!3108 = !DILocalVariable(name: "getsize", scope: !3106, file: !3107, line: 35, type: !61)
!3109 = !DILocation(line: 35, column: 6, scope: !3106)
!3110 = !DILocalVariable(name: "gettime", scope: !3106, file: !3107, line: 36, type: !59)
!3111 = !DILocation(line: 36, column: 15, scope: !3106)
!3112 = !DILocalVariable(name: "getcount", scope: !3106, file: !3107, line: 37, type: !61)
!3113 = !DILocation(line: 37, column: 6, scope: !3106)
!3114 = !DILocalVariable(name: "pipe", scope: !3106, file: !3107, line: 38, type: !61)
!3115 = !DILocation(line: 38, column: 6, scope: !3106)
!3116 = !DILocalVariable(name: "prio", scope: !3106, file: !3107, line: 39, type: !61)
!3117 = !DILocation(line: 39, column: 6, scope: !3106)
!3118 = !DILocalVariable(name: "getinfo", scope: !3106, file: !3107, line: 40, type: !3119)
!3119 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "getinfo", file: !1335, line: 18, size: 96, elements: !3120)
!3120 = !{!3121, !3122, !3123}
!3121 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !3119, file: !1335, line: 19, baseType: !61, size: 32)
!3122 = !DIDerivedType(tag: DW_TAG_member, name: "time", scope: !3119, file: !1335, line: 20, baseType: !59, size: 32, offset: 32)
!3123 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !3119, file: !1335, line: 21, baseType: !61, size: 32, offset: 64)
!3124 = !DILocation(line: 40, column: 17, scope: !3106)
!3125 = !DILocation(line: 44, column: 15, scope: !3126)
!3126 = distinct !DILexicalBlock(scope: !3106, file: !3107, line: 44, column: 2)
!3127 = !DILocation(line: 44, column: 7, scope: !3126)
!3128 = !DILocation(line: 44, column: 20, scope: !3129)
!3129 = distinct !DILexicalBlock(scope: !3126, file: !3107, line: 44, column: 2)
!3130 = !DILocation(line: 44, column: 28, scope: !3129)
!3131 = !DILocation(line: 44, column: 2, scope: !3126)
!3132 = !DILocation(line: 45, column: 13, scope: !3133)
!3133 = distinct !DILexicalBlock(scope: !3134, file: !3107, line: 45, column: 3)
!3134 = distinct !DILexicalBlock(scope: !3129, file: !3107, line: 44, column: 65)
!3135 = !DILocation(line: 45, column: 8, scope: !3133)
!3136 = !DILocation(line: 45, column: 18, scope: !3137)
!3137 = distinct !DILexicalBlock(scope: !3133, file: !3107, line: 45, column: 3)
!3138 = !DILocation(line: 45, column: 23, scope: !3137)
!3139 = !DILocation(line: 45, column: 3, scope: !3133)
!3140 = !DILocation(line: 46, column: 13, scope: !3141)
!3141 = distinct !DILexicalBlock(scope: !3137, file: !3107, line: 45, column: 36)
!3142 = !DILocation(line: 47, column: 23, scope: !3141)
!3143 = !DILocation(line: 47, column: 12, scope: !3141)
!3144 = !DILocation(line: 47, column: 38, scope: !3141)
!3145 = !DILocation(line: 48, column: 5, scope: !3141)
!3146 = !DILocation(line: 47, column: 4, scope: !3141)
!3147 = !DILocation(line: 49, column: 19, scope: !3141)
!3148 = !DILocation(line: 49, column: 12, scope: !3141)
!3149 = !DILocation(line: 49, column: 17, scope: !3141)
!3150 = !DILocation(line: 50, column: 19, scope: !3141)
!3151 = !DILocation(line: 50, column: 12, scope: !3141)
!3152 = !DILocation(line: 50, column: 17, scope: !3141)
!3153 = !DILocation(line: 51, column: 20, scope: !3141)
!3154 = !DILocation(line: 51, column: 12, scope: !3141)
!3155 = !DILocation(line: 51, column: 18, scope: !3141)
!3156 = !DILocation(line: 53, column: 25, scope: !3141)
!3157 = !DILocation(line: 53, column: 35, scope: !3141)
!3158 = !DILocation(line: 53, column: 4, scope: !3141)
!3159 = !DILocation(line: 54, column: 3, scope: !3141)
!3160 = !DILocation(line: 45, column: 32, scope: !3137)
!3161 = !DILocation(line: 45, column: 3, scope: !3137)
!3162 = distinct !{!3162, !3139, !3163}
!3163 = !DILocation(line: 54, column: 3, scope: !3133)
!3164 = !DILocation(line: 55, column: 2, scope: !3134)
!3165 = !DILocation(line: 44, column: 58, scope: !3129)
!3166 = !DILocation(line: 44, column: 2, scope: !3129)
!3167 = distinct !{!3167, !3131, !3168}
!3168 = !DILocation(line: 55, column: 2, scope: !3126)
!3169 = !DILocation(line: 57, column: 12, scope: !3170)
!3170 = distinct !DILexicalBlock(scope: !3106, file: !3107, line: 57, column: 2)
!3171 = !DILocation(line: 57, column: 7, scope: !3170)
!3172 = !DILocation(line: 57, column: 17, scope: !3173)
!3173 = distinct !DILexicalBlock(scope: !3170, file: !3107, line: 57, column: 2)
!3174 = !DILocation(line: 57, column: 22, scope: !3173)
!3175 = !DILocation(line: 57, column: 2, scope: !3170)
!3176 = !DILocation(line: 59, column: 15, scope: !3177)
!3177 = distinct !DILexicalBlock(scope: !3178, file: !3107, line: 59, column: 2)
!3178 = distinct !DILexicalBlock(scope: !3173, file: !3107, line: 57, column: 35)
!3179 = !DILocation(line: 59, column: 7, scope: !3177)
!3180 = !DILocation(line: 59, column: 38, scope: !3181)
!3181 = distinct !DILexicalBlock(scope: !3177, file: !3107, line: 59, column: 2)
!3182 = !DILocation(line: 59, column: 46, scope: !3181)
!3183 = !DILocation(line: 59, column: 2, scope: !3177)
!3184 = !DILocation(line: 60, column: 34, scope: !3185)
!3185 = distinct !DILexicalBlock(scope: !3181, file: !3107, line: 59, column: 67)
!3186 = !DILocation(line: 60, column: 32, scope: !3185)
!3187 = !DILocation(line: 60, column: 12, scope: !3185)
!3188 = !DILocation(line: 61, column: 13, scope: !3189)
!3189 = distinct !DILexicalBlock(scope: !3185, file: !3107, line: 61, column: 3)
!3190 = !DILocation(line: 61, column: 8, scope: !3189)
!3191 = !DILocation(line: 61, column: 18, scope: !3192)
!3192 = distinct !DILexicalBlock(scope: !3189, file: !3107, line: 61, column: 3)
!3193 = !DILocation(line: 61, column: 23, scope: !3192)
!3194 = !DILocation(line: 61, column: 3, scope: !3189)
!3195 = !DILocation(line: 63, column: 23, scope: !3196)
!3196 = distinct !DILexicalBlock(scope: !3192, file: !3107, line: 61, column: 36)
!3197 = !DILocation(line: 63, column: 12, scope: !3196)
!3198 = !DILocation(line: 64, column: 6, scope: !3196)
!3199 = !DILocation(line: 64, column: 15, scope: !3196)
!3200 = !DILocation(line: 63, column: 4, scope: !3196)
!3201 = !DILocation(line: 65, column: 19, scope: !3196)
!3202 = !DILocation(line: 65, column: 12, scope: !3196)
!3203 = !DILocation(line: 65, column: 17, scope: !3196)
!3204 = !DILocation(line: 66, column: 19, scope: !3196)
!3205 = !DILocation(line: 66, column: 12, scope: !3196)
!3206 = !DILocation(line: 66, column: 17, scope: !3196)
!3207 = !DILocation(line: 67, column: 20, scope: !3196)
!3208 = !DILocation(line: 67, column: 12, scope: !3196)
!3209 = !DILocation(line: 67, column: 18, scope: !3196)
!3210 = !DILocation(line: 69, column: 25, scope: !3196)
!3211 = !DILocation(line: 69, column: 35, scope: !3196)
!3212 = !DILocation(line: 69, column: 4, scope: !3196)
!3213 = !DILocation(line: 70, column: 3, scope: !3196)
!3214 = !DILocation(line: 61, column: 32, scope: !3192)
!3215 = !DILocation(line: 61, column: 3, scope: !3192)
!3216 = distinct !{!3216, !3194, !3217}
!3217 = !DILocation(line: 70, column: 3, scope: !3189)
!3218 = !DILocation(line: 71, column: 2, scope: !3185)
!3219 = !DILocation(line: 59, column: 60, scope: !3181)
!3220 = !DILocation(line: 59, column: 2, scope: !3181)
!3221 = distinct !{!3221, !3183, !3222}
!3222 = !DILocation(line: 71, column: 2, scope: !3177)
!3223 = !DILocation(line: 72, column: 2, scope: !3178)
!3224 = !DILocation(line: 57, column: 31, scope: !3173)
!3225 = !DILocation(line: 57, column: 2, scope: !3173)
!3226 = distinct !{!3226, !3175, !3227}
!3227 = !DILocation(line: 72, column: 2, scope: !3170)
!3228 = !DILocation(line: 74, column: 1, scope: !3106)
!3229 = distinct !DISubprogram(name: "pipeget", scope: !3107, file: !3107, line: 89, type: !3230, scopeLine: 91, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !581, retainedNodes: !609)
!3230 = !DISubroutineType(types: !3231)
!3231 = !{!61, !3232, !572, !61, !61, !1579}
!3232 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3233, size: 32)
!3233 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_pipe", file: !6, line: 4324, size: 352, elements: !3234)
!3234 = !{!3235, !3236, !3237, !3238, !3239, !3240, !3244, !3267}
!3235 = !DIDerivedType(tag: DW_TAG_member, name: "buffer", scope: !3233, file: !6, line: 4325, baseType: !261, size: 32)
!3236 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !3233, file: !6, line: 4326, baseType: !79, size: 32, offset: 32)
!3237 = !DIDerivedType(tag: DW_TAG_member, name: "bytes_used", scope: !3233, file: !6, line: 4327, baseType: !79, size: 32, offset: 64)
!3238 = !DIDerivedType(tag: DW_TAG_member, name: "read_index", scope: !3233, file: !6, line: 4328, baseType: !79, size: 32, offset: 96)
!3239 = !DIDerivedType(tag: DW_TAG_member, name: "write_index", scope: !3233, file: !6, line: 4329, baseType: !79, size: 32, offset: 128)
!3240 = !DIDerivedType(tag: DW_TAG_member, name: "lock", scope: !3233, file: !6, line: 4330, baseType: !3241, size: 32, offset: 160)
!3241 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "k_spinlock", file: !99, line: 234, size: 32, elements: !3242)
!3242 = !{!3243}
!3243 = !DIDerivedType(tag: DW_TAG_member, name: "thread_cpu", scope: !3241, file: !99, line: 243, baseType: !134, size: 32)
!3244 = !DIDerivedType(tag: DW_TAG_member, name: "wait_q", scope: !3233, file: !6, line: 4335, baseType: !3245, size: 128, offset: 192)
!3245 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !3233, file: !6, line: 4332, size: 128, elements: !3246)
!3246 = !{!3247, !3266}
!3247 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !3245, file: !6, line: 4333, baseType: !3248, size: 64)
!3248 = !DIDerivedType(tag: DW_TAG_typedef, name: "_wait_q_t", file: !99, line: 210, baseType: !3249)
!3249 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !99, line: 208, size: 64, elements: !3250)
!3250 = !{!3251}
!3251 = !DIDerivedType(tag: DW_TAG_member, name: "waitq", scope: !3249, file: !99, line: 209, baseType: !3252, size: 64)
!3252 = !DIDerivedType(tag: DW_TAG_typedef, name: "sys_dlist_t", file: !116, line: 42, baseType: !3253)
!3253 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_dnode", file: !116, line: 31, size: 64, elements: !3254)
!3254 = !{!3255, !3261}
!3255 = !DIDerivedType(tag: DW_TAG_member, scope: !3253, file: !116, line: 32, baseType: !3256, size: 32)
!3256 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !3253, file: !116, line: 32, size: 32, elements: !3257)
!3257 = !{!3258, !3260}
!3258 = !DIDerivedType(tag: DW_TAG_member, name: "head", scope: !3256, file: !116, line: 33, baseType: !3259, size: 32)
!3259 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3253, size: 32)
!3260 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !3256, file: !116, line: 34, baseType: !3259, size: 32)
!3261 = !DIDerivedType(tag: DW_TAG_member, scope: !3253, file: !116, line: 36, baseType: !3262, size: 32, offset: 32)
!3262 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !3253, file: !116, line: 36, size: 32, elements: !3263)
!3263 = !{!3264, !3265}
!3264 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !3262, file: !116, line: 37, baseType: !3259, size: 32)
!3265 = !DIDerivedType(tag: DW_TAG_member, name: "prev", scope: !3262, file: !116, line: 38, baseType: !3259, size: 32)
!3266 = !DIDerivedType(tag: DW_TAG_member, name: "writers", scope: !3245, file: !6, line: 4334, baseType: !3248, size: 64, offset: 64)
!3267 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !3233, file: !6, line: 4339, baseType: !161, size: 8, offset: 320)
!3268 = !DILocalVariable(name: "pipe", arg: 1, scope: !3229, file: !3107, line: 89, type: !3232)
!3269 = !DILocation(line: 89, column: 28, scope: !3229)
!3270 = !DILocalVariable(name: "option", arg: 2, scope: !3229, file: !3107, line: 89, type: !572)
!3271 = !DILocation(line: 89, column: 52, scope: !3229)
!3272 = !DILocalVariable(name: "size", arg: 3, scope: !3229, file: !3107, line: 89, type: !61)
!3273 = !DILocation(line: 89, column: 64, scope: !3229)
!3274 = !DILocalVariable(name: "count", arg: 4, scope: !3229, file: !3107, line: 89, type: !61)
!3275 = !DILocation(line: 89, column: 74, scope: !3229)
!3276 = !DILocalVariable(name: "time", arg: 5, scope: !3229, file: !3107, line: 90, type: !1579)
!3277 = !DILocation(line: 90, column: 18, scope: !3229)
!3278 = !DILocalVariable(name: "i", scope: !3229, file: !3107, line: 92, type: !61)
!3279 = !DILocation(line: 92, column: 6, scope: !3229)
!3280 = !DILocalVariable(name: "t", scope: !3229, file: !3107, line: 93, type: !59)
!3281 = !DILocation(line: 93, column: 15, scope: !3229)
!3282 = !DILocalVariable(name: "sizexferd_total", scope: !3229, file: !3107, line: 94, type: !79)
!3283 = !DILocation(line: 94, column: 9, scope: !3229)
!3284 = !DILocalVariable(name: "size2xfer_total", scope: !3229, file: !3107, line: 95, type: !79)
!3285 = !DILocation(line: 95, column: 9, scope: !3229)
!3286 = !DILocation(line: 95, column: 27, scope: !3229)
!3287 = !DILocation(line: 95, column: 34, scope: !3229)
!3288 = !DILocation(line: 95, column: 32, scope: !3229)
!3289 = !DILocation(line: 98, column: 20, scope: !3229)
!3290 = !DILocation(line: 98, column: 2, scope: !3229)
!3291 = !DILocation(line: 99, column: 6, scope: !3229)
!3292 = !DILocation(line: 99, column: 4, scope: !3229)
!3293 = !DILocation(line: 100, column: 9, scope: !3294)
!3294 = distinct !DILexicalBlock(scope: !3229, file: !3107, line: 100, column: 2)
!3295 = !DILocation(line: 100, column: 7, scope: !3294)
!3296 = !DILocation(line: 100, column: 14, scope: !3297)
!3297 = distinct !DILexicalBlock(scope: !3294, file: !3107, line: 100, column: 2)
!3298 = !DILocation(line: 100, column: 21, scope: !3297)
!3299 = !DILocation(line: 100, column: 32, scope: !3297)
!3300 = !DILocation(line: 100, column: 36, scope: !3297)
!3301 = !DILocation(line: 100, column: 40, scope: !3297)
!3302 = !DILocation(line: 100, column: 38, scope: !3297)
!3303 = !DILocation(line: 100, column: 2, scope: !3294)
!3304 = !DILocalVariable(name: "sizexferd", scope: !3305, file: !3107, line: 101, type: !79)
!3305 = distinct !DILexicalBlock(scope: !3297, file: !3107, line: 100, column: 53)
!3306 = !DILocation(line: 101, column: 10, scope: !3305)
!3307 = !DILocalVariable(name: "size2xfer", scope: !3305, file: !3107, line: 102, type: !79)
!3308 = !DILocation(line: 102, column: 10, scope: !3305)
!3309 = !DILocation(line: 102, column: 22, scope: !3305)
!3310 = !DILocalVariable(name: "ret", scope: !3305, file: !3107, line: 103, type: !61)
!3311 = !DILocation(line: 103, column: 7, scope: !3305)
!3312 = !DILocation(line: 105, column: 20, scope: !3305)
!3313 = !DILocation(line: 105, column: 37, scope: !3305)
!3314 = !DILocation(line: 106, column: 18, scope: !3305)
!3315 = !DILocation(line: 106, column: 26, scope: !3305)
!3316 = !DILocation(line: 105, column: 9, scope: !3305)
!3317 = !DILocation(line: 105, column: 7, scope: !3305)
!3318 = !DILocation(line: 108, column: 7, scope: !3319)
!3319 = distinct !DILexicalBlock(scope: !3305, file: !3107, line: 108, column: 7)
!3320 = !DILocation(line: 108, column: 11, scope: !3319)
!3321 = !DILocation(line: 108, column: 7, scope: !3305)
!3322 = !DILocation(line: 109, column: 4, scope: !3323)
!3323 = distinct !DILexicalBlock(scope: !3319, file: !3107, line: 108, column: 17)
!3324 = !DILocation(line: 112, column: 7, scope: !3325)
!3325 = distinct !DILexicalBlock(scope: !3305, file: !3107, line: 112, column: 7)
!3326 = !DILocation(line: 112, column: 14, scope: !3325)
!3327 = !DILocation(line: 112, column: 25, scope: !3325)
!3328 = !DILocation(line: 112, column: 28, scope: !3325)
!3329 = !DILocation(line: 112, column: 41, scope: !3325)
!3330 = !DILocation(line: 112, column: 38, scope: !3325)
!3331 = !DILocation(line: 112, column: 7, scope: !3305)
!3332 = !DILocation(line: 113, column: 4, scope: !3333)
!3333 = distinct !DILexicalBlock(scope: !3325, file: !3107, line: 112, column: 52)
!3334 = !DILocation(line: 116, column: 22, scope: !3305)
!3335 = !DILocation(line: 116, column: 19, scope: !3305)
!3336 = !DILocation(line: 117, column: 7, scope: !3337)
!3337 = distinct !DILexicalBlock(scope: !3305, file: !3107, line: 117, column: 7)
!3338 = !DILocation(line: 117, column: 26, scope: !3337)
!3339 = !DILocation(line: 117, column: 23, scope: !3337)
!3340 = !DILocation(line: 117, column: 7, scope: !3305)
!3341 = !DILocation(line: 118, column: 4, scope: !3342)
!3342 = distinct !DILexicalBlock(scope: !3337, file: !3107, line: 117, column: 43)
!3343 = !DILocation(line: 121, column: 7, scope: !3344)
!3344 = distinct !DILexicalBlock(scope: !3305, file: !3107, line: 121, column: 7)
!3345 = !DILocation(line: 121, column: 25, scope: !3344)
!3346 = !DILocation(line: 121, column: 23, scope: !3344)
!3347 = !DILocation(line: 121, column: 7, scope: !3305)
!3348 = !DILocation(line: 122, column: 4, scope: !3349)
!3349 = distinct !DILexicalBlock(scope: !3344, file: !3107, line: 121, column: 42)
!3350 = !DILocation(line: 124, column: 2, scope: !3305)
!3351 = !DILocation(line: 100, column: 49, scope: !3297)
!3352 = !DILocation(line: 100, column: 2, scope: !3297)
!3353 = distinct !{!3353, !3303, !3354}
!3354 = !DILocation(line: 124, column: 2, scope: !3294)
!3355 = !DILocation(line: 126, column: 27, scope: !3229)
!3356 = !DILocation(line: 126, column: 6, scope: !3229)
!3357 = !DILocation(line: 126, column: 4, scope: !3229)
!3358 = !DILocation(line: 127, column: 10, scope: !3229)
!3359 = !DILocation(line: 127, column: 3, scope: !3229)
!3360 = !DILocation(line: 127, column: 8, scope: !3229)
!3361 = !DILocation(line: 128, column: 6, scope: !3362)
!3362 = distinct !DILexicalBlock(scope: !3229, file: !3107, line: 128, column: 6)
!3363 = !DILocation(line: 128, column: 23, scope: !3362)
!3364 = !DILocation(line: 128, column: 6, scope: !3229)
!3365 = !DILocation(line: 129, column: 7, scope: !3366)
!3366 = distinct !DILexicalBlock(scope: !3367, file: !3107, line: 129, column: 7)
!3367 = distinct !DILexicalBlock(scope: !3362, file: !3107, line: 128, column: 28)
!3368 = !DILocation(line: 129, column: 7, scope: !3367)
!3369 = !DILocation(line: 130, column: 4, scope: !3370)
!3370 = distinct !DILexicalBlock(scope: !3366, file: !3107, line: 129, column: 30)
!3371 = !DILocation(line: 133, column: 3, scope: !3370)
!3372 = !DILocation(line: 134, column: 4, scope: !3373)
!3373 = distinct !DILexicalBlock(scope: !3366, file: !3107, line: 133, column: 10)
!3374 = !DILocation(line: 138, column: 3, scope: !3367)
!3375 = !DILocation(line: 140, column: 2, scope: !3367)
!3376 = !DILocation(line: 141, column: 2, scope: !3229)
!3377 = !DILocation(line: 142, column: 1, scope: !3229)
!3378 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !581, retainedNodes: !609)
!3379 = !DILocalVariable(name: "et", scope: !3378, file: !573, line: 177, type: !58)
!3380 = !DILocation(line: 177, column: 11, scope: !3378)
!3381 = !DILocation(line: 179, column: 2, scope: !3378)
!3382 = !DILocation(line: 180, column: 7, scope: !3378)
!3383 = !DILocation(line: 180, column: 5, scope: !3378)
!3384 = !DILocation(line: 181, column: 9, scope: !3378)
!3385 = !DILocation(line: 181, column: 2, scope: !3378)
!3386 = distinct !DISubprogram(name: "k_pipe_get", scope: !765, file: !765, line: 944, type: !3387, scopeLine: 945, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !581, retainedNodes: !609)
!3387 = !DISubroutineType(types: !3388)
!3388 = !{!61, !3232, !60, !79, !3050, !79, !3389}
!3389 = !DIDerivedType(tag: DW_TAG_typedef, name: "k_timeout_t", file: !54, line: 69, baseType: !3390)
!3390 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !54, line: 67, size: 64, elements: !3391)
!3391 = !{!3392}
!3392 = !DIDerivedType(tag: DW_TAG_member, name: "ticks", scope: !3390, file: !54, line: 68, baseType: !53, size: 64)
!3393 = !DILocalVariable(name: "pipe", arg: 1, scope: !3386, file: !765, line: 944, type: !3232)
!3394 = !DILocation(line: 944, column: 64, scope: !3386)
!3395 = !DILocalVariable(name: "data", arg: 2, scope: !3386, file: !765, line: 944, type: !60)
!3396 = !DILocation(line: 944, column: 77, scope: !3386)
!3397 = !DILocalVariable(name: "bytes_to_read", arg: 3, scope: !3386, file: !765, line: 944, type: !79)
!3398 = !DILocation(line: 944, column: 90, scope: !3386)
!3399 = !DILocalVariable(name: "bytes_read", arg: 4, scope: !3386, file: !765, line: 944, type: !3050)
!3400 = !DILocation(line: 944, column: 114, scope: !3386)
!3401 = !DILocalVariable(name: "min_xfer", arg: 5, scope: !3386, file: !765, line: 944, type: !79)
!3402 = !DILocation(line: 944, column: 133, scope: !3386)
!3403 = !DILocalVariable(name: "timeout", arg: 6, scope: !3386, file: !765, line: 944, type: !3389)
!3404 = !DILocation(line: 944, column: 155, scope: !3386)
!3405 = !DILocation(line: 957, column: 2, scope: !3386)
!3406 = !DILocation(line: 957, column: 2, scope: !3407)
!3407 = distinct !DILexicalBlock(scope: !3386, file: !765, line: 957, column: 2)
!3408 = !{i32 -2141850296}
!3409 = !DILocation(line: 958, column: 27, scope: !3386)
!3410 = !DILocation(line: 958, column: 33, scope: !3386)
!3411 = !DILocation(line: 958, column: 39, scope: !3386)
!3412 = !DILocation(line: 958, column: 54, scope: !3386)
!3413 = !DILocation(line: 958, column: 66, scope: !3386)
!3414 = !DILocation(line: 958, column: 9, scope: !3386)
!3415 = !DILocation(line: 958, column: 2, scope: !3386)
!3416 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !581, retainedNodes: !609)
!3417 = !DILocation(line: 82, column: 20, scope: !3416)
!3418 = !DILocation(line: 82, column: 18, scope: !3416)
!3419 = !DILocation(line: 90, column: 6, scope: !3420)
!3420 = distinct !DILexicalBlock(scope: !3416, file: !63, line: 90, column: 6)
!3421 = !DILocation(line: 90, column: 22, scope: !3420)
!3422 = !DILocation(line: 90, column: 6, scope: !3416)
!3423 = !DILocation(line: 91, column: 3, scope: !3424)
!3424 = distinct !DILexicalBlock(scope: !3420, file: !63, line: 90, column: 39)
!3425 = !DILocation(line: 93, column: 2, scope: !3416)
!3426 = !DILocation(line: 94, column: 1, scope: !3416)
!3427 = distinct !DISubprogram(name: "high_timer_overflow", scope: !63, file: !63, line: 102, type: !1073, scopeLine: 103, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !581, retainedNodes: !609)
!3428 = !DILocation(line: 107, column: 6, scope: !3429)
!3429 = distinct !DILexicalBlock(scope: !3427, file: !63, line: 107, column: 6)
!3430 = !DILocation(line: 107, column: 26, scope: !3429)
!3431 = !DILocation(line: 107, column: 56, scope: !3429)
!3432 = !DILocation(line: 107, column: 22, scope: !3429)
!3433 = !DILocation(line: 107, column: 6, scope: !3427)
!3434 = !DILocation(line: 109, column: 3, scope: !3435)
!3435 = distinct !DILexicalBlock(scope: !3429, file: !63, line: 108, column: 39)
!3436 = !DILocation(line: 111, column: 2, scope: !3427)
!3437 = !DILocation(line: 112, column: 1, scope: !3427)
!3438 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !581, retainedNodes: !609)
!3439 = !DILocation(line: 72, column: 18, scope: !3438)
!3440 = !DILocation(line: 74, column: 2, scope: !3438)
!3441 = !DILocation(line: 75, column: 20, scope: !3438)
!3442 = !DILocation(line: 75, column: 18, scope: !3438)
!3443 = !DILocation(line: 76, column: 1, scope: !3438)
!3444 = distinct !DISubprogram(name: "recvtask", scope: !590, file: !590, line: 33, type: !404, scopeLine: 34, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !586, retainedNodes: !609)
!3445 = !DILocalVariable(name: "p1", arg: 1, scope: !3444, file: !590, line: 33, type: !60)
!3446 = !DILocation(line: 33, column: 21, scope: !3444)
!3447 = !DILocalVariable(name: "p2", arg: 2, scope: !3444, file: !590, line: 33, type: !60)
!3448 = !DILocation(line: 33, column: 31, scope: !3444)
!3449 = !DILocalVariable(name: "p3", arg: 3, scope: !3444, file: !590, line: 33, type: !60)
!3450 = !DILocation(line: 33, column: 41, scope: !3444)
!3451 = !DILocation(line: 37, column: 24, scope: !3444)
!3452 = !DILocation(line: 37, column: 2, scope: !3444)
!3453 = !DILocation(line: 38, column: 2, scope: !3444)
!3454 = !DILocation(line: 41, column: 24, scope: !3444)
!3455 = !DILocation(line: 41, column: 2, scope: !3444)
!3456 = !DILocation(line: 42, column: 2, scope: !3444)
!3457 = !DILocation(line: 45, column: 24, scope: !3444)
!3458 = !DILocation(line: 45, column: 2, scope: !3444)
!3459 = !DILocation(line: 46, column: 2, scope: !3444)
!3460 = !DILocation(line: 49, column: 24, scope: !3444)
!3461 = !DILocation(line: 49, column: 2, scope: !3444)
!3462 = !DILocation(line: 50, column: 2, scope: !3444)
!3463 = !DILocation(line: 52, column: 1, scope: !3444)
!3464 = distinct !DISubprogram(name: "sema_test", scope: !3465, file: !3465, line: 20, type: !206, scopeLine: 21, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !593, retainedNodes: !609)
!3465 = !DIFile(filename: "appl/Zephyr/app_kernel/src/sema_b.c", directory: "/home/kenny/ara")
!3466 = !DILocalVariable(name: "et", scope: !3464, file: !3465, line: 22, type: !58)
!3467 = !DILocation(line: 22, column: 11, scope: !3464)
!3468 = !DILocalVariable(name: "i", scope: !3464, file: !3465, line: 23, type: !61)
!3469 = !DILocation(line: 23, column: 6, scope: !3464)
!3470 = !DILocation(line: 25, column: 2, scope: !3464)
!3471 = !DILocation(line: 26, column: 7, scope: !3464)
!3472 = !DILocation(line: 26, column: 5, scope: !3464)
!3473 = !DILocation(line: 27, column: 9, scope: !3474)
!3474 = distinct !DILexicalBlock(scope: !3464, file: !3465, line: 27, column: 2)
!3475 = !DILocation(line: 27, column: 7, scope: !3474)
!3476 = !DILocation(line: 27, column: 14, scope: !3477)
!3477 = distinct !DILexicalBlock(scope: !3474, file: !3465, line: 27, column: 2)
!3478 = !DILocation(line: 27, column: 16, scope: !3477)
!3479 = !DILocation(line: 27, column: 2, scope: !3474)
!3480 = !DILocation(line: 28, column: 4, scope: !3481)
!3481 = distinct !DILexicalBlock(scope: !3477, file: !3465, line: 27, column: 40)
!3482 = !DILocation(line: 29, column: 2, scope: !3481)
!3483 = !DILocation(line: 27, column: 36, scope: !3477)
!3484 = !DILocation(line: 27, column: 2, scope: !3477)
!3485 = distinct !{!3485, !3479, !3486}
!3486 = !DILocation(line: 29, column: 2, scope: !3474)
!3487 = !DILocation(line: 30, column: 28, scope: !3464)
!3488 = !DILocation(line: 30, column: 7, scope: !3464)
!3489 = !DILocation(line: 30, column: 5, scope: !3464)
!3490 = !DILocation(line: 31, column: 2, scope: !3464)
!3491 = !DILocation(line: 33, column: 2, scope: !3492)
!3492 = distinct !DILexicalBlock(scope: !3464, file: !3465, line: 33, column: 2)
!3493 = !DILocation(line: 36, column: 2, scope: !3464)
!3494 = !DILocation(line: 37, column: 2, scope: !3464)
!3495 = !DILocation(line: 39, column: 7, scope: !3464)
!3496 = !DILocation(line: 39, column: 5, scope: !3464)
!3497 = !DILocation(line: 40, column: 9, scope: !3498)
!3498 = distinct !DILexicalBlock(scope: !3464, file: !3465, line: 40, column: 2)
!3499 = !DILocation(line: 40, column: 7, scope: !3498)
!3500 = !DILocation(line: 40, column: 14, scope: !3501)
!3501 = distinct !DILexicalBlock(scope: !3498, file: !3465, line: 40, column: 2)
!3502 = !DILocation(line: 40, column: 16, scope: !3501)
!3503 = !DILocation(line: 40, column: 2, scope: !3498)
!3504 = !DILocation(line: 41, column: 3, scope: !3505)
!3505 = distinct !DILexicalBlock(scope: !3501, file: !3465, line: 40, column: 40)
!3506 = !DILocation(line: 42, column: 2, scope: !3505)
!3507 = !DILocation(line: 40, column: 36, scope: !3501)
!3508 = !DILocation(line: 40, column: 2, scope: !3501)
!3509 = distinct !{!3509, !3503, !3510}
!3510 = !DILocation(line: 42, column: 2, scope: !3498)
!3511 = !DILocation(line: 43, column: 28, scope: !3464)
!3512 = !DILocation(line: 43, column: 7, scope: !3464)
!3513 = !DILocation(line: 43, column: 5, scope: !3464)
!3514 = !DILocation(line: 44, column: 2, scope: !3464)
!3515 = !DILocation(line: 46, column: 2, scope: !3516)
!3516 = distinct !DILexicalBlock(scope: !3464, file: !3465, line: 46, column: 2)
!3517 = !DILocation(line: 49, column: 7, scope: !3464)
!3518 = !DILocation(line: 49, column: 5, scope: !3464)
!3519 = !DILocation(line: 50, column: 9, scope: !3520)
!3520 = distinct !DILexicalBlock(scope: !3464, file: !3465, line: 50, column: 2)
!3521 = !DILocation(line: 50, column: 7, scope: !3520)
!3522 = !DILocation(line: 50, column: 14, scope: !3523)
!3523 = distinct !DILexicalBlock(scope: !3520, file: !3465, line: 50, column: 2)
!3524 = !DILocation(line: 50, column: 16, scope: !3523)
!3525 = !DILocation(line: 50, column: 2, scope: !3520)
!3526 = !DILocation(line: 51, column: 3, scope: !3527)
!3527 = distinct !DILexicalBlock(scope: !3523, file: !3465, line: 50, column: 40)
!3528 = !DILocation(line: 52, column: 2, scope: !3527)
!3529 = !DILocation(line: 50, column: 36, scope: !3523)
!3530 = !DILocation(line: 50, column: 2, scope: !3523)
!3531 = distinct !{!3531, !3525, !3532}
!3532 = !DILocation(line: 52, column: 2, scope: !3520)
!3533 = !DILocation(line: 53, column: 28, scope: !3464)
!3534 = !DILocation(line: 53, column: 7, scope: !3464)
!3535 = !DILocation(line: 53, column: 5, scope: !3464)
!3536 = !DILocation(line: 54, column: 2, scope: !3464)
!3537 = !DILocation(line: 56, column: 2, scope: !3538)
!3538 = distinct !DILexicalBlock(scope: !3464, file: !3465, line: 56, column: 2)
!3539 = !DILocation(line: 60, column: 1, scope: !3464)
!3540 = distinct !DISubprogram(name: "BENCH_START", scope: !573, file: !573, line: 175, type: !755, scopeLine: 176, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !593, retainedNodes: !609)
!3541 = !DILocalVariable(name: "et", scope: !3540, file: !573, line: 177, type: !58)
!3542 = !DILocation(line: 177, column: 11, scope: !3540)
!3543 = !DILocation(line: 179, column: 2, scope: !3540)
!3544 = !DILocation(line: 180, column: 7, scope: !3540)
!3545 = !DILocation(line: 180, column: 5, scope: !3540)
!3546 = !DILocation(line: 181, column: 9, scope: !3540)
!3547 = !DILocation(line: 181, column: 2, scope: !3540)
!3548 = distinct !DISubprogram(name: "check_result", scope: !573, file: !573, line: 184, type: !206, scopeLine: 185, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !593, retainedNodes: !609)
!3549 = !DILocation(line: 186, column: 6, scope: !3550)
!3550 = distinct !DILexicalBlock(scope: !3548, file: !573, line: 186, column: 6)
!3551 = !DILocation(line: 186, column: 23, scope: !3550)
!3552 = !DILocation(line: 186, column: 6, scope: !3548)
!3553 = !DILocation(line: 187, column: 3, scope: !3554)
!3554 = distinct !DILexicalBlock(scope: !3555, file: !573, line: 187, column: 3)
!3555 = distinct !DILexicalBlock(scope: !3550, file: !573, line: 186, column: 28)
!3556 = !DILocation(line: 188, column: 3, scope: !3555)
!3557 = !DILocation(line: 190, column: 1, scope: !3548)
!3558 = distinct !DISubprogram(name: "bench_test_end", scope: !63, file: !63, line: 80, type: !1073, scopeLine: 81, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !593, retainedNodes: !609)
!3559 = !DILocation(line: 82, column: 20, scope: !3558)
!3560 = !DILocation(line: 82, column: 18, scope: !3558)
!3561 = !DILocation(line: 90, column: 6, scope: !3562)
!3562 = distinct !DILexicalBlock(scope: !3558, file: !63, line: 90, column: 6)
!3563 = !DILocation(line: 90, column: 22, scope: !3562)
!3564 = !DILocation(line: 90, column: 6, scope: !3558)
!3565 = !DILocation(line: 91, column: 3, scope: !3566)
!3566 = distinct !DILexicalBlock(scope: !3562, file: !63, line: 90, column: 39)
!3567 = !DILocation(line: 93, column: 2, scope: !3558)
!3568 = !DILocation(line: 94, column: 1, scope: !3558)
!3569 = distinct !DISubprogram(name: "bench_test_start", scope: !63, file: !63, line: 70, type: !206, scopeLine: 71, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !593, retainedNodes: !609)
!3570 = !DILocation(line: 72, column: 18, scope: !3569)
!3571 = !DILocation(line: 74, column: 2, scope: !3569)
!3572 = !DILocation(line: 75, column: 20, scope: !3569)
!3573 = !DILocation(line: 75, column: 18, scope: !3569)
!3574 = !DILocation(line: 76, column: 1, scope: !3569)
!3575 = distinct !DISubprogram(name: "waittask", scope: !3576, file: !3576, line: 22, type: !206, scopeLine: 23, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !599, retainedNodes: !609)
!3576 = !DIFile(filename: "appl/Zephyr/app_kernel/src/sema_r.c", directory: "/home/kenny/ara")
!3577 = !DILocalVariable(name: "i", scope: !3575, file: !3576, line: 24, type: !61)
!3578 = !DILocation(line: 24, column: 6, scope: !3575)
!3579 = !DILocation(line: 26, column: 9, scope: !3580)
!3580 = distinct !DILexicalBlock(scope: !3575, file: !3576, line: 26, column: 2)
!3581 = !DILocation(line: 26, column: 7, scope: !3580)
!3582 = !DILocation(line: 26, column: 14, scope: !3583)
!3583 = distinct !DILexicalBlock(scope: !3580, file: !3576, line: 26, column: 2)
!3584 = !DILocation(line: 26, column: 16, scope: !3583)
!3585 = !DILocation(line: 26, column: 2, scope: !3580)
!3586 = !DILocation(line: 27, column: 21, scope: !3587)
!3587 = distinct !DILexicalBlock(scope: !3583, file: !3576, line: 26, column: 40)
!3588 = !DILocation(line: 27, column: 3, scope: !3587)
!3589 = !DILocation(line: 28, column: 2, scope: !3587)
!3590 = !DILocation(line: 26, column: 36, scope: !3583)
!3591 = !DILocation(line: 26, column: 2, scope: !3583)
!3592 = distinct !{!3592, !3585, !3593}
!3593 = !DILocation(line: 28, column: 2, scope: !3580)
!3594 = !DILocation(line: 29, column: 9, scope: !3595)
!3595 = distinct !DILexicalBlock(scope: !3575, file: !3576, line: 29, column: 2)
!3596 = !DILocation(line: 29, column: 7, scope: !3595)
!3597 = !DILocation(line: 29, column: 14, scope: !3598)
!3598 = distinct !DILexicalBlock(scope: !3595, file: !3576, line: 29, column: 2)
!3599 = !DILocation(line: 29, column: 16, scope: !3598)
!3600 = !DILocation(line: 29, column: 2, scope: !3595)
!3601 = !DILocation(line: 30, column: 21, scope: !3602)
!3602 = distinct !DILexicalBlock(scope: !3598, file: !3576, line: 29, column: 40)
!3603 = !DILocation(line: 30, column: 3, scope: !3602)
!3604 = !DILocation(line: 31, column: 2, scope: !3602)
!3605 = !DILocation(line: 29, column: 36, scope: !3598)
!3606 = !DILocation(line: 29, column: 2, scope: !3598)
!3607 = distinct !{!3607, !3600, !3608}
!3608 = !DILocation(line: 31, column: 2, scope: !3595)
!3609 = !DILocation(line: 33, column: 1, scope: !3575)
!3610 = distinct !DISubprogram(name: "k_ms_to_ticks_ceil64", scope: !856, file: !856, line: 369, type: !857, scopeLine: 370, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !599, retainedNodes: !609)
!3611 = !DILocalVariable(name: "t", arg: 1, scope: !3612, file: !856, line: 78, type: !69)
!3612 = distinct !DISubprogram(name: "z_tmcvt", scope: !856, file: !856, line: 78, type: !861, scopeLine: 82, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !599, retainedNodes: !609)
!3613 = !DILocation(line: 78, column: 63, scope: !3612, inlinedAt: !3614)
!3614 = distinct !DILocation(line: 372, column: 9, scope: !3610)
!3615 = !DILocalVariable(name: "from_hz", arg: 2, scope: !3612, file: !856, line: 78, type: !58)
!3616 = !DILocation(line: 78, column: 75, scope: !3612, inlinedAt: !3614)
!3617 = !DILocalVariable(name: "to_hz", arg: 3, scope: !3612, file: !856, line: 79, type: !58)
!3618 = !DILocation(line: 79, column: 18, scope: !3612, inlinedAt: !3614)
!3619 = !DILocalVariable(name: "const_hz", arg: 4, scope: !3612, file: !856, line: 79, type: !863)
!3620 = !DILocation(line: 79, column: 30, scope: !3612, inlinedAt: !3614)
!3621 = !DILocalVariable(name: "result32", arg: 5, scope: !3612, file: !856, line: 80, type: !863)
!3622 = !DILocation(line: 80, column: 14, scope: !3612, inlinedAt: !3614)
!3623 = !DILocalVariable(name: "round_up", arg: 6, scope: !3612, file: !856, line: 80, type: !863)
!3624 = !DILocation(line: 80, column: 29, scope: !3612, inlinedAt: !3614)
!3625 = !DILocalVariable(name: "round_off", arg: 7, scope: !3612, file: !856, line: 81, type: !863)
!3626 = !DILocation(line: 81, column: 14, scope: !3612, inlinedAt: !3614)
!3627 = !DILocalVariable(name: "mul_ratio", scope: !3612, file: !856, line: 84, type: !863)
!3628 = !DILocation(line: 84, column: 7, scope: !3612, inlinedAt: !3614)
!3629 = !DILocalVariable(name: "div_ratio", scope: !3612, file: !856, line: 86, type: !863)
!3630 = !DILocation(line: 86, column: 7, scope: !3612, inlinedAt: !3614)
!3631 = !DILocalVariable(name: "off", scope: !3612, file: !856, line: 93, type: !69)
!3632 = !DILocation(line: 93, column: 11, scope: !3612, inlinedAt: !3614)
!3633 = !DILocalVariable(name: "rdivisor", scope: !3634, file: !856, line: 96, type: !58)
!3634 = distinct !DILexicalBlock(scope: !3635, file: !856, line: 95, column: 18)
!3635 = distinct !DILexicalBlock(scope: !3612, file: !856, line: 95, column: 6)
!3636 = !DILocation(line: 96, column: 12, scope: !3634, inlinedAt: !3614)
!3637 = !DILocalVariable(name: "t", arg: 1, scope: !3610, file: !856, line: 369, type: !69)
!3638 = !DILocation(line: 369, column: 69, scope: !3610)
!3639 = !DILocation(line: 372, column: 17, scope: !3610)
!3640 = !DILocation(line: 84, column: 19, scope: !3612, inlinedAt: !3614)
!3641 = !DILocation(line: 84, column: 28, scope: !3612, inlinedAt: !3614)
!3642 = !DILocation(line: 85, column: 4, scope: !3612, inlinedAt: !3614)
!3643 = !DILocation(line: 85, column: 12, scope: !3612, inlinedAt: !3614)
!3644 = !DILocation(line: 85, column: 10, scope: !3612, inlinedAt: !3614)
!3645 = !DILocation(line: 85, column: 21, scope: !3612, inlinedAt: !3614)
!3646 = !DILocation(line: 85, column: 26, scope: !3612, inlinedAt: !3614)
!3647 = !DILocation(line: 85, column: 34, scope: !3612, inlinedAt: !3614)
!3648 = !DILocation(line: 85, column: 32, scope: !3612, inlinedAt: !3614)
!3649 = !DILocation(line: 85, column: 43, scope: !3612, inlinedAt: !3614)
!3650 = !DILocation(line: 0, scope: !3612, inlinedAt: !3614)
!3651 = !DILocation(line: 86, column: 19, scope: !3612, inlinedAt: !3614)
!3652 = !DILocation(line: 86, column: 28, scope: !3612, inlinedAt: !3614)
!3653 = !DILocation(line: 87, column: 4, scope: !3612, inlinedAt: !3614)
!3654 = !DILocation(line: 87, column: 14, scope: !3612, inlinedAt: !3614)
!3655 = !DILocation(line: 87, column: 12, scope: !3612, inlinedAt: !3614)
!3656 = !DILocation(line: 87, column: 21, scope: !3612, inlinedAt: !3614)
!3657 = !DILocation(line: 87, column: 26, scope: !3612, inlinedAt: !3614)
!3658 = !DILocation(line: 87, column: 36, scope: !3612, inlinedAt: !3614)
!3659 = !DILocation(line: 87, column: 34, scope: !3612, inlinedAt: !3614)
!3660 = !DILocation(line: 87, column: 43, scope: !3612, inlinedAt: !3614)
!3661 = !DILocation(line: 89, column: 6, scope: !3662, inlinedAt: !3614)
!3662 = distinct !DILexicalBlock(scope: !3612, file: !856, line: 89, column: 6)
!3663 = !DILocation(line: 89, column: 17, scope: !3662, inlinedAt: !3614)
!3664 = !DILocation(line: 89, column: 14, scope: !3662, inlinedAt: !3614)
!3665 = !DILocation(line: 89, column: 6, scope: !3612, inlinedAt: !3614)
!3666 = !DILocation(line: 90, column: 10, scope: !3667, inlinedAt: !3614)
!3667 = distinct !DILexicalBlock(scope: !3662, file: !856, line: 89, column: 24)
!3668 = !DILocation(line: 90, column: 32, scope: !3667, inlinedAt: !3614)
!3669 = !DILocation(line: 90, column: 22, scope: !3667, inlinedAt: !3614)
!3670 = !DILocation(line: 90, column: 21, scope: !3667, inlinedAt: !3614)
!3671 = !DILocation(line: 90, column: 37, scope: !3667, inlinedAt: !3614)
!3672 = !DILocation(line: 90, column: 3, scope: !3667, inlinedAt: !3614)
!3673 = !DILocation(line: 95, column: 7, scope: !3635, inlinedAt: !3614)
!3674 = !DILocation(line: 95, column: 6, scope: !3612, inlinedAt: !3614)
!3675 = !DILocation(line: 96, column: 23, scope: !3634, inlinedAt: !3614)
!3676 = !DILocation(line: 96, column: 36, scope: !3634, inlinedAt: !3614)
!3677 = !DILocation(line: 96, column: 46, scope: !3634, inlinedAt: !3614)
!3678 = !DILocation(line: 96, column: 44, scope: !3634, inlinedAt: !3614)
!3679 = !DILocation(line: 96, column: 55, scope: !3634, inlinedAt: !3614)
!3680 = !DILocation(line: 98, column: 7, scope: !3681, inlinedAt: !3614)
!3681 = distinct !DILexicalBlock(scope: !3634, file: !856, line: 98, column: 7)
!3682 = !DILocation(line: 98, column: 7, scope: !3634, inlinedAt: !3614)
!3683 = !DILocation(line: 99, column: 10, scope: !3684, inlinedAt: !3614)
!3684 = distinct !DILexicalBlock(scope: !3681, file: !856, line: 98, column: 17)
!3685 = !DILocation(line: 99, column: 19, scope: !3684, inlinedAt: !3614)
!3686 = !DILocation(line: 99, column: 8, scope: !3684, inlinedAt: !3614)
!3687 = !DILocation(line: 100, column: 3, scope: !3684, inlinedAt: !3614)
!3688 = !DILocation(line: 100, column: 14, scope: !3689, inlinedAt: !3614)
!3689 = distinct !DILexicalBlock(scope: !3681, file: !856, line: 100, column: 14)
!3690 = !DILocation(line: 100, column: 14, scope: !3681, inlinedAt: !3614)
!3691 = !DILocation(line: 101, column: 10, scope: !3692, inlinedAt: !3614)
!3692 = distinct !DILexicalBlock(scope: !3689, file: !856, line: 100, column: 25)
!3693 = !DILocation(line: 101, column: 19, scope: !3692, inlinedAt: !3614)
!3694 = !DILocation(line: 101, column: 8, scope: !3692, inlinedAt: !3614)
!3695 = !DILocation(line: 102, column: 3, scope: !3692, inlinedAt: !3614)
!3696 = !DILocation(line: 103, column: 2, scope: !3634, inlinedAt: !3614)
!3697 = !DILocation(line: 110, column: 6, scope: !3698, inlinedAt: !3614)
!3698 = distinct !DILexicalBlock(scope: !3612, file: !856, line: 110, column: 6)
!3699 = !DILocation(line: 110, column: 6, scope: !3612, inlinedAt: !3614)
!3700 = !DILocation(line: 111, column: 8, scope: !3701, inlinedAt: !3614)
!3701 = distinct !DILexicalBlock(scope: !3698, file: !856, line: 110, column: 17)
!3702 = !DILocation(line: 111, column: 5, scope: !3701, inlinedAt: !3614)
!3703 = !DILocation(line: 112, column: 7, scope: !3704, inlinedAt: !3614)
!3704 = distinct !DILexicalBlock(scope: !3701, file: !856, line: 112, column: 7)
!3705 = !DILocation(line: 112, column: 16, scope: !3704, inlinedAt: !3614)
!3706 = !DILocation(line: 112, column: 20, scope: !3704, inlinedAt: !3614)
!3707 = !DILocation(line: 112, column: 22, scope: !3704, inlinedAt: !3614)
!3708 = !DILocation(line: 112, column: 7, scope: !3701, inlinedAt: !3614)
!3709 = !DILocation(line: 113, column: 22, scope: !3710, inlinedAt: !3614)
!3710 = distinct !DILexicalBlock(scope: !3704, file: !856, line: 112, column: 36)
!3711 = !DILocation(line: 113, column: 12, scope: !3710, inlinedAt: !3614)
!3712 = !DILocation(line: 113, column: 28, scope: !3710, inlinedAt: !3614)
!3713 = !DILocation(line: 113, column: 38, scope: !3710, inlinedAt: !3614)
!3714 = !DILocation(line: 113, column: 36, scope: !3710, inlinedAt: !3614)
!3715 = !DILocation(line: 113, column: 25, scope: !3710, inlinedAt: !3614)
!3716 = !DILocation(line: 113, column: 11, scope: !3710, inlinedAt: !3614)
!3717 = !DILocation(line: 113, column: 4, scope: !3710, inlinedAt: !3614)
!3718 = !DILocation(line: 115, column: 11, scope: !3719, inlinedAt: !3614)
!3719 = distinct !DILexicalBlock(scope: !3704, file: !856, line: 114, column: 10)
!3720 = !DILocation(line: 115, column: 16, scope: !3719, inlinedAt: !3614)
!3721 = !DILocation(line: 115, column: 26, scope: !3719, inlinedAt: !3614)
!3722 = !DILocation(line: 115, column: 24, scope: !3719, inlinedAt: !3614)
!3723 = !DILocation(line: 115, column: 15, scope: !3719, inlinedAt: !3614)
!3724 = !DILocation(line: 115, column: 13, scope: !3719, inlinedAt: !3614)
!3725 = !DILocation(line: 115, column: 4, scope: !3719, inlinedAt: !3614)
!3726 = !DILocation(line: 117, column: 13, scope: !3727, inlinedAt: !3614)
!3727 = distinct !DILexicalBlock(scope: !3698, file: !856, line: 117, column: 13)
!3728 = !DILocation(line: 117, column: 13, scope: !3698, inlinedAt: !3614)
!3729 = !DILocation(line: 118, column: 7, scope: !3730, inlinedAt: !3614)
!3730 = distinct !DILexicalBlock(scope: !3731, file: !856, line: 118, column: 7)
!3731 = distinct !DILexicalBlock(scope: !3727, file: !856, line: 117, column: 24)
!3732 = !DILocation(line: 118, column: 7, scope: !3731, inlinedAt: !3614)
!3733 = !DILocation(line: 119, column: 22, scope: !3734, inlinedAt: !3614)
!3734 = distinct !DILexicalBlock(scope: !3730, file: !856, line: 118, column: 17)
!3735 = !DILocation(line: 119, column: 12, scope: !3734, inlinedAt: !3614)
!3736 = !DILocation(line: 119, column: 28, scope: !3734, inlinedAt: !3614)
!3737 = !DILocation(line: 119, column: 36, scope: !3734, inlinedAt: !3614)
!3738 = !DILocation(line: 119, column: 34, scope: !3734, inlinedAt: !3614)
!3739 = !DILocation(line: 119, column: 25, scope: !3734, inlinedAt: !3614)
!3740 = !DILocation(line: 119, column: 11, scope: !3734, inlinedAt: !3614)
!3741 = !DILocation(line: 119, column: 4, scope: !3734, inlinedAt: !3614)
!3742 = !DILocation(line: 121, column: 11, scope: !3743, inlinedAt: !3614)
!3743 = distinct !DILexicalBlock(scope: !3730, file: !856, line: 120, column: 10)
!3744 = !DILocation(line: 121, column: 16, scope: !3743, inlinedAt: !3614)
!3745 = !DILocation(line: 121, column: 24, scope: !3743, inlinedAt: !3614)
!3746 = !DILocation(line: 121, column: 22, scope: !3743, inlinedAt: !3614)
!3747 = !DILocation(line: 121, column: 15, scope: !3743, inlinedAt: !3614)
!3748 = !DILocation(line: 121, column: 13, scope: !3743, inlinedAt: !3614)
!3749 = !DILocation(line: 121, column: 4, scope: !3743, inlinedAt: !3614)
!3750 = !DILocation(line: 124, column: 7, scope: !3751, inlinedAt: !3614)
!3751 = distinct !DILexicalBlock(scope: !3752, file: !856, line: 124, column: 7)
!3752 = distinct !DILexicalBlock(scope: !3727, file: !856, line: 123, column: 9)
!3753 = !DILocation(line: 124, column: 7, scope: !3752, inlinedAt: !3614)
!3754 = !DILocation(line: 125, column: 23, scope: !3755, inlinedAt: !3614)
!3755 = distinct !DILexicalBlock(scope: !3751, file: !856, line: 124, column: 17)
!3756 = !DILocation(line: 125, column: 27, scope: !3755, inlinedAt: !3614)
!3757 = !DILocation(line: 125, column: 25, scope: !3755, inlinedAt: !3614)
!3758 = !DILocation(line: 125, column: 35, scope: !3755, inlinedAt: !3614)
!3759 = !DILocation(line: 125, column: 33, scope: !3755, inlinedAt: !3614)
!3760 = !DILocation(line: 125, column: 42, scope: !3755, inlinedAt: !3614)
!3761 = !DILocation(line: 125, column: 40, scope: !3755, inlinedAt: !3614)
!3762 = !DILocation(line: 125, column: 11, scope: !3755, inlinedAt: !3614)
!3763 = !DILocation(line: 125, column: 4, scope: !3755, inlinedAt: !3614)
!3764 = !DILocation(line: 127, column: 12, scope: !3765, inlinedAt: !3614)
!3765 = distinct !DILexicalBlock(scope: !3751, file: !856, line: 126, column: 10)
!3766 = !DILocation(line: 127, column: 16, scope: !3765, inlinedAt: !3614)
!3767 = !DILocation(line: 127, column: 14, scope: !3765, inlinedAt: !3614)
!3768 = !DILocation(line: 127, column: 24, scope: !3765, inlinedAt: !3614)
!3769 = !DILocation(line: 127, column: 22, scope: !3765, inlinedAt: !3614)
!3770 = !DILocation(line: 127, column: 31, scope: !3765, inlinedAt: !3614)
!3771 = !DILocation(line: 127, column: 29, scope: !3765, inlinedAt: !3614)
!3772 = !DILocation(line: 127, column: 4, scope: !3765, inlinedAt: !3614)
!3773 = !DILocation(line: 130, column: 1, scope: !3612, inlinedAt: !3614)
!3774 = !DILocation(line: 372, column: 2, scope: !3610)
