#pragma once

void InitBoard(void);
void StopBoard(void);
void StopBoard(int);

// TODO, this is taken from dosek/Zedboard. Make this not a stub
#define GIC_DIST_BASE (0xF8F01000)
#define GIC_CPU_BASE (0xF8F00100)
#define cfIRQ_MAXHANDLERNUM 96
#define IRQ_PRIO_SYSCALL 0x20 //!< syscall software interrupt
