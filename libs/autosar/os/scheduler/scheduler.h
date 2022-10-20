/**
 * @file

 * @brief Scheduler implementation
 */
#ifndef __SCHEDULER_H__
#define __SCHEDULER_H__

#include "dispatch.h"
#include "reschedule-ast.h"
#include "syscall.h"

extern "C" void __OS_ASTSchedule(int dummy);

#endif // __SCHEDULER_H__
