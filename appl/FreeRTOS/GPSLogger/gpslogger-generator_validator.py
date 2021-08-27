#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    assert 'uxNumberOfItems' in generated_os
    assert re.search('InitializedStack_t<512> tSD_Thread_\d+_static_stack\(\(void \*\)_Z9vSDThreadPv,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<170> tLED_Thread_\d+_static_stack\(\(void \*\)_Z10vLEDThreadPv,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<768> tDisplay_Task_\d+_static_stack\(\(void \*\)_Z12vDisplayTaskPv,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<170> tButtons_Thread_\d+_static_stack\(\(void \*\)_Z14vButtonsThreadPv,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<256> tGPS_Task_\d+_static_stack\(\(void \*\)_Z8vGPSTaskPv,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<170> tidle_task_\d+_static_stack\(\(void \*\)prvIdleTask,\(void \*\)0\);', generated_os)
    assert re.search('.pxNext = \(ListItem_t \*\) &tButtons_Thread_\d+_tcb.xStateListItem,', generated_os)
    assert re.search('.pxPrevious = \(ListItem_t \*\) &tLED_Thread_\d+_tcb.xStateListItem,', generated_os)
    assert re.search('.pxIndex = \(ListItem_t \*\) &__queue_head__ZN12GPSDataModel13_the_instanceE\d+.xTasksWaitingToSend.xListEnd,', generated_os)
    assert re.search('.pxNext = \(ListItem_t \*\) &__queue_head_sdQueue\d+.xTasksWaitingToSend.xListEnd,', generated_os)
    assert re.search('.pxNext = \(ListItem_t \*\) &__queue_head_buttonsQueue\d+.xTasksWaitingToReceive.xListEnd,', generated_os)
    assert re.search('.pxNext = \(ListItem_t \*\) &__queue_head_\d+.xTasksWaitingToReceive.xListEnd,', generated_os)

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert '.pxNext ' not in generated_os
    assert 'uxNumberOfItems' not in generated_os
    assert 'InitializedStack_t' not in generated_os
    assert re.search('StackType_t tSD_Thread_\d+_static_stack\[512\] = { };', generated_os)
    assert re.search('StackType_t tLED_Thread_\d+_static_stack\[170\] = { };', generated_os)
    assert re.search('StackType_t tDisplay_Task_\d+_static_stack\[768\] = { };', generated_os)
    assert re.search('StackType_t tButtons_Thread_\d+_static_stack\[170\] = { };', generated_os)
    assert re.search('StackType_t tGPS_Task_\d+_static_stack\[256\] = { };', generated_os)
    assert re.search('StackType_t tidle_task_\d+_static_stack\[170\] = { };', generated_os)
