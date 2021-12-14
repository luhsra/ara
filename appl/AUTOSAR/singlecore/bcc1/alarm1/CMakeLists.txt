DOSEK_BINARY(
  NAME bcc1_alarm1a
  SYSTEM_DESC system.oil
  VERIFY verify_a.py
  LIBS libtest
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm1b
  SYSTEM_DESC system.oil
  VERIFY verify_b.py
  LIBS libtest
  SOURCES
  b.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm1c
  SYSTEM_DESC system.oil
  VERIFY verify_c.py
  LIBS libtest
  SOURCES
  c.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm1d
  SYSTEM_DESC system.oil
  VERIFY verify_d.py
  LIBS libtest
  SOURCES
  d.cc
)

DOSEK_BINARY(
  NAME bcc1_alarm1e
  SYSTEM_DESC system.oil
  VERIFY verify_e.py
  LIBS libtest
  SOURCES
  e.cc
)


DOSEK_BINARY(
  NAME bcc1_alarm1f
  SYSTEM_DESC system.oil
  # VERIFY verify_f.py
  LIBS libtest
  SOURCES
  f.cc
)
