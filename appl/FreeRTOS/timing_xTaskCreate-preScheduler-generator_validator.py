#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    if not re.search('InitializedStack_t<[0-9]+> txxx35_[0-9]_static_stack', generated_os):
        assert False, 'missing initialized stack for xxx35'
    assert '.pxContainer = &pxReadyTasksLists[2]' not in generated_os, "task xxx darf erst zur Laufzeit auf die ready-liste gesetzt werden"
    assert '.uxNumberOfItems = 30' in generated_os

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert 'InitializedStack_t<10+> txxx35_1_static_stack' not in generated_os
    assert 'extern "C" StaticTask_t txxx35_1_tcb;' in generated_os
    assert 'uxNumberOfItems' not in generated_os
