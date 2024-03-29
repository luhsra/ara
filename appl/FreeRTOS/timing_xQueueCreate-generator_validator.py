#!/usr/bin/env python3

import re
def check_vanilla(app_name, modified_app, generated_os, elf):
    assert 'initialized' not in generated_os
def check_passthrough(*args):
    check_vanilla(*args)

def check_instances_full_initialized(app_name, modified_app, generated_os, elf):
    assert 'initialized' in generated_os
    assert re.search('.pxNext = \(ListItem_t \*\) &__queue_head_queue\d+.xTasksWaitingToReceive.xListEnd,', generated_os)
    assert 'uxNumberOfItems' in generated_os

def check_instances_full_static(app_name, modified_app, generated_os, elf):
    assert re.search('Queue_t __queue_head_queue\d+ =\s*{\s*};', generated_os)
    assert not re.search('.pxNext = \(ListItem_t \*\) &__queue_head_queue\d+.xTasksWaitingToReceive.xListEnd,', generated_os)
    assert 'uxNumberOfItems' not in generated_os
