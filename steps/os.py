# definitions for different operating systems

from enum import Enum


class OS(Enum):
    OSEK = 0
    FreeRTOS = 1


class SyscallType(Enum):
    DEFAULT = 0
    CREATE = 1
    START = 2


OS_API = [
    # OSEK
    {
        "name": "OSEKOS_ActivateTask",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_StartOS",
        "os": OS.OSEK,
        "type": SyscallType.START,
    },
    {
        "name": "OSEKOS_ShutdownOS",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_TerminateTask",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_ChainTask",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_CancelAlarm",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_GetResource",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_ReleaseResource",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_DisableAllInterrupts",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_EnableAllInterrupts",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_SuspendAllInterrupts",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_ResumeAllInterrupts",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_SuspendOSInterrupts",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_ResumeOSInterrupts",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_GetAlarm",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_AdvanceCounter",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_SetEvent",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_ClearEvent",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_WaitEvent",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_GetEvent",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_SetRelAlarm",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "OSEKOS_CheckAlarm",
        "os": OS.OSEK,
        "type": SyscallType.DEFAULT,
    },
    # FreeRTOS
    {
        "name": "vTaskNotifyGiveFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskCreate",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xTaskCreateStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xTaskCreateRestricted",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xQueueGenericCreate",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xQueueCreateStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xQueueCreateSet",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "vSemaphoreCreateBinary",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xSemaphoreCreateBinary",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xSemaphoreCreateBinaryStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xQueueCreateMutex",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xSemaphoreCreateMutexStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xSemaphoreCreateRecursiveMutex",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xSemaphoreCreateRecursiveMutexStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xQueueCreateCountingSemaphore",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xSemaphoreCreateCountingStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xTimerCreate",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xTimerCreateStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xEventGroupCreate",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xEventGroupCreateStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xStreamBufferGenericCreate",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xStreamBufferCreateStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "xMessageBufferCreateStatic",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "vTaskAllocateMPURegions",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskAbortDelay",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskCallApplicationTaskHook",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskCheckForTimeOut",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskDelay",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskDelayUntil",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskDelete",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "portDISABLE_INTERRUPTS",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "portENABLE_INTERRUPTS",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskEnterCritical",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "portSET_INTERRUPT_MASK_FROM_ISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskExitCritical",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskGetApplicationTaskTag",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskGetCurrentTaskHandle",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskGetIdleTaskHandle",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskGetHandle",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "uxTaskGetNumberOfTasks",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskGetRunTimeStats",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "uxTaskGetStackHighWaterMark",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "eTaskGetState",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "uxTaskGetSystemState",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "pvTaskGetThreadLocalStoragePointer",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "pcTaskGetName",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskGetTickCount",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskGetTickCountFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskList",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskNotifyStateClear",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "ulTaskNotifyTake",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "uxTaskPriorityGet",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskPrioritySet",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskResume",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskResumeAll",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTaskResumeFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskSetApplicationTaskTag",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskSetThreadLocalStoragePointer",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskSetTimeOutState",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskStartScheduler",
        "os": OS.FreeRTOS,
        "type": SyscallType.START,
    },
    {
        "name": "vTaskStepTick",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskSuspend",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTaskSuspendAll",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "portYIELD",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueGenericSend",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueGenericSendFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueReceive",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueReceiveFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueuePeek",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueuePeekFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueIsQueueEmptyFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueIsQueueFullFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "uxQueueMessagesWaiting",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "uxQueueSpacesAvailable",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vQueueDelete",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "pcQueueGetName",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueReset",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueGiveFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueSemaphoreTake",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueGetMutexHolder",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueGetMutexHolderFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueGiveMutexRecursive",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueTakeMutexRecursive",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTimerGenericCommand",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTimerGetExpiryTime",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "pcTimerGetName",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTimerGetPeriod",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTimerGetTimerDaemonTaskHandle",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "pvTimerGetTimerID",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTimerIsTimerActive",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTimerPendFunctionCall",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xTimerPendFunctionCallFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vTimerSetTimerID",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vQueueAddToRegistry",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "uxQueueMessagesWaitingFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueAddToSet",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueRemoveFromSet",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueSelectFromSet",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xQueueSelectFromSetFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xEventGroupClearBits",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xEventGroupClearBitsFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vEventGroupDelete",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xEventGroupGetBitsFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xEventGroupSetBits",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xEventGroupSetBitsFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xEventGroupSync",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xEventGroupWaitBits",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferBytesAvailable",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "vStreamBufferDelete",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferIsEmpty",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferIsFull",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferReceive",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferReceiveFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferReset",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferResetFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferSend",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferSendFromISR",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferSetTriggerLevel",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xStreamBufferSpacesAvailable",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    },
    {
        "name": "xCoRoutineCreate",
        "os": OS.FreeRTOS,
        "type": SyscallType.CREATE,
    },
    {
        "name": "vCoRoutineSchedule",
        "os": OS.FreeRTOS,
        "type": SyscallType.DEFAULT,
    }
]
