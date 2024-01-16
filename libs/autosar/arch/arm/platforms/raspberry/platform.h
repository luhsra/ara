//#define PBASE 0x3F000000 //raspi2b
#define PBASE 0xFE000000 //raspi4b

#define ARM_TIMER_CTL   (PBASE+0x0000B408)
#define ARM_TIMER_CNT   (PBASE+0x0000B420)

#define GPFSEL1         (PBASE+0x00200004)
#define GPSET0          (PBASE+0x0020001C)
#define GPCLR0          (PBASE+0x00200028)
#define GPPUD           (PBASE+0x00200094)
#define GPPUDCLK0       (PBASE+0x00200098)

#define AUX_ENABLES     (PBASE+0x00215004)
#define AUX_MU_IO_REG   (PBASE+0x00215040)
#define AUX_MU_IER_REG  (PBASE+0x00215044)
#define AUX_MU_IIR_REG  (PBASE+0x00215048)
#define AUX_MU_LCR_REG  (PBASE+0x0021504C)
#define AUX_MU_MCR_REG  (PBASE+0x00215050)
#define AUX_MU_LSR_REG  (PBASE+0x00215054)
#define AUX_MU_MSR_REG  (PBASE+0x00215058)
#define AUX_MU_SCRATCH  (PBASE+0x0021505C)
#define AUX_MU_CNTL_REG (PBASE+0x00215060)
#define AUX_MU_STAT_REG (PBASE+0x00215064)
#define AUX_MU_BAUD_REG (PBASE+0x00215068)

/* Power Management, Reset controller and Watchdog registers */
#define PM_BASE                     (PBASE + 0x100000)
#define PM_RSTC                     (PM_BASE+0x1c)
#define PM_WDOG                     (PM_BASE+0x24)
#define PM_WDOG_RESET               0000000000
#define PM_PASSWORD                 0x5a000000
#define PM_WDOG_TIME_SET            0x000fffff
#define PM_RSTC_WRCFG_CLR           0xffffffcf
#define PM_RSTC_WRCFG_SET           0x00000030
#define PM_RSTC_WRCFG_FULL_RESET    0x00000020
#define PM_RSTC_RESET               0x00000102

#define GIC_DIST_BASE (0xff841000)
#define GIC_CPU_BASE  (0xff842000)

#define SERIAL_BASE 0xE0001000

#define PRIVATE_TIMER_BASE 0xF8F00600
#define CPU_FREQ_HZ 500000000


// According to GICdist().ICTR = 2
// max IRQs = 32*(ICTR+1)
#define cfIRQ_MAXHANDLERNUM 96

/**
 * @name IRQ priot, lower number is higher priority
 * @{
 */
#define IRQ_PRIO_LOWEST      0xff //!< the lowest available priority
#define IRQ_PRIO_RESCHEDULE    0xe0   //!< reschedule (AST) software interrupt
#define IRQ_PRIO_DISPATCH 0x10 //!< dispatch IRQ priority prio
#define IRQ_PRIO_LOCAL_TIMER 0x30 //!< local CPU timer interrupt
#define IRQ_PRIO_SYSCALL 0x20 //!< syscall software interrupt
#define IRQ_PRIO_MIN_ISR2 0x30 //!< syscall software interrupt