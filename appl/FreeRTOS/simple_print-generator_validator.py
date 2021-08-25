#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    if not re.search('InitializedStack_t<10+> tzzz_0_static_stack', generated_os):
        assert False, 'missing initialized stack for zzz'

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert 'InitializedStack_t<1000> tzzz_0_static_stack' not in generated_os
    assert 'extern "C" StaticTask_t tzzz_0_tcb;' in generated_os

