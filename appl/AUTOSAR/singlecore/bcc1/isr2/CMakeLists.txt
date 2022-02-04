DOSEK_BINARY(
  NAME bcc1_isr2a
  SYSTEM_DESC system.oil
  VERIFY verify_a.py
  LIBS libtest
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME bcc1_isr2b
  SYSTEM_DESC system.oil
  VERIFY verify_b.py
  LIBS libtest
  SOURCES
  b.cc
)

DOSEK_BINARY(
  NAME bcc1_isr2c
  SYSTEM_DESC system.oil
  VERIFY verify_c.py
  LIBS libtest
  SOURCES
  c.cc
)

DOSEK_BINARY(
  NAME bcc1_isr2d
  SYSTEM_DESC system.oil
  VERIFY verify_d.py
  LIBS libtest
  SOURCES
  d.cc
)

DOSEK_BINARY(
  NAME bcc1_isr2e
  SYSTEM_DESC system.oil
  VERIFY verify_e.py
  LIBS libtest
  SOURCES
  e.cc
)


