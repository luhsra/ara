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

foreach file : src_files
  smartplug_targets += custom_target('smartplug-' + file.underscorify(),
                                    input: file + '.c',
                                    output: 'smartplug-' + file.underscorify() + '.ll',
                                    depfile: file.underscorify() + '_deps',
                                    command : [clang,
                                               '@INPUT@',
                                               '-o', '@OUTPUT@', '-MD', '-MF', '@DEPFILE@', c_std] +
											  freertos_includes +
                                              clang_flags)
endforeach

smartplug_runtarget = run_target('smartplug-full',
                                 command: nop,
                                 depends: smartplug_targets)
