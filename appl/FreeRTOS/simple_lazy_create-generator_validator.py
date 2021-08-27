#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    assert re.search('InitializedStack_t<10+> tzzz_[0-9]_static_stack', generated_os), 'missing initialized stack for zzz'
    assert re.search('.pxNext = \(ListItem_t \*\) &__queue_head_mutex\d+.xTasksWaitingToSend.xListEnd,', generated_os)
    assert '.pxContainer = &pxReadyTasksLists[2]' not in generated_os, "task xxx darf erst zur Laufzeit auf die ready-liste gesetzt werden"

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert not re.search('InitializedStack_t<10+> tzzz_\d+_static_stack', generated_os)
    assert re.search('extern "C" StaticTask_t tzzz_\d+_tcb;', generated_os)
    assert not re.search('.pxNext = \(ListItem_t \*\) &__queue_head_mutex0.xTasksWaitingToSend.xListEnd,', generated_os)
