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
# Make sure to provide a test with musl and without musl when this is possible.

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
test('mutex_counter_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'mutex_counter.json', posix_mutex_counter_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('pipe',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pipe.json', posix_pipe],
        env: [python_path],
        suite: 'posix'
)
test('pipe_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pipe.json', posix_pipe_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('file_read',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_read.json', posix_file_read],
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

test('file_write',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_write.json', posix_file_write],
        env: [python_path],
        suite: 'posix'
)
test('file_write_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_write.json', posix_file_write_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('open_twice',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'open_twice.json', posix_open_twice],
        env: [python_path],
        suite: 'posix'
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
test('semaphore_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'semaphore.json', posix_semaphore_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('mutex_initializer',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'mutex_initializer.json', posix_mutex_initializer],
        env: [python_path],
        suite: 'posix'
)
test('mutex_initializer_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'mutex_initializer.json', posix_mutex_initializer_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('signal_handler',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'signal_handler.json', posix_signal_handler],
        env: [python_path],
        suite: 'posix',
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
test('file_readv_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_readv.json', posix_file_readv_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('file_writev',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_writev.json', posix_file_writev],
        env: [python_path],
        suite: 'posix'
)
test('file_writev_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'file_writev.json', posix_file_writev_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

# Linux syscall detection is only possible with musl libc.
test('filestream_open_musl_syscall',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'filestream_open_musl_syscall.json', posix_filestream_open_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 400
)

test('nanosleep',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'nanosleep.json', posix_nanosleep],
        env: [python_path],
        suite: 'posix'
)
test('nanosleep_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'nanosleep.json', posix_nanosleep_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

# sleep detection is only possible with musl libc,
# because we do sleep() -> nanosleep()
test('sleep',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'sleep.json', posix_sleep_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('set_thread_attr',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'set_thread_attr.json', posix_set_thread_attr],
        env: [python_path],
        suite: 'posix'
)
test('set_thread_attr_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'set_thread_attr.json', posix_set_thread_attr_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('set_thread_attr_inheritance',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'set_thread_attr_inheritance.json', posix_set_thread_attr_inheritance],
        env: [python_path],
        suite: 'posix'
)
test('set_thread_attr_inherit_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'set_thread_attr_inheritance.json', posix_set_thread_attr_inheritance_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('pthread_detach',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pthread_detach.json', posix_pthread_detach],
        env: [python_path],
        suite: 'posix'
)
test('pthread_detach_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pthread_detach.json', posix_pthread_detach_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('pthread_cancel',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pthread_cancel.json', posix_pthread_cancel],
        env: [python_path],
        suite: 'posix'
)
test('pthread_cancel_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pthread_cancel.json', posix_pthread_cancel_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('condition_variable',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'condition_variable.json', posix_condition_variable],
        env: [python_path],
        suite: 'posix'
)
test('condition_variable_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'condition_variable.json', posix_condition_variable_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('condition_var_initializer',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'condition_var_initializer.json', posix_condition_var_initializer],
        env: [python_path],
        suite: 'posix'
)
test('condition_var_initializer_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'condition_var_initializer.json', posix_condition_var_initializer_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('condition_var_broadcast',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'condition_var_broadcast.json', posix_condition_var_broadcast],
        env: [python_path],
        suite: 'posix'
)
test('condition_var_broadcast_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'condition_var_broadcast.json', posix_condition_var_broadcast_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

# In this test we issue the Linux syscalls directly without the musl libc.
test('linux_syscalls',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_syscalls.json', posix_linux_syscalls],
        env: [python_path],
        suite: 'posix'
)