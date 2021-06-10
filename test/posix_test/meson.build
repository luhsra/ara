test('posix_class',
    py3_inst,
    args: files('posix_class.py'),
    env: [python_path],
    suite: 'posix'
)

remove_sysfunc_body_data = meson.current_source_dir() / 'testdata/remove_sysfunc_body_test.ll'

test('remove_sysfunc_body_auto_os',
    py3_inst,
    args: [files('remove_sysfunc_body_auto_os.py'), files('remove_sysfunc_body.json'), remove_sysfunc_body_data],
    env: [python_path],
    suite: 'posix'
)

test('remove_sysfunc_body_posix_os',
    py3_inst,
    args: [files('remove_sysfunc_body_posix_os.py'), files('remove_sysfunc_body.json'), remove_sysfunc_body_data],
    env: [python_path],
    suite: 'posix'
)

# Instance-Graph Test cases

appl_json = meson.current_source_dir() / 'appl_json'
posix_test_settings = meson.current_source_dir() / 'settings'

test('pthread_create',
        py3_inst,
        # The json object is not a files() object to allow paths to non existing json files.
        # See test/posix_test/posix_instance_graph.py for more information.
        args: [files('posix_instance_graph.py'), appl_json / 'pthread_create.json', posix_pthread_create],
        env: [python_path],
        suite: 'posix'
)

test('pthread_create_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), appl_json / 'pthread_create.json', posix_pthread_create_musl, posix_test_settings / 'no_recursive_func.json'],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('mutex_counter',
        py3_inst,
        args: [files('posix_instance_graph.py'), appl_json / 'mutex_counter.json', posix_mutex_counter],
        env: [python_path],
        suite: 'posix'
)