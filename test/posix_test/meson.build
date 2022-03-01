# This file describes all testcases of the POSIX test suite.

test('posix_class',
    py3_inst,
    args: files('posix_class.py'),
    env: [python_path],
    suite: 'posix'
)

remove_sysfunc_body_data = meson.current_source_dir() / 'testdata/remove_sysfunc_body_test.ll'

test('remove_sysfunc_body_auto',
    py3_inst,
    args: [files('remove_sysfunc_body.py'), files('remove_sysfunc_body.json'), remove_sysfunc_body_data, 'False'],
    env: [python_path],
    suite: 'posix'
)
test('remove_sysfunc_body_posix',
    py3_inst,
    args: [files('remove_sysfunc_body.py'), files('remove_sysfunc_body.json'), remove_sysfunc_body_data, 'False', 'POSIX'],
    env: [python_path],
    suite: 'posix'
)
test('remove_sysfunc_body_auto_drop',
    py3_inst,
    args: [files('remove_sysfunc_body.py'), files('remove_sysfunc_body_drop_llvm.json'), remove_sysfunc_body_data, 'True'],
    env: [python_path],
    suite: 'posix'
)
test('remove_sysfunc_body_posix_drop',
    py3_inst,
    args: [files('remove_sysfunc_body.py'), files('remove_sysfunc_body_drop_llvm.json'), remove_sysfunc_body_data, 'True', 'POSIX'],
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

test('pthread_setname_np',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pthread_setname_np.json', posix_pthread_setname_np],
        env: [python_path],
        suite: 'posix'
)
test('pthread_setname_np_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'pthread_setname_np.json', posix_pthread_setname_np_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('mutex',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'mutex.json', posix_mutex],
        env: [python_path],
        suite: 'posix'
)
test('mutex_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'mutex.json', posix_mutex_musl],
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

test('wrong_pipe_access',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'wrong_pipe_access.json', posix_wrong_pipe_access],
        env: [python_path],
        suite: 'posix'
)
test('wrong_pipe_access_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'wrong_pipe_access.json', posix_wrong_pipe_access_musl],
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

test('open_two_files',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'open_two_files.json', posix_open_two_files],
        env: [python_path],
        suite: 'posix'
)
test('open_two_files_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'open_two_files.json', posix_open_two_files_musl],
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

test('wrong_call_in_sighandler',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'wrong_call_in_sighandler.json', posix_wrong_call_in_sighandler],
        env: [python_path],
        suite: 'posix'
)
test('wrong_call_sighandler_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'wrong_call_in_sighandler.json', posix_wrong_call_in_sighandler_musl],
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

test('sigaction_macro_test',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'sigaction_macro_test.json', posix_sigaction_macro_test],
        env: [python_path],
        suite: 'posix'
)
test('sigaction_macro_test_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'sigaction_macro_test.json', posix_sigaction_macro_test_musl],
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

test('wrong_file_access',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'wrong_file_access.json', posix_wrong_file_access],
        env: [python_path],
        suite: 'posix'
)
test('wrong_file_access_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'wrong_file_access.json', posix_wrong_file_access_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

# Linux syscall detection is only possible with musl libc.
test('filestream_open_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'filestream_open_musl.json', posix_filestream_open_musl],
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

test('thread_attr_inheritence',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_inheritance.json', posix_thread_attr_inheritance],
        env: [python_path],
        suite: 'posix'
)
test('thread_attr_inherit_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_inheritance.json', posix_thread_attr_inheritance_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('thread_attr_not_unique',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_not_unique.json', posix_thread_attr_not_unique],
        env: [python_path],
        suite: 'posix'
)
test('thread_attr_not_unique_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_not_unique.json', posix_thread_attr_not_unique_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('thread_attr_double_call',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_double_call.json', posix_thread_attr_double_call],
        env: [python_path],
        suite: 'posix'
)
test('thread_attr_double_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_double_call.json', posix_thread_attr_double_call_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('thread_attr_cond_calls',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_cond_calls.json', posix_thread_attr_cond_calls],
        env: [python_path],
        suite: 'posix'
)
test('thread_attr_cond_calls_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_attr_cond_calls.json', posix_thread_attr_cond_calls_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('thread_setname_cond_calls',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_setname_cond_calls.json', posix_thread_setname_cond_calls],
        env: [python_path],
        suite: 'posix'
)
test('thread_setname_cond_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'thread_setname_cond_calls.json', posix_thread_setname_cond_calls_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('system_profile_inheritance',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'system_profile_inheritance.json', posix_system_profile_inheritance],
        env: [python_path],
        suite: 'posix'
)

# Thread attribute tests with Linux profile
test('linux_pthread_create',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_pthread_create.json', posix_pthread_create, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)
test('linux_pthread_create_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_pthread_create.json', posix_pthread_create_musl, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('linux_set_thread_attr',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_set_thread_attr.json', posix_set_thread_attr, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)

test('linux_thread_attr_inherit',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_thread_attr_inheritance.json', posix_thread_attr_inheritance, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)

test('linux_thread_attr_not_uniq',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_thread_attr_not_unique.json', posix_thread_attr_not_unique, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)

test('linux_thread_attr_double',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_thread_attr_double_call.json', posix_thread_attr_double_call, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)

test('linux_thread_attr_cond',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_thread_attr_cond_calls.json', posix_thread_attr_cond_calls, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)

test('linux_pthread_setname_np',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_pthread_setname_np.json', posix_pthread_setname_np, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)

test('linux_thread_setname_cond',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_thread_setname_cond_calls.json', posix_thread_setname_cond_calls, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)

test('linux_profile_inherit',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_profile_inherit.json', posix_system_profile_inheritance, files('settings/system_profile_linux.json')],
        env: [python_path],
        suite: 'posix'
)
test('linux_profile_inherit_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'linux_profile_inherit.json', posix_system_profile_inheritance_musl, files('settings/system_profile_linux.json')],
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
test('condition_var_init_musl',
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
test('condition_var_broad_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'condition_var_broadcast.json', posix_condition_var_broadcast_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)

test('create_everything',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'create_everything.json', posix_create_everything],
        env: [python_path],
        suite: 'posix'
)
test('create_everything_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'create_everything.json', posix_create_everything_musl],
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

# Complex application test
test('semaphore_ring_buffer',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'semaphore_ring_buffer.json', posix_semaphore_ring_buffer],
        env: [python_path],
        suite: 'posix'
)
test('semaphore_ring_buffer_musl',
        py3_inst,
        args: [files('posix_instance_graph.py'), graphs / 'semaphore_ring_buffer.json', posix_semaphore_ring_buffer_musl],
        env: [python_path],
        suite: 'posix',
        timeout: 300
)