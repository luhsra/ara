#ifndef _DOSEK_OS_OS_H_
#define _DOSEK_OS_OS_H_

#include "util/inline.h"
#include "helper.h"
#include "hooks.h"




/******************************************************************************
 *                                                                            *
 * Macro Definitions                                                          *
 *                                                                            *
 ******************************************************************************/
#define dosek_unused __attribute__((unused))

#ifdef CONFIG_ARCH_PATMOS

//#include "arch/patmos/irq.h"

#define ISR2(taskname)                                          \
    __attribute__((always_inline)) __attribute__((used))        \
    EXTERN_C_DECL void AUTOSAR_ISR_##taskname(const arch::IRQ::Context &)

#else

#define ISR2(taskname) \
	__attribute__((always_inline)) __attribute__((used)) \
    EXTERN_C_DECL void AUTOSAR_ISR_##taskname(void)

#endif

#define DeclareTask(x)				\
	extern const TaskType AUTOSAR_TASK_ ## x;		\
    static dosek_unused const TaskType &x = AUTOSAR_TASK_ ## x;	\

/**
 * @satisfies{13,2,5}
 */
#define TASK(taskname) \
	noinline EXTERN_C_DECL void AUTOSAR_TASK_FUNC_##taskname(void)

#define ActivateTask(x)				\
  AUTOSAR_ActivateTask(AUTOSAR_TASK_##x)

#define ChainTask(x)				\
	AUTOSAR_ChainTask(AUTOSAR_TASK_##x)

#define TerminateTask()				\
  AUTOSAR_TerminateTask()

#define Schedule()				\
  AUTOSAR_Schedule()

#define DeclareResource(x)				\
	extern const ResourceType AUTOSAR_RESOURCE_ ## x;		\
    static dosek_unused const ResourceType &x = AUTOSAR_RESOURCE_ ## x;

#define GetResource(x)					\
  AUTOSAR_GetResource(AUTOSAR_RESOURCE_##x)

#define GetTaskID(x)					\
  AUTOSAR_GetTaskID(x)

#define ReleaseResource(x)				\
  AUTOSAR_ReleaseResource(AUTOSAR_RESOURCE_##x)

#define GetSpinlock(x) AUTOSAR_GetSpinlock(AUTOSAR_SPINLOCK_##x)

#define TryToGetSpinlock(x, s) AUTOSAR_TryToGetSpinlock(AUTOSAR_SPINLOCK_##x, s)

#define ReleaseSpinlock(x) AUTOSAR_ReleaseSpinlock(AUTOSAR_SPINLOCK_##x)

#define DeclareSpinlock(x)                                                                                             \
	extern const SpinlockType AUTOSAR_SPINLOCK_##x;                                                                    \
	static dosek_unused const SpinlockType& x = AUTOSAR_SPINLOCK_##x;

#define DeclareEvent(x, c) extern const EventMaskType x = (c);

#define SetEvent(task,event)						\
  AUTOSAR_SetEvent(AUTOSAR_TASK_##task,event)

#define GetEvent(task,event)						\
  AUTOSAR_GetEvent(AUTOSAR_TASK_##task,event)

#define ClearEvent(event)				\
  AUTOSAR_ClearEvent(event)

#define WaitEvent(event)				\
  AUTOSAR_WaitEvent(event)

#define DeclareAlarm(x)				\
	extern const AlarmType AUTOSAR_ALARM_ ## x;		\
    static dosek_unused const AlarmType &x = AUTOSAR_ALARM_ ## x;

#define ALARMCALLBACK(x)				\
  EXTERN_C_DECL void AUTOSAR_ALARMCB_##x()

#define GetAlarm(x,tick)				\
  AUTOSAR_GetAlarm(AUTOSAR_ALARM_##x,tick)

#define SetRelAlarm(x,inc,period)				\
  AUTOSAR_SetRelAlarm(AUTOSAR_ALARM_##x,inc,period)

#define SetAbsAlarm(x,inc,period)				\
  AUTOSAR_SetRelAlarm(AUTOSAR_ALARM_##x,inc,period)

#define CancelAlarm(x)						\
  AUTOSAR_CancelAlarm(AUTOSAR_ALARM_##x)

#define GetAlarmBase(x,b)				\
  AUTOSAR_GetAlarmBase(AUTOSAR_ALARM_##x,b)

#define DeclareCounter(x)			\
	extern const CounterType AUTOSAR_COUNTER_ ## x;		\
    static dosek_unused const CounterType &x = AUTOSAR_COUNTER_ ## x;

#define AdvanceCounter(x)			\
  AUTOSAR_AdvanceCounter(AUTOSAR_COUNTER_##x)

#define IncrementCounter(x)			\
  AUTOSAR_AdvanceCounter(AUTOSAR_COUNTER_##x)

#define GetCounter(x)								\
	AUTOSAR_GetCounter(AUTOSAR_COUNTER_##x)

#define DeclareDevice(x)                                                \
    extern const DeviceType AUTOSAR_DEVICE_ ## x;			\
    static dosek_unused const DeviceType &x = AUTOSAR_DEVICE_ ## x

#define ActivateDevice(x)                          \
    AUTOSAR_ActivateDevice(AUTOSAR_DEVICE_##x)

#define DeactivateDevice(x)                      \
    AUTOSAR_DeactivateDevice(AUTOSAR_DEVICE_##x)
    
#define StartOS(x)				\
	AUTOSAR_StartOS(x)		\



// #define DeclareMessage(x)						\
// struct MESSAGEStruct AUTOSAR_MESSAGE_##x

// #define SendMessage(MSG,DATA)				\
//   AUTOSAR_SendMessage(AUTOSAR_MESSAGE_##MSG,DATA)
//
// #define ReceiveMessage(MSG,DATA)				\
//   AUTOSAR_ReceiveMessage(AUTOSAR_MESSAGE_##MSG,DATA)
//
// #define SendDynamicMessage(MSG,DATA,LENGTH)				\
//   AUTOSAR_SendDynamicMessage(AUTOSAR_MESSAGE_##MSG,DATA,LENGTH)
//
// #define ReceiveDynamicMessage(MSG,DATA,LENGTH)				\
//   AUTOSAR_ReceiveDynamicMessage(AUTOSAR_MESSAGE_##MSG,DATA,LENGTH)
//
// #define SendZeroMessage(MSG)				\
//   AUTOSAR_SendZeroMessage(AUTOSAR_MESSAGE_##MSG)

#define ShutdownOS(STATUS)			\
  AUTOSAR_ShutdownOS(STATUS)

#define DisableAllInterrupts()                  \
  AUTOSAR_DisableAllInterrupts()
#define EnableAllInterrupts()                  \
  AUTOSAR_EnableAllInterrupts()
#define SuspendAllInterrupts()                  \
  AUTOSAR_SuspendAllInterrupts()
#define ResumeAllInterrupts()                   \
  AUTOSAR_ResumeAllInterrupts()
#define SuspendOSInterrupts()                  \
  AUTOSAR_SuspendOSInterrupts()
#define ResumeOSInterrupts()                   \
  AUTOSAR_ResumeOSInterrupts()



/******************************************************************************
 *                                                                            *
 * API Definitions                                                            *
 *                                                                            *
 ******************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif
    
    


 void os_main(void);
//EXTERN_C_DECL void StartOS(int);
 void StartOS(char *);


/**
 * \brief Artificial function at beginning of a subtask handler
 **/

void AUTOSAR_kickoff();


/**
 * \brief Activate a TASK
 * \param t The TASK to be activated
 **/
extern StatusType AUTOSAR_ActivateTask(TaskType t);

/**
 * \brief Terminate the calling TASK and immediately activate another TASK
 * \param t The TASK to be activated
 **/
#if CONFIG_ARCH_OSEK_V
extern StatusType AUTOSAR_ChainTask(TaskType t);
extern StatusType AUTOSAR_TerminateTask();
#else
extern __attribute__((noreturn)) StatusType AUTOSAR_ChainTask(TaskType t);
extern __attribute__((noreturn)) StatusType AUTOSAR_TerminateTask();
#endif

extern StatusType AUTOSAR_Schedule();

/**
 * Get current Task's ID
 */
extern StatusType AUTOSAR_GetTaskID(TaskRefType a);

/**
 * \brief Acquire a RESOURCE
 * \param r The RESOURCE to be locked
 **/
extern StatusType AUTOSAR_GetResource(ResourceType r);

/**
 * \brief Release the given RESOURCE again
 * \param r The RESOURCE to be released
 **/
extern StatusType AUTOSAR_ReleaseResource(ResourceType r);

/**
 * \brief Acquire a SPINLOCK
 * \param r The SPINLOCK to be locked
 **/
extern StatusType AUTOSAR_GetSpinlock(SpinlockType r);

/**
 * \brief Try to acquire a SPINLOCK
 * \param r The SPINLOCK to be locked
 **/
extern StatusType AUTOSAR_TryToGetSpinlock(SpinlockType r, int* success);

/**
 * \brief Release the given SPINLOCK again
 * \param r The SPINLOCK to be released
 **/
extern StatusType AUTOSAR_ReleaseSpinlock(SpinlockType r);

/**
 * \brief Set an EVENT
 * \param t The TASK owning the EVENT
 * \param e The EVENT the will be set
 **/
extern StatusType AUTOSAR_SetEvent(TaskType t,EventMaskType e);

/**
 * \brief Get the event mask of the given TASK
 * \param t The TASK owning the EVENT
 * \param e The EVENT the will be set
 **/
extern StatusType AUTOSAR_GetEvent(TaskType t, EventMaskRefType e);

/**
 * \brief Clear the given EVENT from the TASKs event mask
 * \param e The EVENT to be cleared
 **/
extern StatusType AUTOSAR_ClearEvent(EventMaskType e);

/**
 * \brief Wait for the given event
 **/
extern StatusType AUTOSAR_WaitEvent(EventMaskType e);

/**
 * \brief Get the ticks until the next expiration
 **/
extern StatusType AUTOSAR_GetAlarm(AlarmType a,TickType* ticks);

/**
 * \brief Trigger the given Alarm to expire in certain amount of time
 * \param a The ALARM to be triggered
 * \param inc The relative offset for the first expiration of the given ALARM
 * \param cycle The ALARM will periodically expire every cycle time units
 **/
extern StatusType AUTOSAR_SetRelAlarm(AlarmType a,TickType inc, TickType cycle);

/**
 * \brief Reset the given ALARM
 **/
extern StatusType AUTOSAR_CancelAlarm(AlarmType a);

/**
 * \brief Get the AlarmBase
 **/
extern StatusType AUTOSAR_GetAlarmBase(AlarmType a,AlarmBaseRefType ab);

/**
 * \brief Advance the given UserCounter c by one tick
 **/
extern StatusType AUTOSAR_AdvanceCounter(CounterType c);

/**
 * \brief Send the given Message
 * \param m The MESSAGE to be sent.
 * \param data The content of the message
 **/
extern StatusType AUTOSAR_SendMessage(MessageIdentifier m,void *data);

/**
 * \brief Receive the given Message
 * \param m The MESSAGE to be received.
 * \param data The content of the message is stored here.
 **/
extern StatusType AUTOSAR_ReceiveMessage(MessageIdentifier m,void *data);

/**
 * \brief Send the given Message of statical unknown lenght
 * \param m The MESSAGE to be sent.
 * \param data The content of the message
 * \param length The lenght of the content in bytes
 **/
extern StatusType AUTOSAR_SendDynamicMessage(MessageIdentifier m,void *data,unsigned int length);

/**
 * \brief Receive the given Message
 * \param m The MESSAGE to be received.
 * \param data The content of the message is stored here
 * \param length The lenght of the content in bytes
 **/
extern StatusType AUTOSAR_ReceiveDynamicMessage(MessageIdentifier m,void *data,unsigned int length);

/**
 * \brief Send a message without content
 **/
extern StatusType AUTOSAR_SendZeroMessage(MessageIdentifier m);

/**
 * \brief Methods for interrupt disabling/enabling. This pair cannot
 *        be stacked.
 **/
extern void AUTOSAR_DisableAllInterrupts();
extern void AUTOSAR_EnableAllInterrupts();

/**
 * \brief Same as disable/enable but can be stacked.
 **/
extern void AUTOSAR_SuspendAllInterrupts();
extern void AUTOSAR_ResumeAllInterrupts();
extern void AUTOSAR_SuspendOSInterrupts();
extern void AUTOSAR_ResumeOSInterrupts();


extern StatusType AUTOSAR_ActivateDevice(DeviceType r);
extern StatusType AUTOSAR_DeactivateDevice(DeviceType r);



/******************************************************************************
 *                                                                            *
 * API Definitions (not supported, not creating any dependencies              *
 *                                                                            *
 ******************************************************************************/

extern __attribute__((noreturn)) void AUTOSAR_ShutdownOS(StatusType status);


#ifdef __cplusplus
}
#endif

#endif
