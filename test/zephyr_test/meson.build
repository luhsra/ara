
graphs = meson.current_source_dir() / 'graphs'

test('zephyr_blinky',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'zephyr_blinky.json', zephyr_blinky, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_button',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'zephyr_button.json', zephyr_button, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

# C++ is currently not supported
#test('zephyr_cpp_sems',
#        py3_inst,
#        args: [files('../instance_graph.py'), graphs / 'zephyr_cpp_sems.json', zephyr_cpp_sems, 'ZEPHYR'],
#        env: [python_path],
#        suite: 'zephyr'
#)

test('zephyr_duplicate_syscalls',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'duplicate_syscalls.json', zephyr_duplicate_syscalls, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_heap',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_heap.json', zephyr_dyn_heap, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_isr',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_isr.json', zephyr_dyn_isr, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_msgq',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_msgq.json', zephyr_dyn_msgq, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_pipe',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_pipe.json', zephyr_dyn_pipe, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_queue',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_queue.json', zephyr_dyn_queue, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_sems',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_sems.json', zephyr_dyn_sems, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_stack',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_stack.json', zephyr_dyn_stack, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_dyn_sys_sems',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'dyn_sys_sems.json', zephyr_dyn_sys_sems, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

# Is not running with LLVM-12
#test('zephyr_latency_measure',
#        py3_inst,
#        args: [files('../instance_graph.py'), graphs / 'latency_measure.json', zephyr_latency_measure, 'ZEPHYR'],
#        env: [python_path],
#        suite: 'zephyr'
#)

test('zephyr_minimal',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'minimal.json', zephyr_minimal, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_multi_init',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'multi_init.json', zephyr_multi_init, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

# Currently not supported:
#test('zephyr_prod_consumer',
#        py3_inst,
#        args: [files('../instance_graph.py'), graphs / 'prod_consumer.json', zephyr_prod_consumer, 'ZEPHYR'],
#        env: [python_path],
#        suite: 'zephyr'
#)
#test('zephyr_shared_mem',
#        py3_inst,
#        args: [files('../instance_graph.py'), graphs / 'shared_mem.json', zephyr_shared_mem, 'ZEPHYR'],
#        env: [python_path],
#        suite: 'zephyr'
#)

test('zephyr_static_heap',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_heap.json', zephyr_static_heap, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_isr',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_isr.json', zephyr_static_isr, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_msgq',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_msgq.json', zephyr_static_msgq, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_pipe',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_pipe.json', zephyr_static_pipe, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_queue',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_queue.json', zephyr_static_queue, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_sems',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_sems.json', zephyr_static_sems, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_stack',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_stack.json', zephyr_static_stack, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_sys_sems',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_stack.json', zephyr_static_sys_sems, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_threads',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_threads.json', zephyr_static_threads, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

# Complex applications
test('zephyr_app_kernel',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'app_kernel.json', zephyr_app_kernel, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)
test('zephyr_sys_kernel',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'sys_kernel.json', zephyr_sys_kernel, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)