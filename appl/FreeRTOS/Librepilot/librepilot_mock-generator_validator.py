#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    assert 'uxNumberOfItems' in generated_os
    assert 'InitializedStack_t<175> tSystem_0_static_stack((void *)systemTask,(void *)0);' in generated_os
    assert 'InitializedStack_t<48> tidle_task_1_static_stack((void *)prvIdleTask,(void *)0);' in generated_os
    assert 'InitializedStack_t<175> tActuator_18_static_stack((void *)actuatorTask,(void *)0);' in generated_os
    assert 'InitializedStack_t<135> tAttitude_19_static_stack((void *)AttitudeTask,(void *)0);' in generated_os
    assert 'InitializedStack_t<160> tReceiver_20_static_stack((void *)receiverTask,(void *)0);' in generated_os
    assert 'InitializedStack_t<140> tRadioTx_28_static_stack((void *)telemetryTxTask,(void *)&radioChannel);' in generated_os
    assert 'InitializedStack_t<102> tRadioRx_31_static_stack((void *)telemetryRxTask,(void *)&radioChannel);' in generated_os


def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert '.pxNext ' not in generated_os
    assert 'uxNumberOfItems' not in generated_os
    assert 'StackType_t tSystem_0_static_stack[175] = { };' in generated_os
    assert 'StackType_t tidle_task_1_static_stack[48] = { };' in generated_os
    assert 'StackType_t tActuator_18_static_stack[175] = { };' in generated_os
    assert 'StackType_t tAttitude_19_static_stack[135] = { };' in generated_os
    assert 'StackType_t tReceiver_20_static_stack[160] = { };' in generated_os
    assert 'StackType_t tRadioTx_28_static_stack[140] = { };' in generated_os
    assert 'StackType_t tRadioRx_31_static_stack[102] = { };' in generated_os
