DOSEK_BINARY(
  NAME bcc1_alarm3a
  SYSTEM_DESC system.oil
  VERIFY verify_a.py
  LIBS libtest
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm3b
  SYSTEM_DESC system.oil
  VERIFY verify_b.py
  LIBS libtest
  SOURCES
  b.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm3c
  SYSTEM_DESC system.oil
  VERIFY verify_c.py
  LIBS libtest
  SOURCES
  c.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm3d
  SYSTEM_DESC system.oil
  VERIFY verify_d.py
  LIBS libtest
  SOURCES
  d.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm3e
  SYSTEM_DESC system.oil
  VERIFY verify_e.py
  LIBS libtest
  SOURCES
  e.cc
)


set_tests_properties(bcc1_alarm3a PROPERTIES  TIMEOUT 30)
set_tests_properties(bcc1_alarm3b PROPERTIES  TIMEOUT 30)
set_tests_properties(bcc1_alarm3c PROPERTIES  TIMEOUT 30)
set_tests_properties(bcc1_alarm3d PROPERTIES  TIMEOUT 30)
set_tests_properties(bcc1_alarm3e PROPERTIES  TIMEOUT 30)
