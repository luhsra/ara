#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    if not re.search('InitializedStack_t<10+> tzzz_[0-9]_static_stack', generated_os):
        assert False, 'missing initialized stack for zzz'
    assert '.pxNext = (ListItem_t *) &__queue_head_global_mutex1.xTasksWaitingToSend.xListEnd,' in generated_os
    assert '.pxNext = (ListItem_t *) &__queue_head__ZN16GuardedSingleton13_the_instanceE0.xTasksWaitingToSend.xListEnd,' in generated_os

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert 'InitializedStack_t<10+> tzzz_2_static_stack' not in generated_os
    assert 'extern "C" StaticTask_t tzzz_2_tcb;' in generated_os
    assert '.pxNext = (ListItem_t *) &__queue_head_global_mutex1.xTasksWaitingToSend.xListEnd,' not in generated_os
    assert '&__queue_head__ZN16GuardedSingleton13_the_instanceE0.xTasksWaitingToSend.xListEnd,' not in generated_os
