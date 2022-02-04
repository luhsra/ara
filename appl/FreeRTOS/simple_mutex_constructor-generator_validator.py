#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    assert re.search('InitializedStack_t<10+> tzzz_\d+_static_stack', generated_os), 'missing initialized stack for zzz'
    assert re.search('.pxNext = \(ListItem_t \*\) &__queue_head_global_mutex\d+.xTasksWaitingToSend.xListEnd,', generated_os)
    assert re.search('.pxNext = \(ListItem_t \*\) &__queue_head__ZN16GuardedSingleton13_the_instanceE\d.xTasksWaitingToSend.xListEnd,', generated_os)

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert not re.search('InitializedStack_t<10+> tzzz_\d+_static_stack', generated_os)
    assert re.search('extern "C" StaticTask_t tzzz_\d_tcb;', generated_os)
    assert not re.search('.pxNext = \(ListItem_t \*\) &__queue_head_global_mutex\d+.xTasksWaitingToSend.xListEnd,', generated_os)
    assert not re.search('&__queue_head__ZN16GuardedSingleton13_the_instanceE\d.xTasksWaitingToSend.xListEnd,', generated_os)
