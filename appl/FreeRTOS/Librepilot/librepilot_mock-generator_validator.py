#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    assert 'uxNumberOfItems' in generated_os
    assert re.search('InitializedStack_t<175> tSystem_\d+_static_stack\(\(void \*\)systemTask,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<48> tidle_task_\d+_static_stack\(\(void \*\)prvIdleTask,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<175> tActuator_\d+_static_stack\(\(void \*\)actuatorTask,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<135> tAttitude_\d+_static_stack\(\(void \*\)AttitudeTask,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<160> tReceiver_\d+_static_stack\(\(void \*\)receiverTask,\(void \*\)0\);', generated_os)
    assert re.search('InitializedStack_t<140> tRadioTx_\d+_static_stack\(\(void \*\)telemetryTxTask,\(void \*\)&radioChannel\);', generated_os)
    assert re.search('InitializedStack_t<102> tRadioRx_\d+_static_stack\(\(void \*\)telemetryRxTask,\(void \*\)&radioChannel\);', generated_os)


def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert '.pxNext ' not in generated_os
    assert 'uxNumberOfItems' not in generated_os
    assert re.search('StackType_t tSystem_\d+_static_stack\[175\] = { };', generated_os)
    assert re.search('StackType_t tidle_task_\d+_static_stack\[48\] = { };', generated_os)
    assert re.search('StackType_t tActuator_\d+_static_stack\[175\] = { };', generated_os)
    assert re.search('StackType_t tAttitude_\d+_static_stack\[135\] = { };', generated_os)
    assert re.search('StackType_t tReceiver_\d+_static_stack\[160\] = { };', generated_os)
    assert re.search('StackType_t tRadioTx_\d+_static_stack\[140\] = { };', generated_os)
    assert re.search('StackType_t tRadioRx_\d+_static_stack\[102\] = { };', generated_os)
