.option norvc
.section .text.init,"ax",@progbits
.globl _start
.globl reset_vector
reset_vector:
	j do_reset

.global do_reset;
do_reset:
	li x1, 0
	li x2, 0
	li x3, 0
	li x4, 0
	li x5, 0
	li x6, 0
	li x7, 0
	li x8, 0
	li x9, 0
	// save a0 and a1; arguments from previous boot loader stage:
	//  li x10, 0
	//  li x11, 0
	li x12, 0
	li x13, 0
	li x14, 0
	li x15, 0
	li x16, 0
	li x17, 0
	li x18, 0
	li x19, 0
	li x20, 0
	li x21, 0
	li x22, 0
	li x23, 0
	li x24, 0
	li x25, 0
	li x26, 0
	li x27, 0
	li x28, 0
	li x29, 0
	li x30, 0
	li x31, 0
	csrw mscratch, x0

	# write mtvec and make sure it sticks
	la t0, trap_vector
	csrw mtvec, t0
	csrr t1, mtvec
1:	bne t0, t1, 1b

2:
	csrr a0, mhartid // read CPU ID

	// calculate offset in stack table
	li a1, 4096
	mul a1, a0, a1
	// set cpu0 stack
	la sp, os_stack + 4096 - 16
	add sp, sp, a1 // offset to correct stack

	bnez a0, ap
	jal main

.size do_reset, . - do_reset

ap:
    jal mainAP

.global idle_entry
idle_entry:
	la sp, os_stack + 4096 - 16
	jal __OS_HOOK_PreIdleHook
1:
	wfi
	j 1b
.size idle_entry, . - idle_entry

.global interrupt_handler
.global trap_vector
trap_vector:
	
	csrw mscratch, sp
	addi sp, sp, -34*8

	sd ra, 1*8(sp)
	sd gp, 3*8(sp)
	sd tp, 4*8(sp)
	sd t0, 5*8(sp)
	sd t1, 6*8(sp)
	sd t2, 7*8(sp)
	sd s0, 8*8(sp)
	sd s1, 9*8(sp)
	sd a0, 10*8(sp)
	sd a1, 11*8(sp)
	sd a2, 12*8(sp)
	sd a3, 13*8(sp)
	sd a4, 14*8(sp)
	sd a5, 15*8(sp)
	sd a6, 16*8(sp)
	sd a7, 17*8(sp)
	sd s2, 18*8(sp)
	sd s3, 19*8(sp)
	sd s4, 20*8(sp)
	sd s5, 21*8(sp)
	sd s6, 22*8(sp)
	sd s7, 23*8(sp)
	sd s8, 24*8(sp)
	sd s9, 25*8(sp)
	sd s10, 26*8(sp)
	sd s11, 27*8(sp)
	sd t3,  28*8(sp)
	sd t4,  29*8(sp)
	sd t5,  30*8(sp)
	sd t6,  31*8(sp)

	# Store the exception return address
	csrr a0, mepc
	sd a0,  32*8(sp)

		# Arguments for our interrupt handler
	csrr a1, mscratch           # ra <- user sp
	sd a1, 2*8(sp)            # sp
	csrr a0, mcause
	mv a1, sp
	jal interrupt_handler_c

	# Restore exception pointer
	ld a0, 32*8(sp)
	csrw mepc, a0

	ld ra, 1*8(sp)
	# sp is restored at end
	ld gp, 3*8(sp)
	ld tp, 4*8(sp)
	ld t0, 5*8(sp)
	ld t1, 6*8(sp)
	ld t2, 7*8(sp)
	ld s0, 8*8(sp)
	ld s1, 9*8(sp)
	ld a0, 10*8(sp)
	ld a1, 11*8(sp)
	ld a2, 12*8(sp)
	ld a3, 13*8(sp)
	ld a4, 14*8(sp)
	ld a5, 15*8(sp)
	ld a6, 16*8(sp)
	ld a7, 17*8(sp)
	ld s2, 18*8(sp)
	ld s3, 19*8(sp)
	ld s4, 20*8(sp)
	ld s5, 21*8(sp)
	ld s6, 22*8(sp)
	ld s7, 23*8(sp)
	ld s8, 24*8(sp)
	ld s9, 25*8(sp)
	ld s10, 26*8(sp)
	ld s11, 27*8(sp)
	ld t3,  28*8(sp)
	ld t4,  29*8(sp)
	ld t5,  30*8(sp)
	ld t6,  31*8(sp)

	ld sp, 2*8(sp)
	mret

.size trap_vector, . - trap_vector

.global __switch_to
__switch_to:
	/* Save context into prev->thread */
	sd ra,  0*8(a0)
	sd sp,  1*8(a0)
	sd s0,  2*8(a0)
	sd s1,  3*8(a0)
	sd s2,  4*8(a0)
	sd s3,  5*8(a0)
	sd s4,  6*8(a0)
	sd s5,  7*8(a0)
	sd s6,  8*8(a0)
	sd s7,  9*8(a0)
	sd s8,  10*8(a0)
	sd s9,  11*8(a0)
	sd s10, 12*8(a0)
	sd s11, 13*8(a0)
__switch_to__half:
	/* Restore context from next->thread */
	ld ra,  0*8(a1)
	ld sp,  1*8(a1)
	ld s0,  2*8(a1)
	ld s1,  3*8(a1)
	ld s2,  4*8(a1)
	ld s3,  5*8(a1)
	ld s4,  6*8(a1)
	ld s5,  7*8(a1)
	ld s6,  8*8(a1)
	ld s7,  9*8(a1)
	ld s8,  10*8(a1)
	ld s9,  11*8(a1)
	ld s10, 12*8(a1)
	ld s11, 13*8(a1)
	mv tp, a1 /* Next current pointer */
	ret
.size __switch_to, . - __switch_to

.global __start_to
__start_to:
	/* Restore context from next->thread */
	ld ra,  0*8(a0)
	ld sp,  1*8(a0)
	ld s0,  2*8(a0)
	ld s1,  3*8(a0)
	ld s2,  4*8(a0)
	ld s3,  5*8(a0)
	ld s4,  6*8(a0)
	ld s5,  7*8(a0)
	ld s6,  8*8(a0)
	ld s7,  9*8(a0)
	ld s8,  10*8(a0)
	ld s9,  11*8(a0)
	ld s10, 12*8(a0)
	ld s11, 13*8(a0)
	mv tp, a1 /* Next current pointer */
	ret
.size __start_to, . - __start_to
