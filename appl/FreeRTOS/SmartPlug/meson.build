smartplug_targets = []

src_files = [
    'client',
    'cloud',
    'http_server',
    'i2c',
    'main',
    'parsers',
    'plc',
    'power_meter',
    'sntp_sync',
    'spiffs_local',
    'system',
]
smartplug_includes = []

if get_option('arch') == 'arm'
  smartplug_includes += ['-I', '/usr/include/newlib/',
                        ]
endif

foreach file : src_files
  smartplug_targets += custom_target('smartplug-' + file.underscorify(),
                                    input: file + '.c',
                                    output: 'smartplug-' + file.underscorify() + '.ll',
                                    depfile: file.underscorify() + '_deps',
                                    command : clang_c +
                                              libs_includes +
                                              smartplug_includes +
                                              freertos_default_config +
                                              ir_flags +
                                              clang_flags)
endforeach

smartplug_application = custom_target('smartplug_app.ll',
                              input: smartplug_targets,
                              output: 'smartplug_app.ll',
                              command: llvm_link_cmd,
                              )
