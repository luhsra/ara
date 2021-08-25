#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    assert 'uxNumberOfItems' in generated_os
    assert 'InitializedStack_t<512> tSD_Thread_3_static_stack((void *)_Z9vSDThreadPv,(void *)0);' in generated_os
    assert 'InitializedStack_t<170> tLED_Thread_4_static_stack((void *)_Z10vLEDThreadPv,(void *)0);' in generated_os
    assert 'InitializedStack_t<768> tDisplay_Task_5_static_stack((void *)_Z12vDisplayTaskPv,(void *)0);' in generated_os
    assert 'InitializedStack_t<170> tButtons_Thread_6_static_stack((void *)_Z14vButtonsThreadPv,(void *)0);' in generated_os
    assert 'InitializedStack_t<256> tGPS_Task_7_static_stack((void *)_Z8vGPSTaskPv,(void *)0);' in generated_os
    assert 'InitializedStack_t<170> tidle_task_8_static_stack((void *)prvIdleTask,(void *)0);' in generated_os
    assert '.pxNext = (ListItem_t *) &tButtons_Thread_6_tcb.xStateListItem,' in generated_os
    assert '.pxPrevious = (ListItem_t *) &tLED_Thread_4_tcb.xStateListItem,' in generated_os
    assert '.pxIndex = (ListItem_t *) &__queue_head__ZN12GPSDataModel13_the_instanceE1.xTasksWaitingToSend.xListEnd,' in generated_os
    assert '.pxNext = (ListItem_t *) &__queue_head_sdQueue9.xTasksWaitingToSend.xListEnd,' in generated_os
    assert '.pxNext = (ListItem_t *) &__queue_head_buttonsQueue2.xTasksWaitingToReceive.xListEnd,' in generated_os
    assert '.pxNext = (ListItem_t *) &__queue_head_0.xTasksWaitingToReceive.xListEnd,' in generated_os

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert '.pxNext ' not in generated_os
    assert 'uxNumberOfItems' not in generated_os
    assert 'InitializedStack_t' not in generated_os
    assert 'StackType_t tSD_Thread_3_static_stack[512] = { };' in generated_os
    assert 'StackType_t tLED_Thread_4_static_stack[170] = { };' in generated_os
    assert 'StackType_t tDisplay_Task_5_static_stack[768] = { };' in generated_os
    assert 'StackType_t tButtons_Thread_6_static_stack[170] = { };' in generated_os
    assert 'StackType_t tGPS_Task_7_static_stack[256] = { };' in generated_os
    assert 'StackType_t tidle_task_8_static_stack[170] = { };' in generated_os
