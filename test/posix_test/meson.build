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

graphs = meson.current_source_dir() / 'graphs'
posix_test_settings = meson.current_source_dir() / 'settings'

test('pthread_create',
        py3_inst,
        # The json object is not a files() object to allow paths to non existing json files.
        # See test/posix_test/posix_instance_graph.py for more information.
        args: [files('posix_instance_graph.py'), graphs / 'pthread_create.json', posix_pthread_create],
        env: [python_path],
        suite: 'posix'
)

test('pthread_create_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pthread_create.json', posix_pthread_create_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('mutex_counter',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'mutex_counter.json', posix_mutex_counter],
        env: [python_path],
        suite: 'posix'
)

test('pipe',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pipe.json', posix_pipe],
        env: [python_path],
        suite: 'posix'
)

test('file_read',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_read.json', posix_file_read],
        env: [python_path],
        suite: 'posix'
)

test('file_write',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_write.json', posix_file_write],
        env: [python_path],
        suite: 'posix'
)

test('open_twice',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'open_twice.json', posix_open_twice],
        env: [python_path],
        suite: 'posix'
)

test('file_read_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_read.json', posix_file_read_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('file_write_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_write.json', posix_file_write_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('open_twice_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'open_twice.json', posix_open_twice_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('semaphore',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'semaphore.json', posix_semaphore],
        env: [python_path],
        suite: 'posix'
)

test('mutex_initializer',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'mutex_initializer.json', posix_mutex_initializer],
        env: [python_path],
        suite: 'posix'
)

test('signal_handler',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'signal_handler.json', posix_signal_handler],
        env: [python_path],
        suite: 'posix'
)

test('signal_handler_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'signal_handler.json', posix_signal_handler_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('signal_handler_siginfo',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'signal_handler_siginfo.json', posix_signal_handler_siginfo],
        env: [python_path],
        suite: 'posix'
)

test('signal_handler_siginfo_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'signal_handler_siginfo.json', posix_signal_handler_siginfo_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('ignore_signal',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'ignore_signal.json', posix_ignore_signal],
        env: [python_path],
        suite: 'posix'
)

test('ignore_signal_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'ignore_signal.json', posix_ignore_signal_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('multiple_sigactions',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'multiple_sigactions.json', posix_multiple_sigactions],
        env: [python_path],
        suite: 'posix'
)

test('multiple_sigactions_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'multiple_sigactions.json', posix_multiple_sigactions_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('file_readv',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_readv.json', posix_file_readv],
        env: [python_path],
        suite: 'posix'
)

test('file_writev',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_writev.json', posix_file_writev],
        env: [python_path],
        suite: 'posix'
)

test('filestream_open_musl_syscall',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'filestream_open_musl_syscall.json', 
               posix_filestream_open_musl, posix_test_settings / 'musl_syscall_detection.json'],
        env: [python_path],
        suite: 'posix',
        timeout: 400
)