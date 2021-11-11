# SSE is the symbolic system execution

DOSEK_BINARY(
  NAME bcc1_sse1a
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_a.py
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME bcc1_sse1b
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_b.py
  SOURCES
  b.cc
)


DOSEK_BINARY(
  NAME bcc1_sse1c
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_c.py
  SOURCES
  c.cc
)
