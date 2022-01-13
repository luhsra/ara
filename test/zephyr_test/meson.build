
graphs = meson.current_source_dir() / 'graphs'

test('zephyr_blinky',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'zephyr_blinky.json', zephyr_blinky, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)

test('zephyr_static_threads',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_threads.json', zephyr_static_threads, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)