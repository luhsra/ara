#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    if not re.search('InitializedStack_t<[0-9]+> txxx37_\d+_static_stack', generated_os):
        assert False, 'missing initialized stack for xxx35'
    assert '.pxContainer = &pxReadyTasksLists[1]' not in generated_os, "task xxx darf erst zur Laufzeit auf die ready-liste gesetzt werden"
    assert '.pxContainer = &pxReadyTasksLists[2]' in generated_os, "task setup muss vor der Laufzeit auf die ready-liste gesetzt werden"
    assert '.uxNumberOfItems = 1' in generated_os, 'setup task von Anfang an auf der Readyliste'
    assert '.uxNumberOfItems = 30' not in generated_os, 'die anderen dürfen erst zur laufzeit'

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert not re.search('InitializedStack_t<10+> txxx\d+_\d+_static_stack', generated_os)
    assert re.search('extern "C" StaticTask_t txxx40_\d+_tcb;', generated_os)
    assert 'uxNumberOfItems' not in generated_os
