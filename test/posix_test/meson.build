test('posix_class',
    py3_inst,
    args: files('posix_class.py'),
    env: [python_path],
    suite: 'posix'
)

remove_sysfunc_body_data = files(meson.current_source_dir() + '/testdata/remove_sysfunc_body_test.ll')

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