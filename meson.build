project('arsa', 'cpp',
  default_options : ['warning_level=3', 'cpp_std=c++17'])

cython = find_program('cython')
py3_mod = import('python')
py3_inst = py3_mod.find_installation('python3')

llvm_dep = dependency('llvm', version : '>=7.0')

cython_flags = ['-Wextra', '--cplus', '-3']

build_dir = meson.current_build_dir()
source_dir = meson.source_root()

subdir('libgraph')
subdir('steps')
subdir('appl')
subdir('test')

test('arsa_tester',
  py3_inst,
  #args: [files('arsa.py', 'test/data/GPSLogger.ll','test/data/ScreenManager.ll','test/data/GPSThread.ll','test/data/SDThread.ll','test/data/LEDThread.ll','test/data/ButtonsThread.ll','test/data/SdFatSPIDriver.ll','test/data/GPSDataModel.ll','test/data/SpeedScreen.ll'), '--os', 'freertos'],
  #args : [files('arsa.py'), '--os', 'freertos', freertos_targets[2]],
  #args : [files('arsa.py'), '--os', 'freertos', freertos_targets[16]],
  args : [files('arsa.py'), '--os', 'osek', '--log-level', 'debug', osek_targets[3]],
  env : ['PYTHONPATH=' + passdir + ':' + 'subprojects/libgraph']
)


#test('ara tester',
	#py3_inst,
	#args : [files('arsa.py', 'test/data/GPSLogger.ll','test/data/ScreenManager.ll','test/data/GPSThread.ll','test/data/SDThread.ll','test/data/LEDThread.ll','test/data/ButtonsThread.ll','test/data/SdFatSPIDriver.ll','test/data/GPSDataModel.ll','test/data/SpeedScreen.ll'), '--os', 'freertos','--application_file' , 'invalid_mutex.cc'],
	
	#args : [files('arsa.py','test/data/appl.ll'), '--os', 'freertos','--application_file' , 'timer.cc'],

    #args : [files('arsa.py','test/data/appl.ll'), '--os', 'freertos','--application_file' , 'loop_detection.cc'],
    #args : [files('arsa.py','test/data/appl.ll'), '--os', 'freertos','--application_file' , 'before_scheduler_validation.cc'],
    # priority inversion test case
    #args : [files('arsa.py'), '--os', 'freertos', freertos_targets[2]],

	#env : ['PYTHONPATH=' + passdir + ':' + 'subprojects/libgraph']
#)

