// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

.syntax unified

#define LOCAL_BASE 0xff800000 // Pi4 from armstub7
#define OSC_FREQ	54000000
#define ARML_PRESCALER	0x08
#define NSACR_VAL	0xc00

.section .text.startup,"ax"
.globl _start
.globl _boot
.globl _estack_os
_boot:
_start:
	// switch EL2 -> EL1
    mrs r0,cpsr

	and r1, r0, #0x1F
	cmp r1,#19 // EL1 already
	beq EL1

    bic r0,r0,#0x1F
    orr r0,r0,#0x13
    msr spsr_cxsf,r0
    add r0,pc,#4
    msr ELR_hyp,r0
    eret
EL1:
    mrc p15, 0, r9, c0, c0, 5   // cpuid to r9: will always stay there! -ffixed-r9
    and	r9, r9, #0xf            // mask

setup_sp:
	ldr sp, = _estack_os - 16
	sub sp, sp, r9, LSL #12

setup_irq:
	ldr	r2, = interrupt_vector_table
	mcr	p15, 0, r2, c12, c0, 0

setup_smp:
#ifdef QEMU
	// hack: qemu running as cortex-a7
	mrc	p15, 0, r1, c1, c0, 1		@ Read Auxiliary Control Register
	orr	r1, r1, #(1<<6)				@ Enable SMP
	mcr	p15, 0, r1, c1, c0, 1		@ Write Auxiliary Control Register
#else
	mrrc p15, 1, r1, r2, c15		@ CPU Extended Control Register
	orr	r1, r1, #(1<<6)				@ Enable SMP
	bic	r2, r2, #3					@ Set L2 load data prefetch to 0b11 = 22 requests (A72-specific)
	mcrr p15, 1, r1, r2, c15		@ CPU Extended Control Register
#endif
setup_timer:
	// from RasPi armstub7.S
	@ Initialize the architectural timer
	ldr r7, =LOCAL_BASE// Local base for RPi 4

	ldr	r1, =OSC_FREQ			@ osc = 19.2 or 54MHz
	mcr	p15, 0, r1, c14, c0, 0		@ Write CNTFRQ
	mov	r1, #0x80000000			@ Set ARM_LOCAL_TIMER_PRE_ADD to 1
	str	r1, [r7, #ARML_PRESCALER]

	bl serial_init

setup_pmu:
	# enable PMU access from userspace ELO
	mov r3, 1
	mcr p15, 0, r3, c9, c14, 0

	# activate noninvasive debug
	MRC p15, 0, r3, c1, c1, 1
	orr r3, r3, 0x2
	MCR p15, 0, r3, c1, c1, 1

    cmp	r9, #0
	beq	run
	b run_ap

run:
    bl main

    b loop0

run_ap:
	// from RasPi armstub7.S
	lsl r6, r9, #4		@ Calculate offset to mailbox register (i.e. ARML_MBOX_CLR03 + coreid*0x10)
	adds r6, r6, 0xcc //#ARML_MBOX_CLR03
0:	wfe
	ldr	r3, [r7, r6]			@ Read message (secondary kernel entrypoint)
	cmp	r3, #0				@ If zero, there is no message
	beq	0b
	str	r3, [r7, r6]			@ Clear mailbox
9:
@ Jump to kernel
	mov r0, r9 // core id as parameter
	bx	r3

loop0:
	wfe
	b	loop0
