DOSEK_BINARY(
  NAME bcc1_complex1a
  SYSTEM_DESC system.oil
  VERIFY verify_a.py
  LIBS libtest
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME bcc1_complex1b
  SYSTEM_DESC system.oil
  VERIFY verify_b.py
  LIBS libtest
  SOURCES
  b.cc
 )

DOSEK_BINARY(
  NAME bcc1_complex1c
  SYSTEM_DESC system.oil
  VERIFY verify_c.py
  LIBS libtest
  SOURCES
  c.cc
)

DOSEK_BINARY(
  NAME bcc1_complex1d
  SYSTEM_DESC system.oil
  LIBS libtest
  SOURCES
  d.cc
)
