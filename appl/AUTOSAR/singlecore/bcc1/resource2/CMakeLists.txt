DOSEK_BINARY(
  NAME bcc1_resource2a
  SYSTEM_DESC system.oil
  VERIFY verify_a.py
  LIBS libtest
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME bcc1_resource2b
  SYSTEM_DESC system.oil
  VERIFY verify_b.py
  LIBS libtest
  SOURCES
  b.cc
)
