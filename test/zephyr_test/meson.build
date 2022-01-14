
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

test('zephyr_static_threads',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_threads.json', zephyr_static_threads, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)