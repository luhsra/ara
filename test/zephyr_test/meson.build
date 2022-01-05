
graphs = meson.current_source_dir() / 'graphs'

test('zephyr_static_threads',
        py3_inst,
        args: [files('../instance_graph.py'), graphs / 'static_threads.json', zephyr_static_threads, 'ZEPHYR'],
        env: [python_path],
        suite: 'zephyr'
)